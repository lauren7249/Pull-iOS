//
//  SMSMessage.m
//  Pull
//
//  Created by Adam Horowitz on 9/4/14.
//
//

#import "SMSMessage.h"

@implementation SMSMessage
@synthesize launchedOn;
@synthesize composedBy;
@synthesize sentByMe;
@synthesize box;
@synthesize isDelayed;
@synthesize acl;


-(id)initWIthSMSInfo:(NSNumber *)date aMessage:(NSString *)message anAddress:(NSString *)address aPerson:(NSString *)person aType:(NSNumber *)type anOwner:(NSString *)owner{
    self = [super init];
    
    if(self){
        self[@"message"] = message;
        self[@"address"] = address;
        self[@"smsDate"] = date;
        self[@"type"] = type;
        self[@"owner"] = owner;
        self[@"person"] = person;
        self[@"user"] = [PFUser currentUser];
        self[@"username"] = [[PFUser currentUser] username];
        
    }
    
    return self;
}


@end
