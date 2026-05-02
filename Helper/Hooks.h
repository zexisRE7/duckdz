#pragma once
// MSHookFunction is provided by CydiaSubstrate (linked automatically by Theos)

// ─────────────────────────────────────────────────────────────────────────────
// Helper/Hooks.h  — OB53 offsets + feature logic
//
// Included AFTER drawfunc.h which already defines:
//   game_sdk_t, game_sdk, Transform_INTERNAL_Set/GetPosition,
//   getPosition, GetHeadPosition, CameraMain, GetRotationToTheLocation,
//   tanghinh, ProcessAimbot
//
// This file only adds:
//   • initOB53()  — overwrites game_sdk fields with real OB53 offsets
//   • Extra globals not in drawfunc.h (WorldToViewpoint, helpers)
//   • ZX_ feature booleans + feature functions
//   • BLAGCMCGEJG1 / AutoFire hooks
//   • ZX_ApplyAndRun()
// ─────────────────────────────────────────────────────────────────────────────

#include <chrono>

// ── Silent aim / wall check flags ────────────────────────────────────────────
bool SilentAim  = false;
bool CheckWall1 = false;

// ── AutoFire delay ────────────────────────────────────────────────────────────
static float FireDelay = 0.01f;

// ── ZX_ feature toggles ───────────────────────────────────────────────────────
bool  ZX_AimKill        = false;
bool  ZX_Telekill       = false;
bool  ZX_FreeFly        = false;
float ZX_FreeFlySpeed   = 8.0f;
bool  ZX_FlyAlt         = false;
float ZX_FlySpeed       = 5.0f;
bool  ZX_NoRecoil       = false;
bool  ZX_NoReload       = false;
bool  ZX_FastFire       = false;
bool  ZX_LongRange      = false;
bool  ZX_BulletThru     = false;
bool  ZX_ChainDamage    = false;
int   ZX_ChainDmgValue  = 1000;
bool  ZX_FastSwitch     = false;
bool  ZX_MarkTeleport   = false;
bool  ZX_AutoTeleport   = false;
bool  ZX_AmmoSpeedFast  = false;
bool  ZX_BlueMap        = false;
bool  ZX_GhostVip       = false;
bool  ZX_NinjaDash      = false;
bool  ZX_FlyUltira      = false;
bool  ZX_EnemiesPull    = false;
bool  ZX_UnderKill      = false;
bool  ZX_MovePlayer     = false;
bool  ZX_SpinePlayer    = false;
bool  ZX_EnemiesAir     = false;
bool  ZX_FlyMap         = false;
bool  ZX_FlySky         = false;
bool  ZX_SpeedRun       = false;
bool  ZX_SpeedTime      = false;
bool  ZX_SetMark        = false;
bool  ZX_ResetAcc       = false;

enum FireMode   { MANUL, AUTO };
enum FireStatus { FS_NONE, FS_FIRING, FS_CANCEL };

// ── HitObjectInfo ─────────────────────────────────────────────────────────────
struct HitObjectInfo {
    void    *klass, *monitor;
    bool     m_IsInPool;
    void    *HitObject, *HitCollider;
    Vector3  HitLocation, HitNormal, RayDir, StartPosition;
    int32_t  Damage;
    float    Distance;
    int32_t  ActorLayer, HitGroup;
    void    *HitPhysicMaterial;
    bool     IgnoreHappens, ViewBlocked;
    Vector3  OrigStartPosition;
    uint8_t  SpecialHitType;
    uint32_t SpecialHitLevelObjID;
};

// ── WorldToViewpoint — extra offset not guaranteed in drawfunc.h game_sdk_t ───
static Vector3 (*WorldToViewpoint_OB53)(void *, Vector3, int) = nullptr;

// ── Extra helpers not in drawfunc.h ──────────────────────────────────────────
static bool IsGod(void *p) { return *(bool*)((uint64_t)p + 0xF4C); }

static void *get_gameObject(void *t) {
    return ((void*(*)(void*))getRealOffset(0x854065C))(t);
}
static void *GetWeaponOnHand1(void *local) {
    return ((void*(*)(void*))getRealOffset(0x4A16560))(local);
}
static void *getItransform(void *t) {
    return ((void*(*)(void*))getRealOffset(0x5C52CFC))(t);
}
static float get_Range(void *w) {
    return ((float(*)(void*))getRealOffset(oxo("0x4E8703C")))(w);
}
static bool isEnemyInRangeWeapon(void *local, void *enemy, void *weapon) {
    float range = get_Range(weapon);
    return Vector3::Distance(GetHeadPosition(local), GetHeadPosition(enemy)) <= range;
}

