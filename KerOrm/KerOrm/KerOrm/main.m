//
//  main.m
//  KerOrm
//
//  Created by Jean-Francois Kervella on 20/03/2014.
//  Copyright (c) 2014 Supinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DBGest.h"
#import "KerUser.h"

int main(int argc, const char * argv[])
{

	////////
	
    @autoreleasepool {
	
	DBGest *bdd = [[DBGest alloc] initDb:@"/Users/Captp/Desktop/kerOrm.sql"];
	// NOTE AU PROFESSEUR : remplacer par un path correct, renvoyant vers une base de donnée SQLITE3 vierge (dispo dans l'archive).
	
	
	NSString *query;
	NSError *error = nil;
	
	
	
	////////////// OBJETS SIMPLE ////////////
	
	
	//Création dynamique d'une table ( BONUS )
	NSLog(@"(Bonus)Création d'une table NSString");
	query = @"CREATE TABLE NSString (id INTEGER PRIMARY KEY, value VARCHAR(255))";
        
    //Pour désactiver la création automatique des tables , passer la ligne ci-dessous en commentaire.
	[bdd SQLQuery: query withError: &error];
	
	
	NSLog(@"Création de deux objets simples NSString value = mot_a_inserer");
	NSString *string1 = @"premiere string";
    NSString *string2 = @"deuxieme string";
	
        NSLog(@"string1 : 'premiere string' \n string2 : 'deuxieme string' ");
	
	NSLog(@"ajout des deux variables à la table NSString");
	
	
	//insertion d'objets simples dans la db.
	query = [NSString stringWithFormat:@"INSERT INTO %@ (value) VALUES ('%@')", @"NSString", string1 ];
    [bdd SQLQuery: query withError: &error]; // execution
	
	query = [NSString stringWithFormat:@"INSERT INTO %@ (value) VALUES ('%@')", @"NSString", string2 ];
	[bdd SQLQuery: query withError: &error]; // execution
        NSLog(@"Ajout correctement effectué et visible dans la table via un gestionnaire.");
	
	
	
	/*La fonction ci-dessous ne fonctionne pas car je n'arrive pas à assigner une valeure à l'objet NSString fraichement crée...ceci-dit, j'arrive à acceder à chaque enregistrements dans la table. Visible au debug.
	
	//NSLog(@"Contenu de la table NSString :");
	//query = @"SELECT * FROM NSString";
	//NSLog(@"%@", [bdd findSimpleObjects: query : @"NSString" withError: &error]); // execution de l'ORM
     
     */
    
	////////////// FIN OBJETS SIMPLES ////////
	
	
        NSLog(@"FIN OBJETS SIMPLES.");
        NSLog(@"DEBUT OBJETS COMPLEXES");
	
	////////////// OBJETS COMPLEXES //////////
	
        
	query = @"CREATE TABLE keruser (id INTEGER PRIMARY KEY, nom VARCHAR(255), prenom VARCHAR(255), age INTEGER)";
        
    //Pour désactiver la création automatique des tables , passer la ligne ci-dessous en commentaire.
	[bdd SQLQuery: query withError: &error];
        
	if (error) {
		NSLog(@"%@", error);
	}
	else {
		NSLog(@"(Bonus)Creation d'une nouvelle table 'kerUser' \n");
	}

        NSLog(@"Création de 3 kerUser :");
        keruser *usr1 = [[keruser alloc] init];
        usr1.nom  = @"kervella";
        usr1.prenom  = @"lucille";
        NSLog(@" usr1 : %@" , usr1.prenom);
        usr1.age  = [NSNumber numberWithInt: 25];
    
       // [NSThread detachNewThreadSelector:@selector(save:) toTarget:[keruser class] withObject:nil];
    
        keruser *usr2 = [[keruser alloc] init];
        usr2.nom  = @"kervella";
        usr2.prenom  = @"Jeff";
        NSLog(@"usr2 : %@" , usr2.prenom);
        usr2.age  = [NSNumber numberWithInt: 21];
	
        keruser *usr3 = [[keruser alloc] init];
        usr3.nom  = @"kervella";
        usr3.prenom  = @"Candice";
        NSLog(@"usr3 : %@" , usr3.prenom);
        usr3.age  = [NSNumber numberWithInt: 20];
	
        NSLog(@"Enregistrement des trois objets COMPLEXES 'kerUser' dans la base");
        [usr1 save: bdd];
        [usr2 save: bdd];
        [usr3 save: bdd];
        
        query = @"SELECT * FROM keruser";
        
        // Je n'ai pas compris pourquoi il y a un warning ici..Le compilateur arrive quand même à trouver la methode.
        NSMutableArray *kerusers = [bdd findObjects: query : @"keruser" withError: &error];
        
        NSLog(@"Recupération des kerUsers depuis la base de donnée, et placement dans un tableau d'objets.\n");
        NSLog(@"taille du tableau contenant les objets de type 'KerUser' : %lu \n", (unsigned long)[kerusers count]);
        
        keruser *usr4 = [ kerusers objectAtIndex:0 ];
        [kerusers addObject:usr4];
        NSLog(@"création d'un kerUser4 avec les mêmes propriétés que kerUser1 (visible au debug)");
        
        /* En posant un breakpoint sur le dernier nslog, on constate
           que toutes les valeurs des variables de usr4 sont bien les mêmes que celles de usr1. Attention,
            le resultat peut differer en fonction de la premiere ligne retournée dans la requete sql, et donc 
         du premier objet associé au NSMutableArray. Cette association est juste faite pour l'exemple.
         */
        
	///////////// FIN OBJETS COMPLEXES /////////////
	}
    return 0;
}

