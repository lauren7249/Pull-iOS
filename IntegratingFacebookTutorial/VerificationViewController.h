//
//  VerificationViewController.h
//  Pull
//
//  Created by Adam Horowitz on 8/12/14.
//
//

#import <UIKit/UIKit.h>

@interface VerificationViewController : UIViewController{
    NSMutableString *verifyNum;
    NSString *phoneNumber;
}

@property (readwrite) NSMutableString *verifyNum;
@property (readwrite) NSString *phoneNumber;


- (IBAction)verifyButtonTouchHandler:(id)sender;

@end
