//
//  DatabaseHandler.m
//  Pull
//
//  Created by Adam Horowitz on 9/9/14.
//
//

#import "DatabaseHandler.h"
#import <parse/Parse.h>
#import <AddressBook/AddressBook.h>

NSString* const DATABASE_NAME = @"pullDB";
// Contacts table name
NSString* const TABLE_SHARED_CONVERSATIONS = @"sharedConversations";
NSString* const TABLE_OUTBOX = @"outbox";
NSString* const TABLE_SHARED_CONVERSATION_SMS = @"sharedConversationsSMSs";
NSString* const TABLE_SHARED_CONVERSATION_COMMENTS = @"sharedConversationsComments";

// Columns for shared convos
NSString* const KEY_ID = @"id";
NSString* const KEY_DATE = @"date";
NSString* const KEY_SHARED_WITH = @"number";
NSString* const KEY_CONVERSATION_FROM = @"orig_number";
NSString* const KEY_HASHTAG_ID = @"hashtagID";
NSString* const KEY_SHARER = @"sharer";
NSString* const KEY_PROPOSED = @"isproposal";
NSString* const KEY_CONVERSATION_FROM_NAME = @"orig_name";
NSString* const KEY_CONVO_TYPE = @"convo_type";
NSString* const KEY_APPROVER = @"apporver";
NSString* const KEY_OWNER = @"owner";



@implementation DatabaseHandler

@synthesize databasePath;
@synthesize myDatabase;


-(id)initWithDBInfo{
    self = [super init];
    
    if(self){
//        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
//        NSString *docsDir = dirPaths[0];
//        databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingString:DATABASE_NAME]];
        
        NSString * docsPath= NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        databasePath = [docsPath stringByAppendingPathComponent:@"Pull.db"];
        
        int rc=0;
        
        rc = sqlite3_open_v2([databasePath cStringUsingEncoding:NSUTF8StringEncoding], &myDatabase, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
        if (SQLITE_OK != rc)
        {
            sqlite3_close(myDatabase);
            NSLog(@"Failed to open db connection");
        }
        else{
            [self createTables:myDatabase];
        }
    }
    
    return self;
}

-(void) createTables:(sqlite3 *)myDatabaseTemp{
    
    char * errInfo;
    
    const char *CREATE_MESSAGES_TABLE = "CREATE TABLE IF NOT EXISTS sharedConversations (id TEXT, date DATE, number TEXT, orig_number TEXT, orig_name TEXT, convo_type TEXT, sharer TEXT)";
    const char *CREATE_OUTBOX_TABLE = "CREATE TABLE IF NOT EXISTS outbox (id INTEGER PRIMARY KEY AUTOINCREMENT, date_sent DATE, date DATE, body TEXT, address TEXT, approver TEXT)";
    const char *CREATE_SHARED_SMS_TABLE = "CREATE TABLE IF NOT EXISTS sharedConversationsSMSs (id TEXT, hashcode INTEGER, convo_type TEXT, date DATE, body TEXT, type TEXT, address TEXT, owner TEXT)";
    const char *CREATE_SHARED_COMMENTS = "CREATE TABLE IF NOT EXISTS sharedConversationsComments (id TEXT, body TEXT, type TEXT, address TEXT, date DATE, isproposal TEXT)";


    
    if(sqlite3_exec(myDatabaseTemp, CREATE_MESSAGES_TABLE, NULL, NULL, &errInfo) == SQLITE_OK){
        NSLog(@"%@", @"Success");
    }
    else{
        NSLog(@"%s", errInfo);
    }
    
    if(sqlite3_exec(myDatabaseTemp, CREATE_OUTBOX_TABLE, NULL, NULL, &errInfo) == SQLITE_OK){
        NSLog(@"%@", @"Success2");
    }
    else{
        NSLog(@"%s", errInfo);
    }
    
    if(sqlite3_exec(myDatabaseTemp, CREATE_SHARED_SMS_TABLE, NULL, NULL, &errInfo) == SQLITE_OK){
        NSLog(@"%@", @"Success3");
    }
    else{
        NSLog(@"%s", errInfo);
    }
    
    if(sqlite3_exec(myDatabaseTemp, CREATE_SHARED_COMMENTS, NULL, NULL, &errInfo) == SQLITE_OK){
        NSLog(@"%@", @"Success4");
    }
    else{
        NSLog(@"%s", errInfo);
    }
}

-(void) addSharedMessage:(NSString *)convo_id aMsg:(PFObject *)msg aConvoType: (int)convoType{
    if(msg == nil) return;
    if(msg[@"smsMessage"] == nil) return;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM sharedConversationsSMSs WHERE id= '%@' AND hashcode='%@'", convo_id, msg[@"hashCode"]];
    NSLog(@"%@", query);
    if([self recordExistOrNot:query]) return;
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO sharedConversationsSMSs (id, hashcode, convo_type, date, body, type, address, owner) VALUES ('%@', '%@', '%d', '%@', '%@', '%@', '%@', '%@')", convo_id, msg[@"hashCode"], convoType, msg[@"smsDate"], [msg[@"smsMessage"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], msg[@"type"], msg[@"address"], msg[@"owner"]];
    
    NSLog(@"%@",insertQuery);
    
    char * errInfo;
    if(sqlite3_exec(myDatabase, [insertQuery UTF8String], NULL, NULL, &errInfo) != SQLITE_OK){
        NSLog(@"Failed to insert record msg=%s",errInfo);
    }
}

-(void) addSharedConversation:(NSString *)convo_id aConfidante:(NSString *)confidante anOriginalRecipientName:(NSString *)originalRecipientName anOriginalRecipient:(NSString *)originalRecipient anOwner:(NSString *)owner aType:(int)type{
    char * errInfo;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM sharedConversations WHERE id='%@'", convo_id];
    NSLog(@"%@", query);
    if([self recordExistOrNot:query]){
        NSString *updateQuery = [NSString stringWithFormat:@"UPDATE sharedConversations SET id='%@', date='%f', number='%@', orig_name='%@', orig_number='%@', sharer='%@', convo_type='%d' WHERE id='%@'", convo_id, [[NSDate date] timeIntervalSince1970] * 1000, confidante, [originalRecipientName stringByReplacingOccurrencesOfString:@"'" withString:@"''"], originalRecipient, owner, type, convo_id];
        NSLog(@"%@", updateQuery);
        if(sqlite3_exec(myDatabase, [updateQuery UTF8String], NULL, NULL, &errInfo) != SQLITE_OK){
            NSLog(@"Failed to update record msg=%s",errInfo);
        }
    }
    else{
        NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO sharedConversations (id, date, number, orig_name, orig_number, sharer, convo_type) VALUES('%@', '%f', '%@', '%@', '%@', '%@', '%d')", convo_id, [[NSDate date] timeIntervalSince1970] * 1000, confidante, [originalRecipientName stringByReplacingOccurrencesOfString:@"'" withString:@"''"], originalRecipient, owner, type];
        NSLog(@"%@", insertQuery);
        if(sqlite3_exec(myDatabase, [insertQuery UTF8String], NULL, NULL, &errInfo) != SQLITE_OK){
            NSLog(@"Failed to update record msg=%s",errInfo);
        }
    }
}


-(NSArray *)getSharedConversations{
    NSMutableArray *sharedConversations = [[NSMutableArray alloc] init];
    int rc = 0;
    sqlite3_stmt* stmt = NULL;
    NSString *query = @"SELECT * FROM sharedConversations";
    rc = sqlite3_prepare_v2(myDatabase, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) //get each row in loop
        {
            NSString *sharer = [self getNameFromContacts:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)]];
            NSString *conversant = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            
            NSString *convoID = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
            
            NSString *sharerPhone = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            
            NSString *conversantPhone = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            
            NSDictionary *sharedConversation =[NSDictionary dictionaryWithObjectsAndKeys:sharer,@"sharer",
                                    conversant,@"conversant",convoID,@"convoID", sharerPhone,@"sharerPhone", conversantPhone,@"conversantPhone", nil];
            [sharedConversations addObject:sharedConversation];
            
        }
        NSLog(@"Done");
        sqlite3_finalize(stmt);
    }

    return sharedConversations;
}

