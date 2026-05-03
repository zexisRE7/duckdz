#pragma once
// menuUIKIT/drawfunc.h
// Defines: game_sdk_t, game_sdk, Vvector3, Dictionary<K,V>,
//          Transform helpers, getPosition, GetHeadPosition,
//          tanghinh, ProcessAimbot, GetRotationToTheLocation, CameraMain
//
// Included by Draw.mm BEFORE Helper/Hooks.h.
// Hooks.h calls initOB53() to overwrite game_sdk->* with real OB53 offsets.

#include <stdint.h>
#include <cmath>

// Note: Vvector3 is defined in Helper/Vector3.h
// Note: Dictionary<K,V> is defined in Helper/Monostring.h
// Both are already included in Draw.mm before this file.

// ── game_sdk_t ────────────────────────────────────────────────────────────────
class game_sdk_t {
public:
    void init();

    int          (*GetHp)(void *player)                          = nullptr;
    void        *(*Curent_Match)()                               = nullptr;
    void        *(*GetLocalPlayer)(void *Game)                   = nullptr;
    void        *(*GetHeadPositions)(void *player)               = nullptr;
    Vector3      (*get_position)(void *transform)                = nullptr;
    void        *(*Component_GetTransform)(void *player)         = nullptr;
    void        *(*get_camera)()                                 = nullptr;
    bool         (*get_isVisible)(void *player)                  = nullptr;
    bool         (*get_isLocalTeam)(void *player)                = nullptr;
    bool         (*get_IsDieing)(void *player)                   = nullptr;
    int          (*get_MaxHP)(void *player)                      = nullptr;
    Vector3      (*GetForward)(void *transform)                  = nullptr;
    void         (*set_aim)(void *, Quaternion look)             = nullptr;
    bool         (*get_IsSighting)(void *player)                 = nullptr;
    bool         (*get_IsFiring)(void *player)                   = nullptr;
    monoString  *(*name)(void *player)                           = nullptr;

    // Bone transform getters
    void        *(*_GetHeadPositions)(void *player)              = nullptr;
    void        *(*_newHipMods)(void *player)                    = nullptr;
    void        *(*_GetLeftAnkleTF)(void *player)                = nullptr;
    void        *(*_GetRightAnkleTF)(void *player)               = nullptr;
    void        *(*_GetLeftToeTF)(void *player)                  = nullptr;
    void        *(*_GetRightToeTF)(void *player)                 = nullptr;
    void        *(*_getLeftHandTF)(void *player)                 = nullptr;
    void        *(*_getRightHandTF)(void *player)                = nullptr;
    void        *(*_getLeftForeArmTF)(void *player)              = nullptr;
    void        *(*_getRightForeArmTF)(void *player)             = nullptr;
};

game_sdk_t *game_sdk = new game_sdk_t();

void game_sdk_t::init() {
    // OB53 offsets — also overridden by initOB53() in Helper/Hooks.h
    this->GetHp              = (int(*)(void*))              getRealOffset(oxo("0x4A8478C"));
    this->Curent_Match       = (void*(*)())                 getRealOffset(oxo("0x4E355B0"));
    this->GetLocalPlayer     = (void*(*)(void*))            getRealOffset(oxo("0x28FC854"));
    this->GetHeadPositions   = (void*(*)(void*))            getRealOffset(oxo("0x4AA1A28"));
    this->get_position       = (Vector3(*)(void*))          getRealOffset(oxo("0x8552BAC"));
    this->Component_GetTransform = (void*(*)(void*))        getRealOffset(oxo("0x854060C"));
    this->get_camera         = (void*(*)())                 getRealOffset(oxo("0x84E7148"));
    this->get_isVisible      = (bool(*)(void*))             getRealOffset(oxo("0x4A20AF4"));
    this->get_isLocalTeam    = (bool(*)(void*))             getRealOffset(oxo("0x4A38D90"));
    this->get_IsDieing       = (bool(*)(void*))             getRealOffset(oxo("0x4A02EA8"));
    this->get_MaxHP          = (int(*)(void*))              getRealOffset(oxo("0x4A8489C"));
    this->GetForward         = (Vector3(*)(void*))          getRealOffset(oxo("0x85534CC"));
    this->set_aim            = (void(*)(void*,Quaternion))  getRealOffset(oxo("0x4A1C91C"));
    this->get_IsSighting     = (bool(*)(void*))             getRealOffset(oxo("0x4A0FF18"));
    this->get_IsFiring       = (bool(*)(void*))             getRealOffset(oxo("0x4A05634"));
    this->name               = (monoString*(*)(void*))      getRealOffset(oxo("0x4A16D38"));

    this->_GetHeadPositions  = (void*(*)(void*)) getRealOffset(oxo("0x4AA1A28"));
    this->_newHipMods        = (void*(*)(void*)) getRealOffset(oxo("0x4AA1BD8"));
    this->_GetLeftAnkleTF    = (void*(*)(void*)) getRealOffset(oxo("0x4AA2028"));
    this->_GetRightAnkleTF   = (void*(*)(void*)) getRealOffset(oxo("0x4AA2134"));
    this->_GetLeftToeTF      = (void*(*)(void*)) getRealOffset(oxo("0x4AA2240"));
    this->_GetRightToeTF     = (void*(*)(void*)) getRealOffset(oxo("0x4AA234C"));
    this->_getLeftHandTF     = (void*(*)(void*)) getRealOffset(oxo("0x4A1B9B4"));
    this->_getRightHandTF    = (void*(*)(void*)) getRealOffset(oxo("0x4A1BAB8"));
    this->_getLeftForeArmTF  = (void*(*)(void*)) getRealOffset(oxo("0x4A1BBBC"));
    this->_getRightForeArmTF = (void*(*)(void*)) getRealOffset(oxo("0x4A1BCC0"));
}

