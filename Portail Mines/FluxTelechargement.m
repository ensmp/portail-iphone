//
//  FluxTelechargement.m
//  Portail Mines
//
//  Created by Valérian Roche on 15/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "FluxTelechargement.h"
#import "Reseau.h"

@implementation FluxTelechargement

-(id)initWithDomaine:(NSString *)domaine etUsername:(NSString *)username withParent:(Reseau *)parent etPhoto:(BOOL)photoOuDoc {
    self = [super init];
    if (self) {
        nomDomaine = domaine;
        reseau = parent;
        type = photoOuDoc;
        personne = username;
        if (photoOuDoc) {
            getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/static/%@.jpg",username]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        }
        else {
            getRequete = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[nomDomaine stringByAppendingString:[NSString stringWithFormat:@"/people/%@/json",username]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        }

    }
    return self;
}

-(void)startDownload {
    connection = [[NSURLConnection alloc] initWithRequest:getRequete delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) data = [[NSMutableData alloc] init];
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    if (type) {
        image = [UIImage imageWithData:data];
        [reseau renvoieImage:image forUsername:personne];
    }
    else {
        NSError *error;
        NSDictionary *dico = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
        }
        [reseau renvoieInfos:dico forUsername:personne];
    }
    data=nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Erreur time-out");
    if (type) {
        [reseau renvoieImage:nil forUsername:personne];
    }
    else {
        [reseau renvoieInfos:nil forUsername:personne];
    }

}

@end
