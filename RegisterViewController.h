//
//  RegisterViewController.h
//  Pull
//
//  Created by Adam Horowitz on 8/12/14.
//
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController {
    NSMutableString *verifyNum;
}

@property (readwrite) NSMutableString *verifyNum;
@property (readwrite) NSMutableString *verifyNumOnly;

- (IBAction)registerWithoutButtonTouchHandler:(id)sender;


@end
