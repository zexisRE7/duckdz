#import "GameRunner.h"
#import <QuartzCore/QuartzCore.h>

// ZX_ApplyAndRun is defined in Draw.mm (via Hooks.h) — just forward-declare it
extern void ZX_ApplyAndRun();

static CADisplayLink *g_displayLink = nil;

@implementation GameRunner

+ (void)start {
    if (g_displayLink) return;
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
