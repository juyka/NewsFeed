//
//  VKCaptchaViewController.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VKCaptchaViewController.h"
#import "VKCaptchaView.h"
#import "VKUtil.h"
#import "VKSharedTransitioningObject.h"

@implementation VKCaptchaViewController {
    VKSharedTransitioningObject *_transitionDelegate;
    VKCaptchaView *_captchaView;
}
+ (instancetype)captchaControllerWithError:(VKError *)error {
	VKCaptchaViewController *controller = [VKCaptchaViewController new];
	controller->_captchaError = error;
	[[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(captchaDidAnswered) name:VKCaptchaAnsweredEvent object:nil];
	return controller;
}

- (void)loadView {

    CGRect captchaFrame = CGRectMake(0, 0, kCaptchaImageWidth + 10, kCaptchaViewHeight + 10 );
    if (VK_IS_DEVICE_IPAD) {
        self.view = [[UIView alloc] initWithFrame:captchaFrame];
    } else {
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        captchaFrame.origin = CGPointMake(roundf((self.view.frame.size.width - captchaFrame.size.width) / 2.f), roundf((self.view.frame.size.height - captchaFrame.size.height) / 2.f) - kCaptchaViewHeight);
    }
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.3f];
    _captchaView = [[VKCaptchaView alloc] initWithFrame:captchaFrame andError:_captchaError];
    _captchaView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_captchaView];
}

- (void)captchaDidAnswered {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentIn:(UIViewController *)controller {
	UIViewController *presenting = controller.presentedViewController;
	if (presenting && (presenting.isBeingDismissed || presenting.isBeingPresented)) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^(void) {
		    [self presentIn:controller];
		});
		return;
	}
    UIModalPresentationStyle oldStyle = controller.navigationController ? controller.navigationController.modalPresentationStyle : controller.modalPresentationStyle;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    } else if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _transitionDelegate = [VKSharedTransitioningObject new];
        self.transitioningDelegate  = _transitionDelegate;
        self.modalPresentationStyle = UIModalPresentationCustom;
    } else {
        if (controller.navigationController) {
            controller.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    }
    self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
	[controller presentViewController:self animated:YES completion:nil];
    if (controller.navigationController) {
        controller.navigationController.modalPresentationStyle = oldStyle;
    } else {
        controller.modalPresentationStyle = oldStyle;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (CGSize)preferredContentSize {
    return CGSizeMake(kCaptchaImageWidth + 10, kCaptchaViewHeight + 10);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end