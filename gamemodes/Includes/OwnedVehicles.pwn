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
	
	cache_get_row_count(rows);
	cache_get_field_count(fields);
	
	for(new i = 0; i < rows && i < MAX_VEHICLES; i++) {
		new modelId, Float:posX, Float:posY, Float:posZ, Float:posA, color1, color2;
		
		cache_get_value_name_int(i, "ModelID", modelId);
		cache_get_value_name_float(i, "PosX", posX);
		cache_get_value_name_float(i, "PosY", posY);
		cache_get_value_name_float(i, "PosZ", posZ);
		cache_get_value_name_float(i, "PosA", posA);
		cache_get_value_name_int(i, "Color1", color1);
		cache_get_value_name_int(i, "Color2", color2);
	
		vehicleId = CreateVehicle(modelId, posX, posY, posZ, posA, color1, color2 -1, false);
		
		if(vehicleId != INVALID_VEHICLE_ID) {
			cache_get_value_name_int(i, "id", OwnedCarData[vehicleId][OwnedCarID]);
			cache_get_value_name_int(i, "OwnerID", OwnedCarData[vehicleId][OwnedCarOwner]);
			cache_get_value_name_int(i, "LockState", OwnedCarData[vehicleId][OwnedCarLock]);
			OwnedCarData[vehicleId][OwnedCarModel] = modelId;
			
			OwnedCarData[vehicleId][OwnedCarColor][0] = color1;
			OwnedCarData[vehicleId][OwnedCarColor][1] = color2;
			
			OwnedCarData[vehicleId][OwnedCarPos][0] = posX;
			OwnedCarData[vehicleId][OwnedCarPos][1] = posY;
			OwnedCarData[vehicleId][OwnedCarPos][2] = posZ;
			OwnedCarData[vehicleId][OwnedCarPos][3] = posA;
			
			cache_get_value_name(i, "Plate", OwnedCarData[vehicleId][OwnedCarPlate]);
			SetVehicleNumberPlate(vehicleId, OwnedCarData[vehicleId][OwnedCarPlate]);
			
			SetVehicleToRespawn(vehicleId);
			
			if(OwnedCarData[vehicleId][OwnedCarLock] == 1) ToggleVehicleLock(vehicleId, true);
			else ToggleVehicleLock(vehicleId, false);
		}
	}

	return true;
}