#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
#import "pthread.h"
#include <array>
#import "menuUIKIT/drawview.h"
#import "menuUIKIT/touchView.h"
#import "Themes/ThemeManager.h"
#import "Themes/UIComponents.h"
#import "menuUIKIT/Vars.h"
#import <unistd.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <stdlib.h>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <fstream>
#include <algorithm>
#import "Esp/SecureMap.h"
#import "JRMemory.framework/JRHelper.h"
#include <string>
#include "JRMemory.framework/Headers/MemScan.h"
#include <map>
#include <vector>
#import <mach-o/dyld.h>
#import <mach-o/dyld_images.h>
#import <dlfcn.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#include "Helper/Vector3.h"
#import "Helper/SecurityCheck.h"
#import <substrate.h>
#include "hook/hook.h"
#include <sstream>
#include <cstring>
#include <cstdlib>
#import <sys/sysctl.h>
#include <cstdio>
#include <cstdint>
#include <cinttypes>
#include <cerrno>
#include <cctype>
#import <CommonCrypto/CommonCrypto.h>
#import "Esp/CaptainHook.h"
#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#include "font.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
#include "Helper/Obfuscate.h"
#import "menuUIKIT/drawfunc.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <unistd.h>
#include <string.h>
#import <objc/message.h>
#import <objc/runtime.h>

// ── Wwww-main game logic ──────────────────────────────────────────────────────
// Include AFTER all standard headers so types/macros are resolved
#include "Helper/Hooks.h"

#define patch_NULL(a, b) \
    vm(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))
#define patch(a, b) \
    vm_unity(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale  [UIScreen mainScreen].scale

bool Guest(void* _this)      { return true; }
bool SetHighFPS(void* _this) { return true; }

static const NSInteger kFeatureButtonBaseTag     = 88800;
static const NSInteger kGhostButtonTag           = 88801;
static const NSInteger kTeleVIPButtonTag         = 88802;
static const NSInteger kUndergroundButtonTag     = 88803;
static const NSInteger kAITelekillButtonTag      = 88804;
static const NSInteger kNinjaRunButtonTag        = 88805;
static const NSInteger kFlyAlturaButtonTag       = 88806;
static const NSInteger kFlyNormalButtonTag       = 88807;
static const NSInteger kSavePosButtonTag         = 88808;
static const NSInteger kClearAntiuButtonTag      = 88809;
static const NSInteger kMagnetKillButtonTag      = 88810;

extern int ESPLineColor;
extern int ESPBoxColor;
extern int ESPSkeletonColor;
extern int ESPNameColor;
extern int AimbotFOVColor;
extern float AimbotFOVThickness;
extern int MenuColorTheme;

bool fmedkit          = false;
bool StopGarenaLogs   = false;
bool FastSwitch       = false;
bool testGhost        = false;
bool func_ghost       = false;

typedef NS_ENUM(NSInteger, MenuTab) {
    MenuTabAimbot = 0,
    MenuTabESP,
    MenuTabMSL,
    MenuTabWeapons,
    MenuTabProfile
};

@interface ModMenuViewController () <UIGestureRecognizerDelegate>
- (void)saveSettingsToFile;
- (void)loadSettingsFromFile;
- (void)saveUIState;
- (void)loadUIState;
- (NSString *)settingsFilePath;
@property (nonatomic, strong) UIScrollView   *sidebarScrollView;
@property (nonatomic, strong) UIView         *sidebarView;
@property (nonatomic, strong) UIScrollView   *contentScrollView;
@property (nonatomic, strong) UIView         *contentContainer;
@property (nonatomic, assign) MenuTab         currentTab;
@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, strong) NSMutableDictionary *checkboxStates;
@property (nonatomic, strong) NSTimer        *fpsTimer;
@property (nonatomic, assign) NSInteger       frameCount;
@property (nonatomic, assign) CGFloat         currentFPS;
@property (nonatomic, strong) UILabel        *fpsLabel;
@property (nonatomic, strong) UILabel        *timeLabel;
@property (nonatomic, strong) UIButton       *headerButton;
@property (nonatomic, strong) UIView         *tabSelectorPopup;
@property (nonatomic, strong) UIVisualEffectView *headerBlurView;
@property (nonatomic, strong) UIColor        *currentThemeColor;
@property (nonatomic, assign) BOOL            isUpdatingUI;
@property (nonatomic, assign) BOOL            isChangingTab;
@property (nonatomic, assign) NSInteger       currentLanguage;
@end

