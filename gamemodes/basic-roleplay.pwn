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

#include "../gamemodes/Includes/VariablesEnumsDefines.pwn"
#include "../gamemodes/Includes/OtherFunctions.pwn"
#include "../gamemodes/Includes/Publics.pwn"

#include "../gamemodes/Includes/Commands/General.pwn"
#include "../gamemodes/Includes/Commands/Account.pwn"

#include "../gamemodes/Includes/Houses.pwn"
#include "../gamemodes/Includes/Businesses.pwn"
#include "../gamemodes/Includes/OwnedVehicles.pwn"
#include "../gamemodes/Includes/Factions.pwn"
#include "../gamemodes/Includes/FactionVehicles.pwn"

main(){}

public OnGameModeInit()
{
	SetGameModeText("Basic Roleplay "VERSION_TEXT"");

	mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
	
	sqlConnection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);
	
	OneSecondTimer = SetTimer("TIMER_OneSecondTimer", 1000, true);

	return true;
}

public OnGameModeExit()
{
	KillTimer(OneSecondTimer);

	mysql_close(sqlConnection);

	return false;
}

public OnPlayerConnect(playerid)
{
	DefaultPlayerValues(playerid);
	DoesPlayerExist(playerid);
	
	SetTimerEx("TIMER_SetCameraPos", 1000, false, "i", playerid);
	
	return true;
}

public OnPlayerDisconnect(playerid, reason)
{
	DefaultPlayerValues(playerid);
	
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
			
			new query[256];
			mysql_format(sqlConnection, query, sizeof(query), "SELECT id FROM players WHERE Name = '%e' AND Password = sha1('%e') LIMIT 1", GetName(playerid), inputtext);
			mysql_pquery(sqlConnection, query, "SQL_OnAccountLogin", "i", playerid);
		}
	}

	return false;
}