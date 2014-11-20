//
//  RZPoseurWebView_Private.h
//  RZPoseurWebViewDemo
//
//  Created by Justin Kaufman on 11/20/14.
//  Copyright (c) 2014 Justin Kaufman. All rights reserved.
//

#define RZPoseurWebViewDelegateMethodUnimplementedAssert(delegateSelector) \
        NSAssert(NO, @"Method (%@) was called, but the correspoinding RZPoseurWebView delegate method (%@) is not implemented. This is an error.", \
                 NSStringFromSelector(delegateSelector), \
                 NSStringFromSelector(_cmd));

@interface RZPoseurWebView ()

@end