@implementation ModMenuViewController {
    UIView   *floatingPanel;
    UIButton *themeToggle;
    UIButton *closeButton;
    CGFloat   panelWidth;
    CGFloat   panelHeight;
    BOOL      isDarkMode;
    NSMutableDictionary *allCheckboxes;
}

static ModMenuViewController *g_ModMenuInstance = nil;
void SetModMenuInstance(ModMenuViewController *inst) { g_ModMenuInstance = inst; }

UIColor* GetThemeAccentColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(accentColor)])
        return [g_ModMenuInstance accentColor];
    return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
}
UIColor* GetThemeTextColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(textColor)])
        return [g_ModMenuInstance textColor];
    return [UIColor whiteColor];
}
UIColor* GetThemeGlowColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(glowColor)])
        return [g_ModMenuInstance glowColor];
    return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.7];
}

- (id)getLicenseManager {
    Class licenseClass = NSClassFromString(@"LicenseManager");
    if (licenseClass && [licenseClass respondsToSelector:@selector(shared)])
        return [licenseClass performSelector:@selector(shared)];
    return nil;
}

static const CGFloat kSidebarWidth      = 70;
static const CGFloat kTabIconSize       = 48;
static const CGFloat kTabIconImageSize  = 28;
static const CGFloat kTabSpacing        = 8;
static const CGFloat kPillHeight        = 50;
static const CGFloat kPillSpacing       = 7;
static const CGFloat kContentPadding    = 10;
static const CGFloat kContentTopInset   = 5;
static const CGFloat kContentBottomInset= 10;
static const CGFloat kSeparatorPadding  = 25;

void secureCrash() { volatile char *ptr = (char*)0x1; *ptr = 0xFF; }
void switchfast(void *_this) { return; }
float fastmedkit(void *_this) { return 9.0; }

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    SetModMenuInstance(self);

    // ── Init game SDK (idempotent) ────────────────────────────────────────────
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ game_sdk->init(); });

    // ── Install BLAGCMCGEJG1 silent-aim hook ──────────────────────────────────
    static dispatch_once_t hookOnce;
    dispatch_once(&hookOnce, ^{
        NSString *r = StaticInlineHookPatch(
            "Frameworks/UnityFramework.framework/UnityFramework",
            0x4EB3E88, nullptr);
        if (r) {
            void *res = StaticInlineHookFunction(
                "Frameworks/UnityFramework.framework/UnityFramework",
                0x4EB3E88, (void*)BLAGCMCGEJG1);
            *(void**)(&old_BLAGCMCGEJG1) = res;
        }
    });

    [self loadSettingsFromFile];
    [self loadUIState];
    [self setupUI];
    [self setupFPSTimer];
}

#pragma mark - UI Setup
- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];

    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    panelWidth  = MIN(sw * 0.85f, 380.0f);
    panelHeight = MIN(sh * 0.80f, 620.0f);

    CGPoint savedPos = [self loadPanelPosition];

    floatingPanel = [[UIView alloc] initWithFrame:CGRectMake(
        savedPos.x, savedPos.y, panelWidth, panelHeight)];
    floatingPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:0.97];
    floatingPanel.layer.cornerRadius = 16;
    floatingPanel.layer.masksToBounds = YES;
    [self.view addSubview:floatingPanel];

    [self buildHeader];
    [self buildSidebar];
    [self buildContent];

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [floatingPanel addGestureRecognizer:pan];

    UITapGestureRecognizer *outside =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOutsideTap:)];
    outside.delegate = self;
    [self.view addGestureRecognizer:outside];

    [self animatePanelEntrance];
}

