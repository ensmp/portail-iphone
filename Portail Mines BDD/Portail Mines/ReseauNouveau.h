//
//  ReseauNouveau.h
//  Portail Mines
//
//  Created by Valérian Roche on 24/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReseauDelegate <NSObject>

@optional
    @property (nonatomic, strong) NSString *vendomeEnCours;

    -(void)identification;

    -(void)setListeEdtTelecharge:(NSString *)edt;
    -(BOOL)sauvegardeSondage:(NSDictionary *)sondage apresVote:(BOOL)vote;
    -(BOOL)sauvegardeMessage:(NSArray *)messages pourTous:(BOOL)tous;
    -(void)setPetitCours:(NSArray *)petitsCours;
    -(void)setPhotoAsso:(UIImage *)image pourAsso:(NSString *)asso;
    -(void)sauvegardeTrombi:(NSArray *)trombi;
    -(void)setMessagesChat:(NSDictionary *)messagesChat;

@end



@interface ReseauNouveau : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<ReseauDelegate> delegue;
@property (nonatomic, readonly) BOOL reseau;

-(void)requeteConnexionDispo;
-(void)requeteToken;
-(void)requeteIdentAvecUsername:(NSString *)username etPassword:(NSString *)password etCookie:(NSHTTPCookie *)cookie;

-(void)requeteEdt:(NSString *)edt;

-(void)requeteListeVendomeAvecTelechargement;
-(void)requeteVendome:(NSString *)nom;

-(void)requeteSondage:(NSInteger)jour;
-(void)postVoteSondage:(NSInteger)choix;

-(void)requeteMessagePourTous:(BOOL)tous;
-(void)postMessageLu:(NSString *)url;
-(void)postMessageFavori:(NSString *)url;

-(void)requetePetitsCours;
-(void)requeteDemandePCpourID:(int)i;

-(void)requeteCalendrier;

-(void)requetePhotoAsso:(NSString *)asso;

-(void)requeteTrombi;

-(void)requeteChat;
-(void)postMessageChat:(NSString *)message;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
