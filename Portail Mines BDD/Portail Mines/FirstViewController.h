//
//  FirstViewController.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IdentificationViewController;
@class Reseau;
@class AffichageMessage;

@interface FirstViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate> {
    @private
        BOOL choixNouveau;
        BOOL chargementEnCours;
        Reseau *reseauTest;
        NSArray *messages;
        NSArray *tousMessages;
        NSArray *utilise;
        UISegmentedControl *choix;
        UIRefreshControl *refresh;
        AffichageMessage *vueDetail;
    
        NSArray *nouveauTableauFini;
        NSArray *nouveauTableauFiniTous;
    
        NSDateFormatter *deformatter;
        NSDateFormatter *formatterJour;
}

@property (nonatomic, strong) IBOutlet UITableView *liste;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
