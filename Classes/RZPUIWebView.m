//
//  RZPUIWebView.m
//
//  Created by Justin Kaufman on 11/18/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPUIWebView.h"
#import "RZPoseurWebView_Private.h"

@interface RZPUIWebView () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *backingView;

@end

@implementation RZPUIWebView

@synthesize delegate = _delegate;

- (id)initWebViewHostWithDelegate:(id <RZPoseurWebViewDelegate>)delegate options:(NSDictionary *)options
{
    if ( (self = [super initWithFrame:CGRectZero]) ) {
        _delegate = delegate;
        
        _backingView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _backingView.delegate = self;

        _backingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_backingView];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_backingView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
        
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_backingView
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:0];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_backingView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1
                                                                             constant:0];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_backingView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1
                                                                            constant:0];
        
        [self addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint]];
    }
    
    return self;
}

- (NSString *)backingFramework
{
    return @"UIKit";
}

#pragma mark UIWebView pass-through

- (void)loadRequest:(NSURLRequest *)request
{
    [self.backingView loadRequest:request];
}

- (void)reload
{
    [self.backingView reload];
}

- (void)stopLoading
{
    [self.backingView stopLoading];
}

- (BOOL)canGoBack
{
    return [self.backingView canGoBack];
}

- (void)goBack
{
    [self.backingView goBack];
}

- (BOOL)canGoForward
{
    return [self.backingView canGoForward];
}

- (void)goForward
{
    [self.backingView goForward];
}

- (BOOL)isLoading
{
    return [self.backingView isLoading];
}

#pragma mark - Delegate proxying

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL respondsToSelector = NO;
    
    SEL correspondingNavigationSelector = [[self class] degradingWebViewDelegateSelectorForUIWebViewDelegateSelector:aSelector];
    if ( correspondingNavigationSelector ) {
        // If the method has a corresponding implementation in RZPoseurWebViewDelegate, check if the delegate implements the method.
        // We want UIWebView to perform its default behavior for decisions that the delegate hasn't implemented.
        respondsToSelector = [self.delegate respondsToSelector:aSelector];
    }
    else {
        // Default to super implementation
        respondsToSelector = [super respondsToSelector:aSelector];
    }
    
    return respondsToSelector;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = NO;
    
    SEL delegateSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        RZPoseurWebViewNavigationType degradedNavigationType = [[self class] degradingWebViewNavigationTypeForUIWebViewNavigationType:navigationType];
        shouldStartLoad = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:degradedNavigationType];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
    
    return shouldStartLoad;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    SEL delegateSelector = @selector(webViewDidStartLoad:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webViewDidStartLoad:self];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    SEL delegateSelector = @selector(webViewDidFinishLoad:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webViewDidFinishLoad:self];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    SEL delegateSelector = @selector(webView:didFailLoadWithError:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

#pragma mark - Utility

+ (RZPoseurWebViewNavigationType)degradingWebViewNavigationTypeForUIWebViewNavigationType:(UIWebViewNavigationType)navigationType
{
    RZPoseurWebViewNavigationType degradingWebViewNavigationType;
    switch ( navigationType ) {
        case UIWebViewNavigationTypeLinkClicked:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeLinkActivated;
            break;
        case UIWebViewNavigationTypeFormSubmitted:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeFormSubmitted;
            break;
        case UIWebViewNavigationTypeBackForward:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeBackForward;
            break;
        case UIWebViewNavigationTypeReload:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeReload;
            break;
        case UIWebViewNavigationTypeFormResubmitted:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeFormResubmitted;
            break;
        case UIWebViewNavigationTypeOther:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeOther;
            break;
    }
    
    return degradingWebViewNavigationType;
}

+ (SEL)degradingWebViewDelegateSelectorForUIWebViewDelegateSelector:(SEL)selector
{
    SEL degradedSelector = NULL;
    
    // Map UIWebViewDelegate methods to their RZPoseurWebViewDelegate equivalents.
    // An explicit NULL indicates that there no equivalent exists.
    
    if ( selector == @selector(webView:shouldStartLoadWithRequest:navigationType:) ) {
        degradedSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    }
    else if ( selector == @selector(webViewDidStartLoad:) ) {
        degradedSelector = @selector(webViewDidStartLoad:);
    }
    else if ( selector == @selector(webView:didFailLoadWithError:) ) {
        degradedSelector = @selector(webView:didFailLoadWithError:);
    }
    else if ( selector == @selector(webViewDidFinishLoad:) ) {
        degradedSelector = @selector(webViewDidFinishLoad:);
    }
    
    return degradedSelector;
}

@end
