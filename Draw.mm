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
#import "Helper/GameRunner.h"

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

// ── ZXToggle — pill OFF / blue-circle ON toggle ───────────────────────────────
@interface ZXToggle : UIControl
@property (nonatomic, assign) BOOL on;
@end
@implementation ZXToggle
- (instancetype)initWithFrame:(CGRect)f {
    self = [super initWithFrame:f];
    if (self) {
        self.clipsToBounds = YES;
        [self addTarget:self action:@selector(_tap) forControlEvents:UIControlEventTouchUpInside];
        [self _draw];
    }
    return self;
}
- (void)setOn:(BOOL)v { _on = v; [self _draw]; }
- (void)_tap { self.on = !_on; [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (void)_draw {
    for (UIView *s in self.subviews) [s removeFromSuperview];
    CGFloat r = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f;
    self.layer.cornerRadius = r;
    if (_on) {
        self.backgroundColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
        UILabel *ck = [[UILabel alloc] initWithFrame:self.bounds];
        ck.text = @"✓";
        ck.textColor = [UIColor whiteColor];
        ck.textAlignment = NSTextAlignmentCenter;
        ck.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:ck];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.22 green:0.26 blue:0.34 alpha:1.0];
    }
}
@end

// ─────────────────────────────────────────────────────────────────────────────

@implementation ModMenuViewController {
    UIView   *floatingPanel;
    UIButton *themeToggle;
    UIButton *closeButton;
    CGFloat   panelWidth;
    CGFloat   panelHeight;
    BOOL      isDarkMode;
    NSMutableDictionary *allCheckboxes;
    UILabel  *_headerTabLabel;
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

static const CGFloat kSidebarWidth      = 72;
static const CGFloat kTabIconSize       = 44;
static const CGFloat kTabIconImageSize  = 22;
static const CGFloat kTabSpacing        = 6;
static const CGFloat kPillHeight        = 52;
static const CGFloat kPillSpacing       = 6;
static const CGFloat kContentPadding    = 10;
static const CGFloat kContentTopInset   = 8;
static const CGFloat kContentBottomInset= 10;
static const CGFloat kSeparatorPadding  = 25;

void secureCrash() { volatile char *ptr = (char*)0x1; *ptr = 0xFF; }
void switchfast(void *_this) { return; }
float fastmedkit(void *_this) { return 9.0; }

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    SetModMenuInstance(self);

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
    floatingPanel.backgroundColor = [UIColor colorWithRed:0.05 green:0.10 blue:0.16 alpha:0.97];
    floatingPanel.layer.cornerRadius = 20;
    floatingPanel.layer.masksToBounds = YES;
    [self.view addSubview:floatingPanel];

    [self startParticles];
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
    // Header row: pill tab label + action buttons
    CGFloat hY = 10;
    CGFloat hH = 44;
    CGFloat btnSz = 36;
    CGFloat rightX = panelWidth - 10;

    UIImageSymbolConfiguration *hCfg = [UIImageSymbolConfiguration
        configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];

    // ── Close button ────────────────────────────────────────────────────────
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightX -= btnSz;
    closeButton.frame = CGRectMake(rightX, hY + (hH - btnSz) / 2, btnSz, btnSz);
    closeButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.18 blue:0.26 alpha:1.0];
    closeButton.layer.cornerRadius = btnSz / 2;
    closeButton.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    [closeButton setImage:[[UIImage systemImageNamed:@"xmark" withConfiguration:hCfg]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(animateClose) forControlEvents:UIControlEventTouchUpInside];
    [floatingPanel addSubview:closeButton];
    rightX -= 8;

    // ── Moon / theme button ──────────────────────────────────────────────────
    UIButton *moonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightX -= btnSz;
    moonBtn.frame = CGRectMake(rightX, hY + (hH - btnSz) / 2, btnSz, btnSz);
    moonBtn.backgroundColor = [UIColor colorWithRed:0.12 green:0.18 blue:0.26 alpha:1.0];
    moonBtn.layer.cornerRadius = btnSz / 2;
    moonBtn.tintColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
    [moonBtn setImage:[[UIImage systemImageNamed:@"moon.fill" withConfiguration:hCfg]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [floatingPanel addSubview:moonBtn];
    rightX -= 8;

    // ── Save button ──────────────────────────────────────────────────────────
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightX -= btnSz;
    saveBtn.frame = CGRectMake(rightX, hY + (hH - btnSz) / 2, btnSz, btnSz);
    saveBtn.backgroundColor = [UIColor colorWithRed:0.12 green:0.18 blue:0.26 alpha:1.0];
    saveBtn.layer.cornerRadius = btnSz / 2;
    saveBtn.tintColor = [UIColor colorWithWhite:0.70 alpha:1.0];
    [saveBtn setImage:[[UIImage systemImageNamed:@"square.and.arrow.up" withConfiguration:hCfg]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveSettingsToFile) forControlEvents:UIControlEventTouchUpInside];
    [floatingPanel addSubview:saveBtn];
    rightX -= 8;

    // ── Tab label pill ───────────────────────────────────────────────────────
    CGFloat pillW = rightX - kSidebarWidth - 12;
    UIView *pill = [[UIView alloc] initWithFrame:CGRectMake(kSidebarWidth + 8, hY, pillW, hH)];
    pill.backgroundColor = [UIColor colorWithRed:0.12 green:0.18 blue:0.26 alpha:1.0];
    pill.layer.cornerRadius = hH / 2;
    [floatingPanel addSubview:pill];

    _headerTabLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pillW, hH)];
    _headerTabLabel.text = @"ESP";
    _headerTabLabel.textColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
    _headerTabLabel.font = [UIFont boldSystemFontOfSize:14];
    _headerTabLabel.textAlignment = NSTextAlignmentCenter;
    [pill addSubview:_headerTabLabel];

    // ── FPS label ────────────────────────────────────────────────────────────
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSidebarWidth + 8, hY + hH + 2, 80, 14)];
    self.fpsLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.fpsLabel.font = [UIFont systemFontOfSize:10];
    self.fpsLabel.text = @"FPS: 0";
    [floatingPanel addSubview:self.fpsLabel];
}

