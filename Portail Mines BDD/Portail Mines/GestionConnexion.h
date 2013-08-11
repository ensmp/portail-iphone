//
//  GestionConnexion.h
//  Portail Mines
//
//  Created by Valérian Roche on 07/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Reseau;
@class IdentificationViewController;

@interface GestionConnexion : NSObject <UIAlertViewDelegate> {
    @private
    Reseau *reseau;
    UIViewController *controller;
    IdentificationViewController *control;
}

-(id)initWithController:(UIViewController *)controller etReseau:(Reseau *)reseau;
-(void)afficherControllerAvecAnimation:(BOOL)anime;
-(void)supprimerController;
-(void)deconnexion;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
