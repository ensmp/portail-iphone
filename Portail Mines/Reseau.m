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

-(id)init {
    
    if (self) {
        _nomDomaine = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Domaine"];
    }
    
    return self;
}

-(void)connectionDispo {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    /*NSData *data = [NSURLConnection sendSynchronousRequest:getRequete returningResponse:nil error:nil];
    return (data != nil ) ? YES : NO;*/
    testReseau = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
}

-(BOOL)dejaConnecte {
    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if ([(NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:fichierDonnees] objectForKey:@"dejaConnecte"] boolValue]) {
        return YES;
    }
    else {
        return NO;
    }
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
    
    //[self performSelectorInBackground:@selector(connection:) withObject:getRequete];
    return YES;
}

-(BOOL)deconnexion {
    
    KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
    [key resetKeychainItem];

    NSArray *existants = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:_nomDomaine]];
    if ([existants count] == 2) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:1]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }
    if ([existants count] == 1) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[existants objectAtIndex:0]];
    }
    connecte = NO;

    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
    [temp setObject:[NSNumber numberWithBool:NO] forKey:@"dejaConnecte"];
    [temp writeToFile:fichierDonnees atomically:NO];
    
    return YES;
}

//##################  EdT  ###################//

-(void)getEmploiDuTemps:(NSString *)choix {
    NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Nom Intranet"] stringByAppendingString:@"Semaine/Encours1A.pdf"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
}

//################## Trombi ##################//
// Renvoie le trombi (ou nil s'il n'existe pas. Il faut donc penser à faire le teste. En cas d'attente (première connexion), il faut attendre la notification @"trombi" avant de charger à nouveau.
-(NSArray *)getTrombi {
    if (!trombi) {
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierTrombi]) {
            trombi = [[NSArray alloc] initWithContentsOfFile:fichierTrombi];
        }
        if (!change && reseau) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/people/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            recupTrombi = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
            change = YES;
        }
    }
    return trombi;
}

-(NSArray *)getMessage {
    // Pour la gestion des cookies
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Ok" object:nil];
    if (!message) {
        if (reseau) {
            NSMutableURLRequest *getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_nomDomaine stringByAppendingString:@"/messages/json/"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
            recupMessage = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self];
        }
        else {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/message.data"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichierMessage]) {
                message = [[NSArray alloc] initWithContentsOfFile:fichierMessage];
            }
        }
    }
    return message;
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

-(void)chercheImage:(NSString *)username pourImage:(BOOL)imageOuMessage {
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
                int i = [trombi indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
                    if ([[[trombi objectAtIndex:index] objectForKey:@"username"] isEqualToString:identifiant]) {
                        return YES;
                    }
                    else return NO;
                }];
                return [trombi objectAtIndex:i];
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
            return nil;
        }
    }

}

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne {
    if ([telechargements count]) {
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
    if ([telechargements count]) {
        [[telechargements objectAtIndex:0] startDownload];
        [telechargements removeObjectAtIndex:0];
    }
    if (dico) {
        NSString *fichierDico = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/trombi/%@.plist",personne]];
        if ([dico writeToFile:fichierDico atomically:NO]) {
            [messages setObject:dico forKey:personne];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageTelecharge" object:nil userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:personne, [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"username",@"succes",@"image", nil]]];
        }
        else NSLog(@"c");
    }
}

-(void)recupTout {
    NSString *dosImages = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/photos/"];
    NSString *donnees = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi/"];
    
    images = [NSMutableDictionary dictionaryWithCapacity:[trombi count]];
    telechargements = [NSMutableArray arrayWithCapacity:2*[trombi count]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:donnees]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:donnees withIntermediateDirectories:YES attributes:nil error: NULL];
        /*for (NSDictionary *dico in trombi) {
            [self getImage:[dico objectForKey:@"username"] etTelechargement:YES];
        }*/
    }
    for (NSDictionary *dico in trombi) {
        [self getInfos:[dico objectForKey:@"username"] etTelechargement:NO];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dosImages]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dosImages withIntermediateDirectories:YES attributes:nil error: NULL];
        /*for (NSDictionary *dico in trombi) {
            [self getInfos:[dico objectForKey:@"username"] etTelechargement:YES];
        }*/
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
}

//################## Délégué #################//

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == testReseau) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pas de reseau" object:nil];
        reseau = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        NSLog(@"Erreur réseau");
    }
    else if (connection == recupToken) {
        if (reseau) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoCookie" object:nil];
            NSLog(@"Echec site");
        }
    }
    else if (connection == recupTrombi) {
        NSLog(@"Erreur chargement trombi");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == testReseau) {
        reseau = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDispo" object:nil];
        [connection cancel];
    }
    if (connection == recupTrombi || connection == recupMessage) {
        [donneesRecues appendData:data];
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
    if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Non" object:nil]];
            NSLog(@"Echec identification");
        }
    }
    
    if (connection == recupTrombi || connection == recupMessage) {
        donneesRecues = [[NSMutableData alloc] initWithLength:0];
    }
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (connection == ident) {
        if ([(NSHTTPURLResponse *)response statusCode] == 302) {
            NSLog(@"Succès");
            [connection cancel];
            connecte = YES;
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Ok" object:nil]];
            
            NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
            [temp setObject:[NSNumber numberWithBool:YES] forKey:@"dejaConnecte"];
            [temp writeToFile:fichierDonnees atomically:NO];
            
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
    if (connection == recupTrombi) {
        NSError *error;
        NSMutableArray *trombiTemp = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"Trombi téléchargé");
        [trombiTemp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES], nil]];
        
        NSString *fichierTrombi = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi.data"];
        trombi = [trombiTemp copy];
        
        [self performSelectorInBackground:@selector(recupTout) withObject:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tTelecharge" object:nil];
        
        [trombi writeToFile:fichierTrombi atomically:NO];
    }
    
    else if (connection == recupMessage) {
        NSError *error;
        message = [NSJSONSerialization JSONObjectWithData:donneesRecues options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Erreur lors du parsage");
            
            KeychainItemWrapper *key = [[KeychainItemWrapper alloc] initWithIdentifier:@"Identification" accessGroup:nil];
            [self identification:[key objectForKey:(__bridge id)kSecAttrAccount] andPassword:[key objectForKey:(__bridge id)kSecValueData]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessage) name:@"Ok" object:nil];
        
        }
        if (message) {
            NSString *fichierMessage = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/message.data"];
            [message writeToFile:fichierMessage atomically:NO];
            NSLog(@"Messages téléchargés");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mTelecharge" object:nil];
        }
    }
}
@end