// ── Transform helpers ─────────────────────────────────────────────────────────
static void Transform_INTERNAL_SetPosition(void *transform, Vvector3 in) {
    static auto fn = (void(*)(void*, Vvector3))getRealOffset(oxo("0x8552CE8"));
    if (fn) fn(transform, in);
}

static Vector3 Transform_INTERNAL_GetPosition(void *transform) {
    Vector3 out = Vector3::zero();
    static auto fn = (void(*)(void*, Vector3*))getRealOffset(ENCRYPTOFFSET("0x8552C10"));
    if (fn) fn(transform, &out);
    return out;
}

// ── Position helpers ──────────────────────────────────────────────────────────
static Vector3 getPosition(void *player) {
    if (!player) return Vector3::zero();
    void *tf = game_sdk->Component_GetTransform(player);
    if (!tf) return Vector3::zero();
    return game_sdk->get_position(tf);
}

static Vector3 GetBoneTransformPosition(void *player, void*(*getBone)(void*)) {
    if (!player || !getBone) return Vector3::zero();
    void *itf = getBone(player);
    if (!itf) return Vector3::zero();
    void *tf = ((void*(*)(void*))getRealOffset(0x5C52CFC))(itf);
    if (!tf) return Vector3::zero();
    return Transform_INTERNAL_GetPosition(tf);
}

static Vector3 GetHeadPosition(void *player) {
    return GetBoneTransformPosition(player, game_sdk->_GetHeadPositions);
}

// ── tanghinh — visibility / collider helpers ──────────────────────────────────
class tanghinh {
public:
    static void *Player_GetHeadCollider(void *player) {
        static auto fn = (void*(*)(void*))getRealOffset(oxo("0x4A1A9D4"));
        return (fn && player) ? fn(player) : nullptr;
    }

    static bool isVisible(void *enemy) {
        if (!enemy) return false;
        void *headCol = Player_GetHeadCollider(enemy);
        if (!headCol) return false;
        void *cam = game_sdk->get_camera();
        if (!cam) return false;
        return true; // simplified; full raycast omitted for stability
    }
};

// ── CameraMain — returns current camera transform ─────────────────────────────
static void *CameraMain() {
    return game_sdk->get_camera ? game_sdk->get_camera() : nullptr;
}

// ── GetRotationToTheLocation — quaternion from src → dst ─────────────────────
static Quaternion GetRotationToTheLocation(Vector3 src, Vector3 dst) {
    Vector3 dir = dst - src;
    float len = sqrtf(dir.x*dir.x + dir.y*dir.y + dir.z*dir.z);
    if (len < 0.001f) return Quaternion(0,0,0,1);
    dir.x /= len; dir.y /= len; dir.z /= len;
    // pitch/yaw Euler → quaternion
    float pitch = -asinf(dir.y);
    float yaw   =  atan2f(dir.x, dir.z);
    float cp = cosf(pitch * 0.5f), sp = sinf(pitch * 0.5f);
    float cy = cosf(yaw   * 0.5f), sy = sinf(yaw   * 0.5f);
    return Quaternion(sp*cy, cp*sy, -sp*sy, cp*cy);
}

// ── ProcessAimbot — called every frame from ZX_ApplyAndRun ───────────────────
static void ProcessAimbot() {
    if (!Vars.Aimbot || !Vars.Enable) return;
    void *m = game_sdk->Curent_Match();       if (!m) return;
    void *l = game_sdk->GetLocalPlayer(m);    if (!l) return;
    void *cam = CameraMain();                 if (!cam) return;

    // find closest visible enemy
    float best = 9999.0f; void *target = nullptr;
    Dictionary<uint8_t*, void**> *players =
        *(Dictionary<uint8_t*, void**>**)((long)m + 0x148);
    if (!players) return;
    Vector3 myPos = getPosition(l);
    for (int i = 0; i < players->getSize(); i++) {
        void *p = players->getValues()[i];
        if (!p || p == l) continue;
        if (!game_sdk->get_MaxHP(p))      continue;
        if (game_sdk->get_IsDieing(p))    continue;
        if (game_sdk->get_isLocalTeam(p)) continue;
        if (!tanghinh::isVisible(p))      continue;
        float d = Vector3::Distance(myPos, getPosition(p));
        if (d < best) { best = d; target = p; }
    }
    if (!target) return;

    // aim
    void *camTF = game_sdk->Component_GetTransform(cam);
    if (!camTF) return;
    Vector3 src = Transform_INTERNAL_GetPosition(camTF);
    Vector3 dst = GetHeadPosition(target);
    Quaternion rot = GetRotationToTheLocation(src, dst);
    if (game_sdk->set_aim) game_sdk->set_aim(cam, rot);
}