- (void)buildHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, panelWidth, 50)];
    header.backgroundColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0];
    [floatingPanel addSubview:header];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, panelWidth - 80, 50)];
    title.text = @"FFZ HACK OB53";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:15];
    [header addSubview:title];

    closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(panelWidth - 50, 5, 40, 40);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [closeButton addTarget:self action:@selector(animateClose) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeButton];

    // FPS label
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(panelWidth - 130, 0, 80, 50)];
    self.fpsLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.fpsLabel.font = [UIFont systemFontOfSize:10];
    self.fpsLabel.text = @"FPS: --";
    [header addSubview:self.fpsLabel];
}

- (void)buildSidebar {
    UIView *sidebar = [[UIView alloc] initWithFrame:
        CGRectMake(0, 50, kSidebarWidth, panelHeight - 50)];
    sidebar.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.07 alpha:1.0];
    [floatingPanel addSubview:sidebar];

    NSArray *icons = @[@"🎯", @"👁", @"⚙️", @"🔫", @"👤"];
    self.tabButtons = [NSMutableArray array];
    for (int i = 0; i < icons.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(5, i * (kTabIconSize + kTabSpacing) + 10, kSidebarWidth - 10, kTabIconSize);
        [btn setTitle:icons[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        btn.tag = 1000 + i;
        btn.layer.cornerRadius = 10;
        btn.backgroundColor = (i == 0) ?
            [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:0.5] :
            [UIColor clearColor];
        [btn addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebar addSubview:btn];
        [self.tabButtons addObject:btn];
    }
}

- (void)buildContent {
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:
        CGRectMake(kSidebarWidth, 50, panelWidth - kSidebarWidth, panelHeight - 50)];
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.contentScrollView.showsVerticalScrollIndicator = YES;
    [floatingPanel addSubview:self.contentScrollView];

    self.contentContainer = [[UIView alloc] initWithFrame:self.contentScrollView.bounds];
    [self.contentScrollView addSubview:self.contentContainer];

    [self reloadContentForTab:MenuTabAimbot];
}

#pragma mark - Content tabs
- (void)tabTapped:(UIButton *)btn {
    NSInteger idx = btn.tag - 1000;
    self.currentTab = (MenuTab)idx;
    for (UIButton *b in self.tabButtons) {
        b.backgroundColor = [UIColor clearColor];
    }
    btn.backgroundColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:0.5];
    [self reloadContentForTab:self.currentTab];
}

- (void)reloadContentForTab:(MenuTab)tab {
    for (UIView *v in self.contentContainer.subviews) [v removeFromSuperview];

    CGFloat y = kContentTopInset;
    CGFloat w = self.contentScrollView.bounds.size.width - kContentPadding * 2;

    switch (tab) {
        case MenuTabAimbot:   [self buildAimTab:&y width:w];    break;
        case MenuTabESP:      [self buildESPTab:&y width:w];    break;
        case MenuTabMSL:      [self buildMSLTab:&y width:w];    break;
        case MenuTabWeapons:  [self buildWeaponsTab:&y width:w];break;
        case MenuTabProfile:  [self buildProfileTab:&y width:w];break;
    }

    CGFloat totalH = y + kContentBottomInset;
    self.contentContainer.frame = CGRectMake(0, 0,
        self.contentScrollView.bounds.size.width, totalH);
    self.contentScrollView.contentSize = CGSizeMake(
        self.contentScrollView.bounds.size.width, totalH);
}

// ── Reusable row builder ───────────────────────────────────────────────────────
- (UISwitch *)addRow:(NSString *)label
                 val:(BOOL)on
               action:(SEL)sel
                    y:(CGFloat *)y
                width:(CGFloat)w {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(kContentPadding, *y, w, kPillHeight)];
    row.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:1.0];
    row.layer.cornerRadius = 10;
    [self.contentContainer addSubview:row];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, w - 70, kPillHeight)];
    lbl.text = label;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:13];
    [row addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:
        CGRectMake(w - 58, (kPillHeight - 31) / 2, 51, 31)];
    sw.on = on;
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];

    *y += kPillHeight + kPillSpacing;
    return sw;
}

- (UILabel *)addSectionLabel:(NSString *)text y:(CGFloat *)y width:(CGFloat)w {
    UILabel *lbl = [[UILabel alloc] initWithFrame:
        CGRectMake(kContentPadding, *y, w, 24)];
    lbl.text = text;
    lbl.textColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0];
    lbl.font = [UIFont boldSystemFontOfSize:11];
    [self.contentContainer addSubview:lbl];
    *y += 26;
    return lbl;
}

