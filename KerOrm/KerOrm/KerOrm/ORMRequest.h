//
//  ORMRequest.h
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBGest.h"
@class DBGest;

@interface ORMRequest : NSObject {
    
}

- (void) save: (DBGest *) bdd;
+ (NSArray *) keys;

@end