// ── initOB53 — overwrites game_sdk fields with real OB53 offsets ──────────────
//   Call once after game_sdk->init() (which sets duckdz placeholder offsets).
static bool ob53_ready = false;
inline void initOB53() {
    if (ob53_ready) return;
    ob53_ready = true;

    game_sdk->GetHp              = (int(*)(void*))               getRealOffset(oxo("0x4A8478C"));
    game_sdk->Curent_Match       = (void*(*)())                  getRealOffset(oxo("0x4E355B0"));
    game_sdk->GetLocalPlayer     = (void*(*)(void*))             getRealOffset(oxo("0x28FC854"));
    game_sdk->GetHeadPositions   = (void*(*)(void*))             getRealOffset(oxo("0x4AA1A28"));
    game_sdk->get_position       = (Vector3(*)(void*))           getRealOffset(oxo("0x8552BAC"));
    game_sdk->Component_GetTransform=(void*(*)(void*))           getRealOffset(oxo("0x854060C"));
    game_sdk->get_camera         = (void*(*)())                  getRealOffset(oxo("0x84E7148"));
    game_sdk->get_isVisible      = (bool(*)(void*))              getRealOffset(oxo("0x4A20AF4"));
    game_sdk->get_isLocalTeam    = (bool(*)(void*))              getRealOffset(oxo("0x4A38D90"));
    game_sdk->get_IsDieing       = (bool(*)(void*))              getRealOffset(oxo("0x4A02EA8"));
    game_sdk->get_MaxHP          = (int(*)(void*))               getRealOffset(oxo("0x4A8489C"));
    game_sdk->GetForward         = (Vector3(*)(void*))           getRealOffset(oxo("0x85534CC"));
    game_sdk->set_aim            = (void(*)(void*,Quaternion))   getRealOffset(oxo("0x4A1C91C"));
    game_sdk->get_IsSighting     = (bool(*)(void*))              getRealOffset(oxo("0x4A0FF18"));
    game_sdk->get_IsFiring       = (bool(*)(void*))              getRealOffset(oxo("0x4A05634"));
    game_sdk->name               = (monoString*(*)(void*))       getRealOffset(oxo("0x4A16D38"));

    // Bone getters
    game_sdk->_GetHeadPositions  = (void*(*)(void*)) getRealOffset(oxo("0x4AA1A28"));
    game_sdk->_newHipMods        = (void*(*)(void*)) getRealOffset(oxo("0x4AA1BD8"));
    game_sdk->_GetLeftAnkleTF    = (void*(*)(void*)) getRealOffset(oxo("0x4AA2028"));
    game_sdk->_GetRightAnkleTF   = (void*(*)(void*)) getRealOffset(oxo("0x4AA2134"));
    game_sdk->_GetLeftToeTF      = (void*(*)(void*)) getRealOffset(oxo("0x4AA2240"));
    game_sdk->_GetRightToeTF     = (void*(*)(void*)) getRealOffset(oxo("0x4AA234C"));
    game_sdk->_getLeftHandTF     = (void*(*)(void*)) getRealOffset(oxo("0x4A1B9B4"));
    game_sdk->_getRightHandTF    = (void*(*)(void*)) getRealOffset(oxo("0x4A1BAB8"));
    game_sdk->_getLeftForeArmTF  = (void*(*)(void*)) getRealOffset(oxo("0x4A1BBBC"));
    game_sdk->_getRightForeArmTF = (void*(*)(void*)) getRealOffset(oxo("0x4A1BCC0"));

    // Extra OB53 offset not in drawfunc.h game_sdk_t
    WorldToViewpoint_OB53 = (Vector3(*)(void*,Vector3,int)) getRealOffset(oxo("0x84E6AC8"));
}

