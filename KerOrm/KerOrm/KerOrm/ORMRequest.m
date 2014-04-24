//
//  ORMRequest.m
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import "ORMRequest.h"
#include <objc/runtime.h> //objc runtime api’s

@implementation ORMRequest

- (void) save: (DBGest *) bdd // fonction qui permet de sauvegarder un objet dans la base de donnée
{
    
    NSArray *arrayColonnes = [[self class] keys];
    NSString *nomClasse = NSStringFromClass([self class]);
    NSString *nomTable = [nomClasse lowercaseString];
    NSString *idColumnName = [[nomClasse lowercaseString] stringByAppendingString: @"_id"];
    
    NSString *query; 
    int i, nombreColonnes = (int)[arrayColonnes count]; //cast explicite pour xcode 3.2.6, sinon warning.
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity: nombreColonnes]; // array des colonnes finales
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity: nombreColonnes]; // array des typevalues finaux
    for (i = 0; i < nombreColonnes; i++) {
        NSString *colonne = [arrayColonnes objectAtIndex: i];
        
        if (![colonne isEqualToString: idColumnName]) {
            id value = [self valueForKey: colonne];
			if (value != nil && ![value isKindOfClass: [NSNull class]]) {
                [columns addObject: colonne];
                [values addObject: value];
            } 
			else 
			{
					[columns addObject: colonne];
                    [values addObject: @"string"]; // string car addobject ne peut etre nil
			
            }
        }
    }
	
	query = [NSString stringWithFormat:@"INSERT INTO %@", nomTable];
    query = [query stringByAppendingString: @"("];
	
	
    nombreColonnes = (int)[columns count];
	
	
	// Création de la requette par concaténation des éléments
	
    for (i = 0; i < nombreColonnes; i++) {
        query = [query stringByAppendingFormat: @"%@", [columns objectAtIndex: i]];
        if (i != nombreColonnes - 1) {
            query = [query stringByAppendingString: @","];
        }
    }
    query = [query stringByAppendingString: @") VALUES ("];
    for (i = 0; i < nombreColonnes; i++) {
        query = [query stringByAppendingFormat: @"'%@'", [values objectAtIndex: i]];
        if (i != nombreColonnes - 1) {
            query = [query stringByAppendingString: @","];
        }
    }
    query = [query stringByAppendingString: @")"];
    
    //NSLog(@"%@", query); pour debug
	// Fin de la création de la query. Prète à être envoyée.
	
    [columns release];
    [values release];
    
    NSError *error = nil;
    [bdd SQLQuery: query withError: &error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // We need to update the idColumnName value
    //[self setValue: [bdd lastId] forKey: idColumnName];
}

+ (NSArray *) keys
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    int i;
    NSMutableArray *keys = [[[NSMutableArray alloc] initWithCapacity: outCount] autorelease];
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString: propName encoding: NSUTF8StringEncoding];
            [keys addObject: propertyName];
        }
    }
    free(properties);
    return keys;
}

// id

+(NSDictionary *) keyAndTypes{ return nil; };

+(NSArray *)indexes{
    return nil;
}

+ (BOOL) shouldColumnBeUnique: (NSString *) nomColonne
{
    return false;
}


@end