#pragma mark - Tab: Aim
- (void)buildAimTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"▸ AIM" y:y width:w];
    [self addRow:@"Enable Mod"          val:Vars.Enable   action:@selector(sw_Enable:)     y:y width:w];
    [self addRow:@"Aimbot"              val:Vars.Aimbot   action:@selector(sw_Aimbot:)     y:y width:w];
    [self addRow:@"Silent Aim"          val:Vars.SilentAim action:@selector(sw_Silent:)    y:y width:w];
    [self addRow:@"AimKill (Auto TP+)"  val:ZX_AimKill    action:@selector(sw_AimKill:)    y:y width:w];
    [self addRow:@"Telekill"            val:ZX_Telekill   action:@selector(sw_Telekill:)   y:y width:w];
    [self addRow:@"Free Fly"            val:ZX_FreeFly    action:@selector(sw_FreeFly:)    y:y width:w];
    [self addRow:@"Fly Alt"             val:ZX_FlyAlt     action:@selector(sw_FlyAlt:)     y:y width:w];
    [self addRow:@"Bullet Thru Wall"    val:ZX_BulletThru action:@selector(sw_BulletThru:) y:y width:w];
    [self addRow:@"Chain Damage"        val:ZX_ChainDamage action:@selector(sw_Chain:)     y:y width:w];
    [self addRow:@"No Recoil"           val:ZX_NoRecoil   action:@selector(sw_NoRecoil:)   y:y width:w];
    [self addRow:@"Long Range"          val:ZX_LongRange  action:@selector(sw_LongRange:)  y:y width:w];
    [self addRow:@"Ninja Run"           val:Vars.NinjaRun action:@selector(sw_NinjaRun:)   y:y width:w];
}

#pragma mark - Tab: ESP
- (void)buildESPTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"▸ ESP" y:y width:w];
    [self addRow:@"Box ESP"    val:Vars.Box      action:@selector(sw_Box:)      y:y width:w];
    [self addRow:@"Name"       val:Vars.Name     action:@selector(sw_Name:)     y:y width:w];
    [self addRow:@"Health Bar" val:Vars.Health   action:@selector(sw_Health:)   y:y width:w];
    [self addRow:@"Distance"   val:Vars.Distance action:@selector(sw_Distance:) y:y width:w];
    [self addRow:@"Lines"      val:Vars.lines    action:@selector(sw_Lines:)    y:y width:w];
    [self addRow:@"Skeleton"   val:Vars.skeleton action:@selector(sw_Skel:)     y:y width:w];
    [self addRow:@"Outline"    val:Vars.Outline  action:@selector(sw_Outline:)  y:y width:w];
    [self addRow:@"OOF Arrow"  val:Vars.OOF      action:@selector(sw_OOF:)      y:y width:w];
}

#pragma mark - Tab: Misc
- (void)buildMSLTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"▸ MOVE / FLY" y:y width:w];
    [self addRow:@"Fly Ultira"    val:ZX_FlyUltira   action:@selector(sw_FlyUltira:)  y:y width:w];
    [self addRow:@"Fly Map"       val:ZX_FlyMap      action:@selector(sw_FlyMap:)     y:y width:w];
    [self addRow:@"Fly Sky"       val:ZX_FlySky      action:@selector(sw_FlySky:)     y:y width:w];
    [self addRow:@"Ninja Dash"    val:ZX_NinjaDash   action:@selector(sw_NinjaDash:)  y:y width:w];
    [self addRow:@"Ghost VIP"     val:ZX_GhostVip    action:@selector(sw_GhostVip:)   y:y width:w];
    [self addRow:@"Move Player"   val:ZX_MovePlayer  action:@selector(sw_MovePlayer:) y:y width:w];
    [self addRow:@"Spine Player"  val:ZX_SpinePlayer action:@selector(sw_SpinePl:)    y:y width:w];
    [self addRow:@"Speed Run"     val:ZX_SpeedRun    action:@selector(sw_SpeedRun:)   y:y width:w];
    [self addRow:@"Speed Time"    val:ZX_SpeedTime   action:@selector(sw_SpeedTime:)  y:y width:w];
    [self addSectionLabel:@"▸ ENEMY" y:y width:w];
    [self addRow:@"Enemies Pull"  val:ZX_EnemiesPull action:@selector(sw_EnemPull:)   y:y width:w];
    [self addRow:@"Enemies Air"   val:ZX_EnemiesAir  action:@selector(sw_EnemAir:)    y:y width:w];
    [self addRow:@"Under Kill"    val:ZX_UnderKill   action:@selector(sw_UnderKill:)  y:y width:w];
    [self addSectionLabel:@"▸ MAP" y:y width:w];
    [self addRow:@"Blue Map"      val:ZX_BlueMap     action:@selector(sw_BlueMap:)    y:y width:w];
    [self addRow:@"Mark Teleport" val:ZX_MarkTeleport action:@selector(sw_MarkTP:)   y:y width:w];
    [self addRow:@"Auto Teleport" val:ZX_AutoTeleport action:@selector(sw_AutoTP:)   y:y width:w];
}