// ── Target finders ────────────────────────────────────────────────────────────
void *GetClosestEnemy() {
    try {
        float best = 9999.0f; void *closest = nullptr;
        void *match = game_sdk->Curent_Match(); if (!match) return nullptr;
        void *local = game_sdk->GetLocalPlayer(match); if (!local) return nullptr;
        if (!Vars.Aimbot) return nullptr;
        Dictionary<uint8_t*,void**> *players =
            *(Dictionary<uint8_t*,void**>**)((long)match + oxo("0x148"));
        if (!players) return nullptr;
        Vector3 lp = getPosition(local);
        for (int i = 0; i < players->getSize(); i++) {
            void *p = players->getValues()[i];
            if (!p || p == local) continue;
            if (!game_sdk->get_MaxHP(p))          continue;
            if (game_sdk->get_IsDieing(p))        continue;
            if (game_sdk->get_isLocalTeam(p))     continue;
            float d = Vector3::Distance(lp, getPosition(p));
            if (d < 200.0f && d < best && tanghinh::isVisible(p)) {
                best = d; closest = p;
            }
        }
        return closest;
    } catch (...) { return nullptr; }
}

void *GetClosestEnemysilent() {
    try {
        float best = 99999.0f; void *closest = nullptr;
        void *match = game_sdk->Curent_Match(); if (!match) return nullptr;
        void *local = game_sdk->GetLocalPlayer(match); if (!local) return nullptr;
        if (!Vars.Aimbot) return nullptr;
        Dictionary<uint8_t*,void**> *players =
            *(Dictionary<uint8_t*,void**>**)((long)match + 0x148);
        if (!players) return nullptr;
        Vector3 lp = getPosition(local);
        for (int i = 0; i < players->getSize(); i++) {
            void *p = players->getValues()[i];
            if (!p || p == local) continue;
            if (!game_sdk->get_MaxHP(p))             continue;
            if (game_sdk->get_IsDieing(p))           continue;
            if (game_sdk->get_isLocalTeam(p))        continue;
            if (IsGod(p))                            continue;
            if (Vars.IgnoreKnocked && game_sdk->GetHp(p) <= 0) continue;
            if (CheckWall1 && (!game_sdk->get_isVisible(p) ||
                               !tanghinh::isVisible(p)))        continue;
            float d = Vector3::Distance(lp, getPosition(p));
            if (d < best) { best = d; closest = p; }
        }
        return closest;
    } catch (...) { return nullptr; }
}

// ── Motion helpers ────────────────────────────────────────────────────────────
static void SetFlyState(void *p, bool fly, bool keepVel = false) {
    auto fn = (void(*)(void*,bool,bool))getRealOffset(oxo("0x4F486B0"));
    if (fn) fn(p, fly, keepVel);
}
static void UnLockMaxSpeed(void *p) {
    auto fn = (void(*)(void*))getRealOffset(oxo("0x4F4E708"));
    if (fn) fn(p);
}
static void ForceMovePlayer(void *p, Vector3 dir) {
    auto fn = (void(*)(void*,Vector3))getRealOffset(oxo("0x4A134BC"));
    if (fn) fn(p, dir);
}
static void SetGameTimeScale(float s) {
    auto fn = (void(*)(float))getRealOffset(oxo("0x854EC68"));
    if (fn) fn(s);
}

