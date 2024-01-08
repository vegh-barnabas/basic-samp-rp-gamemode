Server:DoesPlayerExist(playerid)
{
	new query[128];
	mysql_format(sqlConnection, query, sizeof(query), "SELECT id FROM players WHERE Name = '%e' LIMIT 1", GetName(playerid));
	mysql_pquery(sqlConnection, query, "SQL_DoesPlayerExist", "i", playerid);

	return true;
}

Server:SQL_DoesPlayerExist(playerid)
{
	if(cache_num_rows(sqlConnection) != 0)
	{
		ShowLoginDialog(playerid, "");
	}
	else
	{
		ShowRegisterDialog(playerid, "");
	}
	
	TogglePlayerSpectating(playerid, true);
	
	return true;
}

Server:TIMER_SetCameraPos(playerid)
{
	SetPlayerPos(playerid, -109.4670, 1133.6563, 70.2519);
	SetPlayerCameraLookAt(playerid, -206.8355, 1120.8429, 14.7422);
	SetPlayerCameraPos(playerid, -206.8355, 1120.8429, 14.7422);
	
	return true;
}

Server:ShowLoginDialog(playerid, error[])
{
	if(LoggedIn[playerid]) return true;
	
	if(!strmatch(error, "")) {
		SendClientMessage(playerid, COLOR_WHITE, error);
	}
	
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Tutorial Server - Login", "Please enter your password below so you can login.", "Login", "Quit");

	return true;
}

Server:ShowRegisterDialog(playerid, error[])
{
	if(LoggedIn[playerid]) return true;

	if(!strmatch(error, "")) {
		SendClientMessage(playerid, COLOR_WHITE, error);
	}
	
	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Tutorial Server - Register", "Please enter a password below so you can register your account with us", "Register", "Quit");

	return true;
}

Server:SQL_OnAccountRegister(playerid)
{
	SendClientMessage(playerid, COLOR_WHITE, "You have successfully registered to the server!");
	
	DefaultPlayerValues(playerid);
	
	PlayerData[playerid][pSQLID] = cache_insert_id();
	
	return true;
}

Server:SQL_OnAccountLogin(playerid)
{
	if(cache_num_rows() == 0) {
		return ShowLoginDialog(playerid, "Incorrect password.");
	}
	
	SendClientMessage(playerid, COLOR_WHITE, "You have successfully logged into the server.");
	
	PlayerData[playerid][pSQLID] = cache_get_field_content_int(0, "id", sqlConnection);
	LoadPlayerData(playerid);
	
	return true;
}

Server:LoadPlayerData(playerid)
{
	new query[128];
	mysql_format(sqlConnection, query, sizeof(query), "SELECT * FROM players WHERE id = %i LIMIT 1", PlayerData[playerid][pSQLID]);
	mysql_pquery(sqlConnection, query, "SQL_OnLoadAccount", "i", playerid);
}

Server:SQL_OnLoadAccount(playerid)
{
	LoggedIn[playerid] = true;

	PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);
	PlayerData[playerid][pMoney] = cache_get_field_content_int(0, "Money", sqlConnection);
	PlayerData[playerid][pLevel] = cache_get_field_content_int(0, "Level", sqlConnection);
	PlayerData[playerid][pRespect] = cache_get_field_content_int(0, "Respect", sqlConnection);
	
	PlayerData[playerid][pLastPos][0] = cache_get_field_content_float(0, "LastX", sqlConnection);
	PlayerData[playerid][pLastPos][1] = cache_get_field_content_float(0, "LastY", sqlConnection);
	PlayerData[playerid][pLastPos][2] = cache_get_field_content_float(0, "LastZ", sqlConnection);
	PlayerData[playerid][pLastPos][3] = cache_get_field_content_float(0, "LastRot", sqlConnection);
	
	PlayerData[playerid][pLastInt] = cache_get_field_content_int(0, "Interior", sqlConnection);
	PlayerData[playerid][pLastWorld] = cache_get_field_content_int(0, "VW", sqlConnection);
	
	SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
	
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	
	TogglePlayerSpectating(playerid, false);

	LoadPlayerOwnedVehicles(playerid);
	
	SetPlayerSpawn(playerid);
	
	return true;
}

Server:DefaultPlayerValues(playerid)
{
	LoggedIn[playerid] = false;

	PlayerData[playerid][pSQLID] = 0;
	PlayerData[playerid][pAdminLevel] = 0;
	PlayerData[playerid][pMoney] = 0;
	PlayerData[playerid][pLevel] = 1;
	PlayerData[playerid][pRespect] = 0;
	
	ResetDamageData(playerid);
	
	return true;
}

Server:SaveSQLInt(sqlid, table[], row[], value)
{
	new query[128];
	mysql_format(sqlConnection, query, sizeof(query), "UPDATE %e SET %e = %i WHERE id = %i", table, row, value, sqlid);
	mysql_pquery(sqlConnection, query);
	
	return true;
}

Server:SendLocalMessage(playerid, color, msg[])
{
	if(!LoggedIn[playerid]) return true;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(Player, i) {
		if(LoggedIn[i]) {
			if(IsPlayerInRangeOfPoint(i, 15.0, x, y, z) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
				SendClientMessage(i, color, msg);
			}
		}
	}

	return true;
}

