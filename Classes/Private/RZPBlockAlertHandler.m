//
//  RZPBlockAlertHandler.m
//  RZPoseurWebViewDemo
//
//  Created by Justin Kaufman on 11/20/14.
//  Copyright (c) 2014 Justin Kaufman. All rights reserved.
//

#import "RZPBlockAlertHandler.h"
#import <objc/runtime.h>

static NSString * const kRZPBlockHandlerAssociatedObjectKey = @"RZPBlockAlertHandler";

@interface RZPBlockAlertHandler () <UIAlertViewDelegate>

@property (copy, nonatomic) RZPBlockAlertCompletion completion;

@end

@implementation RZPBlockAlertHandler

+ (instancetype)handleAlertView:(UIAlertView *)alertView completion:(RZPBlockAlertCompletion)completion
{
    RZPBlockAlertHandler *handler = [[self alloc] initWithCompletion:completion];
    
    // Force the alert view to retain its handler.
    objc_setAssociatedObject(self, (__bridge const void *)(kRZPBlockHandlerAssociatedObjectKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alertView setDelegate:handler];
    
    return handler;
}

- (instancetype)initWithCompletion:(RZPBlockAlertCompletion)completion
{
    if ( (self = [super init]) )
    {
        _completion = completion;
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( self.completion ) {
        self.completion(alertView, buttonIndex);
    }
}

@end
