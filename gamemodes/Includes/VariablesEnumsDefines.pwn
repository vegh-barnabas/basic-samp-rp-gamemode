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

#define VERSION_TEXT	"1.0"

#define DEFAULT_SKIN		60
#define INVALID_WEAPON_ID	-1

#define MAX_DAMAGES		(MAX_PLAYERS * 10)
#define MAX_HOUSES		50

#define BODY_PART_CHEST			3
#define BODY_PART_TORSO			4
#define BODY_PART_LEFT_ARM		5
#define BODY_PART_RIGHT_ARM		6
#define BODY_PART_LEFT_LEG		7
#define BODY_PART_RIGHT_LEG		8
#define BODY_PART_HEAD			9

enum PLAYER_DATA
{
	pSQLID,
	pAdminLevel,
	pMoney,
	pLevel,
	pRespect,
	Float:pLastPos[5],
	pLastInt,
	pLastWorld
}

enum DAMAGE_DATA
{
	DamagePlayerID,
	DamageWeapon,
	Float:DamageAmount,
	DamageBodyPart
}

enum HOUSE_DATA
{
	HouseID,
	HouseOwnerSQL,
	HouseName[40],
	Float:HouseExterior[4],
	Float:HouseInterior[4],
	HouseInteriorID,
	HousePrice,
	HouseLocked,
	HousePickup,
	Text3D:HouseLabel
}

// Global variables
new sqlConnection;
new OneSecondTimer, lastSaveTime = 0;

// Player variables
new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA], DamageData[MAX_DAMAGES][DAMAGE_DATA], totalDamages = 0;

// House variables
new HouseData[MAX_HOUSES][HOUSE_DATA], totalHousesCreated = 0;