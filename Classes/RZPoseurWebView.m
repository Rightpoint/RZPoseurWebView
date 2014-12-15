//
//  RZPoseurWebView.m
//  RZPoseurWebView
//
//  Created by Justin Kaufman on 11/17/14.
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


#import "RZPoseurWebView.h"
#import <WebKit/WebKit.h>
#import "RZPUIWebView.h"
#import "RZPWKWebView.h"

NSString * const RZPoseurWebViewEnableSwipeNavigationGesturesKey = @"EnableSwipeNavigationGestures";

#define RZPoseurWebViewMethodUnimplementedAssert() \
        NSAssert(NO, @"%@ not implemented. Subclasses of UTDegradingView MUST implement all interface methods.", NSStringFromSelector(_cmd))

@interface RZPoseurWebView ()

@property (strong, nonatomic, readwrite) NSURLRequest *request;

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

- (NSURLRequest *)request
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
