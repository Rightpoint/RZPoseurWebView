//
//  RZPUIWebView.m
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


#import "RZPUIWebView.h"
#import "RZPoseurWebView_Private.h"

@interface RZPUIWebView () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *backingView;

@end

@implementation RZPUIWebView

@synthesize delegate = _delegate;
@synthesize request = _request;

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
        
        // Setting properties to mimic default WKWebView behavior
        _backingView.dataDetectorTypes = UIDataDetectorTypeAll;
        _backingView.scalesPageToFit = YES;
    }
    
    return self;
}

- (NSString *)backingFramework
{
    return @"UIKit";
}

#pragma mark Getters/Setters

- (NSURLRequest *)request
{
    return self.backingView.request ? self.backingView.request : _request;
}

#pragma mark UIWebView pass-through

- (void)loadRequest:(NSURLRequest *)request
{
    _request = request;
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
