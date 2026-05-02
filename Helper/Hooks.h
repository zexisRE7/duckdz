#pragma once
#import "vinhtran.hpp"
#import "loading.hxx"
#include <fstream>
#include <chrono>
#define FMT_HEADER_ONLY
#include "fmt/core.h"
#include "menuUIKIT/Vars.h"

// ── External Vars (defined in Others/Vars.mm) ────────────────────────────────
extern Vars_t Vars;

// ── Silent aim / wall check flags ────────────────────────────────────────────
bool SilentAim  = false;
bool CheckWall1 = false;

// ── AutoFire delay (seconds — 0 = every frame) ───────────────────────────────
static float FireDelay = 0.01f;

// ── ZX_ feature toggles (driven by duckdz UIKit menu) ────────────────────────
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
int   ZX_Tab            = 0;

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

// ── Game SDK ──────────────────────────────────────────────────────────────────
class game_sdk_t {
public:
    void init();
    int      (*GetHp)(void*);
    void*    (*Curent_Match)();
    void*    (*GetLocalPlayer)(void*);
    void*    (*GetHeadPositions)(void*);
    Vector3  (*get_position)(void*);
    void*    (*Component_GetTransform)(void*);
    void*    (*get_camera)();
    Vector3  (*WorldToViewpoint)(void*, Vector3, int);
    bool     (*get_isVisible)(void*);
    bool     (*get_isLocalTeam)(void*);
    bool     (*get_IsDieing)(void*);
    int      (*get_MaxHP)(void*);
    Vector3  (*GetForward)(void*);
    void     (*set_aim)(void*, Quaternion);
    bool     (*get_IsSighting)(void*);
    bool     (*get_IsFiring)(void*);
    monoString* (*name)(void*);
    // Bone transform getters
    void* (*_GetHeadPositions)(void*);
    void* (*_newHipMods)(void*);
    void* (*_GetLeftAnkleTF)(void*);
    void* (*_GetRightAnkleTF)(void*);
    void* (*_GetLeftToeTF)(void*);
    void* (*_GetRightToeTF)(void*);
    void* (*_getLeftHandTF)(void*);
    void* (*_getRightHandTF)(void*);
    void* (*_getLeftForeArmTF)(void*);
    void* (*_getRightForeArmTF)(void*);
};
game_sdk_t *game_sdk = new game_sdk_t();

void game_sdk_t::init() {
    // Wwww-main OB53 offsets
    GetHp                = (int(*)(void*))                    getRealOffset(oxo("0x4A8478C"));
    Curent_Match         = (void*(*)())                       getRealOffset(oxo("0x4E355B0"));
    GetLocalPlayer       = (void*(*)(void*))                  getRealOffset(oxo("0x28FC854"));
    GetHeadPositions     = (void*(*)(void*))                  getRealOffset(oxo("0x4AA1A28"));
    get_position         = (Vector3(*)(void*))                getRealOffset(oxo("0x8552BAC"));
    Component_GetTransform=(void*(*)(void*))                  getRealOffset(oxo("0x854060C"));
    get_camera           = (void*(*)())                       getRealOffset(oxo("0x84E7148"));
    WorldToViewpoint     = (Vector3(*)(void*,Vector3,int))    getRealOffset(oxo("0x84E6AC8"));
    get_isVisible        = (bool(*)(void*))                   getRealOffset(oxo("0x4A20AF4"));
    get_isLocalTeam      = (bool(*)(void*))                   getRealOffset(oxo("0x4A38D90"));
    get_IsDieing         = (bool(*)(void*))                   getRealOffset(oxo("0x4A02EA8"));
    get_MaxHP            = (int(*)(void*))                    getRealOffset(oxo("0x4A8489C"));
    GetForward           = (Vector3(*)(void*))                getRealOffset(oxo("0x85534CC"));
    set_aim              = (void(*)(void*,Quaternion))        getRealOffset(oxo("0x4A1C91C"));
    get_IsSighting       = (bool(*)(void*))                   getRealOffset(oxo("0x4A0FF18"));
    get_IsFiring         = (bool(*)(void*))                   getRealOffset(oxo("0x4A05634"));
    name                 = (monoString*(*)(void*))            getRealOffset(oxo("0x4A16D38"));
    // Bone getters
    _GetHeadPositions    = (void*(*)(void*))                  getRealOffset(oxo("0x4AA1A28"));
    _newHipMods          = (void*(*)(void*))                  getRealOffset(oxo("0x4AA1BD8"));
    _GetLeftAnkleTF      = (void*(*)(void*))                  getRealOffset(oxo("0x4AA2028"));
    _GetRightAnkleTF     = (void*(*)(void*))                  getRealOffset(oxo("0x4AA2134"));
    _GetLeftToeTF        = (void*(*)(void*))                  getRealOffset(oxo("0x4AA2240"));
    _GetRightToeTF       = (void*(*)(void*))                  getRealOffset(oxo("0x4AA234C"));
    _getLeftHandTF       = (void*(*)(void*))                  getRealOffset(oxo("0x4A1B9B4"));
    _getRightHandTF      = (void*(*)(void*))                  getRealOffset(oxo("0x4A1BAB8"));
    _getLeftForeArmTF    = (void*(*)(void*))                  getRealOffset(oxo("0x4A1BBBC"));
    _getRightForeArmTF   = (void*(*)(void*))                  getRealOffset(oxo("0x4A1BCC0"));
}

