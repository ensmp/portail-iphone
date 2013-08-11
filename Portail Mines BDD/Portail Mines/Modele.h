//
//  Modele.h
//  Portail Mines
//
//  Created by Valérian Roche on 24/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReseauNouveau.h"
#import "FluxTelechargement.h"

@interface Modele : NSObject <ReseauDelegate, FluxTelechargementDelegate>

@property (nonatomic, strong) ReseauNouveau *reseau;
@property (nonatomic, strong) NSManagedObjectContext *context;
//@property (nonatomic, strong) NSString *vendomeEnCours; // Déclaré dans le protocole


// Test
+(Modele *)modelePartage:(NSManagedObjectContext *)objectContext;


-(void)connectionDispo;
-(BOOL)dejaConnecte;
-(void)getToken;
-(BOOL)identification:(NSString *)username andPassword:(NSString *)password;
-(BOOL)deconnexion; 

// Emploi du temps
-(NSData *)getEmploiDuTemps:(NSString *)choix;

// Vendomes
-(NSArray *)listeVendomes;
-(void)listeVendomesAvecTelechargement;
-(NSData *)getVendome:(NSString *)urlVendome;

// Sondage
-(NSArray *)obtenirSondage:(NSDate *)date etPrecedent:(BOOL)precedent; 
-(void)voteSondage:(NSInteger)choix;

// Messages
-(NSArray *)getMessageAvecTous:(BOOL)tous;
-(NSArray *)getMessageAvecTous:(BOOL)tous etTelechargement:(BOOL)telechargement;
-(void)setLu:(BOOL)lu pourMessage:(int)ident;
-(void)setFavori:(BOOL)favori pourMessage:(int)ident;
-(BOOL)ecrireMessage:(NSArray *)messagesModifies avecTous:(BOOL)tous;

// Petits Cours
-(NSArray *)getPetitsCours;
-(void)demanderPC:(int)i;

// Calendrier
-(NSArray *)getCalendrier;

// Photo Assos
-(UIImage *)getPhotoAsso:(NSString *)asso;

// Trombi
-(NSArray *)getTrombi;
-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
-(UIImage *)getImage:(NSString *)identifiant;
-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
-(void)chercheImageOuMessage:(BOOL)imageOuMessage pourUsername:(NSString *)username;

// Chat
-(NSDictionary *)getChat;
-(void)postChat:(NSString *)message;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;
-(void)didReceiveMemoryWarning;

@end
