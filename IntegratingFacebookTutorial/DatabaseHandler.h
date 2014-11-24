//
//  DatabaseHandler.h
//  Pull
//
//  Created by Adam Horowitz on 9/9/14.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <Parse/Parse.h>

@interface DatabaseHandler : NSObject

@property(strong, nonatomic) NSString *databasePath;
@property(nonatomic) sqlite3 *myDatabase;

extern NSString* const DATABASE_NAME;

// Contacts table name
extern NSString* const TABLE_SHARED_CONVERSATIONS;
extern NSString* const TABLE_OUTBOX;
extern NSString* const TABLE_SHARED_CONVERSATION_SMS;
extern NSString* const TABLE_SHARED_CONVERSATION_COMMENTS;

// Columns for shared convos
extern NSString* const KEY_ID;
extern NSString* const KEY_DATE;
extern NSString* const KEY_SHARED_WITH;
extern NSString* const KEY_CONVERSATION_FROM;
extern NSString* const KEY_HASHTAG_ID;
extern NSString* const KEY_SHARER;
extern NSString* const KEY_PROPOSED;
extern NSString* const KEY_CONVERSATION_FROM_NAME;
extern NSString* const KEY_CONVO_TYPE;
extern NSString* const KEY_APPROVER;
extern NSString* const KEY_OWNER;

-(id)initWithDBInfo;
-(void)addSharedMessage:(NSString *)convo_id aMsg:(PFObject *)msg aConvoType:(int)convoType;
-(void) addSharedConversation:(NSString *)convo_id aConfidante:(NSString *)confidante anOriginalRecipientName:(NSString *)originalRecipientName anOriginalRecipient:(NSString *)originalRecipient anOwner:(NSString *)owner aType:(int)type;
-(void)close;
-(NSArray *) getSharedConversations;
-(NSArray *) getSharedMessages:(NSString *)convoID;

@end