- (void)buildSidebar {
    UIView *sidebar = [[UIView alloc] initWithFrame:
        CGRectMake(0, 0, kSidebarWidth, panelHeight)];
    sidebar.backgroundColor = [UIColor colorWithRed:0.04 green:0.07 blue:0.12 alpha:1.0];
    [floatingPanel addSubview:sidebar];

    // SF Symbol names matching target screenshots
    NSArray *sfNames = @[
        @"eye.fill",                       // Tab 0: ESP / visibility
        @"scope",                          // Tab 1: Aimbot
        @"gamecontroller.fill",            // Tab 2: Misc
        @"wrench.and.screwdriver.fill",    // Tab 3: Weapons
        @"person.fill"                     // Tab 4: Profile
    ];

    self.tabButtons = [NSMutableArray array];
    CGFloat startY = 10;
    CGFloat btnSz  = kTabIconSize;

    for (int i = 0; i < (int)sfNames.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat bX = (kSidebarWidth - btnSz) / 2;
        btn.frame = CGRectMake(bX, startY + i * (btnSz + kTabSpacing), btnSz, btnSz);
        btn.tag = 1000 + i;
        btn.layer.cornerRadius = btnSz / 2;
        btn.clipsToBounds = YES;

        // SF Symbol image — tinted white (inactive) or blue (active)
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
            configurationWithPointSize:kTabIconImageSize weight:UIImageSymbolWeightMedium];
        UIImage *img = [[UIImage systemImageNamed:sfNames[i]
                        withConfiguration:cfg]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:img forState:UIControlStateNormal];

        if (i == 0) {
            btn.backgroundColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:0.20];
            btn.layer.borderColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:0.55].CGColor;
            btn.layer.borderWidth = 1.5;
            btn.tintColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
        } else {
            btn.backgroundColor = [UIColor colorWithRed:0.10 green:0.15 blue:0.22 alpha:1.0];
            btn.tintColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        }

        [btn addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sidebar addSubview:btn];
        [self.tabButtons addObject:btn];
    }
    [floatingPanel bringSubviewToFront:sidebar];
}

