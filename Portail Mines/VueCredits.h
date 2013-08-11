//
//  VueCredits.h
//  Portail Mines
//
//  Created by Valérian Roche on 07/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AffichageReglage.h"
@class Reseau;
@class GestionConnexion;

@interface VueCredits : UIViewController <MFMailComposeViewControllerDelegate, FlipSideDelegate> {
    NSDictionary *listeAdresse;
    Reseau *reseau;
    GestionConnexion *connexion;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(IBAction)envoieMail:(id)sender;
-(IBAction)deconnexion:(id)sender;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
