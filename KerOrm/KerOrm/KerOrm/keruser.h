//
//  User.h
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DBGest.h"

@interface keruser : ORMRequest {
    int keruser_id;
    NSString *nom;
    NSString *prenom;
    NSNumber *age;
    
}


@property (nonatomic) int keruser_id;
@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *prenom;
@property (nonatomic, retain) NSNumber *age;


@end
