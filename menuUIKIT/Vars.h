// Vars.h — duckdz + Wwww-main OB53 merged
#pragma once
#include <mutex>

enum AimTarget { HEAD, HEADv2, BODY };
enum ProfileType { PROFILE_SAFE, PROFILE_BRUTAL, PROFILE_CUSTOM };

struct Vars_t {
    // ── duckdz original fields ────────────────────────────────────────────────
    bool  UseCustomTelekillDistance;
    float TelekillDistance;
    bool  ShowNinjaRunUI;
    bool  Telekillv3;
    bool  NinjaRun;
    bool  NinjaRun_Slow;
    bool  NinjaRun_Fast;
    int   NinjaRunTick;
    bool  BrutalMode;
    float BrutalTelekillDistance;
    bool  Enable;
    bool  Aimbot;
    float AimFov;
    bool  ShowAITeleKillUI;
    int   AimCheck;
    bool  PerfectAim;
    int   AimType;
    int   AimWhen;
    bool  SilentAim;
    bool  isAimFov;
    bool  Telekill;
    bool  lines;
    bool  EnableGhost;
    bool  Muni;
    bool  playertakedamage2T;
    bool  UndergroundKill2;
    bool  EnableGuestReset;
    bool  PlayerTakeDamageV10;
    bool  TeleVIP;
    bool  SkipWallCheck;
    bool  BypassEnabled;
    bool  ShowNinjaRunButton;
    bool  UndergroundKill;
    float SafeTeleportDistance;
    bool  FakeKnocked;
    bool  AITelekill;
    bool  cameraDown;
    float CrosshairRange;
    float TelekillMaxDistance;
    bool  ShowGhostButton;
    bool  UpPlayer;
    bool  ShowButtons;
    bool  ShowFlyAlturaUI;
    bool  ShowFlyNormalUI;
    bool  AimNearestEnemy;
    bool  AimInvisible;
    bool  FlyPatchUI;
    AimTarget Target;
    bool  fly;
    bool  FlyAltura;
    float flySpeed;
    float flyHeight;
    float ESPLineThickness;
    float ESPBoxThickness;
    bool  PlayerTakeDamageV7;
    float DamageCooldownTime;
    float LastDamageTime;
    bool  Foreceq;
    bool  ShowTeleVIPButton;
    bool  ForceResult;
    bool  antiCatapult;
    bool  AutoWeaponSwitch;
    int   WeaponSwitchMode;
    int   DamageMultiplier;
    bool  ShowUndergroundButton;
    bool  Box;
    bool  Anticheat;
    float fovLineColor[4];
    bool  aimkillsend;
    bool  Outline;
    bool  Name;
    bool  Health;
    bool  Distance;
    bool  fovaimglow;
    bool  Skeleton;
    bool  circlepos;
    bool  headup;
    bool  skeleton;
    bool  SpeedHack;
    bool  SpeedHackEnabled;
    int   WeaponSwapSpeedSlider;
    bool  silentrun;
    bool  OOF;
    bool  playertakedamage2;
    bool  LapTa;
    float LapTaAmount;
    bool  WeaponSwapSafe;
    int   CurrentTab;
    bool  enemycount;
    bool  TeleVIP2;
    float AimSpeed;
    int   currentProfile;
    bool  AimPrediction;
    float AimSmooth;
    bool  fastswitch2;
    bool  ewid;
    bool  ShowEn;
    bool  Aimsilent69;
    bool  ewid2;
    bool  Aimkillsend;
    bool  flyNoGravity;
    bool  invisible;
    bool  ShowSavePosButton;
    bool  ShowClearAntiuButton;
    bool  Glow;
    int   TargetPriority;
    bool  MagnetKill;
    bool  ShowMagnetKillButton;
    bool  rateoffire;

    // ── Wwww-main OB53 new fields ─────────────────────────────────────────────
    // Aimbot extended
    bool  AimbotEnable;
    int   AimMode;          // 0=closest, 1=crosshair
    int   AimHitbox;        // 0=head, 1=neck, 2=body
    int   AimManagerHitbox;
    bool  VisibleCheck;
    bool  IgnoreKnocked;
    bool  UpPlayerOne;      // lift nearest enemy slightly
    // Weapon
    bool  AutoFire;
    bool  FastFire;
    bool  LongRange;
    bool  BulletPenetration;
    bool  ChainDamage;
    int   ChainDamageValue;
    bool  NoRecoil;
    bool  NoReload;
    bool  FastSwitch;
    bool  AmmoSpeedFast;
    // Movement
    bool  FreeFly;
    float FreeFlySpeed;
    bool  FlyUltira;
    bool  FlyMap;
    bool  FlySky;
    bool  GhostVip;
    bool  NinjaDash;
    bool  MovePlayer;
    bool  SpinePlayer;
    bool  SpeedRun;
    bool  SpeedTime;
    // Enemy
    bool  EnemiesPull;
    bool  EnemiesAir;
    bool  UnderKill;
    // Map
    bool  BlueMap;
    bool  AimKill;
    // Misc
    bool  MarkTeleport;
    bool  AutoTeleport;
};

// ── Global declarations ───────────────────────────────────────────────────────
extern Vars_t Vars;
extern bool   HighFPS;
extern bool   autoFireEnabled;
extern bool   StreamMode;
extern bool   Guest2;
extern bool   SpeedHack;
