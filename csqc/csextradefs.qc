#include "../share/defs.h"

vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_BG_WARNING = '0.4 0.3 0.2';
vector MENU_BORDER_WARNING = '0.5 0.4 0.3';
vector MENU_SELECTED = '0 1 0';
vector MENU_UNSELECTED = '1 0 0';
vector MENU_BUTTON = '0.3 0.4 0.5';
//vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_TEXT_3 = '1 1 0';
vector MENU_TEXT_4 = '0.8 0.5 0';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_TEXT_WARNING = '0.8 0 0';
vector MENU_TEXT_GREEN = '0 0.8 0';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';
float MENU_START_CONTENT = 32;

#define MOTD_TIME 30

.float owned_by;
.string netname;
.float playerid;
float fo_hud_editor;
float fo_hud_menu_active;
vector ScreenSize;
float number_of_teams;
float last_skin;
float last_team;
vector sentry_pos;
vector dispenser_pos;
vector touched_dispenser_pos;
//entity player_list_head;
float player_menu_type;
float admin_menu_next_update;
float captain1;
float captain2;
float captain1_temp;
float captain2_temp;
float is_admin;
float motd_expiry;
float quad_round;
float quad_rounds_total;
//float game_started;
float prematch;
float round_active;
float round_over;
float showingscores;
float mapvote_expiry;
float grentimer_waiting; //grenade primed, but not thrown
float jump_counter;
float frames_since_onground;

float(string) GetDrawPanel;
void(string, string, string) Hud_DrawPanelLMP;
void(string id, string identify) Hud_DrawIdentifyPanel;
void (string panelid, float display, string text, string icon) Hud_DrawHudOptionsPanel;
void (string id, float playerclass) Hud_DrawClassInfoPanel;
void (string panelid) Hud_DrawFlagStatusBar;
float(string id, vector pos, vector size, float alpha, float enabled) hud_panel;
vector(float panelid) getPosition;
vector(float panelid) getFillSize;

void () SUB_Null = {
};

enum {
    HUD_ALIGN_RIGHT,
    HUD_ALIGN_LEFT,
    HUD_ALIGN_CENTER
};

string HUD_ALIGN[] = {
    "Right",
    "Left",
    "Center"
};

typedef struct 
{
    string icon;
} FO_Hud_Icons;
FO_Hud_Icons HudIcons[29] = {
    {""},
    {ICON_CLIPSIZE},
    {ICON_FRAGSTREAK},
    {ICON_CAPS},
    {ICON_GREN1},
    {ICON_GREN2},
    {ICON_IDENTIFY},
    {ICON_SCOUT},
    {ICON_SNIPER},
    {ICON_SOLDIER},
    {ICON_DEMOMAN},
    {ICON_MEDIC},
    {ICON_HWGUY},
    {ICON_PYRO},
    {ICON_SPY},
    {ICON_ENGINEER_SG},
    {ICON_ENGINEER_DISP},
    {ICON_SECURITY_BUTTON_GREEN},
    {ICON_SECURITY_BUTTON_YELLOW},
    {ICON_SECURITY_BUTTON_RED},
    {ICON_SECURITY_BUTTON_BLUE},
    {ICON_SECURITY_BUTTON_ANY},
    {ICON_FLAG_ANY},
    {ICON_FLAG_BLUE},
    {ICON_FLAG_RED},
    {ICON_FLAG_YELLOW},
    {ICON_FLAG_GREEN},
    {"textures/wad/num_percent.png"},
    {"textures/wad/anum_percent.png"}
};

