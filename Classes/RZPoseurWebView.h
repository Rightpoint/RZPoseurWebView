//
//  RZPoseurWebView.h
//
//  Created by Justin Kaufman on 11/17/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

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
