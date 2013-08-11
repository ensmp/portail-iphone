//
//  Modele.m
//  Portail Mines
//
//  Created by Valérian Roche on 24/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "Modele.h"
#import "KeychainItemWrapper.h"

// ####################################
//           Interface privée
// ####################################

@interface Modele()

@property (nonatomic, strong) NSArray *trombi, *message, *tousMessages, *petitsCours;
@property (nonatomic, strong) NSMutableArray *telechargements;
@property (nonatomic, strong) NSDictionary *messagesChat;
@property (nonatomic, strong) NSMutableDictionary *images, *messages, *edtTelecharge, *photoAssos;
@property (nonatomic, strong) NSDateFormatter *formatter, *deformatter;
@property (nonatomic, strong) NSDateComponents *decalage;
@property (nonatomic, strong) NSString *nomDomaine;
@property (nonatomic, strong) NSManagedObjectContext *objectContext;

@property (nonatomic) BOOL enPause, majListe, telechargementSondage, majCalendrier, changementTrombi;

-(void)identification;
-(void)recupTout;

@end

@implementation Modele
@synthesize vendomeEnCours;

// Test, voir si concluant
static Modele *modelePartage = nil;
+(Modele *)modelePartage:(NSManagedObjectContext *)context {
    if (!modelePartage) {
        modelePartage = [[Modele alloc] init];
        [modelePartage setContext:context];
    }
    return modelePartage;
}

// ####################################
//        Surcharge des getters
// ####################################

-(NSString *)nomDomaine {
    if (!_nomDomaine) _nomDomaine = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Domaine"];
    return _nomDomaine;
}

-(NSMutableDictionary *)edtTelecharge {
    if (!_edtTelecharge) {
        _edtTelecharge = [[NSMutableDictionary alloc] initWithCapacity:13];
    }
    return _edtTelecharge;
}

-(NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _formatter;
}

-(NSDateFormatter *)deformatter {
    if (!_deformatter) {
        _deformatter = [[NSDateFormatter alloc] init];
        [_deformatter setDateFormat:@"dd/MM/yyyy"];
    }
    return _deformatter;
}

-(NSDateComponents *)decalage {
    if (!_decalage) _decalage = [[NSDateComponents alloc] init];
    return _decalage;
}


// ####################################
//          Délégué du réseau
// ####################################

-(void)setListeEdtTelecharge:(NSString *)edt {
    [self.edtTelecharge setObject:[NSNumber numberWithBool:YES] forKey:edt];
}

-(BOOL)sauvegardeSondage:(NSDictionary *)sondage apresVote:(BOOL)vote {
    NSDate *parution = [self.deformatter dateFromString:[sondage objectForKey:@"date_parution"]];
    
    NSString *date = [self.formatter stringFromDate:parution];
    //NSDate *dateDeformattee = [formatter dateFromString:date];
    
    NSString *fichierSondage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/sondages/" stringByAppendingString:date]];
    
    if ([sondage writeToFile:fichierSondage atomically:NO]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)sauvegardeMessage:(NSArray *)messages pourTous:(BOOL)tous {
    NSString *fichierMessage;
    if (tous) {
        self.tousMessages = messages;
        fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tous-messages.plist"];
    }
    else {
        self.message = messages;
        fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/messages.plist"];
    }
    return [messages writeToFile:fichierMessage atomically:NO];
}

-(void)setPhotoAsso:(UIImage *)image pourAsso:(NSString *)asso {
    [self.photoAssos setObject:image forKey:asso];
}

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne {
    if ([self.telechargements count] && !self.enPause) {
        [[self.telechargements objectAtIndex:0] startDownload];
        [self.telechargements removeObjectAtIndex:0];
    }
    if (image) {
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",personne]];
        if ([data writeToFile:fichierImage atomically:NO]) {
            [self.images setObject:image forKey:personne];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:personne, [NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"username",@"succes",@"image", nil]]];
            
        }
    }
}

-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne {
    if ([self.telechargements count] && !self.enPause) {
        [[self.telechargements objectAtIndex:0] startDownload];
        [self.telechargements removeObjectAtIndex:0];
    }
    if (dico) {
        NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",personne]];
        if ([dico writeToFile:fichierDico atomically:NO]) {
            [self.messages setObject:dico forKey:personne];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:personne, [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"username",@"succes",@"image", nil]]];
        }
    }
}

