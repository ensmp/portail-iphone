//
//  FluxTelechargement.h
//  Portail Mines
//
//  Created by Valérian Roche on 15/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReseauNouveau.h"
@class Reseau;

@protocol FluxTelechargementDelegate;

@interface FluxTelechargement : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSURLConnection *connection;
    NSMutableData* data;
    UIImage *image;
    id<FluxTelechargementDelegate> reseau;
    BOOL type;
    NSString *nomDomaine;
    NSString *personne;
    
    NSMutableURLRequest *getRequete;
}



-(void)startDownload;
-(id)initWithDomaine:(NSString *)domaine etUsername:(NSString *)username withParent:(id<FluxTelechargementDelegate>)parent etPhoto:(BOOL)photoOuDoc;

@end

@protocol FluxTelechargementDelegate <NSObject>

@required

-(void)renvoieImage:(UIImage *)image forUsername:(NSString *)personne;
-(void)renvoieInfos:(NSDictionary *)dico forUsername:(NSString *)personne;

@end