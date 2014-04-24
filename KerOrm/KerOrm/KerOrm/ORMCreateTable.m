//
//  ORMCreateTable.m
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import "ORMCreateTable.h"
#import "ORMRequest.h"
#include <objc/runtime.h> //objc runtime api’s

@implementation ORMCreateTable



+ (void) createTable: (NSString *) database withModels: (NSArray *) models {
    
    DBGest *bdd = [[[DBGest alloc] initDb: database] autorelease];
    
    NSArray *tablesName = nil;
    NSError *error = nil;
    NSMutableArray *tables = [[NSMutableArray alloc] init];
    int i;
    
    unsigned long nbEnregistrements, nbTable;
    
    tablesName = [bdd SQLQuery: @"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name" withError: &error];
    
    nbTable = (int)[models count];
    
    nbEnregistrements = [tablesName count];
    for (i = 0; i < nbEnregistrements; i++) {
        [tables addObject: [[tablesName objectAtIndex: i] objectForKey: @"name"]];
    }
    
    
    
    for ( int i = 0; i < nbTable ; i++) {
        NSString *model = [models objectAtIndex: i]; // nom de la classe à mettre en minuscule
        NSString *table_name = [model lowercaseString]; // Nom de la table
        NSString *id_column_name = [[model lowercaseString] stringByAppendingString: @"_id"];
        
        if ([tables containsObject: table_name]) {
            
            NSLog(@"Cette table existe deja.\nVous devez la supprimez pour pouvoir l'importer a nouveau.\n"); // a debug
            
        }
        else // on ajoute la table dans la db
        {
        
            NSMutableDictionary *colonnes = [[NSMutableDictionary alloc] init]; //Dico qui contiendra les colonnes de la futur table
            [colonnes setObject: @"INTEGER PRIMARY KEY" forKey: id_column_name]; // set la clef primaire
            //ORMRequest *newTable;
            Class class = NSClassFromString(model);
            
            //NSObject *tableObj = [[[NSObject alloc] init] NSObjectFromString:model]; // autre maniere
            
            id modelClass = objc_getClass([model cStringUsingEncoding: NSASCIIStringEncoding]);
            unsigned int outCount, i;
            objc_property_t *properties = class_copyPropertyList(modelClass, &outCount);
    
            for (i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
        
                NSString *name = [NSString stringWithCString: property_getName(property)
                                            encoding: NSASCIIStringEncoding];
                NSString *attr = [NSString stringWithCString: property_getAttributes(property)
                                            encoding: NSASCIIStringEncoding];
        
                NSArray *chunks = [attr componentsSeparatedByString: @","];
                //NSLog(@"%@", chunks);
                NSString *type = [chunks objectAtIndex: 0];
                if ([[type substringWithRange: NSMakeRange(1, 1)] isEqualToString: @"@"]) {
                    type = [type substringWithRange: NSMakeRange(3, [type length] - 4)];
                } else {
                    // Primitive type
                    type = [type substringFromIndex: 1];
                }
        
                // Figure out if we need uniqueness
                BOOL unique = false;
        
                if (![name isEqualToString: id_column_name]) {
                    NSLog(@"%@ %@ %@", name, type, unique ? @"Unique" : @"");
            
                    NSDictionary *typeMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"INTEGER", @"i",
                                     @"INTEGER", @"I",
                                     @"FLOAT", @"f",
                                     @"INTEGER", @"l",
                                     @"INTEGER", @"s",
                                     @"INTEGER", @"c",
                                     @"INTEGER", @"NSNumber",
                                     @"TEXT", @"NSString",
                                     @"BLOB", @"NSData",
                                     @"INTEGER", @"NSDate",
                                     nil];
            
                    NSString *column;
                    if ((column = [typeMap objectForKey: type])) {
                        if (unique) {
                            column = [column stringByAppendingString: @" UNIQUE"];
                        }
                
                        [colonnes setObject: column forKey: name];
                
                }
                else {
                // Ignore unknown
                NSLog(@"Ignoring column %@ of type %@", name, type);
                }
            
            }
        }
    
    NSLog(@"%@", colonnes);
    
    NSString *query = [NSString stringWithFormat: @"CREATE TABLE %@ (", table_name];
    NSEnumerator *enumerator = [colonnes keyEnumerator];
    NSString *columnName;
            
    int j = 0;
    unsigned long m = [colonnes count];
    while ((columnName = [enumerator nextObject])) {
        query = [query stringByAppendingFormat: @"%@ %@", columnName, [colonnes objectForKey: columnName]];
        if (j < m - 1) {
            query = [query stringByAppendingString: @", "];
        }
        j++;
    }
    [colonnes release];
    query = [query stringByAppendingString: @")"];
    
    NSLog(@"query : %@", query);
    [bdd SQLQuery: query withError: &error];
    if (error) {
        NSLog(@"Failed to create table %@: %@", table_name, error);
    }
    else {
        
        // Retrieve indexes
        NSArray *indexesTuples = [class indexes];
        m = [indexesTuples count];
        for (j = 0; j < m; j++) {
            if ([[indexesTuples objectAtIndex: j] isKindOfClass: [NSString class]]) {
                NSString *name = [indexesTuples objectAtIndex: j];
                NSString *indexName = [name stringByAppendingString: @"Index"];
                NSString *indexQuery = [NSString stringWithFormat: @"CREATE INDEX IF NOT EXISTS %@ ON %@ (%@)", indexName, table_name, name];
                NSLog(@"%@", indexQuery);
                
                [bdd SQLQuery: indexQuery withError: &error];
                if (error) {
                    NSLog(@"Failed to create index %@: %@", indexName, error);
                }
                
            }
            else if ([[indexesTuples objectAtIndex: j] isKindOfClass: [NSArray class]]) {
                // Indexing multiple columns
                NSArray *tuples = [indexesTuples objectAtIndex: j];
                NSString *indexName = [[tuples componentsJoinedByString: @""] stringByAppendingString: @"Index"];
                NSString *name = [tuples componentsJoinedByString: @","];
                
                NSString *indexQuery = [NSString stringWithFormat: @"CREATE INDEX IF NOT EXISTS %@ ON %@ (%@)", indexName, table_name, name];
                NSLog(@"%@", indexQuery);
                
                [bdd SQLQuery: indexQuery withError: &error];
                if (error) {
                    NSLog(@"Failed to create index %@: %@", indexName, error);
                }
                
            } // fin if
        } // fin for
    } // fin else

        } // fin for
}
    
} // end of function
@end