-(void)sauvegardeTrombi:(NSArray *)trombi {
    NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
    self.trombi = trombi;
    [self.trombi writeToFile:fichierTrombi atomically:YES];
    [self performSelectorInBackground:@selector(recupTout) withObject:nil];
}


// ####################################
//             Implémentation
//          des méthodes privées
// ####################################

-(void)identification {
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [self identification:[key objectForKey:(__bridge id)kSecAttrAccount] andPassword:[key objectForKey:(__bridge id)kSecValueData]];
    key = nil;
}

-(void)recupTout {
    self.images = [NSMutableDictionary dictionaryWithCapacity:[self.trombi count]];
    self.telechargements = [NSMutableArray arrayWithCapacity:2*[self.trombi count]];
    
    for (NSDictionary *dico in self.trombi) {
        [self getInfos:[dico objectForKey:@"username"] etTelechargement:NO];
    }
    for (NSDictionary *dico in self.trombi) {
        [self getImage:[dico objectForKey:@"username"] etTelechargement:NO];
    }
    
    for (int i=0;i<40;i++) {
        if ([self.telechargements count]) {
            [[self.telechargements objectAtIndex:0] startDownload];
            [self.telechargements removeObjectAtIndex:0];
        }
    }
    [self listeVendomes];
}

// ####################################
//             Implémentation
//         des méthodes publiques
// ####################################

// ############# Réseau ###############

-(void)connectionDispo {
    [self.reseau requeteConnexionDispo];
}

-(BOOL)dejaConnecte {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dejaConnecte"];
}

-(void)getToken {
    [self.reseau requeteToken];
}

-(BOOL)identification:(NSString *)username andPassword:(NSString *)password {
    
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    if ([existants count] == 0) {
        return NO;
    }
    
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [key setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [key setObject:password forKey:(__bridge id)(kSecValueData)];
    key = nil;
    
    [self.reseau requeteIdentAvecUsername:username etPassword:password etCookie:[existants objectAtIndex:0]];
    
    
    return YES;
}

-(BOOL)deconnexion {
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [key resetKeychainItem];
    key = nil;
    
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    if ([existants count] >= 2) {
        for (NSHTTPCookie *cookie in existants) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    if ([existants count] == 1) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dejaConnecte"];
    
    return YES;
}

// ############# Emploi du temps ###############

-(NSData *)getEmploiDuTemps:(NSString *)choix {
    NSString *fichierEdt = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/edt/" stringByAppendingString:[[choix componentsSeparatedByString:@"/"] lastObject]]];
    
    if (![[self.edtTelecharge objectForKey:[[choix componentsSeparatedByString:@"/"] lastObject]] boolValue]) {
        [self.reseau requeteEdt:choix];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierEdt]) {
        return [NSData dataWithContentsOfFile:fichierEdt];
    }
    else return nil;
}

// ############# Vendômes ###############

-(NSArray *)listeVendomes {
    NSArray *listeVendomes = nil;
    NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/vendomes.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierVendome]) {
        listeVendomes = [[NSArray alloc] initWithContentsOfFile:fichierVendome];
    }
    
    if (!self.majListe) {
        self.majListe = YES;
        [self listeVendomesAvecTelechargement];
    }
    
    return listeVendomes;
}

-(void)listeVendomesAvecTelechargement {
    [self.reseau requeteListeVendomeAvecTelechargement];
}

-(NSData *)getVendome:(NSString *)urlVendome {
    NSData *doc = nil;
    NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:[[urlVendome componentsSeparatedByString:@"/"] lastObject]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierVendome]) {
        doc = [[NSData alloc] initWithContentsOfFile:fichierVendome];
    }
    else if (![self.vendomeEnCours isEqualToString:[[urlVendome componentsSeparatedByString:@"/"] lastObject]]){
        [self.reseau requeteVendome:urlVendome];
        self.vendomeEnCours = [[urlVendome componentsSeparatedByString:@"/"] lastObject];
    }
    return doc;
}

// ############# Sondages ###############