#pragma mark - Tab: Weapons
- (void)buildWeaponsTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"▸ WEAPON" y:y width:w];
    [self addRow:@"Fast Fire"      val:ZX_FastFire      action:@selector(sw_FastFire:)    y:y width:w];
    [self addRow:@"No Reload"      val:ZX_NoReload      action:@selector(sw_NoReload:)    y:y width:w];
    [self addRow:@"Ammo Speed"     val:ZX_AmmoSpeedFast action:@selector(sw_AmmoSpeed:)   y:y width:w];
    [self addRow:@"Long Range"     val:ZX_LongRange     action:@selector(sw_LongRange:)   y:y width:w];
    [self addRow:@"Fast Switch"    val:ZX_FastSwitch    action:@selector(sw_FastSwitch:)  y:y width:w];
    [self addRow:@"Rate of Fire"   val:Vars.rateoffire  action:@selector(sw_RateOfFire:)  y:y width:w];
}

#pragma mark - Tab: Profile
- (void)buildProfileTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"▸ SETTINGS" y:y width:w];
    [self addRow:@"Anticheat Bypass" val:Vars.BypassEnabled action:@selector(sw_Bypass:) y:y width:w];
    [self addRow:@"Skip Wall Check"  val:Vars.SkipWallCheck action:@selector(sw_SkipWall:) y:y width:w];
    [self addRow:@"Reset Guest Acc"  val:ZX_ResetAcc       action:@selector(sw_ResetAcc:) y:y width:w];
    [self addSectionLabel:@"▸ SAVE / LOAD" y:y width:w];
    UIButton *save = [UIButton buttonWithType:UIButtonTypeSystem];
    save.frame = CGRectMake(kContentPadding, *y, w, kPillHeight);
    [save setTitle:@"💾  Save Settings" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    save.backgroundColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0];
    save.layer.cornerRadius = 10;
    [save addTarget:self action:@selector(saveSettingsToFile) forControlEvents:UIControlEventTouchUpInside];
    [self.contentContainer addSubview:save];
    *y += kPillHeight + kPillSpacing;
}

