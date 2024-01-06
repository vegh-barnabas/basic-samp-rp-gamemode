CMD:buylevel(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	new neededRespect = PlayerData[playerid][pLevel] * 10;
	
	if(PlayerData[playerid][pRespect] < neededRespect) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough respect points in order to level up.");
	
	PlayerData[playerid][pLevel]++;
	PlayerData[playerid][pRespect] -= neededRespect;

	SaveSQLInt(PlayerData[playerid][pSQLID], "players", "Level", PlayerData[playerid][pLevel]);
	SaveSQLInt(PlayerData[playerid][pSQLID], "players", "Respect", PlayerData[playerid][pRespect]);

	new string[128];
	format(string, sizeof(string), "You have levelled up successfully. You are now level %d. (Respect points left: %d)", PlayerData[playerid][pLevel], PlayerData[playerid][pRespect]);
	SendClientMessage(playerid, COLOR_WHITE, string);

	return true;
}