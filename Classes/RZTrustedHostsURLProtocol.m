//
//  RZTrustedHostsURLProtocol.m
//  RZTrustedHostsURLProtocol
//
//  Created by Adam Howitt on 8/11/15.
//  Copyright (c) 2015 Razilabs. All rights reserved.
//

#import "RZTrustedHostsURLProtocol.h"

static NSString* const kRZTrustedHostsURLProtocolHandledKey = @"RZTrustedHostsURLProtocolHandledKey";
static NSString* const kRZTrustedHostsURLProtocolSchemeHTTPs = @"https";

// Visible Strings
static NSString* const kRZTrustedHostsURLProtocolWarningMessage = @"The identity of \"%@\" cannot be verified. Review the certificate details to continue.";
static NSString* const kRZTrustedHostsURLProtocolWarningTitle = @"Cannot Verify Server Identity";
static NSString* const kRZTrustedHostsURLProtocolWarningButtonTitleCancel = @"Cancel";
static NSString* const kRZTrustedHostsURLProtocolWarningButtonTitleContinue = @"Continue";

@interface RZTrustedHostsURLProtocol () <NSURLConnectionDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableDictionary *hostTrustStatus;
@property (strong, nonatomic) NSString *messageTitle;
@property (strong, nonatomic) NSString *messageBody;

@end

@implementation RZTrustedHostsURLProtocol

#pragma mark - Private

+ (instancetype)sharedInstance
{
    static RZTrustedHostsURLProtocol *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
        s_manager.hostTrustStatus = [NSMutableDictionary dictionary];
        s_manager.messageTitle = kRZTrustedHostsURLProtocolWarningTitle;
        s_manager.messageBody = kRZTrustedHostsURLProtocolWarningMessage;
    });
    return s_manager;
}

#pragma mark - Public

+ (void)clearTrustedHosts
{
    [[self sharedInstance] setHostTrustStatus:[NSMutableDictionary dictionary]];
}

+ (void)configureAlertWithTitle:(NSString *)title message:(NSString *)message
{
    if (title) {
        [[self.class sharedInstance] setMessageTitle:title];
    }
    if (message && [message componentsSeparatedByString:@"%@"].count == 2 ) {
        [[self.class sharedInstance] setMessageBody:message];
    }

}

+ (BOOL)isTrustedHost:(NSString *)host
{
    return [[self.class sharedInstance] hostTrustStatus][host];
}

+ (void)addTrustedHost:(NSString *)host
{
    [[self sharedInstance] hostTrustStatus][host] = @(YES);
}

+ (UIAlertController *)trustDialogForHost:(NSString *)host withError:(NSError *)error completion:(RZTrustedHostsURLProtocolOverrideCompletion)completion
{
    NSString *warningMessage = [NSString stringWithFormat:[[self sharedInstance] messageBody], host];
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:[[self sharedInstance] messageTitle]
                               message:warningMessage
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kRZTrustedHostsURLProtocolWarningButtonTitleCancel
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];

    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:kRZTrustedHostsURLProtocolWarningButtonTitleContinue
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * action) {
                                                               [self addTrustedHost:host];
                                                               if (completion) {
                                                                   completion();
                                                               }
                                                           }];


    [view addAction:cancelAction];
    [view addAction:continueAction];
    return view;
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL canInit = NO;
    // Prevents infinite loop when requests are resubmitted
    if ([request.URL.scheme isEqualToString:kRZTrustedHostsURLProtocolSchemeHTTPs] && ![self propertyForKey:kRZTrustedHostsURLProtocolHandledKey inRequest:request]) {
        canInit = YES;
    }

    return canInit;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [self.class setProperty:@YES forKey:kRZTrustedHostsURLProtocolHandledKey inRequest:newRequest];

    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];

}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

        if ([self.class isTrustedHost:challenge.protectionSpace.host]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            // Use override
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }
        else {
            // Use default handling
            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
        }
        
    }
    
}

@end
