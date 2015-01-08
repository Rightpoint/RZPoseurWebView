//
//  RZPWKWebView.m
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


#import "RZPWKWebView.h"
#import "RZPoseurWebView_Private.h"
#import <WebKit/WebKit.h>
#import "UIAlertView+RZPBlockAlert.h"
#import "WKProcessPool+RZExtensions.h"

#define RZP_NSVALUE_WITH_SELECTOR(selector) [NSValue valueWithPointer:selector]

#define RZP_ALERT_VIEW_CANCEL_BUTTON_TITLE  NSLocalizedString(@"Cancel", nil)
#define RZP_ALERT_VIEW_OK_BUTTON_TITLE      NSLocalizedString(@"OK", nil)

typedef NS_ENUM(NSUInteger, RZPWKWebViewOpenNewWindowBehavior) {
    RZPWKWebViewOpenNewWindowDefaultBehavior = 0,
    RZPWKWebViewOpenNewWindowInCurrentFrameBehavior,
    RZPWKWebViewOpenNewWindowInDefaultBrowserBehavior
};

@interface RZPWKWebView () <WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebView *backingView;
@property (assign, nonatomic) RZPWKWebViewOpenNewWindowBehavior newWindowBehavior;

@end

@implementation RZPWKWebView

@synthesize delegate = _delegate;
@synthesize request = _request;

- (id)initWebViewHostWithDelegate:(id <RZPoseurWebViewDelegate>)delegate options:(NSDictionary *)options
{
    return [self initWebViewHostWithDelegate:delegate configuration:nil options:options];
}

