//
//  UIAlertView+RZPBlockAlert.m
//  RZPoseurWebViewDemo
//
//  Created by Justin Kaufman on 11/20/14.
//  Copyright (c) 2014 Justin Kaufman. All rights reserved.
//

#import "UIAlertView+RZPBlockAlert.h"
#import <objc/runtime.h>

static NSString * const kRZPBlockAlertCompletionAssociatedObjectKey = @"RZPBlockAlertCompltion";

@interface UIAlertView () <UIAlertViewDelegate>
@end

@implementation UIAlertView (RZPBlockAlert)

- (void)rzp_showWithCompletionBlock:(RZPBlockAlertCompletion)completion
{
    // Associate the completion block with this alert.
    objc_setAssociatedObject(self, (__bridge const void *)(kRZPBlockAlertCompletionAssociatedObjectKey), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setDelegate:self];
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    RZPBlockAlertCompletion completion = objc_getAssociatedObject(self, (__bridge const void *)(kRZPBlockAlertCompletionAssociatedObjectKey));
    if ( completion ) {
        completion(alertView, buttonIndex);
    }
}

@end