-(NSArray *)getSharedMessages:(NSString *)convoID{
    NSMutableArray *sharedMessages = [[NSMutableArray alloc] init];
    int rc = 0;
    sqlite3_stmt* stmt = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM sharedConversationsSMSs WHERE id='%@' ORDER BY date ASC", convoID];
    rc = sqlite3_prepare_v2(myDatabase, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) //get each row in loop
        {
            
            NSString *body = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            NSString *dateTemp = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([dateTemp doubleValue] / 1000)];
            NSDateFormatter *dtfrm = [[NSDateFormatter alloc] init];
            [dtfrm setDateFormat:@"MM/dd/yyyy - hh:mm aa"];
            NSString *nDate = [dtfrm stringFromDate:date];
            
            NSString *type = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            
            NSDictionary *sharedMessage =[NSDictionary dictionaryWithObjectsAndKeys:body,@"body",
                                               nDate,@"date",type,@"type",nil];
            if(![[sharedMessage objectForKey:@"body"] isEqualToString:@""])
                [sharedMessages addObject:sharedMessage];
            
        }
        NSLog(@"Done");
        sqlite3_finalize(stmt);
    }
    
    return sharedMessages;
}



-(BOOL)recordExistOrNot:(NSString *)query{
    BOOL recordExist=NO;
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(myDatabase, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
        {
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                recordExist=YES;
            }
            else
            {
                //////NSLog(@"%s,",sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
        }
    return recordExist;
}

-(NSString *)getNameFromContacts:(NSString *)sender
{
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        
        for (int i = 0; i < nPeople; i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name and Last Name
            
            NSString *firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            NSString *lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!firstNames) {
                firstNames = @"";
            }
            if (!lastNames) {
                lastNames = @"";
            }
            else{
                lastNames = [@" " stringByAppendingString:lastNames];
            }
            //get Phone Numbers
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                NSString *newPhoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                            componentsJoinedByString:@""];
                if(newPhoneNumber.length == 10)
                    newPhoneNumber = [@"1" stringByAppendingString:newPhoneNumber];
                if([sender isEqualToString:(newPhoneNumber)]){
                    return [firstNames stringByAppendingString:lastNames];
                }
                
                
                //NSLog(@"All numbers %@", phoneNumbers);
                
            }
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
            
            
            
            
        }
        return nil;
        
        
        
    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
        return NO;
        
        
    }
    
}


-(void)close{
    sqlite3_close(myDatabase);
}




@end