- (id)initWebViewHostWithDelegate:(id <RZPoseurWebViewDelegate>)delegate configuration:(WKWebViewConfiguration *)configuration options:(NSDictionary *)options
{
    if ( (self = [super initWithFrame:CGRectZero]) ) {
        _delegate = delegate;
        
        [self initializeBackingViewWithConfiguration:configuration];
        
        // Align WKWebview behavior with UIWebView. Here, open new windows in-place.
        _newWindowBehavior = RZPWKWebViewOpenNewWindowInCurrentFrameBehavior;
        
        // Unpack options specific to the backing view class.
        NSNumber *enableSwipeGesturesValue = [options objectForKey:RZPoseurWebViewEnableSwipeNavigationGesturesKey];
        if ( enableSwipeGesturesValue ) {
            BOOL enableSwipeGestures = [enableSwipeGesturesValue boolValue];
            _backingView.allowsBackForwardNavigationGestures = enableSwipeGestures;
        }
        
        // Finally, assign the delegates. Options and default settings must be
        // resolved before assigning delegates to _backingView, as these values
        // affect which delegate methods are considered "implemented."
        _backingView.navigationDelegate = self;
        _backingView.UIDelegate = self;
        
        // Position the backing web view.
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

- (void)initializeBackingViewWithConfiguration:(WKWebViewConfiguration*)configuration
{
    if ( !configuration ) {
        configuration = [[WKWebViewConfiguration alloc] init];
    }
    
    NSAssert([WKProcessPool rz_sharedProcessPool] != nil, @"Shared process pool not initialized.");
    configuration.processPool = [WKProcessPool rz_sharedProcessPool];
    
    [configuration.userContentController addUserScript:[self cookieInjectionScript]];

    _backingView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
}

- (WKUserScript *)cookieInjectionScript
{
    // Add cookies from shared cookie storage via javascript injection. Since we have no way of knowing what cookies are being stored
    // in the WKProcessPool, we are not adding the cookies to the page if they already exist.
    NSString *cookieScriptString = @"";
    for ( NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] ) {
        if ( cookie.name && cookie.value ) {
            NSString *tempScriptHolder = [NSString stringWithFormat:@"if ( document.cookie.split('%@').length < 2 ) { document.cookie = '", cookie.name];
            tempScriptHolder = [tempScriptHolder stringByAppendingString:[NSString stringWithFormat:@"%@=%@;",cookie.name,cookie.value]];
            if ( cookie.expiresDate ) {
                tempScriptHolder = [tempScriptHolder stringByAppendingString:[NSString stringWithFormat:@"expires=%@;", [cookie.expiresDate description]]];
            }
            if ( cookie.path ) {
                tempScriptHolder = [tempScriptHolder stringByAppendingString:[NSString stringWithFormat:@"path=%@;", cookie.path]];
            }
            if ( cookie.domain ) {
                tempScriptHolder = [tempScriptHolder stringByAppendingString:[NSString stringWithFormat:@"domain=%@;", cookie.domain]];
            }
            if ( cookie.isSecure ) {
                tempScriptHolder = [tempScriptHolder stringByAppendingString:[NSString stringWithFormat:@"secure;"]];
            }
            cookieScriptString  = [[cookieScriptString stringByAppendingString:tempScriptHolder] stringByAppendingString:@"'; }\n"];
        }
    }
    
    return [[WKUserScript alloc] initWithSource:cookieScriptString
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                               forMainFrameOnly:NO];
}

- (NSString *)backingFramework
{
    return @"WebKit";
}

#pragma mark Getters/Setters

- (NSURLRequest *)request
{
    // Mimicking UIWebView behavior.
    if ( ![_request.URL isEqual:self.backingView.URL] ) {
        _request = [_request mutableCopy];
        [(NSMutableURLRequest*)_request setURL:self.backingView.URL];
        [(NSMutableURLRequest*)_request setMainDocumentURL:self.backingView.URL];
        _request = [_request copy];
    }
    return _request;
}

- (UIScrollView *)scrollView
{
    if ( self.backingView )
    {
        return self.backingView.scrollView;
    }
    else
    {
        return nil;
    }
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

// Methods explicitly implemented by this class. Support for all other methods
// is inferred from the superclass and delegate.
- (NSArray *)implementedSelectors
{
    static NSArray *_implementedSelectors = nil;
    if ( _implementedSelectors == nil ) {
        _implementedSelectors = @[
                                    RZP_NSVALUE_WITH_SELECTOR(@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)),
                                    RZP_NSVALUE_WITH_SELECTOR(@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)),
                                    RZP_NSVALUE_WITH_SELECTOR(@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:))
                                  ];
    }
    
    return _implementedSelectors;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL respondsToSelector = NO;
    
    // If the method has a corresponding implementation in RZPoseurWebViewDelegate, check if the delegate implements the method.
    // We want WKWebView to perform its default behavior for decisions that the delegate hasn't implemented.
    SEL correspondingNavigationSelector = [[self class] degradingWebViewDelegateSelectorForWKNavigationDelegateSelector:aSelector];
    if ( correspondingNavigationSelector ) {
        respondsToSelector = [self.delegate respondsToSelector:correspondingNavigationSelector];
    }
    // If the method is explicitly declared as implemented by this class, return YES.
    else if ( [[self implementedSelectors] containsObject:RZP_NSVALUE_WITH_SELECTOR(aSelector)] ) {
        respondsToSelector = YES;
    }
    // For this one WKUIDelegate method, we want WKWebview to perform its default behavior unless an override was requested.
    else if ( aSelector == @selector(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:) ) {
        respondsToSelector = ( self.newWindowBehavior != RZPWKWebViewOpenNewWindowDefaultBehavior );
    }
    // Default to super implementation
    else {
        respondsToSelector = [RZPoseurWebView instancesRespondToSelector:aSelector];
    }
    
    return respondsToSelector;
}