-(NSArray *)obtenirSondage:(NSDate *)date etPrecedent:(BOOL)precedent{
    NSString *dossierSondage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/sondages/"];
    
    NSDictionary *dicoSondage = nil;
    BOOL telecharge = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dossierSondage stringByAppendingString:[self.formatter stringFromDate:date]]]) {
        dicoSondage = [NSDictionary dictionaryWithContentsOfFile:[dossierSondage stringByAppendingString:[self.formatter stringFromDate:date]]];
        
        if ([[dicoSondage objectForKey:@"is_premier"] boolValue] && !self.telechargementSondage) {
            self.telechargementSondage = YES;
        }
        else {
            telecharge = NO;
            self.telechargementSondage = NO;
        }
    }
    
    if (telecharge) {
        telecharge = NO;
        
        NSDateComponents *joursDecalage = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
        
        [self.reseau requeteSondage:[joursDecalage day]];
        
        NSArray *fichiers = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dossierSondage error:NULL];
        if (fichiers && [fichiers count]) {
            int index = [fichiers indexOfObjectPassingTest:^BOOL(id obj,NSUInteger ind, BOOL *stop){
                if ([(NSString *)[[(NSString *)obj componentsSeparatedByString:@"/"] lastObject] compare:[self.formatter stringFromDate:date]] == NSOrderedDescending) {
                    BOOL stopp = YES;
                    stop = &stopp;
                    return YES;
                }
                return NO;
            }];
            if (precedent && index > 0)
                index--;
            if (index > [fichiers count])
                index = [fichiers count]-1;
            
            if (![[fichiers objectAtIndex:index] isEqualToString:@".DS_STORE"]) {
                dicoSondage = [NSDictionary dictionaryWithContentsOfFile:[dossierSondage stringByAppendingString:[fichiers objectAtIndex:index]]];
                date = [self.formatter dateFromString:[fichiers objectAtIndex:index]];
            }
        }
    }
    NSArray *tab = [NSArray arrayWithObjects:dicoSondage, date, nil];
    
    return tab;
}

-(void)voteSondage:(NSInteger)choix {
    [self.reseau postVoteSondage:choix];
}

// ############# Messages ###############

-(NSArray *)getMessageAvecTous:(BOOL)tous {
    return [self getMessageAvecTous:tous etTelechargement:NO];
}

-(NSArray *)getMessageAvecTous:(BOOL)tous etTelechargement:(BOOL)telechargement {
    if (!tous) {
        if (!self.message) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/messages.plist"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                self.message = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }
            
            [self.reseau requeteMessagePourTous:NO];
        }
        else if (telechargement) {
            [self.reseau requeteMessagePourTous:NO];
        }
        
        return self.message;
    }
    else {
        if (!self.tousMessages) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tous-messages.plist"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                self.tousMessages = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }

            [self.reseau requeteMessagePourTous:YES];
        }
        else if (telechargement) {
            [self.reseau requeteMessagePourTous:YES];
        }
        
        return self.tousMessages;
    }
}

-(void)setLu:(BOOL)lu pourMessage:(int)ident {
    NSString *url = [self.nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/messages/%d/",ident]];
    if (lu) {
        url = [url stringByAppendingString:@"lire/"];
    }
    else {
        url = [url stringByAppendingString:@"classer_non_lu/"];
    }
    [self.reseau postMessageLu:url];
}

-(void)setFavori:(BOOL)favori pourMessage:(int)ident {
    NSString *url = [self.nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/messages/%d/",ident]];
    if (favori) {
        url = [url stringByAppendingString:@"classer_important/"];
    }
    else {
        url = [url stringByAppendingString:@"classer_non_important/"];
    }
    [self.reseau postMessageFavori:url];
}

-(BOOL)ecrireMessage:(NSArray *)messagesModifies avecTous:(BOOL)tous {
    NSString *fichierMessage;
    if (tous) {
        fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/messages.plist"];
    }
    else {
        fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tous-messages.plist"];
    }
    return [messagesModifies writeToFile:fichierMessage atomically:NO];
}

// ########### Petits Cours ###########

-(NSArray *)getPetitsCours {
    if (!self.petitsCours) {
        [self.reseau requetePetitsCours];
        return nil;
    }
    else {
        return self.petitsCours;
    }
}

-(void)demanderPC:(int)i {
    [self.reseau requeteDemandePCpourID:i];
}

// ############ Calendrier ############

-(NSArray *)getCalendrier {
    NSString *fichierCalendrier = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/calendrier.plist"];
    NSArray *calendier;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierCalendrier]) {
        calendier = [[NSArray alloc] initWithContentsOfFile:fichierCalendrier];
    }
    if (!self.majCalendrier) {
        self.majCalendrier = YES;
        [self.reseau requeteCalendrier];
    }
    else {
        self.majCalendrier = NO;
    }
    
    return calendier;
}

// ############ Photo Assos ###########

