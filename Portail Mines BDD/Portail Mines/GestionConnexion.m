//
//  GestionConnexion.m
//  Portail Mines
//
//  Created by Valérian Roche on 07/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "GestionConnexion.h"
#import "IdentificationViewController.h"
#import "Reseau.h"

@implementation GestionConnexion

-(id)initWithController:(UIViewController *)nouveauController etReseau:(Reseau *)nouveauReseau {
    if (self) {
        controller = nouveauController;
        reseau = nouveauReseau;
    }
    return self;
}

-(void)afficherControllerAvecAnimation:(BOOL)anime {
    if ([reseau dejaConnecte])
        [reseau deconnexion];
    control = [[IdentificationViewController alloc] initWithNibName:@"IdentificationViewController" bundle:nil andNetwork:reseau];
    if (anime)
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    else
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [controller presentViewController:control animated:anime completion:nil];
    [control setDelegue:self];
    control = nil;
}

// ##################### Gère la déconnexion #######################

-(void)deconnexion {
    [[[UIAlertView alloc] initWithTitle:@"Deconnexion" message:@"Tu veux vraiment te déconnecter??" delegate:self cancelButtonTitle:@"Et oui, je me casse!!" otherButtonTitles:@"Mais non je reste",nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self afficherControllerAvecAnimation:YES];
        [reseau deconnexion];
    }
}

-(void)supprimerController {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [controller dismissViewControllerAnimated:YES completion:nil];
    control = nil;
    controller = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void)applicationWillResignActive {
    if (control)
        [control applicationWillResignActive];
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
}

- (void)applicationDidBecomeActive {
    if (control)
        [control applicationDidBecomeActive];
}

@end