- (void)buildContent {
    CGFloat contentY = 64;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:
        CGRectMake(kSidebarWidth, contentY, panelWidth - kSidebarWidth, panelHeight - contentY)];
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    [floatingPanel addSubview:self.contentScrollView];

    self.contentContainer = [[UIView alloc] initWithFrame:self.contentScrollView.bounds];
    [self.contentScrollView addSubview:self.contentContainer];

    [self reloadContentForTab:MenuTabAimbot];
}

#pragma mark - Content tabs
- (void)tabTapped:(UIButton *)btn {
    NSInteger idx = btn.tag - 1000;
    self.currentTab = (MenuTab)idx;
    UIColor *blue   = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
    UIColor *dimBg  = [UIColor colorWithRed:0.10 green:0.15 blue:0.22 alpha:1.0];
    UIColor *dimTint= [UIColor colorWithWhite:0.55 alpha:1.0];
    for (UIButton *b in self.tabButtons) {
        b.backgroundColor  = dimBg;
        b.tintColor        = dimTint;
        b.layer.borderWidth = 0;
    }
    btn.backgroundColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:0.20];
    btn.tintColor       = blue;
    btn.layer.borderColor = [blue colorWithAlphaComponent:0.55].CGColor;
    btn.layer.borderWidth = 1.5;

    NSArray *names = @[@"  ESP", @"  AIMBOT", @"  MISC", @"  WEAPONS", @"  PROFILE"];
    if (idx < (NSInteger)names.count) _headerTabLabel.text = names[idx];

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

// ── Reusable row builder (ZXToggle) ──────────────────────────────────────────
- (ZXToggle *)addRow:(NSString *)label
                 val:(BOOL)on
               action:(SEL)sel
                    y:(CGFloat *)y
                width:(CGFloat)w {
    return [self addRow:label subtitle:nil val:on action:sel y:y width:w];
}
- (ZXToggle *)addRow:(NSString *)label
            subtitle:(NSString *)sub
                 val:(BOOL)on
              action:(SEL)sel
                   y:(CGFloat *)y
               width:(CGFloat)w {
    CGFloat rowH = sub ? kPillHeight + 18 : kPillHeight;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(kContentPadding, *y, w, rowH)];
    row.backgroundColor = [UIColor colorWithRed:0.10 green:0.15 blue:0.22 alpha:1.0];
    row.layer.cornerRadius = 12;
    [self.contentContainer addSubview:row];

    CGFloat togSz = 32;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, w - togSz - 28, kPillHeight)];
    lbl.text = label;
    lbl.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    lbl.font = [UIFont systemFontOfSize:15];
    [row addSubview:lbl];

    if (sub) {
        UILabel *subLbl = [[UILabel alloc] initWithFrame:
            CGRectMake(16, kPillHeight - 2, w - togSz - 28, 20)];
        subLbl.text = sub;
        subLbl.textColor = [UIColor colorWithWhite:0.42 alpha:1.0];
        subLbl.font = [UIFont systemFontOfSize:11];
        [row addSubview:subLbl];
    }

    ZXToggle *tog = [[ZXToggle alloc] initWithFrame:
        CGRectMake(w - togSz - 12, (kPillHeight - togSz) / 2, togSz, togSz)];
    tog.on = on;
    [tog addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [row addSubview:tog];

    *y += rowH + kPillSpacing;
    return tog;
}

- (UILabel *)addSectionLabel:(NSString *)text y:(CGFloat *)y width:(CGFloat)w {
    UILabel *lbl = [[UILabel alloc] initWithFrame:
        CGRectMake(kContentPadding + 4, *y, w, 22)];
    lbl.text = text;
    lbl.textColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:0.8];
    lbl.font = [UIFont boldSystemFontOfSize:11];
    [self.contentContainer addSubview:lbl];
    *y += 24;
    return lbl;
}

