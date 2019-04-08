//
//  VDObjcHandle.m
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/9.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

#import "VDObjcHandle.h"

@implementation VDObjcHandle

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

@end
