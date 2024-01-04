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