typedef struct {
    string ClipSize;
    float FragStreak;
    float Caps;
    string Identify;
    float PlayerClass;
    float Gren1;
    float Gren2;
    string MOTD;
    string Hint;
    //1 = Clanmode, 2 = Quadmode, 4 = Duelmode, 8 = Prematch
    float GameMode;
    float Ready;
    float CountdownStarted;
    // scout
    float ScannerOn;
    float ScannerRange;
    float ScannerTeamNo;
    float ScannerPlayerClass;
    float ScannerTFItemsFlags;
    // sniper
    float SniperDam;
    float SniperMax;
    // demoman
    float IsDetpacking;
    float DetpackLeft;
    // medic
    float AuraActive;
    float HealCount;
    float HealAmount;
    float AuraStatus;
    // hwguy
    float LockedCannon;
    // spy
    float IsUndercover;
    float InvisOnly;
    float UndercoverTeam;
    float UndercoverSkin;
    float UndercoverTimer;
    float DisguiseTeam;
    float QueueTeam;
    float DisguiseSkin;
    float QueueSkin;
    // engineer
    float IsBuilding;
    float BuildingPercentage;
    float HasSentry;
    float SentryLevel;
    float SentryHealth;
    float SentryAmmoShells;
    float SentryAmmoRockets;
    float HasDispenser;
    float DispenserHealth;
} FO_SBAR;
FO_SBAR SBAR;

typedef struct {
    float ceasefire;
    float pubmode;
    float clanmode;
    float quadmode;
    float duelmode;
    float quad_rounds;
    float quad_round_time;
    float captainmode;
    float timelimit;
    float fraglimit;
    float class_override;
    float class_limit_scout;
    float class_limit_sniper;
    float class_limit_soldier;
    float class_limit_demoman;
    float class_limit_medic;
    float class_limit_hwguy;
    float class_limit_pyro;
    float class_limit_spy;
    float class_limit_engineer;
    float spurs_on;
    float spurs_scout;
    float spurs_spy;
    float spurs_engineer;
    float spurs_duration;
    float spurs_boost;
    float spurs_consume;
    float spurs_flag;
} SERVER_SETTINGS;
SERVER_SETTINGS SERVER_ADMIN;

typedef struct
{
    float x;
    float y;
} MouseStruct;

MouseStruct Mouse;

typedef struct {
    string filename;
    vector colour;
} HUDIcon;

typedef struct {
    float id;
    string message;
    //string model;
    entity model;
    float timeleft;
    float state;
    vector loc;
    string carrier;
    string locname;
    HUDIcon icon;
} FlagInfoLine;

FlagInfoLine FlagInfoLines[10];

// hud stuff
typedef struct {
    string id;
    string Name;
    vector Position;
    vector FillSize;
    float Scale;
    float TextScale;
    float Display;
    float NodeInsertLoc;
    void(string panelid, float display, string text, string icon) drawPanel;
    string() getValue;
} FO_Hud_Panel;

FO_Hud_Panel DrawPanel;
FO_Hud_Panel NewPanel;
float Editor_SelectedPanel_Index;

typedef struct {
    vector MousePos;
} FO_Hud_Settings;
FO_Hud_Settings HudSettings;

typedef struct {
    float grentype;
    float expires;
    float icon_index;
} FO_Hud_Grentimer;

FO_Hud_Grentimer FO_Hud_Grentimers[5];

enum {
    HUD_PANEL_HUDOPTIONS,
    HUD_PANEL_CLIPSIZE,
    HUD_PANEL_FRAGSTREAK,
    HUD_PANEL_CAPS,
    HUD_PANEL_GREN1,
    HUD_PANEL_GREN2,
    HUD_PANEL_PLAYERCLASS,
    HUD_PANEL_IDENTIFY,
    HUD_PANEL_FLAGINFO,
    HUD_PANEL_GRENTIMER,
    HUD_PANEL_MENU,
    HUD_PANEL_MOTD,
    HUD_PANEL_MENU_HINT,
    HUD_PANEL_GAME_MODE,
    HUD_PANEL_READY
};

#define FOCMD_AUTOHOP "fo_autohop"
#define FOCMD_GRENTIMER "fo_grentimer"
#define FOCMD_ADMIN_MENU_UPDATE_TIME "fo_adminrefresh"

float team_no;
float is_spectator;
float player_class;

vector FO_Hud_Icon_Size = [24, 24, 0];
vector FO_Hud_Icon_Font_Size = [8, 8, 0];

#pragma noref 1
#pragma warning error Q101 /*too many parms*/
#pragma warning error Q105 /*too few parms*/
#pragma warning enable F301 /*non-utf-8 strings*/
#pragma warning enable F302 /*uninitialised locals*/
#pragma target FTE
#ifndef CSQC
#define CSQC
#endif

string(string s) strtrim = #0:strtrim; /*
		Trims the whitespace from the start+end of the string. */
