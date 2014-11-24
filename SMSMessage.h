//
//  SMSMessage.h
//  Pull
//
//  Created by Adam Horowitz on 9/4/14.
//
//

#import <Parse/Parse.h>

@interface SMSMessage : PFObject

@property NSInteger *launchedOn;
@property NSString *composedBy;
@property BOOL sentByMe;
@property BOOL box;
@property BOOL isDelayed;
@property PFACL *acl;

-(id)initWIthSMSInfo:(NSNumber *)date aMessage:(NSString *)message anAddress:(NSString *)address aPerson:(NSString *)person aType:(NSNumber *)type anOwner:(NSString *)owner;

@end
