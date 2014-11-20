//
//  UIAlertView+RZPBlockAlert.h
//
//  Created by Justin Kaufman on 11/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RZPBlockAlertCompletion)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (RZPBlockAlert)

- (void)rzp_showWithCompletionBlock:(RZPBlockAlertCompletion)completion;

@end
