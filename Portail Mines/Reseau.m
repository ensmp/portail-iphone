//
//  Réseau.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "Reseau.h"
#import "FirstViewController.h"
#import "FluxTelechargement.h"
#import "KeychainItemWrapper.h"

@implementation Reseau

@synthesize messagesChat = _messagesChat;

-(id)init {
    self = [super init];
    if (self) {
        _nomDomaine = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Domaine"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        deformatter = [[NSDateFormatter alloc] init];
        [deformatter setDateFormat:@"dd/MM/yyyy"];
        decalage = [[NSDateComponents alloc] init];
        
        majListe = NO;
    }
    
    return self;
}

// A garder
-(void)connectionDispo {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    testReseau = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

// A supprimer
-(BOOL)dejaConnecte {
    /*NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if ([(NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:fichierDonnees] objectForKey:@"dejaConnecte"] boolValue]) {
        return YES;
    }
    else {
        return NO;
    }*/
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dejaConnecte"];
}

-(void)getToken {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_nomDomaine] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4];
    [getRequete setHTTPMethod:@"GET"];
    recupToken = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(BOOL)identification:(NSString *)username andPassword:(NSString *)password {
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    if ([existants count] == 0) {
        return NO;
    }

    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [key setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [key setObject:password forKey:(__bridge id)(kSecValueData)];
    key = nil;
    
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/accounts/login/"]]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    [chaine appendString:@"&username="];
    [chaine appendString:username];
    [chaine appendString:@"&password="];
    [chaine appendString:password];
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    ident = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
    
    return YES;
}

-(BOOL)deconnexion {
    
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [key resetKeychainItem];
    key = nil;

    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    if ([existants count] >= 2) {
        for (NSHTTPCookie *cookie in existants) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        /*[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:1]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];*/
    }
    if ([existants count] == 1) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }

    /*NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
    [temp setObject:[NSNumber numberWithBool:NO] forKey:@"dejaConnecte"];
    [temp writeToFile:fichierDonnees atomically:NO];*/
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dejaConnecte"];
    
    return YES;
}

//##################  EdT  ###################//
-(void)obtentionEdts {
    NSArray *nomEdt = [NSArray arrayWithObjects:@"Semaine/Encours1A.pdf",@"Semaine/Encours2A.pdf",@"Semaine/Encours3A.pdf",@"Semaine/Prochain1A.pdf",@"Semaine/Prochain2A.pdf",@"Semaine/Prochain3A.pdf", nil];
    for (NSString *s in nomEdt) {
        [self getEmploiDuTemps:s];
    }
    int annee = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]] year];
    if ([[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:[NSDate date]] month] < 9) {
        annee--;
    }
    NSString *chaine;
    for (int i=0;i<6;i++) {
        chaine = [NSString stringWithFormat:@"%d/S%d_%d_%d.pdf",annee,i+1,annee%1000,annee%1000+1];
        [self getEmploiDuTemps:chaine];
    }
    chaine = [NSString stringWithFormat:@"%d/VS.pdf",annee];
    [self getEmploiDuTemps:chaine];
}

-(NSData *)getEmploiDuTemps:(NSString *)choix {
    
    if (!edtTelecharge) {
        edtTelecharge = [[NSMutableDictionary alloc] initWithCapacity:13];
    }
    
    NSString *fichierEdt = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/edt/" stringByAppendingString:[[choix componentsSeparatedByString:@"/"] lastObject]]];
    
    if (![[edtTelecharge objectForKey:[[choix componentsSeparatedByString:@"/"] lastObject]] boolValue]) {
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Intranet"] stringByAppendingString:choix]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        recupEdt = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierEdt]) {
        return [NSData dataWithContentsOfFile:fichierEdt];
    }
    else return nil;
    
}

//################  Vendomes  ################//

-(NSArray *)listeVendomes {
    
    NSArray *listeVendomes = nil;
    NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/vendomes.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierVendome]) {
        listeVendomes = [[NSArray alloc] initWithContentsOfFile:fichierVendome];
    }
    
    if (!majListe) {
        majListe = YES;
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/associations/vendome/archives/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        recupVendome = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [recupVendome scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [recupVendome start];
    }
    
    return listeVendomes;
}

