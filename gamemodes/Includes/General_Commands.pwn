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

CMD:injuries(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	new id;
	
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /injuries [player id or name]");

	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't connected.");
	if(!LoggedIn[id]) return SendClientMessage(playerid, COLOR_WHITE, "That player isn't logged in.");
	
	// this doesnt work for some reason
	// if(!GetDistanceBetweenPlayers(playerid, id, 5.0)) return SendClientMessage(playerid, COLOR_WHITE, "You must be close to the player.");
	
	DisplayDamageData(id, playerid);
	
	return true;
}

CMD:enter(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(IsPlayerInAnyVehicle(playerid)) return true;
	
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(HouseData[i][HouseID] != 0) {
			if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2])) {
				if(HouseData[i][HouseLocked] == 0) {
					SetPlayerPos(playerid, HouseData[i][HouseInterior][0], HouseData[i][HouseInterior][1], HouseData[i][HouseInterior][2]);
					SetPlayerFacingAngle(playerid, HouseData[i][HouseInterior][3]);
					
					SetPlayerInterior(playerid, HouseData[i][HouseInteriorID]);
					SetPlayerVirtualWorld(playerid, HouseData[i][HouseID]);
				}
				else return SendClientMessage(playerid, COLOR_WHITE, "The door is locked.");
			}
		}
	}
	
	return true;
}

CMD:exit(playerid, params[])
{
	if(!LoggedIn[playerid]) return true;
	
	if(IsPlayerInAnyVehicle(playerid)) return true;
	
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(HouseData[i][HouseID] != 0 && GetPlayerVirtualWorld(playerid) == HouseData[i][HouseID]) {
			if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseData[i][HouseInterior][0], HouseData[i][HouseInterior][1], HouseData[i][HouseInterior][2])) {
				if(HouseData[i][HouseLocked] == 0) {
					SetPlayerPos(playerid, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2]);
					SetPlayerFacingAngle(playerid, HouseData[i][HouseExterior][3]);
					
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
				}
				else return SendClientMessage(playerid, COLOR_WHITE, "The door is locked.");
			}
		}
	}
	
	return true;
}