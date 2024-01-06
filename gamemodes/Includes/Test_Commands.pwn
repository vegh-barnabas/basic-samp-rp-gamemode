CMD:testcommands(playerid, params[])
{
	SendClientMessage(playerid, COLOR_WHITE, "Test commands: /giveinjury");
	
	return true;
}

CMD:giveinjury(playerid, params[])
{
	new bodyPart = 3 + random(6);
	
	new validWeapons[] = {0, 1, 2, 3, 5, 6, 7, 10, 11, 12, 13, 14, 15, 4, 8, 9, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 16, 18, 35, 36, 37, 39, 40};
	new weaponId = validWeapons[random(sizeof(validWeapons) - 1)];
	
	new weaponName[25] = EOS;
	GetWeaponName(weaponId, weaponName, sizeof(weaponName));
	
	new Float:amount = random(100);
	
	SaveDamageData(playerid, weaponId, bodyPart, amount);
	
	new string[128];
	format(string, sizeof(string), "Injury given to yourself. (%s (%s) - %s | %f HP)", GetDamageType(weaponId), weaponName, GetBoneDamaged(bodyPart), amount);
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}