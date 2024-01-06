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