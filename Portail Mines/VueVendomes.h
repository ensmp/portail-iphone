//
//  VueVendomes.h
//  Portail Mines
//
//  Created by Valérian Roche on 09/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;
@class AffichageVendome;

@interface VueVendomes : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    @private
        Reseau *reseau;
        AffichageVendome *affichage;
        NSArray *listeVendome;
        NSArray *listeTriee;
        NSArray *listeMois;
        // On met les indexPaths des vendomes téléchargés
        NSMutableArray *vendomeTelecharge;
        NSDateFormatter *decode;
        NSDateFormatter *recode;
        int decalage;
        BOOL edition;
        UIRefreshControl *refresh;
        BOOL chargementEnCours;
}

@property (strong, nonatomic) IBOutlet UITableView *liste;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