// ── Low-level helpers ─────────────────────────────────────────────────────────
static void Transform_INTERNAL_SetPosition(void *tf, Vvector3 in) {
    ((void(*)(void*,Vvector3))getRealOffset(oxo("0x8552CE8")))(tf, in);
}
static Vector3 Transform_INTERNAL_GetPosition(void *tf) {
    Vector3 out = Vector3::zero();
    ((void(*)(void*,Vector3*))getRealOffset(oxo("0x8552C10")))(tf, &out);
    return out;
}
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

// ── Position helpers ──────────────────────────────────────────────────────────
static Vector3 getPosition(void *p) {
    return game_sdk->get_position(game_sdk->Component_GetTransform(p));
}
static Vector3 GetHeadPosition(void *p) {
    return game_sdk->get_position(game_sdk->GetHeadPositions(p));
}
static Vector3 CameraMain(void *p) {
    return game_sdk->get_position(*(void**)((uint64_t)p + oxo("0x390")));
}
static Vector3 GetHipPosition(void *p) {
    void *hip = *(void**)((uint64_t)p + 0x648);
    return Transform_INTERNAL_GetPosition(getItransform(hip));
}
static float get_Range(void *w) {
    return ((float(*)(void*))getRealOffset(oxo("0x4E8703C")))(w);
}
static bool isEnemyInRangeWeapon(void *local, void *enemy, void *weapon) {
    float range = get_Range(weapon);
    return Vector3::Distance(GetHeadPosition(local), GetHeadPosition(enemy)) <= range;
}
static Quaternion GetRotationToTheLocation(Vector3 Target, float H, Vector3 Me) {
    Vector3 dir = (Target + Vector3(0, H, 0)) - Me;
    return Quaternion::LookRotation(dir, Vector3(0, 1, 0));
}

// ── Visibility ────────────────────────────────────────────────────────────────
class tanghinh {
public:
    static Vector3 Transform_GetPosition(void *p) {
        Vector3 out = Vector3::zero();
        ((void(*)(void*,Vector3*))getRealOffset(oxo("0x8552C10")))(p, &out);
        return out;
    }
    static void *Player_GetHeadCollider(void *p) {
        return ((void*(*)(void*))getRealOffset(oxo("0x4A1A9D4")))(p);
    }
    static bool Physics_Raycast(Vector3 cam, Vector3 head, unsigned int L, void *col) {
        return ((bool(*)(Vector3,Vector3,unsigned int,void*))
                getRealOffset(oxo("0x5580870")))(cam, head, L, col);
    }
    static bool isVisible(void *enemy) {
        if (!enemy) return false;
        void *hitObj = nullptr;
        auto cam    = Transform_GetPosition(
            game_sdk->Component_GetTransform(game_sdk->get_camera()));
        auto target = Transform_GetPosition(
            game_sdk->Component_GetTransform(Player_GetHeadCollider(enemy)));
        return !Physics_Raycast(cam, target, 12, &hitObj);
    }
};

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

