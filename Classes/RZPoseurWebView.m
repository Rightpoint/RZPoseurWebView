//
//  RZPoseurWebView.m
//
//  Created by Justin Kaufman on 11/17/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPoseurWebView.h"
#import <WebKit/WebKit.h>
#import "RZPUIWebView.h"
#import "RZPWKWebView.h"

NSString * const RZPoseurWebViewEnableSwipeNavigationGesturesKey = @"EnableSwipeNavigationGestures";

#define RZPoseurWebViewMethodUnimplementedAssert() \
        NSAssert(NO, @"%@ not implemented. Subclasses of UTDegradingView MUST implement all interface methods.", NSStringFromSelector(_cmd))

@interface RZPoseurWebView ()

@end

@implementation RZPoseurWebView

- (id)initWithDelegate:(id<RZPoseurWebViewDelegate>)delegate options:(NSDictionary *)options
{
    Class class = nil;
    if ( [WKWebView class] ) {
        class = [RZPWKWebView class];
    }
    else {
        class = [RZPUIWebView class];
    }

    RZPoseurWebView *instance = [[class alloc] initWebViewHostWithDelegate:delegate options:options];
    
    return instance;
}

- (id)initWebViewHostWithDelegate:(id<RZPoseurWebViewDelegate>)delegate options:(NSDictionary *)options
{
    RZPoseurWebViewMethodUnimplementedAssert();
    return nil;
}

- (NSString *)backingFramework
{
    RZPoseurWebViewMethodUnimplementedAssert();
    return nil;
}

- (void)loadRequest:(NSURLRequest *)request
{
    RZPoseurWebViewMethodUnimplementedAssert();
}

- (void)reload
{
    RZPoseurWebViewMethodUnimplementedAssert();
}

- (void)stopLoading
{
    RZPoseurWebViewMethodUnimplementedAssert();
}

- (BOOL)canGoBack
{
    RZPoseurWebViewMethodUnimplementedAssert();
    return NO;
}

- (void)goBack
{
    RZPoseurWebViewMethodUnimplementedAssert();
}

- (BOOL)canGoForward
{
    RZPoseurWebViewMethodUnimplementedAssert();
    return NO;
}

- (void)goForward
{
    RZPoseurWebViewMethodUnimplementedAssert();
}

- (BOOL)isLoading
{
    RZPoseurWebViewMethodUnimplementedAssert();
    return NO;
}


@end
