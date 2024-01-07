GetIP(playerid)
{
	new ip[20];
	
	GetPlayerIp(playerid, ip, sizeof(ip));

	return ip;
}

GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	
	return name;
}

NameRP(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	
	for(new i = 0; i < strlen(name); i++) {
		if(name[i] == '_') {
			name[i] = ' ';
		}
	}

	return true;
}

strmatch(const string1[], const string2[])
{
	if((strcmp(string1, string2, true, strlen(string2)) == 0) && (strlen(string2) == strlen(string1))) return true;
	
	return false;
}

GetDamageType(weaponid)
{
	new damageType[25] = EOS;
	
	switch(weaponid)
	{
		case 0 .. 3, 5 .. 7, 10 .. 15: damageType = "Blunt trauma";
		case 4, 8, 9: damageType = "Stab wound";
		case 22 .. 34: damageType = "Gunshot wound";
		case 16, 18, 35 .. 37, 39, 40: damageType = "Burn/Explosive wound";
		default: damageType = "Unkown wound";
	}

	return damageType;
}

GetBoneDamaged(bodypart)
{
	new bodypartR[20] = EOS;
	switch(bodypart)
	{
		case BODY_PART_CHEST: bodypartR = "Chest";
		case BODY_PART_TORSO: bodypartR = "Torso";
		case BODY_PART_LEFT_ARM: bodypartR = "Left Arm";
		case BODY_PART_RIGHT_ARM: bodypartR = "Right Arm";
		case BODY_PART_LEFT_LEG: bodypartR = "Left Leg";
		case BODY_PART_RIGHT_LEG: bodypartR = "Right Leg";
		case BODY_PART_HEAD: bodypartR = "Head";
	}

	return bodypartR;
}

ReturnAdminRank(rankid)
{
	new string[20] = EOS;

	switch(rankid) {
		case 1: string = "Trial Moderator";
		case 2: string = "Moderator";
		case 3: string = "Admin";
		case 4: string = "Lead Admin";
		case 5: string = "Owner";
		default: string = "None";
	}

	return string;
}

GetNearestHouseID(playerid, Float:range = 5.0)
{
	new id = -1;
	
	for(new i = 0; i < MAX_HOUSES && id == -1; i++) {
		if(HouseData[i][HouseID] != 0) {
			if(IsPlayerInRangeOfPoint(playerid, range, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2])) {
				id = i;
			}
		}
	}

	return id;
}