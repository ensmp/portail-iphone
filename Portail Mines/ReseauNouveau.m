//
//  ReseauNouveau.m
//  Portail Mines
//
//  Created by Valérian Roche on 24/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "ReseauNouveau.h"

// ####################################
//           Interface privée
// ####################################

@interface ReseauNouveau()

@property (nonatomic, strong) NSURLConnection *testReseau, *recupToken, *ident, *recupTrombi, *recupMessage, *recupEdt;
@property (nonatomic, strong) NSURLConnection *recupVendome, *sondage, *recupPC, *recupCalendrier, *recupPhotoAsso;
@property (nonatomic, strong) NSURLConnection *classementMessageLu, *classementMessageFavori, *recupChat, *postChat;
@property (nonatomic, strong) NSMutableData *donneesRecues, *donneesVendome;

@property (nonatomic, strong) NSDateFormatter *deformatter;
@property (nonatomic, strong) NSDateComponents *decalage;
@property (nonatomic, strong) NSString *nomDomaine;
@property (nonatomic, readwrite) BOOL reseau, tentative;
@property (nonatomic) long tailleTelechargement;
@property (nonatomic) NSTimeInterval tempsChat;

@end

@implementation ReseauNouveau

// ####################################
//         Surcharge des getters
// ####################################

-(NSString *)nomDomaine {
    if (!_nomDomaine) _nomDomaine = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Domaine"];
    return _nomDomaine;
}

-(NSDateComponents *)decalage {
    if (!_decalage) _decalage = [[NSDateComponents alloc] init];
    return _decalage;
}

-(NSDateFormatter *)deformatter {
    if (!_deformatter) {
        _deformatter = [[NSDateFormatter alloc] init];
        [_deformatter setDateFormat:@"dd/MM/yyyy"];
    }
    return _deformatter;
}

// ####################################
//          Début des méthodes
// ####################################

-(void)requeteConnexionDispo {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    self.testReseau = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requeteToken {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.nomDomaine] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4];
    [getRequete setHTTPMethod:@"GET"];
    self.recupToken = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requeteIdentAvecUsername:(NSString *)username etPassword:(NSString *)password etCookie:(NSHTTPCookie *)cookie {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/accounts/login/"]]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[cookie value]];
    [chaine appendString:@"&username="];
    [chaine appendString:username];
    [chaine appendString:@"&password="];
    [chaine appendString:password];
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.ident = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requeteEdt:(NSString *)edt {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Intranet"] stringByAppendingString:edt]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    self.recupEdt = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requeteListeVendomeAvecTelechargement {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/associations/vendome/archives/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    self.recupVendome = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupVendome scheduleInRunLoop:[NSRunLoop mainRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [self.recupVendome start];
}

-(void)requeteVendome:(NSString *)nom {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:nom]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    self.recupVendome = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupVendome scheduleInRunLoop:[NSRunLoop mainRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [self.recupVendome start];
}

-(void)requeteSondage:(NSInteger)jour {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/sondages/%d/json/",jour]]]];
    self.sondage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.sondage scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [self.sondage start];
}

-(void)postVoteSondage:(NSInteger)choix {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/sondages/voter/"]]];
    [getRequete setHTTPMethod:@"POST"];
    
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    [chaine appendString:@"&choix="];
    [chaine appendString:[NSString stringWithFormat:@"%d",choix]];
    [chaine appendString:@"&next="];
    [chaine appendString:@"/sondages/0/json/"];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.sondage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requeteMessagePourTous:(BOOL)tous {
    NSMutableURLRequest *getRequete;
    if (tous) {
        getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/messages/tous/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    }
    else
        getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/messages/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    self.recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)postMessageLu:(NSString *)url {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.classementMessageLu = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)postMessageFavori:(NSString *)url {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [getRequete setHTTPMethod:@"POST"];
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    [chaine appendString:@"csrfmiddlewaretoken="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:1] value]];
    [chaine appendString:@"&sessionid="];
    [chaine appendString:[(NSHTTPCookie *)[existants objectAtIndex:0] value]];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    self.classementMessageFavori = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)requetePetitsCours {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/petitscours/json/"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    self.recupPC = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupPC scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [self.recupPC start];
}

-(void)requeteDemandePCpourID:(int)i {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/petitscours/request/%d",i]]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    self.recupPC = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupPC scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [self.recupPC start];
}

-(void)requeteCalendrier {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/calendrier/json/"]]];
    
    self.recupCalendrier = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupCalendrier scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
    [self.recupCalendrier start];
}

