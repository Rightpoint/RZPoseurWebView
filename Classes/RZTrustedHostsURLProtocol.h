//
//  RZTrustedHostsURLProtocol.h
//  RZTrustedHostsURLProtocol
//
//  Created by Adam Howitt on 8/11/15.
//  Copyright (c) 2015 Razilabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZTrustedHostsURLProtocolOverrideCompletion)(void);

@interface RZTrustedHostsURLProtocol : NSURLProtocol

/*!
 @method configureAlertWithTitle:message:
 @abstract Allows you to customize the title of the alert shown in trust dialogs.
 @param title The title of the dialog.
 @param message The body of the dialog. Should contain exactly one %@ format specifier to allow the insertion of the domain name in the message
 */
+ (void)configureAlertWithTitle:(NSString *)title message:(NSString *)message;

/*!
 @method isTrustedHost:
 @abstract Checks the whitelist of trusted hosts maintained by the shared instance to see if host is present.
 @param host The host to check.
 @return @c YES if the host is trusted, else @c NO
 */
+ (BOOL)isTrustedHost:(NSString *)host;

/*!
 @method addTrustedHost:
 @abstract Adds a host to the whitelist of trusted hosts maintained by the shared instance.
 @param host The host to add.
 */
+ (void)addTrustedHost:(NSString *)host;

/*!
 @method clearTrustedHosts
 @abstract Deletes the contents of the shared whitelist of trusted hosts
 */
+ (void)clearTrustedHosts;

/*!
 @method trustDialogForHost:withError:completion:
 @abstract Generates a UIAlertController trust dialog configured to resemble the Safari warnings when an SSL certificate is invalid. Presently doesn't offer a details option.
 @param host The host to check.
 @param error The NSURLError returned when the URL request failed.
 @param completion The completion block to execute if the user taps continue.
 @return UIAlertController A UIAlertController
 */
+ (UIAlertController *)trustDialogForHost:(NSString *)host withError:(NSError *)error completion:(RZTrustedHostsURLProtocolOverrideCompletion)completion;

@end
