//
//  Réseau.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FluxTelechargement;

@interface Reseau : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    @private
    NSURLConnection *ident;
    NSURLConnection *testReseau;
    NSURLConnection *recupToken;
    NSURLConnection *recupTrombi;
    NSURLConnection *recupMessage;
    NSURLConnection *recupPhoto;
    BOOL reseau;
    BOOL connecte;
    BOOL change;
    NSMutableData *donneesRecues;
    NSArray *trombi;
    NSArray *message;
    NSString *identPhoto;
    NSString *identInfo;
    NSMutableDictionary *images;
    NSMutableDictionary *messages;
    
    NSMutableArray *telechargements;
}

@property (nonatomic,strong) NSString *nomDomaine;
-(id)init;
-(void)connectionDispo;
-(BOOL)dejaConnecte;
-(void)getToken;
-(BOOL)identification:(NSString *)username andPassword:(NSString *)password;
-(BOOL)deconnexion;

// Emploi du temps
-(void)getEmploiDuTemps:(NSString *)choix;

// Messages
-(NSArray *)getMessage;

// Trombi
-(NSArray *)getTrombi;
-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
-(UIImage *)getImage:(NSString *)identifiant;
-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement;
// Pour la gestion des résultats
-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne;
-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne;
-(void)chercheImage:(NSString *)username pourImage:(BOOL)imageOuMessage;

@end
