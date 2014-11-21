//
//  RZPoseurWebView.h
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

#import <UIKit/UIKit.h>

@class RZPoseurWebView;

// Optional functionality, enabled via the options dictionary passed on init.
// Features are only enabled if the resolved backing framework supports the
// requested functionality. It it does not, the options key is ignored.

// Pass YES to enable back/forward navigation edge swipe gestures.
extern NSString * const RZPoseurWebViewEnableSwipeNavigationGesturesKey;

// Navigation types. These match both UIWebView and WKWebView.
typedef NS_ENUM(NSUInteger, RZPoseurWebViewNavigationType) {
    RZPoseurWebViewNavigationTypeLinkActivated = 0,
    RZPoseurWebViewNavigationTypeFormSubmitted,
    RZPoseurWebViewNavigationTypeBackForward,
    RZPoseurWebViewNavigationTypeReload,
    RZPoseurWebViewNavigationTypeFormResubmitted,
    RZPoseurWebViewNavigationTypeOther = -1
};

@protocol RZPoseurWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(RZPoseurWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(RZPoseurWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(RZPoseurWebView *)webView;
- (void)webViewDidFinishLoad:(RZPoseurWebView *)webView;
- (void)webView:(RZPoseurWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface RZPoseurWebView : UIView

@property (assign, nonatomic) id<RZPoseurWebViewDelegate> delegate;

- (id)initWithDelegate:(id<RZPoseurWebViewDelegate>)delegate options:(NSDictionary *)options;

- (NSString *)backingFramework;

- (void)loadRequest:(NSURLRequest *)request;

- (void)reload;
- (void)stopLoading;

- (BOOL)canGoBack;
- (void)goBack;

- (BOOL)canGoForward;
- (void)goForward;

- (BOOL)isLoading;

@end
