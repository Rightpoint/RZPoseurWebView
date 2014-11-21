//
//  RZPBlockAlertHandler.m
//  RZPoseurWebView
//
//  Created by Justin Kaufman on 11/20/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
