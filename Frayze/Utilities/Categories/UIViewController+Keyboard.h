//
//  UIViewController+Keyboard.h
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIViewControllerKeyboardProtocol <NSObject>

@optional
- (void)keyboardWillShow:(NSNotification *)notification duration:(double)duration options:(UIViewAnimationOptions)options;
- (void)keyboardWillHide:(NSNotification *)notification duration:(double)duration options:(UIViewAnimationOptions)options;
- (void)keyboardDidShow:(NSNotification *)notification duration:(double)duration options:(UIViewAnimationOptions)options;
- (void)keyboardDidHide:(NSNotification *)notification duration:(double)duration options:(UIViewAnimationOptions)options;

@end

@interface UIViewController (Keyboard) <UIViewControllerKeyboardProtocol>

- (void)registerKeyboard;
- (void)unregisterKeyboard;

@end
