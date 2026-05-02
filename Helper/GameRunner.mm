#import "GameRunner.h"
#import "Helper/Hooks.h"

extern void ZX_ApplyAndRun();
extern void game_sdk_t::init();
extern game_sdk_t *game_sdk;

static CADisplayLink *g_displayLink = nil;
static bool g_sdkInited = false;

@interface GameRunner ()
@end

@implementation GameRunner

+ (void)start {
    if (g_displayLink) return;
    if (!g_sdkInited) {
        game_sdk->init();
        g_sdkInited = true;
    }
    g_displayLink = [CADisplayLink displayLinkWithTarget:[GameRunner class]
                                                selector:@selector(tick:)];
    g_displayLink.preferredFramesPerSecond = 60;
    [g_displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                        forMode:NSRunLoopCommonModes];
}

+ (void)stop {
    [g_displayLink invalidate];
    g_displayLink = nil;
}

+ (void)tick:(CADisplayLink *)link {
    @try {
        ZX_ApplyAndRun();
    } @catch (...) {}
}

@end
