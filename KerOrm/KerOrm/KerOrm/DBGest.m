//
//  DBGest.m
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import "DBGest.h"

@implementation DBGest

@synthesize databasePath = _databasePath;
@synthesize created = _created;


+ (DBGest *) getDb: (NSString *) database
{
    return [[[DBGest alloc] initDb: database] autorelease];
}

- (id) initDb: (NSString *) database
{
    if (self = [super init]) {
        _databasePath = [database retain];
        
        NSFileManager *NSfm = [NSFileManager defaultManager];
        if ([NSfm fileExistsAtPath: _databasePath] == YES) {
            NSLog(@"BDD SQLITE3 trouvee a l'emplacement : %@", _databasePath);
        } else {
            NSLog(@"Pas de BDD SQLITE3 a l'emplacement : %@ . Veuillez créer une BDD SQLITE3 à cet emplacement, ou changer le Path", _databasePath);
        }
        if(sqlite3_open([_databasePath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"ERREUR : probleme lors de l'ouverture de la bdd");
        }
    }
    return self;
}


- (NSArray *) findSimpleObjects: (NSString*) query : (NSString*) nomClass withError:(NSError **) error
{
	
	NSMutableArray *results = nil;
    sqlite3_stmt *stmt; // statement sqlite
    
    //NSLog(@"%@", query); //pour debug
    
    if (!_database) {
        if (error) {
            NSLog(@"Erreur : ouverture database");
        }
        return results;
    }
    
    @synchronized(self) {
        
        if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
            if (error) {
				NSLog(@"Database returned error %d: %s", sqlite3_errcode(_database), sqlite3_errmsg(_database));
                NSLog(@"Erreur : la preparation de la requete a echouee");
            }
            return results;
        }
		
		NSString *nomClasse = nomClass;

		
		while (SQLITE_ROW == sqlite3_step(stmt)) {
			
			Class obj = [[NSClassFromString(nomClasse) alloc] init];
			
			int i, n = sqlite3_column_count(stmt);
			
			for (i = 0; i < n; i++) {

				const char *name = sqlite3_column_name(stmt, i);
				
				int type = sqlite3_column_type(stmt, i);
				
				if ([@"id" isEqualToString:[NSString stringWithUTF8String:name]])
					continue;
				
				
				
				switch (type) {
					case SQLITE_INTEGER:
					{
						int v = sqlite3_column_int(stmt, i);
						[obj setValue: [NSNumber numberWithInt: v]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_FLOAT:
					{
						double v = sqlite3_column_double(stmt, i);
						[obj setValue: [NSNumber numberWithFloat: v]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					default:
					case SQLITE_TEXT:
					{
						const char *v = (const char *)sqlite3_column_text(stmt, i);
						[obj setValue: [NSString stringWithCString:v encoding: NSUTF8StringEncoding]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_BLOB:
					{
						const void *v = sqlite3_column_blob(stmt, i);
						int len = sqlite3_column_bytes(stmt, i);
						[obj setValue: [NSData dataWithBytes: v length:len]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_NULL:
					{
						[obj setValue: [NSNull null]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
				}
			}
			
			[results addObject: obj];
		}
		
		if (SQLITE_OK != sqlite3_finalize(stmt)) {
			if (error) {
				NSLog(@"Erreur :  LA REQUETE A ECHOUE");
			}
			return [results autorelease];
		}
		
	}
	return [results autorelease];
}




- (NSArray *) findObjects: (NSString*) query : (NSString*) nomClass withError:(NSError **) error
{
	
	NSMutableArray *results = nil;
    sqlite3_stmt *stmt; // statement sqlite
    
    //NSLog(@"%@", query); // pour debug
    
    if (!_database) {
        if (error) {
            NSLog(@"Erreur : ouverture database");
        }
        return results;
    }
    
    @synchronized(self) {
        
        if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
            if (error) {
				NSLog(@"Database returned error %d: %s", sqlite3_errcode(_database), sqlite3_errmsg(_database));
                NSLog(@"Erreur : la preparation de la requete a echouee");
            }
            return results;
        }
		
		NSString *nomClasse = nomClass; 
		NSString *strid = @"id";
		const char *name;
		const char *tmp;
		
		while (SQLITE_ROW == sqlite3_step(stmt)) {
			if (!results) {
				results = [[NSMutableArray alloc] init];
			}
			
			int i, n = sqlite3_column_count(stmt);
			strid = @"id";
			
			Class obj = [[NSClassFromString(nomClasse) alloc] init]; // lowercasestring pour eviter les pb de syntaxe
			
			for (i = 0; i < n; i++) {
				tmp = sqlite3_column_name(stmt, i);
				if ([strid isEqualToString:[NSString stringWithUTF8String:tmp]])
				{
					strid = [NSString stringWithFormat:@"%@_%@", nomClasse, strid];
				}
				else 
				{
					strid = [[NSString alloc] initWithBytes:tmp length:100 encoding:NSASCIIStringEncoding];
				}
				
				name = [strid UTF8String];
				
				int type = sqlite3_column_type(stmt, i);
				
				
				
				switch (type) {
					case SQLITE_INTEGER:
					{
						int v = sqlite3_column_int(stmt, i);
						[obj setValue: [NSNumber numberWithInt: v]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_FLOAT:
					{
						double v = sqlite3_column_double(stmt, i);
						[obj setValue: [NSNumber numberWithFloat: v]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					default:
					case SQLITE_TEXT:
					{
						const char *v = (const char *)sqlite3_column_text(stmt, i);
						[obj setValue: [NSString stringWithCString:v encoding: NSUTF8StringEncoding]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_BLOB:
					{
						const void *v = sqlite3_column_blob(stmt, i);
						int len = sqlite3_column_bytes(stmt, i);
						[obj setValue: [NSData dataWithBytes: v length:len]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
					case SQLITE_NULL:
					{
						[obj setValue: [NSNull null]
							   forKey: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
						break;
					}
				}
			}
			
			[results addObject: obj];
		}
		
		if (SQLITE_OK != sqlite3_finalize(stmt)) {
			if (error) {
				NSLog(@"Erreur :  LA REQUETE A ECHOUE");
			}
			return [results autorelease];
		}
		
	}
	return [results autorelease];
}

- (NSArray *) SQLQuery: (NSString *) query withArguments: (NSArray *) args andError: (NSError **) error //fonction qui envoi les request
{
    NSMutableArray *results = nil;
    sqlite3_stmt *stmt; // statement sqlite
    
    // NSLog(@"%@", query); //pour debug
    
    if (!_database) {
        if (error) {
            NSLog(@"Erreur : ouverture database");
        }
        return results;
    }
    
    @synchronized(self) {
        
        if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
            if (error) {
                NSLog(@"Erreur : la preparation de la requete a echouee");
            }
            return results;
        }
        if (args) {
            int i = 1;
            for(id arg in args) {
                if ([[arg className] isEqualToString: @"NSCFNumber"]) {
                    NSNumber *aNumber = arg;
                    if((strcasecmp([aNumber objCType], @encode(int))) == 0) {
                        if (SQLITE_OK != sqlite3_bind_int(stmt, i, [arg intValue])) {
                            if (error) {
                                NSLog(@"Erreur !");
                            }
                            return results;
                        }
                    } else if((strcasecmp([aNumber objCType], @encode(double))) == 0) {
                        if (SQLITE_OK != sqlite3_bind_double(stmt, i, [arg doubleValue])) {
                            if (error) {
                                NSLog(@"Erreur !");
                            }
                            return results;
                        }
                        
                    } else if((strcasecmp([aNumber objCType], @encode(long))) == 0 || (strcasecmp([aNumber objCType], @encode(long long))) == 0) {
                        if (SQLITE_OK != sqlite3_bind_double(stmt, i, [arg longValue])) {
                            if (error) {
								NSLog(@"Erreur !");
                            }
                            return results;
                        }
                    } else if((strcasecmp([aNumber objCType], @encode(float))) == 0) {
                        if (SQLITE_OK != sqlite3_bind_double(stmt, i, [arg floatValue])) {
                            if (error) {
                                NSLog(@"Erreur !");
                            }
                            return results;
                        }
                    } else {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else if ([[arg className] isEqualToString: @"NSCFString"]) {
                    if (SQLITE_OK != sqlite3_bind_text(stmt, i, [arg UTF8String], (int)strlen([arg UTF8String]), NULL)) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else if ([[arg className] isEqualToString: @"NSPathStore2"]) {
                    if (SQLITE_OK != sqlite3_bind_text(stmt, i, [arg UTF8String], (int)strlen([arg UTF8String]), NULL)) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else if ([[arg className] isEqualToString: @"NSCFBoolean"]) {
                    if (SQLITE_OK != sqlite3_bind_int(stmt, i, [arg intValue])) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                    
                } else if ([[arg className] isEqualToString: @"__NSCFDate"]) {
                    if (SQLITE_OK != sqlite3_bind_double(stmt, i, (long)[arg timeIntervalSince1970])) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else if ([[arg className] isEqualToString: @"NSCFData"] || [[arg className] isEqualToString: @"NSConcreteData"]) {
                    if (SQLITE_OK != sqlite3_bind_blob(stmt, i, [arg bytes], (int)[arg length], NULL)) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else if ([[arg className] isEqualToString: @"NSNull"]) {
                    if (SQLITE_OK != sqlite3_bind_null(stmt, i)) {
                        if (error) {
                            NSLog(@"Erreur !");
                        }
                        return results;
                    }
                } else {
                    if (error) {
                        NSLog(@"Erreur !");
                    }
                    return results;
                }
                i++;
            }
        }

		
        while (SQLITE_ROW == sqlite3_step(stmt)) { // ATTENTION OBLIGATOIRE SINON NE FONCTIONNE PAS
            if (!results) {
                results = [[NSMutableArray alloc] init];
            }
            
		}

        if (SQLITE_OK != sqlite3_finalize(stmt)) {
            if (error) {
                NSLog(@"Erreur :  LA REQUETE A ECHOUE");
			}
            return [results autorelease];
        }
        
        
    }
    
    return [results autorelease];
}



- (NSArray *)SQLQuery: (NSString *)sqlQuery withError: (NSError **)error
{
    return [self SQLQuery: sqlQuery withArguments: nil andError: error];
}

//pour debug
- (NSNumber *)lastInsert
{
    return [NSNumber numberWithLongLong: sqlite3_last_insert_rowid(_database)];
}

@end