#pragma mark - Tab: Aim
- (void)buildAimTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"AIM" y:y width:w];
    [self addRow:@"Enable Aimbot"       val:Vars.Aimbot   action:@selector(sw_Aimbot:)     y:y width:w];
    [self addRow:@"Aimsilent"  subtitle:@"Hides aimbot from killcam and replays"
                                        val:Vars.SilentAim action:@selector(sw_Silent:)    y:y width:w];
    [self addRow:@"Aim Kill"   subtitle:@"Automatically kills enemies when aiming at them"
                                        val:ZX_AimKill    action:@selector(sw_AimKill:)    y:y width:w];
    [self addRow:@"AutoFire"            val:ZX_FastFire   action:@selector(sw_FastFire:)   y:y width:w];
    [self addRow:@"Enable Mod"          val:Vars.Enable   action:@selector(sw_Enable:)     y:y width:w];
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
    [self addSectionLabel:@"ESP" y:y width:w];
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
    [self addSectionLabel:@"MOVE / FLY" y:y width:w];
    [self addRow:@"Fly Ultira"    val:ZX_FlyUltira   action:@selector(sw_FlyUltira:)  y:y width:w];
    [self addRow:@"Fly Map"       val:ZX_FlyMap      action:@selector(sw_FlyMap:)     y:y width:w];
    [self addRow:@"Fly Sky"       val:ZX_FlySky      action:@selector(sw_FlySky:)     y:y width:w];
    [self addRow:@"Ninja Dash"    val:ZX_NinjaDash   action:@selector(sw_NinjaDash:)  y:y width:w];
    [self addRow:@"Ghost VIP"     val:ZX_GhostVip    action:@selector(sw_GhostVip:)   y:y width:w];
    [self addRow:@"Move Player"   val:ZX_MovePlayer  action:@selector(sw_MovePlayer:) y:y width:w];
    [self addRow:@"Spine Player"  val:ZX_SpinePlayer action:@selector(sw_SpinePl:)    y:y width:w];
    [self addRow:@"Speed Run"     val:ZX_SpeedRun    action:@selector(sw_SpeedRun:)   y:y width:w];
    [self addRow:@"Speed Time"    val:ZX_SpeedTime   action:@selector(sw_SpeedTime:)  y:y width:w];
    [self addSectionLabel:@"ENEMY" y:y width:w];
    [self addRow:@"Enemies Pull"  val:ZX_EnemiesPull action:@selector(sw_EnemPull:)   y:y width:w];
    [self addRow:@"Enemies Air"   val:ZX_EnemiesAir  action:@selector(sw_EnemAir:)    y:y width:w];
    [self addRow:@"Under Kill"    val:ZX_UnderKill   action:@selector(sw_UnderKill:)  y:y width:w];
    [self addSectionLabel:@"MAP" y:y width:w];
    [self addRow:@"Blue Map"      val:ZX_BlueMap     action:@selector(sw_BlueMap:)    y:y width:w];
    [self addRow:@"Mark Teleport" val:ZX_MarkTeleport action:@selector(sw_MarkTP:)   y:y width:w];
    [self addRow:@"Auto Teleport" val:ZX_AutoTeleport action:@selector(sw_AutoTP:)   y:y width:w];
}

#pragma mark - Tab: Weapons
- (void)buildWeaponsTab:(CGFloat *)y width:(CGFloat)w {
    [self addSectionLabel:@"WEAPON" y:y width:w];
    [self addRow:@"Fast Fire"      val:ZX_FastFire      action:@selector(sw_FastFire:)    y:y width:w];
    [self addRow:@"No Reload"      val:ZX_NoReload      action:@selector(sw_NoReload:)    y:y width:w];
    [self addRow:@"Ammo Speed"     val:ZX_AmmoSpeedFast action:@selector(sw_AmmoSpeed:)   y:y width:w];
    [self addRow:@"Long Range"     val:ZX_LongRange     action:@selector(sw_LongRange:)   y:y width:w];
    [self addRow:@"Fast Switch"    val:ZX_FastSwitch    action:@selector(sw_FastSwitch:)  y:y width:w];
    [self addRow:@"Rate of Fire"   val:Vars.rateoffire  action:@selector(sw_RateOfFire:)  y:y width:w];
}

