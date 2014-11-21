//
//  RZPBlockAlertHandler.h
//  RZPoseurWebViewDemo
//
//  Created by Justin Kaufman on 11/20/14.
//  Copyright (c) 2014 Justin Kaufman. All rights reserved.
//

#import "UIAlertView+RZPBlockAlert.h"

@interface RZPBlockAlertHandler : UIAlertView

+ (instancetype)handleAlertView:(UIAlertView *)alertView completion:(RZPBlockAlertCompletion)completion;

@end