-(void)listeVendomesAvecTelechargement {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/associations/vendome/archives/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    recupVendome = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [recupVendome scheduleInRunLoop:[NSRunLoop mainRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [recupVendome start];
}

-(NSData *)getVendome:(NSString *)urlVendome {
    
    
    NSData *doc = nil;
    NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:[[urlVendome componentsSeparatedByString:@"/"] lastObject]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierVendome]) {
        doc = [[NSData alloc] initWithContentsOfFile:fichierVendome];
    }
    else if (![vendomeEnCours isEqualToString:[[urlVendome componentsSeparatedByString:@"/"] lastObject]]){
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:urlVendome]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
        recupVendome = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [recupVendome scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [recupVendome start];
        vendomeEnCours = [[urlVendome componentsSeparatedByString:@"/"] lastObject];
    }
    return doc;
}

//################## Sondage #################//

-(NSArray *)obtenirSondage:(NSDate *)date etPrecedent:(BOOL)precedent {
    NSString *dossierSondage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/sondages/"];
    
    NSDictionary *dicoSondage = nil;
    BOOL telecharge = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dossierSondage stringByAppendingString:[formatter stringFromDate:date]]]) {
        dicoSondage = [NSDictionary dictionaryWithContentsOfFile:[dossierSondage stringByAppendingString:[formatter stringFromDate:date]]];
        
        if ([[dicoSondage objectForKey:@"is_premier"] boolValue] && !telechargementSondage) {
            telechargementSondage = YES;
        }
        else {
            telecharge = NO;
            telechargementSondage = NO;
        }
    }
    
    if (telecharge) {
        telecharge = NO;
        
        NSDateComponents *joursDecalage = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
        
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/sondages/%d/json/",[joursDecalage day]]]]];
        sondage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [sondage scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [sondage start];
        
        NSArray *fichiers = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dossierSondage error:NULL];
        if (fichiers && [fichiers count]) {
            int index = [fichiers indexOfObjectPassingTest:^BOOL(id obj,NSUInteger ind, BOOL *stop){
                if ([(NSString *)[[(NSString *)obj componentsSeparatedByString:@"/"] lastObject] compare:[formatter stringFromDate:date]] == NSOrderedDescending) {
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
                date = [formatter dateFromString:[fichiers objectAtIndex:index]];
            }
        }
    }
    NSArray *tab = [NSArray arrayWithObjects:dicoSondage, date, nil];
    
    return tab;
}

-(void)voteSondage:(NSInteger)choix {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/sondages/voter/"]]];
    [getRequete setHTTPMethod:@"POST"];
    
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    [chaine appendString:@"&choix="];
    [chaine appendString:[NSString stringWithFormat:@"%d",choix]];
    [chaine appendString:@"&next="];
    [chaine appendString:@"/sondages/0/json/"];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    sondage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

//############### Petits Cours ###############//
-(NSArray *)getPetitsCours {
    if (!petitsCours) {
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/petitscours/json/"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        recupPC = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [recupPC scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
        [recupPC start];
        return nil;
    }
    else {
        return petitsCours;
    }
}

-(void)demanderPC:(int)i {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/petitscours/request/%d",i]]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    recupPC = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [recupPC scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [recupPC start];
}

//################# Calendrier ################//

-(NSArray *)getCalendrier {
    NSString *fichierCalendrier = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/calendrier.plist"];
    NSArray *calendier;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fichierCalendrier]) {
        calendier = [[NSArray alloc] initWithContentsOfFile:fichierCalendrier];
    }
    if (!majCalendrier) {
        majCalendrier = YES;
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/calendrier/json/"]]];
        
        recupCalendrier = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [recupCalendrier scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
        [recupCalendrier start];
    }
    else {
        majCalendrier = NO;
    }
    
    return calendier;
}

// ################# Photo asso ################ //

-(UIImage *)getPhotoAsso:(NSString *)asso {
    if (photoAssos && [photoAssos objectForKey:asso]) {
        return [photoAssos objectForKey:asso];
    }
    
    else {
        if (!photoAssos) {
            photoAssos = [[NSMutableDictionary alloc] init];
        }
        
        UIImage *image;
        NSString *fichierPhoto = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos-assoces/%@.png",asso]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierPhoto]) {
            image = [UIImage imageWithContentsOfFile:fichierPhoto];
            if (!image) {
                [[NSFileManager defaultManager] removeItemAtPath:fichierPhoto error:nil];
            }
            else {
                [photoAssos setObject:image forKey:asso];
            }
        }
        NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/static/logo_%@.png",asso]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        recupPhotoAsso = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
        [recupPhotoAsso scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [recupPhotoAsso start];
        return image;
    }
}

// ################# Messages ################# //

-(NSArray *)getMessageAvecTous:(BOOL)tous {
    return [self getMessageAvecTous:tous etTelechargement:NO];
}

-(NSArray *)getMessageAvecTous:(BOOL)tous etTelechargement:(BOOL)telechargement {
    
    if (!tous) {
        if (!message) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/messages.plist"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                message = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }
            
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        else if (telechargement) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        
        return message;
    }
    else {
        if (!tousMessages) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tous-messages.plist"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                tousMessages = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }
            
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/tous/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        else if (telechargement) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/tous/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        
        return tousMessages;
    }
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

-(void)setFavori:(BOOL)favori pourMessage:(int)identifiant {
    NSString *nom = [_nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/messages/%d/",identifiant]];
    if (favori) {
        nom = [nom stringByAppendingString:@"classer_important/"];
    }
    else {
        nom = [nom stringByAppendingString:@"classer_non_important/"];
    }
    
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:nom]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    classementMessageFavori = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)setLu:(BOOL)lu pourMessage:(int)identifiant {
    NSString *nom = [_nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/messages/%d/",identifiant]];
    if (lu) {
        nom = [nom stringByAppendingString:@"lire/"];
    }
    else {
        nom = [nom stringByAppendingString:@"classer_non_lu/"];
    }
    
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:nom]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    classementMessageLu = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

// ################### Chat ################### //

-(NSDictionary *)getChat {
    /*if (!self.messagesChat) {
        NSString *fichierChat = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/chat.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierChat]) {
            self.messagesChat = [[NSDictionary alloc] initWithContentsOfFile:fichierChat];
        }
    }*/
    
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:[_nomDomaine stringByAppendingString:@"/chat/room/2/ajax/?time=%ld"],(long)tempsChat]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    recupChat = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
    return self.messagesChat;
}

-(void)postChat:(NSString *)messagePost {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/chat/room/2/ajax/"]]];
    [getRequete setHTTPMethod:@"POST"];
    
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    [getRequete setValue:[(NSHTTPCookie *)[existants objectAtIndex:1] value] forHTTPHeaderField:@"X-CSRFToken"];
    [chaine appendString:@"time="];
    [chaine appendString:[NSString stringWithFormat:@"%ld",(long)tempsChat]];
    [chaine appendString:@"&action="];
    [chaine appendString:@"postmsg"];
    [chaine appendString:@"&message="];
    [chaine appendString:messagePost];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    postChat = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

// ################## Trombi ################## //
// Renvoie le trombi (ou nil s'il n'existe pas. Il faut donc penser à faire le teste. En cas d'attente (première connexion), il faut attendre la notification @"trombi" avant de charger à nouveau.
-(NSArray *)getTrombi {
    if (!trombi) {
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierTrombi]) {
            trombi = [[NSArray alloc] initWithContentsOfFile:fichierTrombi];
        }
        if (!change) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/people/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            recupTrombi = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
            [recupTrombi scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                  forMode:NSDefaultRunLoopMode];
            [recupTrombi start];
            change = YES;
        }
    }
    return trombi;
}