#pragma mark - Tab: Profile
- (void)buildProfileTab:(CGFloat *)y width:(CGFloat)w {
    NSString *iosVer = [[UIDevice currentDevice] systemVersion];
    NSString *device = [[UIDevice currentDevice] model];
    NSString *name   = [[UIDevice currentDevice] name];
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";

    NSArray *keys = @[@"FPS", @"Time", @"Device", @"iOS", @"Name", @"Version", @"License Key"];
    NSArray *vals = @[
        [NSString stringWithFormat:@"%ld", (long)self.currentFPS],
        [fmt stringFromDate:now],
        device, iosVer, name, @"1.118.1", @"Not Available"
    ];
    NSArray *valColors = @[
        [UIColor colorWithRed:0.20 green:0.85 blue:0.40 alpha:1.0],  // FPS green
        [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0],  // Time blue
        [UIColor whiteColor], [UIColor whiteColor], [UIColor whiteColor],
        [UIColor colorWithRed:0.20 green:0.85 blue:0.40 alpha:1.0],  // Version green
        [UIColor whiteColor]
    ];

    // ── Plain text rows (no background box) — matches target screenshot ────────
    CGFloat rowH = 36;
    CGFloat keyX = 4;
    CGFloat keyW = w * 0.42f;
    CGFloat valX = keyX + keyW + 4;
    CGFloat valW = w - valX - 4;

    for (NSUInteger i = 0; i < keys.count; i++) {
        UILabel *kLbl = [[UILabel alloc] initWithFrame:CGRectMake(keyX, *y, keyW, rowH)];
        kLbl.text      = keys[i];
        kLbl.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        kLbl.font      = [UIFont systemFontOfSize:14];
        [self.contentContainer addSubview:kLbl];

        UILabel *vLbl = [[UILabel alloc] initWithFrame:CGRectMake(valX, *y, valW, rowH)];
        vLbl.text      = vals[i];
        vLbl.textColor = valColors[i];
        vLbl.font      = [UIFont boldSystemFontOfSize:14];
        [self.contentContainer addSubview:vLbl];

        *y += rowH + 2;
    }

    *y += 16;

    // ── Settings toggles ───────────────────────────────────────────────────────
    [self addSectionLabel:@"SETTINGS" y:y width:w];
    [self addRow:@"Anticheat Bypass" val:Vars.BypassEnabled action:@selector(sw_Bypass:)   y:y width:w];
    [self addRow:@"Skip Wall Check"  val:Vars.SkipWallCheck action:@selector(sw_SkipWall:) y:y width:w];

    *y += 8;

    // ── Save button (blue, full width) ─────────────────────────────────────────
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.frame = CGRectMake(0, *y, w, kPillHeight - 8);
    [save setTitle:@"Save Settings" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    save.backgroundColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
    save.layer.cornerRadius = 12;
    [save addTarget:self action:@selector(saveSettingsToFile) forControlEvents:UIControlEventTouchUpInside];
    [self.contentContainer addSubview:save];
    *y += (kPillHeight - 8) + kPillSpacing;
}

#pragma mark - Switch handlers
// Enable / core
- (void)sw_Enable:(ZXToggle*)s     { Vars.Enable = s.on; }
- (void)sw_Aimbot:(ZXToggle*)s     { Vars.Aimbot = s.on; }
- (void)sw_Silent:(ZXToggle*)s     { Vars.SilentAim = s.on; SilentAim = s.on; }
// Aim features
- (void)sw_AimKill:(ZXToggle*)s    { ZX_AimKill = s.on; }
- (void)sw_Telekill:(ZXToggle*)s   { ZX_Telekill = s.on; Vars.Telekill = s.on; }
- (void)sw_FreeFly:(ZXToggle*)s    { ZX_FreeFly = s.on; Vars.FreeFly = s.on; }
- (void)sw_FlyAlt:(ZXToggle*)s     { ZX_FlyAlt = s.on; Vars.fly = s.on; }
- (void)sw_BulletThru:(ZXToggle*)s { ZX_BulletThru = s.on; }
- (void)sw_Chain:(ZXToggle*)s      { ZX_ChainDamage = s.on; Vars.ChainDamage = s.on; }
- (void)sw_NoRecoil:(ZXToggle*)s   { ZX_NoRecoil = s.on; }
- (void)sw_LongRange:(ZXToggle*)s  { ZX_LongRange = s.on; Vars.LongRange = s.on; }
- (void)sw_NinjaRun:(ZXToggle*)s   { Vars.NinjaRun = s.on; }
// ESP
- (void)sw_Box:(ZXToggle*)s        { Vars.Box = s.on; }
- (void)sw_Name:(ZXToggle*)s       { Vars.Name = s.on; }
- (void)sw_Health:(ZXToggle*)s     { Vars.Health = s.on; }
- (void)sw_Distance:(ZXToggle*)s   { Vars.Distance = s.on; }
- (void)sw_Lines:(ZXToggle*)s      { Vars.lines = s.on; }
- (void)sw_Skel:(ZXToggle*)s       { Vars.skeleton = s.on; }
- (void)sw_Outline:(ZXToggle*)s    { Vars.Outline = s.on; }
- (void)sw_OOF:(ZXToggle*)s        { Vars.OOF = s.on; }
// Misc
- (void)sw_FlyUltira:(ZXToggle*)s  { ZX_FlyUltira = s.on; Vars.FlyAltura = s.on; }
- (void)sw_FlyMap:(ZXToggle*)s     { ZX_FlyMap = s.on; }
- (void)sw_FlySky:(ZXToggle*)s     { ZX_FlySky = s.on; }
- (void)sw_NinjaDash:(ZXToggle*)s  { ZX_NinjaDash = s.on; }
- (void)sw_GhostVip:(ZXToggle*)s   { ZX_GhostVip = s.on; Vars.EnableGhost = s.on; }
- (void)sw_MovePlayer:(ZXToggle*)s { ZX_MovePlayer = s.on; }
- (void)sw_SpinePl:(ZXToggle*)s    { ZX_SpinePlayer = s.on; }
- (void)sw_SpeedRun:(ZXToggle*)s   { ZX_SpeedRun = s.on; }
- (void)sw_SpeedTime:(ZXToggle*)s  { ZX_SpeedTime = s.on; }
- (void)sw_EnemPull:(ZXToggle*)s   { ZX_EnemiesPull = s.on; }
- (void)sw_EnemAir:(ZXToggle*)s    { ZX_EnemiesAir = s.on; }
- (void)sw_UnderKill:(ZXToggle*)s  { ZX_UnderKill = s.on; }
- (void)sw_BlueMap:(ZXToggle*)s    { ZX_BlueMap = s.on; }
- (void)sw_MarkTP:(ZXToggle*)s     { ZX_MarkTeleport = s.on; if (s.on) ZX_SetMark = true; }
- (void)sw_AutoTP:(ZXToggle*)s     { ZX_AutoTeleport = s.on; }
// Weapons
- (void)sw_FastFire:(ZXToggle*)s   { ZX_FastFire = s.on; Vars.rateoffire = s.on; }
- (void)sw_NoReload:(ZXToggle*)s   { ZX_NoReload = s.on; }
- (void)sw_AmmoSpeed:(ZXToggle*)s  { ZX_AmmoSpeedFast = s.on; }
- (void)sw_FastSwitch:(ZXToggle*)s { ZX_FastSwitch = s.on; }
- (void)sw_RateOfFire:(ZXToggle*)s { Vars.rateoffire = s.on; }
// Profile
- (void)sw_Bypass:(ZXToggle*)s     { Vars.BypassEnabled = s.on; }
- (void)sw_SkipWall:(ZXToggle*)s   { Vars.SkipWallCheck = s.on; CheckWall1 = !s.on; }
- (void)sw_ResetAcc:(ZXToggle*)s   { if (s.on) { ZX_ResetAcc = true; s.on = NO; } }

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

#pragma mark - Required protocol methods (declared in drawview.h)

// Called by drawview.h / CADisplayLink each frame — forward to game runner
- (void)updateFrame {
    self.frameCount++;
    ZX_ApplyAndRun();
}

// Theme colors used by drawfunc.h drawing helpers
- (UIColor *)accentColor {
    return [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1.0];
}
- (UIColor *)textColor {
    return [UIColor whiteColor];
}
- (UIColor *)glowColor {
    return [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:0.7];
}

#pragma mark - Particle System
- (void)startParticles {
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:0.9
                                                  target:self
                                                selector:@selector(spawnParticle)
                                                userInfo:nil
                                                 repeats:YES];
    [t fire];
    objc_setAssociatedObject(self, "ptimer", t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)spawnParticle {
    CGFloat pw = floatingPanel.bounds.size.width;
    CGFloat ph = floatingPanel.bounds.size.height;
    CGFloat fontSize = 8 + arc4random_uniform(8);   // 8–15pt
    CGFloat startX   = arc4random_uniform((uint32_t)pw);
    CGFloat startY   = arc4random_uniform((uint32_t)(ph * 0.8f));  // scatter across panel

    UILabel *flake = [[UILabel alloc] init];
    flake.text = @"*";
    flake.font = [UIFont systemFontOfSize:fontSize];
    flake.textColor = [UIColor colorWithRed:0.55 green:0.72 blue:0.96
                                      alpha:0.25 + (arc4random_uniform(30) / 100.0f)];
    [flake sizeToFit];
    flake.center = CGPointMake(startX, startY);
    [floatingPanel insertSubview:flake atIndex:0];

    CGFloat dur   = 4.0 + (arc4random_uniform(30) / 10.0);
    CGFloat driftX = ((int)(arc4random_uniform(40)) - 20);
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        flake.center = CGPointMake(startX + driftX, startY - ph * 0.35f);
        flake.alpha  = 0;
    } completion:^(BOOL f) { [flake removeFromSuperview]; }];
}