#pragma mark WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if ( !navigationAction.targetFrame.isMainFrame ) {
        switch ( self.newWindowBehavior ) {
            case RZPWKWebViewOpenNewWindowDefaultBehavior: {
                // Default UIWebView behavior is to cancel the navigation. We shouldn't reach here.
                NSAssert(NO, @"WKWebView delegate method (%@) was called, but should not have been. This is an error.", NSStringFromSelector(_cmd));
                break;
            }
            case RZPWKWebViewOpenNewWindowInCurrentFrameBehavior: {
                // Post the request back to the webView, without the new window designation.
                [webView loadRequest:navigationAction.request];
                break;
            }
            case RZPWKWebViewOpenNewWindowInDefaultBrowserBehavior: {
                // Post the request to the application (and, thus, the system web browser).
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
                break;
            }
        }
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:RZP_ALERT_VIEW_OK_BUTTON_TITLE, nil];
    [alertView rzp_showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if ( completionHandler ) {
            completionHandler();
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:RZP_ALERT_VIEW_CANCEL_BUTTON_TITLE otherButtonTitles:RZP_ALERT_VIEW_OK_BUTTON_TITLE, nil];
    [alertView rzp_showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if ( completionHandler ) {
            BOOL selectedOKButton = (buttonIndex == [alertView firstOtherButtonIndex]);
            completionHandler(selectedOKButton);
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:RZP_ALERT_VIEW_CANCEL_BUTTON_TITLE otherButtonTitles:RZP_ALERT_VIEW_OK_BUTTON_TITLE, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *alertViewTextField = [alertView textFieldAtIndex:0];
    alertViewTextField.text = defaultText;
    
    [alertView rzp_showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if ( completionHandler ) {
            BOOL selectedOKButton = (buttonIndex == [alertView firstOtherButtonIndex]);
            NSString *inputString = selectedOKButton ? alertViewTextField.text : nil;
            completionHandler(inputString);
        }
    }];
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    SEL delegateSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        RZPoseurWebViewNavigationType navigationType = [[self class] degradingWebViewNavigationTypeForWKWebViewNavigationType:navigationAction.navigationType];
        NSURLRequest *request = navigationAction.request;
        BOOL shouldStart = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
        WKNavigationActionPolicy policy = shouldStart ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel;

        if ( decisionHandler ) {
            decisionHandler(policy);
        }
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    // There is no equivalent degraded delegate method.
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    SEL delegateSelector = @selector(webViewDidStartLoad:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webViewDidStartLoad:self];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    // There is no equivalent degraded delegate method.
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    SEL delegateSelector = @selector(webView:didFailLoadWithError:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    // There is no equivalent degraded delegate method.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    SEL delegateSelector = @selector(webViewDidFinishLoad:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webViewDidFinishLoad:self];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    SEL delegateSelector = @selector(webView:didFailLoadWithError:);
    if ( [self.delegate respondsToSelector:delegateSelector] ) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    else {
        RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector);
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    // There is no equivalent degraded delegate method.
}

#pragma mark - Utility

+ (RZPoseurWebViewNavigationType)degradingWebViewNavigationTypeForWKWebViewNavigationType:(WKNavigationType)navigationType
{
    RZPoseurWebViewNavigationType degradingWebViewNavigationType;
    switch ( navigationType ) {
        case WKNavigationTypeLinkActivated:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeLinkActivated;
            break;
        case WKNavigationTypeFormSubmitted:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeFormSubmitted;
            break;
        case WKNavigationTypeBackForward:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeBackForward;
            break;
        case WKNavigationTypeReload:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeReload;
            break;
        case WKNavigationTypeFormResubmitted:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeFormResubmitted;
            break;
        case WKNavigationTypeOther:
            degradingWebViewNavigationType = RZPoseurWebViewNavigationTypeOther;
            break;
    }
    
    return degradingWebViewNavigationType;
}

+ (SEL)degradingWebViewDelegateSelectorForWKNavigationDelegateSelector:(SEL)selector
{
    SEL degradedSelector = NULL;

    // Map WKWebViewDelegate methods to their RZPoseurWebViewDelegate equivalents.
    // An explicit NULL indicates that there no equivalent exists.
    
    if ( selector == @selector(webView:decidePolicyForNavigationAction:decisionHandler:) ) {
        degradedSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    }
    else if ( selector == @selector(webView:decidePolicyForNavigationResponse:decisionHandler:) ) {
        degradedSelector = NULL;
    }
    else if ( selector == @selector(webView:didStartProvisionalNavigation:) ) {
        degradedSelector = @selector(webViewDidStartLoad:);
    }
    else if ( selector == @selector(webView:didReceiveServerRedirectForProvisionalNavigation:) ) {
        degradedSelector = NULL;
    }
    else if ( selector == @selector(webView:didFailProvisionalNavigation:withError:) ) {
        degradedSelector = @selector(webView:didFailLoadWithError:);
    }
    else if ( selector == @selector(webView:didCommitNavigation:) ) {
        degradedSelector = NULL;
    }
    else if ( selector == @selector(webView:didFinishNavigation:) ) {
        degradedSelector = @selector(webViewDidFinishLoad:);
    }
    else if ( selector == @selector(webView:didFailNavigation:withError:) ) {
        degradedSelector = @selector(webView:didFailLoadWithError:);
    }
    else if ( selector == @selector(webView:didReceiveAuthenticationChallenge:completionHandler:) ) {
        degradedSelector = NULL;
    }
    
    return degradedSelector;
}



@end
