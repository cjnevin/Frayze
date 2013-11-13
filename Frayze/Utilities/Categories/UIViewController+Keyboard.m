//
//  UIViewController+Keyboard.m
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "UIViewController+Keyboard.h"

@implementation UIViewController (Keyboard)

- (UIViewAnimationOptions)optionsForCurve:(UIViewAnimationCurve)curve
{
    UIViewAnimationOptions options;
    switch (curve) {
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
    }
    return options;
}

- (void)registerKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unregisterKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(keyboardWillShow:duration:options:)]) {
        [self keyboardWillShow:notification duration:duration options:[self optionsForCurve:curve]];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(keyboardWillHide:duration:options:)]) {
        [self keyboardWillHide:notification duration:duration options:[self optionsForCurve:curve]];
    }
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(keyboardDidShow:duration:options:)]) {
        [self keyboardDidShow:notification duration:duration options:[self optionsForCurve:curve]];
    }
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(keyboardDidHide:duration:options:)]) {
        [self keyboardDidHide:notification duration:duration options:[self optionsForCurve:curve]];
    }
}

@end
