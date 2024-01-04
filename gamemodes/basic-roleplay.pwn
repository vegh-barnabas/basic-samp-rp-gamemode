/*
Includes & Plugins:
	IZCMD Hungarian Accents: https://github.com/vegh-barnabas/hungarian-accents-I-ZCMD
	MySQL R39-6: https://github.com/pBlueG/SA-MP-MySQL
	Streamer 2.9.0: https://github.com/samp-incognito/samp-streamer-plugin
	foreach: https://github.com/karimcambridge/samp-foreach
	sscanf 2.8.2: https://github.com/Y-Less/sscanf/releases/tag/v2.8.2
	
	All work completed in this script was with the help of iGetty.
	
	Test user:
		name - testuser
		password - testuser
*/


#include <a_samp>
#include <izcmd>
#include <a_mysql>
#include <streamer>
#include <foreach>
#include <sscanf2>

#define Server:%0(%1) forward %0(%1); public %0(%1)

#define MYSQL_HOST "localhost"
#define MYSQL_USER "basic-rp"
#define MYSQL_DATABASE "basic-rp"
#define MYSQL_PASSWORD "basicRoleplay"

#define COLOR_WHITE		0xFFFFFF00
#define COLOR_RED		0xFF000000
#define COLOR_YELLOW	0xFFFF0000
#define COLOR_EMOTE		0xEDA4FF00
#define COLOR_SHOUT		0xD1692C00

#define DIALOG_UNUSED		0
#define DIALOG_REGISTER		1
#define	DIALOG_LOGIN		2

enum PLAYER_DATA
{
	pSQLID,
	pAdminLevel,
	pMoney,
	pLevel,
	pRespect
}

// Global variables
new sqlConnection;

// Player variables
new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA];

main(){}

public OnGameModeInit()
{
	mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
	
	sqlConnection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);

	return true;
}

public OnGameModeExit()
{
	mysql_close(sqlConnection);

	return false;
}

public OnPlayerConnect(playerid)
{
	DefaultPlayerValues(playerid);
	DoesPlayerExist(playerid);
	
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response) return Kick(playerid);
		
			if(strlen(inputtext) < 3 || strlen(inputtext) > 30) {
				ShowRegisterDialog(playerid, "Password length must be above 3 characters and below 30 characters long.");
			
				return true;
			}
			
			new query[128];
			mysql_format(sqlConnection, query, sizeof(query), "INSERT INTO players (Name, Password, RegIP) VALUES('%e', sha1('%e'), '%e')", GetName(playerid), inputtext, GetIP(playerid));
			mysql_pquery(sqlConnection, query, "SQL_OnAccountRegister", "i", playerid);
		}
		case DIALOG_LOGIN:
		{
			if(!response) return Kick(playerid);
			
			new query[128];
			mysql_format(sqlConnection, query, sizeof(query), "SELECT id FROM players WHERE Name = '%e' AND Password = sha1('%e') LIMIT 1", GetName(playerid), inputtext);
			mysql_pquery(sqlConnection, query, "SQL_OnAccountLogin", "i", playerid);
		}
	
	}

	return false;
}

// Server functions
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

// General commands
CMD:shout(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /s(shout) [shout message]");
	
	new string[128];
	format(string, sizeof(string), "%s shouts: %s!", NameRP(playerid), params);
	SendLocalMessageEx(playerid, COLOR_SHOUT, string, 20.0);

	return true;
}
CMD:s(playerid, params[]) return cmd_shout(playerid, params);

CMD:low(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /l(ow) [low message]");
	
	new string[128];
	format(string, sizeof(string), "%s says (low): %s!", NameRP(playerid), params);
	SendLocalMessageEx(playerid, COLOR_WHITE, string, 7.5);

	return true;
}
CMD:l(playerid, params[]) return cmd_low(playerid, params);

CMD:whisper(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	new id, msg[80];
	
	if(sscanf(params, "us[80]", id, msg)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /w(hisper) [player name or id] [whisper message]");
	
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't connected.");
	if(!LoggedIn[id]) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't logged in.");
	
	if(!GetDistanceBetweenPlayers(playerid, id, 3.5)) return SendClientMessage(playerid, COLOR_WHITE, "You must be close to the player to whisper to them.");
	
	new string[128];
	format(string, sizeof(string), "[Whisper from %s] %s", NameRP(playerid), msg);
	SendClientMessage(id, COLOR_YELLOW, string);
	
	format(string, sizeof(string), "[Whisper to %s] %s", NameRP(id), msg);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	
	format(string, sizeof(string), "* %s whispers something to %s...", NameRP(playerid), NameRP(id));
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}
CMD:w(playerid, params[]) return cmd_whisper(playerid, params);

CMD:attempt(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /attempt [action message]");
	
	new string[128];
	format(string, sizeof(string), "** %s attempts to %s and ", NameRP(playerid), params);
	
	new rand = random(50);
	switch(rand) {
		case 0 .. 25:
		{
			strins(string, "fails...", strlen(string));
		}
		default:
		{
			strins(string, "succeeds!", strlen(string));
		}
	}
	
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}

CMD:b(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /b [Local OOC chat message]");
	
	new string[128];
	format(string, sizeof(string), "(( [OOC - Local] %s says: %s ))", NameRP(playerid), params);
	
	SendLocalMessage(playerid, COLOR_YELLOW, string);
	
	return true;
}

CMD:pm(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	new id, msg[80];
	if(sscanf(params, "us[80]", id, msg)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /pm [playerid or name] [message]");
	
	if(playerid == id) return SendClientMessage(playerid, COLOR_WHITE, "You can't send yourself a PM.");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't connected.");
	if(!LoggedIn[id]) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't logged in.");
	
	new string[128];
	format(string, sizeof(string), "(( [Private message from %s (%d)] %s ))", NameRP(playerid), playerid, msg);
	SendClientMessage(id, COLOR_YELLOW, string);
	
	format(string, sizeof(string), "(( [Private message to %s (%d)] %s ))", NameRP(id), id, msg);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	
	return true;
}

CMD:me(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /me [Action message]");

	new string[128];
	format(string, sizeof(string), "* %s %s", NameRP(playerid), params);
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}

CMD:do(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /do [Action message]");

	new string[128];
	format(string, sizeof(string), "* %s (( %s ))", params, NameRP(playerid));
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}

CMD:ame(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /me [Annotated action message]");

	SetPlayerChatBubble(playerid, params, COLOR_EMOTE, 15.0, 10000);
	
	new string[128];
	format(string, sizeof(string), "* Annotated message: %s (( %s ))", params, NameRP(playerid));
	SendLocalMessage(playerid, COLOR_EMOTE, string);

	return true;
}

// Account commands
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

// Stocks and other functions
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