// ── Aimbot ────────────────────────────────────────────────────────────────────
void ProcessAimbot() {
    if (!Vars.Aimbot) return;
    void *match = game_sdk->Curent_Match(); if (!match) return;
    void *local = game_sdk->GetLocalPlayer(match); if (!local) return;
    void *enemy = GetClosestEnemy();  if (!enemy) return;
    Vector3 ePos = GetHeadPosition(enemy);
    Vector3 pPos = CameraMain(local);
    bool firing   = game_sdk->get_IsFiring(local);
    bool sighting = game_sdk->get_IsSighting(local);
    bool shouldAim =
        (Vars.AimWhen == 0) ||
        (Vars.AimWhen == 1 && firing) ||
        (Vars.AimWhen == 2 && sighting) ||
        (Vars.AimWhen == 3 && (firing || sighting));
    if (shouldAim && (!Vars.SkipWallCheck || tanghinh::isVisible(enemy)))
        game_sdk->set_aim(local, GetRotationToTheLocation(ePos, 0.05f, pPos));
}

// ── Motion feature helpers ────────────────────────────────────────────────────
static void SetFlyState(void *p, bool fly, bool keepVel = false) {
    ((void(*)(void*,bool,bool))getRealOffset(oxo("0x4F486B0")))(p, fly, keepVel);
}
static void UnLockMaxSpeed(void *p) {
    ((void(*)(void*))getRealOffset(oxo("0x4F4E708")))(p);
}
static void ForceMovePlayer(void *p, Vector3 dir) {
    ((void(*)(void*,Vector3))getRealOffset(oxo("0x4A134BC")))(p, dir);
}
static void SetGameTimeScale(float s) {
    ((void(*)(float))getRealOffset(oxo("0x854EC68")))(s);
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
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
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
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
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
        if (!game_sdk->get_MaxHP(e))      continue;
        if (game_sdk->get_IsDieing(e))    continue;
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
        if (!game_sdk->get_MaxHP(e))      continue;
        if (game_sdk->get_IsDieing(e))    continue;
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
void RunSpeedTime() {
    SetGameTimeScale(ZX_SpeedTime ? g_SpeedTimeScale : 1.0f);
}

void RunNinjaRun() {
    if (!Vars.NinjaRun || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match(); if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m); if (!l) return;
    void *tf = game_sdk->Component_GetTransform(l); if (!tf) return;
    Vector3 fwd = game_sdk->GetForward(tf), cur = game_sdk->get_position(tf);
    cur.x += fwd.x * 0.1f; cur.z += fwd.z * 0.1f;
    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
}

// ── Utility: Mark / AutoTP / Ammo / BlueMap / Reset ──────────────────────────
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
static void RunMarkTeleport()  { if (g_HasMark) Player_TeleportTo(g_MarkPos); }
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

// ── Hooks ─────────────────────────────────────────────────────────────────────
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
                        hit->HitObject        = get_gameObject(tanghinh::Player_GetHeadCollider(e));
                        hit->HitCollider      = tanghinh::Player_GetHeadCollider(e);
                        hit->HitLocation      = ePos;
                        hit->HitNormal        = ePos;
                        hit->RayDir           = Vector3::Normalized(ePos - sPos);
                        hit->StartPosition    = sPos;
                        hit->OrigStartPosition= sPos;
                        hit->HitGroup         = 1;
                        hit->SpecialHitType   = 0;
                        hit->IgnoreHappens    = false;
                        hit->ViewBlocked      = false;
                        // Chain Damage → Vars.DamageMultiplier (int field in duckdz Vars_t)
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
void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode) {
    using namespace std::chrono;
    static auto lastTime = steady_clock::now();
    static bool fireState = false;
    if (_this && Vars.AutoFire) {
        void *enemy = GetClosestEnemy();
        if (enemy && tanghinh::isVisible(enemy)) {
            double elapsed = duration<double>(steady_clock::now() - lastTime).count();
            float halfDelay = FireDelay * 0.0001f;
            if (elapsed >= halfDelay) { fireState = !fireState; lastTime = steady_clock::now(); }
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
    MSHookFunction((void*)getRealOffset(oxo("0x4A05634")),
                   (void*)old_AutoFire, (void**)&_AutoFire);
}

// ── ZX_ApplyAndRun — called every frame ──────────────────────────────────────
void ZX_ApplyAndRun() {
    // --- sync ZX_ bools → Vars fields (duckdz Vars_t field names) ---
    Vars.isAimFov      = (Vars.AimFov > 0);
    Vars.AutoFire    = ZX_FastFire || Vars.AutoFire;
    FireDelay          = ZX_FastFire ? 0.0f : 0.001f;
    Vars.SkipWallCheck = !CheckWall1;
    SilentAim          = Vars.SilentAim || SilentAim;

    if (ZX_BulletThru) { SilentAim = true; CheckWall1 = false; }

    // Fly (Vars.fly = ZX_FlyAlt)
    Vars.fly    = ZX_FlyAlt || Vars.fly;
    Vars.FlyAltura = ZX_FlyUltira || Vars.FlyAltura;
    Vars.flySpeed  = ZX_FlySpeed;

    // Telekill
    Vars.Telekill = ZX_Telekill || Vars.Telekill;
    Vars.FreeFly  = ZX_FreeFly  || Vars.FreeFly;

    // AimKill master bundle
    if (ZX_AimKill && Vars.Enable) {
        Vars.Aimbot       = true;
        Vars.isAimFov     = true;
        Vars.AimWhen      = 0;
        Vars.AutoFire   = true;
        FireDelay         = 0.0f;
        Vars.SkipWallCheck= true;
        SilentAim         = true;
        CheckWall1        = false;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }

    // FlyAlt — push local up each frame
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

    // FreeFly — move in camera direction
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
                    cur.x += fwd.x * step;
                    cur.y += fwd.y * step;
                    cur.z += fwd.z * step;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }

    // Telekill — tp to closest enemy
    if ((ZX_Telekill || Vars.Telekill) && Vars.Enable) {
        void *m = game_sdk->Curent_Match(); if (m) {
            void *l = game_sdk->GetLocalPlayer(m);
            void *e = GetClosestEnemy();
            if (l && e) {
                void *tf = game_sdk->Component_GetTransform(l); if (tf) {
                    Vector3 ePos = GetHeadPosition(e);
                    Transform_INTERNAL_SetPosition(tf,
                        Vvector3(ePos.x + 1.5f, ePos.y - 1.0f, ePos.z + 1.5f));
                    SilentAim = true;
                }
            }
        }
    }

    // NoRecoil
    if (ZX_NoRecoil && Vars.Enable) {
        Vars.Aimbot = true; Vars.isAimFov = true;
        if (Vars.AimFov < 200.0f) Vars.AimFov = 200.0f;
    }
    // NoReload
    if (ZX_NoReload && Vars.Enable) { Vars.AutoFire = true; FireDelay = 0.0f; }

    // One-shot actions
    if (ZX_SetMark)  { SetMarkAtCurrentPos(); ZX_SetMark  = false; }
    if (ZX_ResetAcc) { DoResetAccount();       ZX_ResetAcc = false; }

    // Periodic feature calls
    if (ZX_BlueMap       && Vars.Enable) RunBlueMap();
    if (ZX_AmmoSpeedFast && Vars.Enable) RunAmmoSpeedFast();
    if (ZX_MarkTeleport  && Vars.Enable) RunMarkTeleport();
    if (ZX_AutoTeleport  && Vars.Enable) RunAutoTeleport();

    // Floating features
    RunFlyUltira();
    RunFlyMap();
    RunFlySky();
    RunSpinePlayer();
    RunGhostVip();
    RunNinjaDash();
    RunEnemiesPull();
    RunUnderKill();
    RunMovePlayer();
    RunEnemiesAir();
    RunSpeedRun();
    RunSpeedTime();
    RunNinjaRun();

    // Aimbot + AutoFire hook init
    if (Vars.Enable) {
        ProcessAimbot();
        initAutoFireHook();
    }
}
