LoadServerHouses()
{
	return mysql_pquery(sqlConnection, "SELECT * FROM houses ORDER BY id ASC", "SQL_LoadServerHouses");
}

Server:SQL_LoadServerHouses()
{
	if(cache_num_rows() == 0) return print("No houses available to load from database!");

	new rows, fields;
	cache_get_row_count(rows);
	cache_get_field_count(fields);
	
	for(new i = 0; i < rows && i < MAX_HOUSES; i++) {
		cache_get_value_name_int(i, "id", HouseData[i+1][HouseID]);
		cache_get_value_name_int(i, "OwnerSQL", HouseData[i+1][HouseOwnerSQL]);
		cache_get_value_name_int(i, "id", HouseData[i+1][HouseName]);
		
		cache_get_value_name(i, "Name", HouseData[i+1][HouseName]);
		
		cache_get_value_name_float(i, "ExtX", HouseData[i+1][HouseExterior][0]);
		cache_get_value_name_float(i, "ExtY", HouseData[i+1][HouseExterior][1]);
		cache_get_value_name_float(i, "ExtZ", HouseData[i+1][HouseExterior][2]);
		cache_get_value_name_float(i, "ExtA", HouseData[i+1][HouseExterior][3]);
		
		cache_get_value_name_float(i, "IntX", HouseData[i+1][HouseInterior][0]);
		cache_get_value_name_float(i, "IntY", HouseData[i+1][HouseInterior][1]);
		cache_get_value_name_float(i, "IntZ", HouseData[i+1][HouseInterior][2]);
		cache_get_value_name_float(i, "IntA", HouseData[i+1][HouseInterior][3]);
		cache_get_value_name_int(i, "IntID", HouseData[i+1][HouseInteriorID]);
		
		cache_get_value_name_int(i, "Price", HouseData[i+1][HousePrice]);
		cache_get_value_name_int(i, "Locked", HouseData[i+1][HouseLocked]);
	
		totalHousesCreated++;
	}
	
	CreateServerHouseData();
	
	printf("%i houses loaded from the database.", totalHousesCreated);

	return true;
}

CreateServerHouseData()
{
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(HouseData[i][HouseID] != 0) {
			HouseData[i][HousePickup] = CreatePickup(1273, 1, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2], 0);
			HouseData[i][HouseLabel] = Create3DTextLabel(HouseData[i][HouseName], 0xFFFFFFFF, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2], 10.0, 0, 0);
		}
	}

	return true;
}

static Float:hCreateExt[4], Float:hCreateInt[4], hCreateIntID, hCreateName[40], hCreatePrice;