// ── Feature functions ─────────────────────────────────────────────────────────
void RunFlyUltira() {
    if (!ZX_FlyUltira || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    SetFlyState(l, true, false);
}
void RunFlyMap() {
    if (!ZX_FlyMap || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 cur = game_sdk->get_position(tf); cur.y += 6.0f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
    SetFlyState(l, true, false);
}
void RunFlySky() {
    if (!ZX_FlySky || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    SetFlyState(l, true, true);
    Vars.BulletPenetration = true; SilentAim = true; CheckWall1 = false;
}
void RunNinjaDash() {
    if (!ZX_NinjaDash || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 fwd = game_sdk->GetForward(tf), cur = game_sdk->get_position(tf);
    cur.x += fwd.x * 3.5f; cur.z += fwd.z * 3.5f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
}
void RunGhostVip() {
    if (!ZX_GhostVip || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    SetFlyState(l, true, true);
    Vars.BulletPenetration = true; SilentAim = true; CheckWall1 = false;
}
void RunEnemiesPull() {
    if (!ZX_EnemiesPull || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *myTF = game_sdk->Component_GetTransform(l); if (!myTF) return;
    Vector3 myPos = game_sdk->get_position(myTF);
    Dictionary<uint8_t*,void**> *players =
        *(Dictionary<uint8_t*,void**>**)((long)m + oxo("0x148"));
    if (!players) return;
    for (int i = 0; i < players->getSize(); i++) {
        void *e = players->getValues()[i];
        if (!e || e == l) continue;
        if (!game_sdk->get_MaxHP(e) || game_sdk->get_IsDieing(e)) continue;
        if (game_sdk->get_isLocalTeam(e)) continue;
        void *eTF = game_sdk->Component_GetTransform(e); if (!eTF) continue;
        Transform_INTERNAL_SetPosition(eTF, Vvector3(myPos.x+1.5f, myPos.y, myPos.z+1.5f));
    }
}
void RunUnderKill() {
    if (!ZX_UnderKill || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 cur = game_sdk->get_position(tf); cur.y -= 5.0f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
    Vars.Aimbot = true; Vars.AutoFire = true;
    SilentAim = true; CheckWall1 = false;
}
void RunMovePlayer() {
    if (!ZX_MovePlayer || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *cam = game_sdk->get_camera(); if (!cam) return;
    void *cTF = game_sdk->Component_GetTransform(cam);
    void *tf  = game_sdk->Component_GetTransform(l);
    if (!tf || !cTF) return;
    Vector3 fwd = game_sdk->GetForward(cTF);
    ForceMovePlayer(l, Vector3(fwd.x * 2.0f, 0, fwd.z * 2.0f));
}
void RunSpinePlayer() {
    if (!ZX_SpinePlayer || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 cur = game_sdk->get_position(tf); cur.y += 0.5f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
}
void RunEnemiesAir() {
    if (!ZX_EnemiesAir || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    Dictionary<uint8_t*,void**> *players =
        *(Dictionary<uint8_t*,void**>**)((long)m + oxo("0x148"));
    if (!players) return;
    for (int i = 0; i < players->getSize(); i++) {
        void *e = players->getValues()[i];
        if (!e || e == l) continue;
        if (!game_sdk->get_MaxHP(e) || game_sdk->get_IsDieing(e)) continue;
        if (game_sdk->get_isLocalTeam(e)) continue;
        void *eTF = game_sdk->Component_GetTransform(e); if (!eTF) continue;
        Vector3 ePos = game_sdk->get_position(eTF); ePos.y += 20.0f;
        Transform_INTERNAL_SetPosition(eTF, Vvector3(ePos.x, ePos.y, ePos.z));
    }
}
void RunSpeedRun() {
    if (!ZX_SpeedRun || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    UnLockMaxSpeed(l);
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 fwd = game_sdk->GetForward(tf), cur = game_sdk->get_position(tf);
    cur.x += fwd.x * 1.2f; cur.z += fwd.z * 1.2f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
}
static float g_SpeedTimeScale = 2.0f;
void RunSpeedTime() { SetGameTimeScale(ZX_SpeedTime ? g_SpeedTimeScale : 1.0f); }

void RunNinjaRun() {
    if (!Vars.NinjaRun || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 fwd = game_sdk->GetForward(tf), cur = game_sdk->get_position(tf);
    cur.x += fwd.x * 0.1f; cur.z += fwd.z * 0.1f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
}

// ── Utility ───────────────────────────────────────────────────────────────────
struct UnityColor { float r, g, b, a; };
static Vector3 g_MarkPos        = Vector3::zero();
static bool    g_HasMark        = false;
static double  g_LastAutoTPTime = 0.0;

static void Player_TeleportTo(const Vector3 &pos) {
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Transform_INTERNAL_SetPosition(tf, Vvector3(pos.x, pos.y, pos.z));
}
static void SetMarkAtCurrentPos() {
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    g_MarkPos = game_sdk->get_position(tf); g_HasMark = true;
}
static void RunMarkTeleport() { if (g_HasMark) Player_TeleportTo(g_MarkPos); }
static void RunAutoTeleport() {
    using namespace std::chrono;
    double now = duration<double>(steady_clock::now().time_since_epoch()).count();
    if (now - g_LastAutoTPTime < 0.5) return;
    g_LastAutoTPTime = now;
    void *e = GetClosestEnemy(); if (!e) return;
    Vector3 head = GetHeadPosition(e);
    Player_TeleportTo(Vector3(head.x + 1.5f, head.y - 1.0f, head.z + 1.5f));
}
static void RunAmmoSpeedFast() {
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *w = GetWeaponOnHand1(l); if (!w) return;
    static auto *fReload = (void(*)(void*,float)) getRealOffset(0x61C82F8);
    static auto *iClip   = (void(*)(void*,int))   getRealOffset(0x61C8308);
    static auto *iOnce   = (void(*)(void*,int))   getRealOffset(0x61C82E8);
    if (fReload) fReload(w, 100.0f);
    if (iClip)   iClip(w, 999);
    if (iOnce)   iOnce(w, 999);
}
static void RunBlueMap() {
    static auto *setAmb  = (void(*)(UnityColor)) getRealOffset(0x8503F7C);
    static auto *setFogC = (void(*)(UnityColor)) getRealOffset(0x85038E8);
    static auto *setFog  = (void(*)(bool))       getRealOffset(0x850363C);
    static auto *setFogD = (void(*)(float))      getRealOffset(0x85039E0);
    if (setAmb)  setAmb ({0.00f, 0.06f, 0.45f, 1.0f});
    if (setFog)  setFog (true);
    if (setFogC) setFogC({0.00f, 0.04f, 0.30f, 1.0f});
    if (setFogD) setFogD(0.10f);
}
static void DoResetAccount() {
    static auto *fn = (void(*)()) getRealOffset(0x5DFCBF8); if (fn) fn();
}

// ── BLAGCMCGEJG1 hook (Silent Aim) ───────────────────────────────────────────
int (*old_BLAGCMCGEJG1)(void*, HitObjectInfo*);
int BLAGCMCGEJG1(void *ist, HitObjectInfo *hit) {
    if (SilentAim && hit) {
        void *m = game_sdk->Curent_Match(); if (m) {
            void *l = game_sdk->GetLocalPlayer(m); if (l) {
                void *w = GetWeaponOnHand1(l);
                void *e = GetClosestEnemysilent();
                if (e && w) {
                    bool inRange = Vars.SkipWallCheck ? true
                                                      : isEnemyInRangeWeapon(l, e, w);
                    if (inRange) {
                        Vector3 ePos = GetHeadPosition(e), sPos = GetHeadPosition(l);
                        hit->HitObject         = get_gameObject(tanghinh::Player_GetHeadCollider(e));
                        hit->HitCollider       = tanghinh::Player_GetHeadCollider(e);
                        hit->HitLocation       = ePos;
                        hit->HitNormal         = ePos;
                        hit->RayDir            = Vector3::Normalized(ePos - sPos);
                        hit->StartPosition     = sPos;
                        hit->OrigStartPosition = sPos;
                        hit->HitGroup          = 1;
                        hit->SpecialHitType    = 0;
                        hit->IgnoreHappens     = false;
                        hit->ViewBlocked       = false;
                        if (Vars.ChainDamage || ZX_ChainDamage)
                            hit->Damage = ZX_ChainDmgValue;
                    }
                }
            }
        }
    }
    return old_BLAGCMCGEJG1(ist, hit);
}

// ── AutoFire hook ─────────────────────────────────────────────────────────────
void (*_AutoFire)(void*, int32_t, int32_t);
void new_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode) {
    using namespace std::chrono;
    static auto lastTime = steady_clock::now();
    static bool fireState = false;
    if (_this && Vars.AutoFire) {
        void *enemy = GetClosestEnemy();
        if (enemy && tanghinh::isVisible(enemy)) {
            double elapsed = duration<double>(steady_clock::now() - lastTime).count();
            if (elapsed >= (double)(FireDelay * 0.0001f)) {
                fireState = !fireState; lastTime = steady_clock::now();
            }
            pFireStatus = fireState ? FS_FIRING : FS_NONE;
            pFireMode   = AUTO;
        } else {
            pFireStatus = FS_NONE; fireState = false;
        }
    }
    return _AutoFire(_this, pFireStatus, pFireMode);
}
void initAutoFireHook() {
    static bool done = false; if (done) return; done = true;
    void *addr = (void*)getRealOffset(oxo("0x4A05634"));
    if (addr) MSHookFunction(addr, (void*)new_AutoFire, (void**)&_AutoFire);
}

// ── ZX_ApplyAndRun — called every frame by GameRunner ────────────────────────
void ZX_ApplyAndRun() {
    initOB53();
    // Guard: don't run ESP/feature logic until game SDK pointers are valid
    if (!game_sdk->Curent_Match || !game_sdk->GetLocalPlayer) return;

    // sync ZX_ bools → Vars fields
    Vars.AutoFire    = ZX_FastFire || Vars.AutoFire;
    FireDelay        = ZX_FastFire ? 0.0f : 0.001f;
    Vars.SkipWallCheck = !CheckWall1;
    SilentAim          = Vars.SilentAim || SilentAim;
    if (ZX_BulletThru) { SilentAim = true; CheckWall1 = false; }
    Vars.fly       = ZX_FlyAlt || Vars.fly;
    Vars.FlyAltura = ZX_FlyUltira || Vars.FlyAltura;
    Vars.flySpeed  = ZX_FlySpeed;
    Vars.Telekill  = ZX_Telekill || Vars.Telekill;
    Vars.FreeFly   = ZX_FreeFly  || Vars.FreeFly;

    // AimKill master bundle
    if (ZX_AimKill && Vars.Enable) {
        Vars.Aimbot  = true; Vars.isAimFov = true; Vars.AimWhen = 0;
        Vars.AutoFire = true; FireDelay = 0.0f;
        Vars.SkipWallCheck = true; SilentAim = true; CheckWall1 = false;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }

    // FlyAlt
    if ((ZX_FlyAlt || Vars.fly) && Vars.Enable) {
        void *m = game_sdk->Curent_Match(); if (m) {
            void *l = game_sdk->GetLocalPlayer(m); if (l) {
                void *tf = game_sdk->Component_GetTransform(l); if (tf) {
                    Vector3 cur = game_sdk->get_position(tf);
                    cur.y += ZX_FlySpeed * 0.1f;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }

    // FreeFly
    if ((ZX_FreeFly || Vars.FreeFly) && Vars.Enable) {
        void *m = game_sdk->Curent_Match(); if (m) {
            void *l = game_sdk->GetLocalPlayer(m);
            void *cam = game_sdk->get_camera();
            if (l && cam) {
                void *tf  = game_sdk->Component_GetTransform(l);
                void *cTF = game_sdk->Component_GetTransform(cam);
                if (tf && cTF) {
                    Vector3 cur = game_sdk->get_position(tf);
                    Vector3 fwd = game_sdk->GetForward(cTF);
                    float step = ZX_FreeFlySpeed * 0.1f;
                    cur.x += fwd.x * step; cur.y += fwd.y * step; cur.z += fwd.z * step;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }

    // Telekill
    if ((ZX_Telekill || Vars.Telekill) && Vars.Enable) {
        void *m = game_sdk->Curent_Match(); if (m) {
            void *l = game_sdk->GetLocalPlayer(m);
            void *e = GetClosestEnemy();
            if (l && e) {
                void *tf = game_sdk->Component_GetTransform(l); if (tf) {
                    Vector3 ePos = GetHeadPosition(e);
                    Transform_INTERNAL_SetPosition(tf,
                        Vvector3(ePos.x+1.5f, ePos.y-1.0f, ePos.z+1.5f));
                    SilentAim = true;
                }
            }
        }
    }

    if (ZX_NoRecoil && Vars.Enable) {
        Vars.Aimbot = true; Vars.isAimFov = true;
        if (Vars.AimFov < 200.0f) Vars.AimFov = 200.0f;
    }
    if (ZX_NoReload && Vars.Enable) { Vars.AutoFire = true; FireDelay = 0.0f; }

    // One-shot actions
    if (ZX_SetMark)  { SetMarkAtCurrentPos(); ZX_SetMark  = false; }
    if (ZX_ResetAcc) { DoResetAccount();       ZX_ResetAcc = false; }

    // Periodic features
    if (ZX_BlueMap       && Vars.Enable) RunBlueMap();
    if (ZX_AmmoSpeedFast && Vars.Enable) RunAmmoSpeedFast();
    if (ZX_MarkTeleport  && Vars.Enable) RunMarkTeleport();
    if (ZX_AutoTeleport  && Vars.Enable) RunAutoTeleport();

    // Floating features
    RunFlyUltira(); RunFlyMap(); RunFlySky();
    RunSpinePlayer(); RunGhostVip(); RunNinjaDash();
    RunEnemiesPull(); RunUnderKill(); RunMovePlayer();
    RunEnemiesAir(); RunSpeedRun(); RunSpeedTime();
    RunNinjaRun();

    // Aimbot + AutoFire
    if (Vars.Enable) {
        ProcessAimbot();
        initAutoFireHook();
    }
}
