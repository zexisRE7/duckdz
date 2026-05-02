#pragma once
#import <UIKit/UIKit.h>

// เรียก ZX_ApplyAndRun() ทุกเฟรมผ่าน CADisplayLink
@interface GameRunner : NSObject
+ (void)start;
+ (void)stop;
@end
