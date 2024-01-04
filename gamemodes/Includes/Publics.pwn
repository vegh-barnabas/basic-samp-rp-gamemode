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
	
	return true;
}

Server:SQL_OnAccountLogin(playerid)
{
	if(cache_num_rows() == 0) {
		ShowLoginDialog(playerid, "Incorrect password.");
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
	mysql_pquery(sqlConnection, query, "SQL_OnLoadAccount", "i");
}

Server:SQL_OnLoadAccount(playerid)
{
	PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);
	PlayerData[playerid][pMoney] = cache_get_field_content_int(0, "Money", sqlConnection);
	PlayerData[playerid][pLevel] = cache_get_field_content_int(0, "Level", sqlConnection);
	PlayerData[playerid][pRespect] = cache_get_field_content_int(0, "Respect", sqlConnection);
	
	SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
	
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	
	
	new string[128];
	format(string, sizeof(string), "SQLID: %d | Admin: %d", PlayerData[playerid][pSQLID], PlayerData[playerid][pAdminLevel]);
	SendClientMessage(playerid, COLOR_WHITE, string);

	return true;
}

Server:DefaultPlayerValues(playerid)
{
	PlayerData[playerid][pSQLID] = 0;
	PlayerData[playerid][pAdminLevel] = 0;
	PlayerData[playerid][pMoney] = 0;
	PlayerData[playerid][pLevel] = 1;
	PlayerData[playerid][pRespect] = 0;
	
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