//
//  DBGest.h
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ORMRequest.h"

@interface DBGest : NSObject {
@private
    NSString *_databasePath;
    sqlite3 *_database;
    BOOL _created;
}

@property (nonatomic, retain) NSString *databasePath;
@property BOOL created;

+ (DBGest *) getDb: (NSString *) database;
- (id) initDb: (NSString *) database;

- (NSArray *) SQLQuery: (NSString *) query withArguments: (NSArray *) args andError: (NSError **) error;
- (NSArray *)SQLQuery: (NSString *)query withError: (NSError **)error;
- (NSArray *) findObjects: (NSString*) query : (NSString*) nomClass withError:(NSError **) error;
- (NSArray *) findSimpleObjects: (NSString*) query : (NSString*) nomClass withError:(NSError **) error;
//- (NSNumber *)lastId;

@end