#pragma mark - Switch handlers
// Enable / core
- (void)sw_Enable:(UISwitch*)s     { Vars.Enable = s.on; }
- (void)sw_Aimbot:(UISwitch*)s     { Vars.Aimbot = s.on; }
- (void)sw_Silent:(UISwitch*)s     { Vars.SilentAim = s.on; SilentAim = s.on; }
// Aim features
- (void)sw_AimKill:(UISwitch*)s    { ZX_AimKill = s.on; }
- (void)sw_Telekill:(UISwitch*)s   { ZX_Telekill = s.on; Vars.Telekill = s.on; }
- (void)sw_FreeFly:(UISwitch*)s    { ZX_FreeFly = s.on; Vars.FreeFly = s.on; }
- (void)sw_FlyAlt:(UISwitch*)s     { ZX_FlyAlt = s.on; Vars.fly = s.on; }
- (void)sw_BulletThru:(UISwitch*)s { ZX_BulletThru = s.on; }
- (void)sw_Chain:(UISwitch*)s      { ZX_ChainDamage = s.on; Vars.ChainDamage = s.on; }
- (void)sw_NoRecoil:(UISwitch*)s   { ZX_NoRecoil = s.on; }
- (void)sw_LongRange:(UISwitch*)s  { ZX_LongRange = s.on; Vars.LongRange = s.on; }
- (void)sw_NinjaRun:(UISwitch*)s   { Vars.NinjaRun = s.on; }
// ESP
- (void)sw_Box:(UISwitch*)s        { Vars.Box = s.on; }
- (void)sw_Name:(UISwitch*)s       { Vars.Name = s.on; }
- (void)sw_Health:(UISwitch*)s     { Vars.Health = s.on; }
- (void)sw_Distance:(UISwitch*)s   { Vars.Distance = s.on; }
- (void)sw_Lines:(UISwitch*)s      { Vars.lines = s.on; }
- (void)sw_Skel:(UISwitch*)s       { Vars.skeleton = s.on; }
- (void)sw_Outline:(UISwitch*)s    { Vars.Outline = s.on; }
- (void)sw_OOF:(UISwitch*)s        { Vars.OOF = s.on; }
// Misc
- (void)sw_FlyUltira:(UISwitch*)s  { ZX_FlyUltira = s.on; Vars.FlyAltura = s.on; }
- (void)sw_FlyMap:(UISwitch*)s     { ZX_FlyMap = s.on; }
- (void)sw_FlySky:(UISwitch*)s     { ZX_FlySky = s.on; }
- (void)sw_NinjaDash:(UISwitch*)s  { ZX_NinjaDash = s.on; }
- (void)sw_GhostVip:(UISwitch*)s   { ZX_GhostVip = s.on; Vars.EnableGhost = s.on; }
- (void)sw_MovePlayer:(UISwitch*)s { ZX_MovePlayer = s.on; }
- (void)sw_SpinePl:(UISwitch*)s    { ZX_SpinePlayer = s.on; }
- (void)sw_SpeedRun:(UISwitch*)s   { ZX_SpeedRun = s.on; }
- (void)sw_SpeedTime:(UISwitch*)s  { ZX_SpeedTime = s.on; }
- (void)sw_EnemPull:(UISwitch*)s   { ZX_EnemiesPull = s.on; }
- (void)sw_EnemAir:(UISwitch*)s    { ZX_EnemiesAir = s.on; }
- (void)sw_UnderKill:(UISwitch*)s  { ZX_UnderKill = s.on; }
- (void)sw_BlueMap:(UISwitch*)s    { ZX_BlueMap = s.on; }
- (void)sw_MarkTP:(UISwitch*)s     { ZX_MarkTeleport = s.on; if (s.on) ZX_SetMark = true; }
- (void)sw_AutoTP:(UISwitch*)s     { ZX_AutoTeleport = s.on; }
// Weapons
- (void)sw_FastFire:(UISwitch*)s   { ZX_FastFire = s.on; Vars.rateoffire = s.on; }
- (void)sw_NoReload:(UISwitch*)s   { ZX_NoReload = s.on; }
- (void)sw_AmmoSpeed:(UISwitch*)s  { ZX_AmmoSpeedFast = s.on; }
- (void)sw_FastSwitch:(UISwitch*)s { ZX_FastSwitch = s.on; }
- (void)sw_RateOfFire:(UISwitch*)s { Vars.rateoffire = s.on; }
// Profile
- (void)sw_Bypass:(UISwitch*)s     { Vars.BypassEnabled = s.on; }
- (void)sw_SkipWall:(UISwitch*)s   { Vars.SkipWallCheck = s.on; CheckWall1 = !s.on; }
- (void)sw_ResetAcc:(UISwitch*)s   { if (s.on) { ZX_ResetAcc = true; s.on = NO; } }

#pragma mark - FPS timer
- (void)setupFPSTimer {
    self.frameCount = 0; self.currentFPS = 0;
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(updateFPS)
                                                  userInfo:nil
                                                   repeats:YES];
}
- (void)updateFPS {
    self.currentFPS = self.frameCount;
    self.frameCount = 0;
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %ld", (long)self.currentFPS];
}