-(UIImage *)getPhotoAsso:(NSString *)asso {
    if (self.photoAssos && [self.photoAssos objectForKey:asso]) {
        return [self.photoAssos objectForKey:asso];
    }
    
    else {
        if (!self.photoAssos) {
            self.photoAssos = [[NSMutableDictionary alloc] init];
        }
        
        UIImage *image;
        NSString *fichierPhoto = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos-assoces/%@.png",asso]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierPhoto]) {
            image = [UIImage imageWithContentsOfFile:fichierPhoto];
            if (!image) {
                [[NSFileManager defaultManager] removeItemAtPath:fichierPhoto error:nil];
            }
            else {
                [self.photoAssos setObject:image forKey:asso];
            }
        }
        [self.reseau requetePhotoAsso:asso];
        return image;
    }
}

// ############## Trombi ##############

-(NSArray *)getTrombi {
    if (!self.trombi) {
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierTrombi]) {
            self.trombi = [[NSArray alloc] initWithContentsOfFile:fichierTrombi];
        }
        if (!self.changementTrombi) {
            [self.reseau requeteTrombi];
            self.changementTrombi = YES;
        }
    }
    return self.trombi;
}

-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        UIImage *result = [self.images objectForKey:identifiant];
        if (!result) {
            NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",identifiant]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:fichierImage]) {
                if (self.reseau.reseau) {
                    [self getImage:identifiant etTelechargement:YES];
                }
                return nil;
            }
            else {
                UIImage *image = [UIImage imageWithContentsOfFile:fichierImage];
                [self.images setObject:image forKey:identifiant];
                return image;
            }
        }
        else {
            return result;
        }
    }
    else {
        if (!self.reseau.reseau) {
            [self getImage:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:self.nomDomaine etUsername:identifiant withParent:self etPhoto:YES];
            [self.telechargements addObject:objet];
            objet = nil;
            return nil;
        }
    }
}

-(UIImage *)getImage:(NSString *)identifiant {
    UIImage *result = [self.images objectForKey:identifiant];
    if (!result) {
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",identifiant]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fichierImage]) {
            return nil;
        }
        else {
            UIImage *image = [UIImage imageWithContentsOfFile:fichierImage];
            [self.images setObject:image forKey:identifiant];
            return image;
        }
    }
    else {
        return result;
    }
}

-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        NSDictionary *dico = [self.messages objectForKey:identifiant];
        if (!dico) {
            NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",identifiant]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDico]) {
                if (self.reseau.reseau) {
                    [self getInfos:identifiant etTelechargement:YES];
                }
                return [[self.trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username like %@",identifiant]] objectAtIndex:0];
            }
            else {
                NSDictionary *dico = [NSDictionary dictionaryWithContentsOfFile:fichierDico];
                [self.messages setObject:dico forKey:identifiant];
                return dico;
            }
        }
        else {
            return dico;
        }
    }
    else {
        if (!self.reseau.reseau) {
            [self getInfos:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:self.nomDomaine etUsername:identifiant withParent:self etPhoto:NO];
            [self.telechargements addObject:objet];
            objet = nil;
            return nil;
        }
    }
}

-(void)chercheImageOuMessage:(BOOL)imageOuMessage pourUsername:(NSString *)username {
    FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:self.nomDomaine etUsername:username withParent:self etPhoto:imageOuMessage];
    [objet startDownload];
}

// ############### Chat ###############

-(NSDictionary *)getChat {
    [self.reseau requeteChat];
    return self.messagesChat;
}

-(void)postChat:(NSString *)message {
    [self.reseau postMessageChat:message];
}


// ####################################
//         Méthode de mémoire
// ####################################

- (void)didReceiveMemoryWarning
{
    [self.images removeAllObjects];
    [self.messages removeAllObjects];
    [self.edtTelecharge removeAllObjects];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillResignActive {
    self.enPause = YES;
    [self identification];
    [self.reseau applicationWillResignActive];
}

- (void)applicationDidBecomeActive {
    self.enPause = NO;
    [self identification];
    if ([self.telechargements count]) {
        for (int i=0;i<40;i++) {
            if ([self.telechargements count]) {
                [[self.telechargements objectAtIndex:0] startDownload];
                [self.telechargements removeObjectAtIndex:0];
            }
        }
    }
    [self.reseau applicationDidBecomeActive];
}

-(void)applicationDidEnterBackground {
    [self.reseau applicationDidEnterBackground];
}
-(void)applicationWillEnterForeground {
    [self.reseau applicationWillEnterForeground];
}

@end