-(void)requetePhotoAsso:(NSString *)asso {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/static/logo_%@.png",asso]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    self.recupPhotoAsso = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupPhotoAsso scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
    [self.recupPhotoAsso start];
}

-(void)requeteTrombi {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/people/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    self.recupTrombi = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [self.recupTrombi scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [self.recupTrombi start];
}

-(void)requeteChat {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:[self.nomDomaine stringByAppendingString:@"/chat/room/2/ajax/?time=%ld"],(long)self.tempsChat]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    self.recupChat = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(void)postMessageChat:(NSString *)message {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.nomDomaine stringByAppendingString:@"/chat/room/2/ajax/"]]];
    [getRequete setHTTPMethod:@"POST"];
    
    NSMutableString *chaine = [[NSMutableString alloc] init];
    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.nomDomaine]];
    [getRequete setValue:[(NSHTTPCookie *)[existants objectAtIndex:1] value] forHTTPHeaderField:@"X-CSRFToken"];
    [chaine appendString:@"time="];
    [chaine appendString:[NSString stringWithFormat:@"%ld",(long)self.tempsChat]];
    [chaine appendString:@"&action="];
    [chaine appendString:@"postmsg"];
    [chaine appendString:@"&message="];
    [chaine appendString:message];
    
    [getRequete setHTTPBody:[chaine dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.postChat = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

// ####################################
//     Délégué pour les connexions
// ####################################

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (connection == self.testReseau) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pas de reseau" object:nil];
        self.reseau = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        NSLog(@"Erreur réseau");
        self.testReseau = nil;
    }
    
    else if (connection == self.recupToken) {
        if (self.reseau) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
            NSLog(@"Echec site");
            self.recupToken = nil;
        }
    }
    
    else if (connection == self.recupEdt) {
        NSLog(@"Echec téléchargement Edt");
        NSString *edt = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        self.recupEdt = nil;
    }
    
    else if (connection == self.recupVendome) {
        NSString *finURL = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        
        if ([finURL isEqualToString:@""]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"liste", nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            [self.delegue setVendomeEnCours:nil];
        }
        self.donneesVendome = nil;
        self.recupVendome = nil;
    }
    
    else if (connection == self.sondage) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        
        if ([[morceaux objectAtIndex:[morceaux count]-2] isEqualToString:@"json"]) {
            int i = [[morceaux objectAtIndex:[morceaux count]-3] intValue];
            [self.decalage setDay:-i];
            NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:self.decalage toDate:[NSDate date] options:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],date, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
        }
        
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        }
        self.sondage = nil;
    }
    
    else if (connection == self.classementMessageLu) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
    }
    
    else if (connection == self.classementMessageFavori) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
    }
    
    else if (connection == self.recupPC) {
        if ([[[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject] isEqualToString:@""])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"demandePC" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        self.recupPC = nil;
    }
    
    else if (connection == self.recupCalendrier) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendrierTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        self.recupCalendrier = nil;
    }
    
    else if (connection == self.recupTrombi) {
        NSLog(@"Erreur chargement trombi");
        self.recupTrombi = nil;
    }
    
    else if (connection == self.recupChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
    }
    
    else if (connection == self.postChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
    }
    
    self.donneesRecues = nil;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == self.recupToken) {
        NSDictionary *cookies = [(NSHTTPURLResponse *)response allHeaderFields];
        
        if ([[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:self.nomDomaine]] count] != 0) {
            NSHTTPCookie *cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:self.nomDomaine]] objectAtIndex:0];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Cookie" object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
        }
    }
    
    else if (connection == self.ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            NSLog(@"Echec identification");
            [connection cancel];
            self.ident = nil;
        }
    }
    
    else if (connection == self.recupEdt) {
        self.donneesRecues = [[NSMutableData alloc] initWithLength:0];
        self.tailleTelechargement = [response expectedContentLength];
    }
    
    else if (connection == self.recupVendome) {
        self.donneesVendome = [[NSMutableData alloc] initWithLength:0];
        self.tailleTelechargement = [response expectedContentLength];
    }
    
    else if (connection == self.recupTrombi || connection == self.recupMessage || connection == self.sondage || connection == self.recupPC || connection == self.recupCalendrier || connection == self.recupPhotoAsso || connection == self.recupChat || connection == self.postChat) {
        self.donneesRecues = [[NSMutableData alloc] initWithLength:0];
    }
    
    else if (connection == self.classementMessageLu) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES],[NSNumber numberWithInt:[[morceaux objectAtIndex:[morceaux count]-3] intValue]], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu",@"Id", nil] ]];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassementMessage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"Succes",@"Lu", nil] ]];
        }
        [connection cancel];
    }
    
    else if (connection == self.classementMessageFavori) {
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

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == self.testReseau) {
        self.reseau = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        [connection cancel];
        self.testReseau = nil;
    }
    
    else if (connection == self.recupEdt) {
        [self.donneesRecues appendData:data];
        float progres = [self.donneesRecues length]/(float)self.tailleTelechargement;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progresTelechargement" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progres] forKey:@"progres"]];
    }
    
    else if (connection == self.recupVendome) {
        [self.donneesVendome appendData:data];
        float progres = [self.donneesVendome length]/(float)self.tailleTelechargement;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progresTelechargement" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progres] forKey:@"progres"]];
    }
    
    else if (connection == self.recupTrombi || connection == self.recupMessage || connection == self.sondage || connection == self.recupPC || connection == self.recupCalendrier || connection == self.recupPhotoAsso || connection == self.recupChat || connection == self.postChat) {
        [self.donneesRecues appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if (connection == self.recupEdt) {
        [[challenge sender] useCredential:[NSURLCredential credentialWithUser:@"ensmp" password:@"mines" persistence:NSURLCredentialPersistenceForSession] forAuthenticationChallenge:challenge];
    }
    
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    
    if (connection == self.ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 302) {
            NSLog(@"Succès");
            [connection cancel];
            self.ident = nil;
            
            NSDictionary *cookies = [(NSHTTPURLResponse *)response allHeaderFields];
            NSHTTPCookie *cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:cookies forURL:[NSURL URLWithString:self.nomDomaine]] objectAtIndex:0];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Ok" object:nil]];
            [self requeteMessagePourTous:NO];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dejaConnecte"];
            
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
    
    if (connection == self.recupEdt && self.donneesRecues) {
        NSData *donneesPdf = self.donneesRecues;
        NSString *edt = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        NSString *fichierImage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/edt/" stringByAppendingString:edt]];
        
        if ([donneesPdf writeToFile:fichierImage atomically:NO]) {
            NSLog(@"Edt téléchargé");
            [self.delegue setListeEdtTelecharge:edt];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        else {
            NSLog(@"Erreur écriture edt");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"edtTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],edt, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
        }
        self.donneesRecues = nil;
        self.recupEdt = nil;
    }
    
    else if (connection == self.recupVendome && self.donneesVendome) {
        NSString *finURL = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject];
        
        if ([finURL isEqualToString:@""]) {
            NSArray *liste = [NSJSONSerialization JSONObjectWithData:self.donneesVendome options:NSJSONReadingAllowFragments error:NULL];
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
            if ([self.donneesVendome writeToFile:fichierVendome atomically:NO]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vendomeTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],finURL, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"nom", nil]]];
            }
            [self.delegue setVendomeEnCours:nil];
        }
        self.donneesVendome = nil;
        self.recupVendome = nil;
    }
    
    else if (connection == self.sondage && self.donneesRecues) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        if ([[morceaux objectAtIndex:[morceaux count]-2] isEqualToString:@"json"]) {
            
            NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:NULL];
            
            if (result) {
                NSDate *parution = [self.deformatter dateFromString:[result objectForKey:@"date_parution"]];
                if ([self.delegue sauvegardeSondage:result apresVote:NO]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],parution, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],parution, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
                }
            }
            else {
                int i = [[morceaux objectAtIndex:[morceaux count]-3] intValue];
                [self.decalage setDay:-i];
                NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:self.decalage toDate:[NSDate date] options:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sondageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],date, nil] forKeys:[NSArray arrayWithObjects:@"succes",@"date", nil]]];
            }
        }
        else {
            if (self.donneesRecues) {
                NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:NULL];
                if (result && [result objectForKey:@"nombre_reponse_1"]) {
                    if ([self.delegue sauvegardeSondage:result apresVote:YES]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                    }
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
                }
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"voteSondage" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        }
        self.donneesRecues = nil;
        self.sondage = nil;
    }
    
    else if (connection == self.recupMessage && self.donneesRecues) {
        NSArray *morceaux = [[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"];
        
        NSError *error;
        NSArray *result = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:&error];
        if (!result) {
            NSLog(@"Erreur lors du parsage");
            
            if (!self.tentative) {
                self.tentative = YES;
                [self.delegue identification];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"succes"]];
            }
        }
        else {
            BOOL tous = YES;
            if ([[morceaux objectAtIndex:[morceaux count]-3] isEqualToString:@"tous"]) {
                [self.delegue sauvegardeMessage:result pourTous:YES];
            }
            else {
                tous = NO;
                [self.delegue sauvegardeMessage:result pourTous:NO];
            }
            NSLog(@"Messages téléchargés");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:tous],nil] forKeys:[NSArray arrayWithObjects:@"succes",@"choix",nil]]];
        }
        self.donneesRecues = nil;
        self.recupMessage = nil;
    }
    
    else if (connection == self.recupPC && self.donneesRecues) {
        if ([[[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"/"] lastObject] isEqualToString:@""]) {
            NSArray *petitsCours = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:NULL];
            if (self.donneesRecues && petitsCours) {
                [self.delegue setPetitCours:petitsCours];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pcTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
            }
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"demandePC" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes", nil]]];
        
        self.donneesRecues = nil;
        self.recupPC = nil;
    }
    
    else if (connection == self.recupCalendrier && self.donneesRecues) {
        NSArray *calendrier;
        calendrier = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:NULL];
        if (self.donneesRecues && calendrier) {
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
        self.donneesRecues = nil;
        self.recupCalendrier = nil;
    }
    
    else if (connection == self.recupPhotoAsso && self.donneesRecues) {
        NSString *nomAsso;
        nomAsso = [[[[[connection currentRequest] URL] absoluteString] componentsSeparatedByString:@"_"] lastObject];
        NSString *fichierPhoto = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/photos-assoces/" stringByAppendingString:nomAsso]];
        [self.donneesRecues writeToFile:fichierPhoto atomically:NO];
        UIImage *image = [UIImage imageWithData:self.donneesRecues];
        if (image)
            [self.delegue setPhotoAsso:image pourAsso:nomAsso];
        self.donneesRecues = nil;
        self.recupPhotoAsso = nil;
    }
    
    else if (connection == self.recupTrombi && self.donneesRecues) {
        NSError *error;
        NSMutableArray *trombiTemp = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"Trombi téléchargé");
        if (!trombiTemp) {
            [self.delegue identification];
            return;
        }
        [trombiTemp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES], nil]];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"(promo != NULL) && (promo != nil)"];
        [trombiTemp filterUsingPredicate:predicate];
        
        [self.delegue sauvegardeTrombi:[trombiTemp copy]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tTelecharge" object:nil];
        
        self.donneesRecues = nil;
        self.recupTrombi = nil;
    }
    
    else if ((connection == self.recupChat || connection == self.postChat) && self.donneesRecues) {
        NSDictionary *resultat = [NSJSONSerialization JSONObjectWithData:self.donneesRecues options:NSJSONReadingAllowFragments error:nil];
        self.tempsChat = [[resultat objectForKey:@"time"] doubleValue];
        if ([[resultat objectForKey:@"status"] boolValue]) {
            [self.delegue setMessagesChat:resultat];
            NSString *fichierChat = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/chat.plist"];
            [resultat writeToFile:fichierChat atomically:NO];
            
            if (connection == self.recupChat)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj", nil]]];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj", nil]]];
        }
        else if (connection == self.recupChat)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MajChat" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithLong:self.tempsChat], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj",@"temps", nil]]];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvoieValide" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithLong:self.tempsChat], nil] forKeys:[NSArray arrayWithObjects:@"succes",@"maj",@"temps", nil]]];
    }
    
}


// ####################################
//       Méthodes pour multi-apps
// ####################################

- (void)applicationDidEnterBackground {
    if (self.ident) [self.ident cancel];
    if (self.testReseau) [self.testReseau cancel];
    if (self.recupToken) [self.recupToken cancel];
    if (self.recupTrombi) [self.recupTrombi cancel];
    if (self.recupMessage) [self.recupMessage cancel];
    if (self.recupEdt) [self.recupEdt cancel];
    if (self.recupVendome) [self.recupVendome cancel];
    if (self.sondage) [self.sondage cancel];
    if (self.recupPC) [self.recupPC cancel];
    if (self.recupCalendrier) [self.recupCalendrier cancel];
    if (self.recupPhotoAsso) [self.recupPhotoAsso cancel];
    if (self.classementMessageLu) [self.classementMessageLu cancel];
    if (self.classementMessageFavori) [self.classementMessageFavori cancel];
    if (self.recupChat) [self.recupChat cancel];
    if (self.postChat) [self.postChat cancel];
}

-(void)applicationWillResignActive{}
-(void)applicationWillEnterForeground{}
-(void)applicationDidBecomeActive{}



@end