#pragma mark - Persist
- (NSString *)settingsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths firstObject] stringByAppendingPathComponent:@"ffz_settings.plist"];
}
- (void)saveSettingsToFile {
    NSDictionary *d = @{
        @"Enable"  : @(Vars.Enable),
        @"Aimbot"  : @(Vars.Aimbot),
        @"Silent"  : @(Vars.SilentAim),
        @"AimKill" : @(ZX_AimKill),
        @"Telekill": @(ZX_Telekill),
        @"FreeFly" : @(ZX_FreeFly),
        @"FlyAlt"  : @(ZX_FlyAlt),
        @"AimFov"  : @(Vars.AimFov),
        @"AimWhen" : @(Vars.AimWhen),
    };
    [d writeToFile:[self settingsFilePath] atomically:YES];
}
- (void)loadSettingsFromFile {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:[self settingsFilePath]];
    if (!d) return;
    Vars.Enable    = [d[@"Enable"]   boolValue];
    Vars.Aimbot    = [d[@"Aimbot"]   boolValue];
    Vars.SilentAim = [d[@"Silent"]   boolValue];
    ZX_AimKill     = [d[@"AimKill"]  boolValue];
    ZX_Telekill    = [d[@"Telekill"] boolValue];
    ZX_FreeFly     = [d[@"FreeFly"]  boolValue];
    ZX_FlyAlt      = [d[@"FlyAlt"]   boolValue];
    Vars.AimFov    = [d[@"AimFov"]   floatValue];
    Vars.AimWhen   = [d[@"AimWhen"]  intValue];
}
- (void)saveUIState   { /* override if needed */ }
- (void)loadUIState   { /* override if needed */ }

#pragma mark - Panel drag / dismiss
- (void)handleDrag:(UIPanGestureRecognizer *)g {
    UIView *v = g.view;
    CGPoint t = [g translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [g setTranslation:CGPointZero inView:v.superview];
    if (g.state == UIGestureRecognizerStateEnded)
        [self savePanelPosition:v.frame.origin];
}
- (void)handleOutsideTap:(UITapGestureRecognizer *)g {
    CGPoint loc = [g locationInView:self.view];
    if (!CGRectContainsPoint(floatingPanel.frame, loc)) [self animateClose];
}
- (void)hideTabSelector {}
- (void)animatePanelEntrance {
    floatingPanel.alpha = 0; floatingPanel.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7
           initialSpringVelocity:0.9 options:0 animations:^{
        floatingPanel.alpha = 1; floatingPanel.transform = CGAffineTransformIdentity;
    } completion:nil];
}
- (void)animateClose {
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9
           initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        floatingPanel.alpha = 0; floatingPanel.transform = CGAffineTransformMakeScale(0.85, 0.85);
        floatingPanel.center = CGPointMake(floatingPanel.center.x, floatingPanel.center.y + 20);
    } completion:^(BOOL f) { [self closeSelf]; }];
}
- (void)closeSelf {
    [self.fpsTimer invalidate]; self.fpsTimer = nil;
    [self saveUIState];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModMenuDidClose" object:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gr shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:floatingPanel];
}
- (void)savePanelPosition:(CGPoint)origin {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setFloat:origin.x forKey:@"ModMenuPanelX"];
    [d setFloat:origin.y forKey:@"ModMenuPanelY"];
    [d synchronize];
}
- (CGPoint)loadPanelPosition {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    CGFloat x = [d floatForKey:@"ModMenuPanelX"];
    CGFloat y = [d floatForKey:@"ModMenuPanelY"];
    return (x == 0 && y == 0) ? CGPointMake(40, 100) : CGPointMake(x, y);
}

// Missing Vars_t fields referenced elsewhere but not in Vars.h — define here:
// (Vars.BulletPenetration / Vars.LongRange / Vars.FreeFly / Vars.ChainDamage /
//  Vars.IgnoreKnocked / Vars.AimKill — these need adding to Vars.h in duckdz,
//  but we can also patch here temporarily.)
// NOTE: Those fields are referenced in Hooks.h and must exist.
// They are already in Vars_t (e.g. FlyAltura, rateoffire). Some have different
// names and are mapped in ZX_ApplyAndRun(). See FIELD_MAP below.

@end