CMD:makehouse(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(PlayerData[playerid][pAdminLevel] == 0) return SendClientMessage(playerid, COLOR_WHITE, "Unknown command.");
	
	if(PlayerData[playerid][pAdminLevel] < 5) return SendClientMessage(playerid, COLOR_WHITE, "You re not the required admin level to use this command. (level 5)");
	
	new section[10], extra[40], string[50];
	if(sscanf(params, "s[10]S('None')[40]", section, extra)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /makehouse [exterior/interior/name/price/complete]");
	
	if(strmatch(section, "exterior")) {
		GetPlayerPos(playerid, hCreateExt[0], hCreateExt[1], hCreateExt[2]);
		GetPlayerFacingAngle(playerid, hCreateExt[3]);
		
		SendClientMessage(playerid, COLOR_YELLOW, "Exterior position set successfully.");
	} else if(strmatch(section, "interior")) {
		hCreateIntID = GetPlayerInterior(playerid);
		
		GetPlayerPos(playerid, hCreateInt[0], hCreateInt[1], hCreateInt[2]);
		GetPlayerFacingAngle(playerid, hCreateInt[3]);
		
		SendClientMessage(playerid, COLOR_YELLOW, "Interior position set successfully.");
	} else if(strmatch(section, "name")) {
		if(strmatch(extra, "None")) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /makehouse name [name to set]");
		
		if(strlen(extra) > 39 || strlen(extra) < 3) return SendClientMessage(playerid, COLOR_WHITE, "Name length must be between 3 and 39 characters long.");
		
		hCreateName = extra;
		
		format(string, sizeof(string), "Name set successfully: {FFFFFF}%s.", hCreateName);
		SendClientMessage(playerid, COLOR_YELLOW, string);
	} else if(strmatch(section, "price")) {
		if(strmatch(extra, "None")) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /makehouse price [price to set]");
	
		if(strval(extra) < 1) return SendClientMessage(playerid, COLOR_WHITE, "Price must be above 1$.");
		
		hCreatePrice = strval(extra);
		
		format(string, sizeof(string), "Price set successfully: {FFFFFF}%d$.", hCreatePrice);
		SendClientMessage(playerid, COLOR_YELLOW, string);
	} else if(strmatch(section, "complete")) {
		if(hCreatePrice == 0) return SendClientMessage(playerid, COLOR_WHITE, "The house doesn't have a price!");
		if(strmatch(hCreateName, "None")) return SendClientMessage(playerid, COLOR_WHITE, "The house doesn't have a name!");
	
		SaveHouseToDatabase(playerid);
		SendClientMessage(playerid, COLOR_WHITE, "House created!");
		
		SetPlayerPos(playerid, hCreateExt[0], hCreateExt[1], hCreateExt[2]);
		SetPlayerFacingAngle(playerid, hCreateExt[3]);
		
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	
	return true;
}

Server:SaveHouseToDatabase(playerid)
{
	new query[512];
	
	mysql_format(sqlConnection, query, sizeof(query), "INSERT INTO houses (OwnerSQL, Name, ExtX, ExtY, ExtZ, ExtA, IntX, IntY, IntZ, IntA, IntID, Price) VALUES(0, '%e', %f, %f, %f, %f, %f, %f, %f, %f, %i, %i)", hCreateName, hCreateExt[0], hCreateExt[1], hCreateExt[2], hCreateExt[3], hCreateInt[0], hCreateInt[1], hCreateInt[2], hCreateInt[3], hCreateIntID, hCreatePrice);
	mysql_pquery(sqlConnection, query, "SQL_SaveHouseToDatabase", "i", playerid);
	
	return true;
}

Server:SQL_SaveHouseToDatabase(playerid)
{
	totalHousesCreated++;
	
	HouseData[totalHousesCreated][HouseID] = cache_insert_id();
	HouseData[totalHousesCreated][HouseOwnerSQL] = 0;
	
	format(HouseData[totalHousesCreated][HouseName], 40, hCreateName);
	
	HouseData[totalHousesCreated][HouseExterior][0] = hCreateExt[0];
	HouseData[totalHousesCreated][HouseExterior][1] = hCreateExt[1];
	HouseData[totalHousesCreated][HouseExterior][2] = hCreateExt[2];
	HouseData[totalHousesCreated][HouseExterior][3] = hCreateExt[3];
	
	HouseData[totalHousesCreated][HouseInterior][0] = hCreateInt[0];
	HouseData[totalHousesCreated][HouseInterior][1] = hCreateInt[1];
	HouseData[totalHousesCreated][HouseInterior][2] = hCreateInt[2];
	HouseData[totalHousesCreated][HouseInterior][3] = hCreateInt[3];
	HouseData[totalHousesCreated][HouseInteriorID] = hCreateIntID;
	
	HouseData[totalHousesCreated][HousePrice] = hCreatePrice;
	HouseData[totalHousesCreated][HouseLocked] = 0;
	
	HouseData[totalHousesCreated][HousePickup] = CreatePickup(1273, 1, HouseData[totalHousesCreated][HouseExterior][0], HouseData[totalHousesCreated][HouseExterior][1], HouseData[totalHousesCreated][HouseExterior][2], 0);
	HouseData[totalHousesCreated][HouseLabel] = Create3DTextLabel(HouseData[totalHousesCreated][HouseName], 0xFFFFFFFF, HouseData[totalHousesCreated][HouseExterior][0], HouseData[totalHousesCreated][HouseExterior][1], HouseData[totalHousesCreated][HouseExterior][2], 10.0, 0, 0);
	
	printf("House ID %i created by %s", HouseData[totalHousesCreated][HouseID], GetName(playerid));
	
	new string[128];
	format(string, sizeof(string), "House ID %i (SQLID %i) created: %s, %d$", totalHousesCreated, HouseData[totalHousesCreated][HouseID], HouseData[totalHousesCreated][HouseName], HouseData[totalHousesCreated][HousePrice]);
	SendClientMessage(playerid, COLOR_YELLOW, string);

	return true;
}

CMD:buyhouse(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(CountPlayerHouses(playerid) > 2) return SendClientMessage(playerid, COLOR_WHITE, "You already own the maximum of two houses.");
	
	new houseId = 0;
	
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(HouseData[i][HouseID] != 0) {
			if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2])) {
				houseId = i;
			}
		}
	}
	
	if(houseId == 0) return SendClientMessage(playerid, COLOR_WHITE, "You are not near to a house that you can purchase.");
	
	if(HouseData[houseId][HouseOwnerSQL] != 0) return SendClientMessage(playerid, COLOR_WHITE, "This house is already owned by an other person.");
	if(PlayerData[playerid][pMoney] < HouseData[houseId][HousePrice]) return SendClientMessage(playerid, COLOR_WHITE, "You don't have enough money to purchase this house.");
	
	GiveCash(playerid, -HouseData[houseId][HousePrice]);
	HouseData[houseId][HouseOwnerSQL] = PlayerData[playerid][pSQLID];
	
	new string[128];
	format(string, sizeof(string), "You have purchased '%s' for %d$.", HouseData[houseId][HouseName], HouseData[houseId][HousePrice]);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	
	SaveSQLInt(HouseData[houseId][HouseID], "houses", "OwnerSQL", HouseData[houseId][HouseOwnerSQL]);

	return true;
}

CMD:lock(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(CountPlayerHouses(playerid) == 0) return SendClientMessage(playerid, COLOR_WHITE, "You do not own a house.");

	new id = GetNearestHouseID(playerid);
	if(GetNearestHouseID(playerid) == -1) return SendClientMessage(playerid, COLOR_WHITE, "You are not near to any houses.");

	if(HouseData[id][HouseOwnerSQL] != PlayerData[playerid][pSQLID]) return SendClientMessage(playerid, COLOR_WHITE, "You do not own this house.");

	if(HouseData[id][HouseLocked] == 0) {
		HouseData[id][HouseLocked] = 1;
		SendClientMessage(playerid, COLOR_WHITE, "House locked.");
		SaveSQLInt(HouseData[id][HouseID], "houses", "Locked", HouseData[id][HouseLocked]);
		
		cmd_me(playerid, "locks the doors of the house.");
	}
	else if(HouseData[id][HouseLocked] == 1) {
		HouseData[id][HouseLocked] = 0;
		SendClientMessage(playerid, COLOR_WHITE, "House unlocked.");
		SaveSQLInt(HouseData[id][HouseID], "houses", "Locked", HouseData[id][HouseLocked]);
		
		cmd_me(playerid, "unlock the doors of the house.");
	}

	return true;
}
CMD:unlock(playerid, params[]) return cmd_lock(playerid, params);