-(UIImage *)getImage:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        UIImage *result = [images objectForKey:identifiant];
        if (!result) {
            NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",identifiant]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:fichierImage]) {
                if (reseau) {
                    [self getImage:identifiant etTelechargement:YES];
                }
                return nil;
            }
            else {
                UIImage *image = [UIImage imageWithContentsOfFile:fichierImage];
                [images setObject:image forKey:identifiant];
                return image;
            }
        }
        else {
            return result;
        }
    }
    else {
        if (!reseau) {
            [self getImage:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:_nomDomaine etUsername:identifiant withParent:self etPhoto:YES];
            [telechargements addObject:objet];
            objet = nil;
            return nil;
        }
    }
}

-(UIImage *)getImage:(NSString *)identifiant {
    UIImage *result = [images objectForKey:identifiant];
    if (!result) {
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",identifiant]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fichierImage]) {
            return nil;
        }
        else {
            UIImage *image = [UIImage imageWithContentsOfFile:fichierImage];
            [images setObject:image forKey:identifiant];
            return image;
        }
    }
    else {
        return result;
    }
}

-(void)chercheImageOuMessage:(BOOL)imageOuMessage pourUsername:(NSString *)username; {
        FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:_nomDomaine etUsername:username withParent:self etPhoto:imageOuMessage];
        [objet startDownload];
}

