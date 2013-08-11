//
//  Réseau.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FluxTelechargement.h"


@interface Reseau : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, FluxTelechargementDelegate> {
    @private
        NSURLConnection *ident;
        NSURLConnection *testReseau;
        NSURLConnection *recupToken;
        NSURLConnection *recupTrombi;
        NSURLConnection *recupMessage;
        NSURLConnection *recupEdt;
        NSURLConnection *recupVendome;
        NSURLConnection *sondage;
        NSURLConnection *recupPC;
        NSURLConnection *recupCalendrier;
        NSURLConnection *recupPhotoAsso;
        NSURLConnection *classementMessageFavori;
        NSURLConnection *classementMessageLu;
        BOOL reseau;
        BOOL change;
        BOOL tentative;
        BOOL enPause;
        NSMutableData *donneesRecues;
        NSMutableData *donneesVendome;
        NSArray *trombi;
        NSArray *message;
        NSArray *tousMessages;
        NSArray *petitsCours;
        NSMutableDictionary *images;
        NSMutableDictionary *messages;
        NSMutableDictionary *edtTelecharge;
        NSMutableDictionary *photoAssos;
        NSString *vendomeEnCours;
        long tailleTelechargement;
        BOOL majListe;
        BOOL majCalendrier;
        // Pour les sondages, permet de ne pas les télécharger deux fois pour rien
        BOOL telechargementSondage;
    
        NSMutableArray *telechargements;
    
        NSDateFormatter *formatter;
        NSDateFormatter *deformatter;
        NSDateComponents *decalage;
    
        NSTimeInterval tempsChat;
        NSURLConnection *recupChat;
        NSURLConnection *postChat;
}

@property (nonatomic,strong) NSString *nomDomaine;
@property (nonatomic, strong) NSDictionary *messagesChat;
@property (nonatomic, strong) NSManagedObjectContext *context;

-(void)connectionDispo;
-(BOOL)dejaConnecte;
-(void)getToken;
-(BOOL)identification:(NSString *)username andPassword:(NSString *)password;
-(BOOL)deconnexion;

// Emploi du temps
-(NSData *)getEmploiDuTemps:(NSString *)choix;
-(void)obtentionEdts;

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

// Mediamines
/*-(NSArray *)getListePhoto;
-(UIImage *)getPhoto:(NSString *)nom;*/

// Trombi
-(NSArray *)getTrombi;
-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
-(UIImage *)getImage:(NSString *)identifiant;
-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
// Pour la gestion des résultats
//-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne;
//-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne;
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