@end

// ─────────────────────────────────────────────────────────────────────────────
// %ctor — dylib entry point: initialise SDK, install hooks, show menu
// ─────────────────────────────────────────────────────────────────────────────
%ctor {
    // Guard: only run inside Free Fire
    NSString *bid = [[NSBundle mainBundle] bundleIdentifier];
    if (!bid) return;
    BOOL isFF = [bid containsString:@"freefire"] ||
                [bid containsString:@"garena"]   ||
                [bid isEqualToString:@"com.dena.a12122439"];
    if (!isFF) return;

    // 1. Initialise game SDK function pointers (OB53 offsets)
    game_sdk->init();

    // 2. Install Silent-Aim hook (BLAGCMCGEJG1)
    //    Offset: the ProcessHitObject function in the game binary
    void *blagAddr = (void *)getRealOffset(ENCRYPTOFFSET("0x4A934BC"));
    if (blagAddr)
        MSHookFunction(blagAddr, (void *)BLAGCMCGEJG1, (void **)&old_BLAGCMCGEJG1);

    // 3. Start per-frame game runner (calls ZX_ApplyAndRun every frame)
    dispatch_async(dispatch_get_main_queue(), ^{
        [GameRunner start];
    });

    // 4. Present the mod menu after a short delay (let game UI settle)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    win = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        if (!win) win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        UIViewController *root = win.rootViewController;
        while (root.presentedViewController)
            root = root.presentedViewController;

        ModMenuViewController *menu = [[ModMenuViewController alloc] init];
        menu.modalPresentationStyle = UIModalPresentationOverFullScreen;
        menu.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        [root presentViewController:menu animated:NO completion:nil];
    });
}