-(NSDictionary *)getInfos:(NSString *)identifiant etTelechargement:(BOOL)telechargement {
    if (!telechargement) {
        NSDictionary *dico = [messages objectForKey:identifiant];
        if (!dico) {
            NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",identifiant]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDico]) {
                if (reseau) {
                    [self getInfos:identifiant etTelechargement:YES];
                }
                return [[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username like %@",identifiant]] objectAtIndex:0];
            }
            else {
                NSDictionary *dico = [NSDictionary dictionaryWithContentsOfFile:fichierDico];
                [messages setObject:dico forKey:identifiant];
                return dico;
            }
        }
        else {
            return dico;
        }
    }
    else {
        if (!reseau) {
            [self getInfos:identifiant etTelechargement:NO];
            return nil;
        }
        else {
            FluxTelechargement *objet = [[FluxTelechargement alloc] initWithDomaine:_nomDomaine etUsername:identifiant withParent:self etPhoto:NO];
            [telechargements addObject:objet];
            objet = nil;
            return nil;
        }
    }

}

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne {
    if ([telechargements count] && !enPause) {
        [[telechargements objectAtIndex:0] startDownload];
        [telechargements removeObjectAtIndex:0];
    }
    if (image) {
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/photos/%@.jpg",personne]];
        if ([data writeToFile:fichierImage atomically:NO]) {
            [images setObject:image forKey:personne];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:personne, [NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"username",@"succes",@"image", nil]]];
            
        }
    }
}

-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne {
    if ([telechargements count] && !enPause) {
        [[telechargements objectAtIndex:0] startDownload];
        [telechargements removeObjectAtIndex:0];
    }
    if (dico) {
        NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",personne]];
        if ([dico writeToFile:fichierDico atomically:NO]) {
            [messages setObject:dico forKey:personne];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:personne, [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"username",@"succes",@"image", nil]]];
        }
    }
}

-(void)recupTout {
    images = [NSMutableDictionary dictionaryWithCapacity:[trombi count]];
    telechargements = [NSMutableArray arrayWithCapacity:2*[trombi count]];
    
    for (NSDictionary *dico in trombi) {
        [self getInfos:[dico objectForKey:@"username"] etTelechargement:NO];
    }
    for (NSDictionary *dico in trombi) {
        [self getImage:[dico objectForKey:@"username"] etTelechargement:NO];
    }
    
    for (int i=0;i<40;i++) {
        if ([telechargements count]) {
            [[telechargements objectAtIndex:0] startDownload];
            [telechargements removeObjectAtIndex:0];
        }
    }
    [self listeVendomes];
    //[self obtentionEdts];
}

//############## Réidentification ############//
-(void)identification {
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [self identification:[key objectForKey:(__bridge id)kSecAttrAccount] andPassword:[key objectForKey:(__bridge id)kSecValueData]];
    key = nil;
}

