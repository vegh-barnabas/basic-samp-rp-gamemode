LoadPlayerOwnedVehicles(playerid)
{
	new query[128];
	mysql_format(sqlConnection, query, sizeof(query), "SELECT * FROM ownedcars WHERE OwnerID = %i LIMIT %i", PlayerData[playerid][pSQLID], MAX_OWNED_VEHICLES);
	mysql_pquery(sqlConnection, query, "SQL_LoadPlayerOwnedVehicles", "i", playerid);

	return true;
}

Server:SQL_LoadPlayerOwnedVehicles(playerid)
{
	if(!cache_num_rows()) return true;
	
	new rows, fields, vehicleId = INVALID_VEHICLE_ID;
	
	cache_get_data(rows, fields, sqlConnection);
	
	for(new i = 0; i < rows && i < MAX_VEHICLES; i++) {
		vehicleId = CreateVehicle(cache_get_field_content_int(i, "ModelID", sqlConnection),
		cache_get_field_content_float(i, "PosX", sqlConnection),
		cache_get_field_content_float(i, "PosY", sqlConnection),
		cache_get_field_content_float(i, "PosZ", sqlConnection),
		cache_get_field_content_float(i, "PosA", sqlConnection),
		cache_get_field_content_int(i, "Color1", sqlConnection),
		cache_get_field_content_int(i, "Color2", sqlConnection), -1, false);
		
		if(vehicleId != INVALID_VEHICLE_ID) {
			OwnedCarData[vehicleId][OwnedCarID] = cache_get_field_content_int(i, "id", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarOwner] = cache_get_field_content_int(i, "OwnerID", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarLock] = cache_get_field_content_int(i, "LockState", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarModel] = cache_get_field_content_int(i, "ModelID", sqlConnection);
			
			OwnedCarData[vehicleId][OwnedCarColor][0] = cache_get_field_content_int(i, "Color1", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarColor][1] = cache_get_field_content_int(i, "Color2", sqlConnection);
			
			OwnedCarData[vehicleId][OwnedCarPos][0] = cache_get_field_content_float(i, "PosX", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarPos][1] = cache_get_field_content_float(i, "PosY", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarPos][2] = cache_get_field_content_float(i, "PosZ", sqlConnection);
			OwnedCarData[vehicleId][OwnedCarPos][3] = cache_get_field_content_float(i, "PosA", sqlConnection);
			
			cache_get_field_content(i, "Plate", OwnedCarData[vehicleId][OwnedCarPlate], sqlConnection, 10);
			SetVehicleNumberPlate(vehicleId, OwnedCarData[vehicleId][OwnedCarPlate]);
			
			SetVehicleToRespawn(vehicleId);
			
			if(OwnedCarData[vehicleId][OwnedCarLock] == 1) ToggleVehicleLock(vehicleId, true);
			else ToggleVehicleLock(vehicleId, false);
		}
	}

	return true;
}