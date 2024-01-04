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