//################## Délégué #################//

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == testReseau) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pas de reseau" object:nil];
        reseau = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        NSLog(@"Erreur réseau");
        testReseau = nil;
    }
    else if (connection == recupToken) {
        if (reseau) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
            NSLog(@"Echec site");
            recupToken = nil;
        }
    }
    else if (connection == recupTrombi) {
        NSLog(@"Erreur chargement trombi");
        recupTrombi = nil;
    }
    
    else if (connection == recupEdt) {
        NSLog(@"Echec téléchargement Edt");
        NSString *edt = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        recupEdt = nil;
    }
    
    else if (connection == recupVendome) {
        NSString *finURL = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        
        if ([finURL isEqualToString:@""]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"liste", nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            vendomeEnCours = @"";
        }
        donneesVendome = nil;
        recupVendome = nil;
    }
    
    else if (connection == sondage) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        
        if ([[morceaux objectAtIndex:[morceaux count]-2] isEqualToString:@"json"]) {
            int i = [[morceaux objectAtIndex:[morceaux count]-3] intValue];
            [decalage setDay:-i];
            NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:decalage toDate:[NSDate date] options:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],date, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
        }
        
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        }
        sondage = nil;
    }
    
    else if (connection == recupPC) {
        if ([[[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject] isEqualToString:@""])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"demandePC" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        recupPC = nil;
    }
    
    else if (connection == recupCalendrier) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendrierTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        recupCalendrier = nil;
    }
    
    else if (connection == classementMessageLu) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
    }
    
    else if (connection == classementMessageFavori) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
    }
    
    else if (connection == recupChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
    }
    
    else if (connection == postChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
    }
    
    donneesRecues = nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection == recupEdt) {
        [[challenge sender] useCredential:[NSURLCredential credentialWithUser:@"ensmp" password:@"mines" persistence:NSURLCredentialPersistenceForSession] forAuthenticationChallenge:challenge];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == testReseau) {
        reseau = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        [connection cancel];
        testReseau = nil;
    }
    else if (connection == recupTrombi || connection == recupMessage || connection == sondage || connection == recupPC || connection == recupCalendrier || connection == recupPhotoAsso || connection == recupChat || connection == postChat) {
        [donneesRecues appendData:data];
    }
    else if (connection == recupEdt) {
        [donneesRecues appendData:data];
        float progres = [donneesRecues length]/(float)tailleTelechargement;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progresTelechargement" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progres] forKey:@"progres"]];
    }
    else if (connection == recupVendome) {
        [donneesVendome appendData:data];
        float progres = [donneesVendome length]/(float)tailleTelechargement;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progresTelechargement" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progres] forKey:@"progres"]];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == recupToken) {
        NSDictionary *cookies = [(NSHTTPURLResponse *)response allHeaderFields];
        
        if ([[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:_nomDomaine]] count] != 0) {
            NSHTTPCookie *cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:_nomDomaine]] objectAtIndex:0];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Cookie" object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
        }
    }
    else if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            NSLog(@"Echec identification");
            [connection cancel];
            ident = nil;
        }
    }
    
    else if (connection == recupTrombi || connection == recupMessage || connection == sondage || connection == recupPC || connection == recupCalendrier || connection == recupPhotoAsso || connection == recupChat || connection == postChat) {
        donneesRecues = [[NSMutableData alloc] initWithLength:0];
    }
    else if (connection == recupEdt) {
        donneesRecues = [[NSMutableData alloc] initWithLength:0];
        tailleTelechargement = [response expectedContentLength];
    }
    else if (connection == recupVendome) {
        donneesVendome = [[NSMutableData alloc] initWithLength:0];
        tailleTelechargement = [response expectedContentLength];
    }
    
    else if (connection == classementMessageLu) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES],[NSNumber numberWithInt:[[morceaux objectAtIndex:[morceaux count]-3] intValue]], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu",@"Id", nil] ]];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
        }
        [connection cancel];
    }
    
    else if (connection == classementMessageFavori) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithInt:[[morceaux objectAtIndex:[morceaux count]-3] intValue]], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu",@"Id", nil] ]];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
        }
        [connection cancel];
    }
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 302) {
            
            NSLog(@"Succès");
            [connection cancel];
            ident = nil;
            
            NSDictionary *cookies = [(NSHTTPURLResponse *)response allHeaderFields];
            NSHTTPCookie *cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:_nomDomaine]] objectAtIndex:0];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Ok" object:nil]];
            [self getMessageAvecTous:NO];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dejaConnecte"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            return nil;
        }
        else if ([(NSHTTPURLResponse *)response statusCode] == 0) {
            return request;
        }
        else {
            NSLog(@"Echec");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            return request;
        }
    }
    
    return request;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == recupTrombi && donneesRecues) {
        NSError *error;
        NSMutableArray *trombiTemp = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"Trombi téléchargé");
        if (!trombiTemp) {
            [self identification];
            return;
        }
        [trombiTemp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES], nil]];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"(promo != NULL) && (promo != nil)"];
        [trombiTemp filterUsingPredicate:predicate];
        
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        trombi = [trombiTemp copy];
        [trombi writeToFile:fichierTrombi atomically:YES];
        [self performSelectorInBackground:@selector(recupTout) withObject:nil];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tTelecharge" object:nil];
        
        donneesRecues = nil;
        recupTrombi = nil;
    }
    
    else if (connection == recupMessage && donneesRecues) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        
        NSError *error;
        NSArray *result = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:&error];
        if (!result) {
            NSLog(@"Erreur lors du parsage");
                        
            if (!tentative) {
                tentative = YES;
                [self identification];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
            }
        }
        else {
            BOOL tous = YES;
            NSString *fichierMessage;
            if ([[morceaux objectAtIndex:[morceaux count]-3] isEqualToString:@"tous"]) {
                tousMessages = result;
                fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tous-messages.plist"];
            }
            else {
                tous = NO;
                message =   result;
                fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/messages.plist"];
            }
            [result writeToFile:fichierMessage atomically:NO];
            NSLog(@"Messages téléchargés");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:tous],nil] forKeys:[NSArray arrayWithObjects:@"succes",@"choix",nil]]];
        }
        donneesRecues = nil;
        recupMessage = nil;
    }
    
    else if (connection == recupEdt && donneesRecues) {
        NSData *donneesPdf = donneesRecues;
        NSString *edt = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/edt/" stringByAppendingString:edt]];
        
        if ([donneesPdf writeToFile:fichierImage atomically:NO]) {
            NSLog(@"Edt téléchargé");
            [edtTelecharge setObject:[NSNumber numberWithBool:YES] forKey:edt];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        else {
            NSLog(@"Erreur écriture edt");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        donneesRecues = nil;
        recupEdt = nil;
    }
    
    else if (connection == recupVendome && donneesVendome) {
        NSString *finURL = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        
        if ([finURL isEqualToString:@""]) {
            NSArray *liste = [NSJSONSerialization JSONObjectWithData:donneesVendome options:NSJSONReadingAllowFragments error:NULL];
            if (liste) {
                NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/vendomes.plist"];
                [liste writeToFile:fichierVendome atomically:NO];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"liste", nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"liste", nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
        }
        
        else {
            NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:finURL]];
            if ([donneesVendome writeToFile:fichierVendome atomically:NO]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
            vendomeEnCours = @"";
        }
        donneesVendome = nil;
        recupVendome = nil;
    }
    else if (connection == sondage && donneesRecues) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        if ([[morceaux objectAtIndex:[morceaux count]-2] isEqualToString:@"json"]) {
            
            NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:NULL];
            
            if (result) {
                NSDate *parution = [deformatter dateFromString:[result objectForKey:@"date_parution"]];
                
                NSString *date = [formatter stringFromDate:parution];
                NSDate *dateDeformattee = [formatter dateFromString:date];
                
                NSString *fichierSondage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/sondages/" stringByAppendingString:date]];
        
                if ([result writeToFile:fichierSondage atomically:NO]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],dateDeformattee, nil] forKeys:[NSArray     arrayWithObjects:@"succes",@"date", nil]]];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],dateDeformattee, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
                }
            }
            else {
                int i = [[morceaux objectAtIndex:[morceaux count]-3] intValue];
                [decalage setDay:-i];
                NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:decalage toDate:[NSDate date] options:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],date, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
            }
        }
        else {
            if (donneesRecues) {
                NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:NULL];
                if (result && [result objectForKey:@"nombre_reponse_1"]) {
                    
                    NSDate *parution = [deformatter dateFromString:[result objectForKey:@"date_parution"]];
                    NSString *date = [formatter stringFromDate:parution];
                    
                    NSString *fichierSondage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/sondages/" stringByAppendingString:date]];
                    
                    if ([result writeToFile:fichierSondage atomically:NO]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                    }
                    else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                    }
                }
                else {
                    [self identification];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                }
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        }
        donneesRecues = nil;
        sondage = nil;
    }
    
    else if (connection == recupPC && donneesRecues) {
        if ([[[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject] isEqualToString:@""]) {
            petitsCours = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:NULL];
            if (donneesRecues && petitsCours) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"demandePC" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        donneesRecues = nil;
        recupPC = nil;
    }
    
    else if (connection == recupCalendrier && donneesRecues) {
        NSArray *calendrier;
        calendrier = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:NULL];
        if (donneesRecues && calendrier) {
            NSString *fichierCalendrier = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/calendrier.plist"];
            if ([calendrier writeToFile:fichierCalendrier atomically:NO]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendrierTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendrierTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"calendrierTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        }
        donneesRecues = nil;
        recupCalendrier = nil;
    }
    
    else if (connection == recupPhotoAsso && donneesRecues) {
        NSString *nomAsso;
        nomAsso = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"_"] lastObject];
        NSString *fichierPhoto = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/photos-assoces/" stringByAppendingString:nomAsso]];
        [donneesRecues writeToFile:fichierPhoto atomically:NO];
        UIImage *image = [UIImage imageWithData:donneesRecues];
        if (image)
            [photoAssos setObject:image forKey:nomAsso];
        donneesRecues = nil;
        recupPhotoAsso = nil;
    }
    
    else if ((connection == recupChat || connection == postChat) && donneesRecues) {
        NSDictionary *resultat = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:nil];
        tempsChat = [[resultat objectForKey:@"time"] doubleValue];
        if ([[resultat objectForKey:@"status"] boolValue]) {
            self.messagesChat = resultat;
            NSString *fichierChat = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/chat.plist"];
            [resultat writeToFile:fichierChat atomically:NO];
            
            if (connection == recupChat) 
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj", nil]]];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj", nil]]];
        }
        else if (connection == recupChat)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithLong:tempsChat], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj",@"temps", nil]]];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithLong:tempsChat], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj",@"temps", nil]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [images removeAllObjects];
    [messages removeAllObjects];
    [edtTelecharge removeAllObjects];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillResignActive {
    enPause = YES;
}

- (void)applicationDidEnterBackground {
    if (ident) [ident cancel];
    if (testReseau) [testReseau cancel];
    if (recupToken) [recupToken cancel];
    if (recupTrombi) [recupTrombi cancel];
    if (recupMessage) [recupMessage cancel];
    if (recupEdt) [recupEdt cancel];
    if (recupVendome) [recupVendome cancel];
    if (sondage) [sondage cancel];
    if (recupPC) [recupPC cancel];
    if (recupCalendrier) [recupCalendrier cancel];
    if (recupPhotoAsso) [recupPhotoAsso cancel];
    if (classementMessageLu) [classementMessageLu cancel];
    if (classementMessageFavori) [classementMessageFavori cancel];
    if (recupChat) [recupChat cancel];
    if (postChat) [postChat cancel];
}

- (void)applicationWillEnterForeground {
    [self identification];
}

- (void)applicationDidBecomeActive {
    //if (self) {
        enPause = NO;
        if ([telechargements count]) {
            for (int i=0;i<40;i++) {
                if ([telechargements count]) {
                    [[telechargements objectAtIndex:0] startDownload];
                    [telechargements removeObjectAtIndex:0];
                }
            }
        }
    //}
}

@end
