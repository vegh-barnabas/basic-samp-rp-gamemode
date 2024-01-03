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

#define DIALOG_UNUSED		0
#define DIALOG_REGISTER		1
#define	DIALOG_LOGIN		2

enum PLAYER_DATA
{
	pSQLID,
	pAdminLevel
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

Server:DoesPlayerExist(playerid)
{
	new query[128];
	mysql_format(sqlConnection, query, sizeof(query), "SELECT id FROM players WHERE Name = '%e' LIMIT 1", GetName(playerid));
	mysql_pquery(sqlConnection, query, "SQL_DoesPlayerExist", "i", playerid);

	return true;
}

Server:SQL_DoesPlayerExist(playerid)
{
	if (cache_num_rows(sqlConnection) != 0)
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
	
	PlayerData[playerid][pSQLID] = cache_get_field_content_int(0, "id", sqlConnection);
	PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);
	
	new string[128];
	format(string, sizeof(string), "SQLID: %d | Admin: %d", PlayerData[playerid][pSQLID], PlayerData[playerid][pAdminLevel]);
	SendClientMessage(playerid, COLOR_WHITE, string);
	
	return true;
}

Server:DefaultPlayerValues(playerid)
{
	PlayerData[playerid][pSQLID] = 0;
	PlayerData[playerid][pAdminLevel] = 0;
	
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

stock strmatch(const string1[], const string2[])
{
	if ((strcmp(string1, string2, true, strlen(string2)) == 0) && (strlen(string2) == strlen(string1))) return true;
	
	return false;
}