Server:SendLocalMessageEx(playerid, color, msg[], Float:distance)
{
	if(!LoggedIn[playerid]) return true;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	
	foreach(Player, i) {
		if(LoggedIn[i]) {
			if(IsPlayerInRangeOfPoint(i, distance, x, y, z) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
				SendClientMessage(i, color, msg);
			}
		}
	}

	return true;
}

Server:GetDistanceBetweenPlayers(playerid, id, Float:distance)
{
	new bool:inRange = false;
	
	foreach(Player, i) {
		if(LoggedIn[i] && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
			new Float:x, Float:y, Float:z;
			if(IsPlayerInRangeOfPoint(i, distance, x, y, z)) {
				inRange = true;
			}
		}
	}
	
	return inRange;
}

Server:SetPlayerSpawn(playerid)
{
	SetSpawnInfo(playerid, 0, DEFAULT_SKIN, PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2], PlayerData[playerid][pLastPos][3], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	
	SetPlayerVirtualWorld(playerid, PlayerData[playerid][pLastWorld]);
	SetPlayerInterior(playerid, PlayerData[playerid][pLastInt]);

	return true;
}

Server:SavePlayerPosition(playerid, bool:save)
{
	GetPlayerPos(playerid, PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2]);
	GetPlayerFacingAngle(playerid, PlayerData[playerid][pLastPos][3]);

	PlayerData[playerid][pLastInt] = GetPlayerInterior(playerid);
	PlayerData[playerid][pLastWorld] = GetPlayerVirtualWorld(playerid);
	
	if(save) {
		new query[512];
		mysql_format(sqlConnection, query, sizeof(query), "UPDATE players SET LastX = %f, LastY = %f, LastZ = %f, LastRot = %f, Interior = %i, VW = %i WHERE id = %i LIMIT 1", PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2], PlayerData[playerid][pLastPos][3], PlayerData[playerid][pLastInt], PlayerData[playerid][pLastWorld], PlayerData[playerid][pSQLID]);
		mysql_pquery(sqlConnection, query);
	}

	return true;
}

Server:TIMER_OneSecondTimer()
{
	if(lastSaveTime < 5) {
		foreach(Player, i) {
			if(LoggedIn[i]) {
				SavePlayerPosition(i, false);
			}
		}
	}
	else {
		foreach(Player, i) {
			if(LoggedIn[i]) {
				SavePlayerPosition(i, true);
			}
		}
		
		lastSaveTime = 0;
	}

	lastSaveTime++;

	return true;
}

Server:ResetDamageData(playerid)
{
	for(new i = 0; i < MAX_DAMAGES; i++) {
		if(DamageData[i][DamagePlayerID] == playerid) {
			DamageData[i][DamagePlayerID] = INVALID_PLAYER_ID;
			DamageData[i][DamageWeapon] = INVALID_WEAPON_ID;
			DamageData[i][DamageAmount] = 0.0;
			DamageData[i][DamageBodyPart] = 0;
		}
	}
	
	return true;
}

Server:SaveDamageData(playerid, weaponid, bodypart, Float:amount)
{
	totalDamages++;
	
	DamageData[totalDamages][DamagePlayerID] = playerid;
	DamageData[totalDamages][DamageWeapon] = weaponid;
	DamageData[totalDamages][DamageAmount] = amount;
	DamageData[totalDamages][DamageBodyPart] = bodypart;

	return true;
}

Server:DisplayDamageData(playerid, forPlayerid)
{
	new count = 0;
	
	for(new i = 0; i < MAX_DAMAGES; i++) {
		if(DamageData[i][DamagePlayerID] == playerid) {
		count++;
		}
	}
	
	if(!count) return SendClientMessage(forPlayerid, COLOR_WHITE, "This player hasn't been injured.");
	
	new longStr[512] = EOS, weaponName[25] = EOS;
	
	for(new i = 0; i < MAX_DAMAGES; i++) {
		if(DamageData[i][DamagePlayerID] == playerid) {
			GetWeaponName(DamageData[i][DamageWeapon], weaponName, sizeof(weaponName));
		
			format(longStr, sizeof(longStr), "%s{FFFFFF}(%s - %s) %s\n", longStr, GetDamageType(DamageData[i][DamageWeapon]), GetBoneDamaged(DamageData[i][DamageBodyPart]), weaponName);
		}
	}
	
	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_LIST, "{FF0000}Damage Information", longStr, "Ok", "");

	return true;
}

Server:GiveCash(playerid, amount)
{
	PlayerData[playerid][pMoney] += amount;
	
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	
	SaveSQLInt(PlayerData[playerid][pSQLID], "players", "Money", PlayerData[playerid][pMoney]);

	return true;
}

Server:CountPlayerHouses(playerid)
{
	new count = 0;
	
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(HouseData[i][HouseID] != 0 && HouseData[i][HouseOwnerSQL] == PlayerData[playerid][pSQLID]) {
			count++;
		}
	}

	return count;
}

Server:ToggleVehicleLock(vehicleId, bool:lockstate)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleId, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleId, engine, lights, alarm, lockstate, bonnet, boot, objective);

	return true;
}