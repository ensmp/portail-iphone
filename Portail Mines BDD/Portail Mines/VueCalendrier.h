//
//  VueCalendrier.h
//  Portail Mines
//
//  Created by Valérian Roche on 17/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;
@class AffichageEvenement;

@interface VueCalendrier : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    Reseau *reseau;
    NSArray *calendrier;
    NSDateFormatter *deformatter;
    NSDateFormatter *formatter;
    NSDateFormatter *formatterJour;
    NSDateFormatter *deformatterMois;
    NSArray *listeMoisTriee;
    NSMutableDictionary *calendrierTriee;
    AffichageEvenement *vueDetail;
}

@property (strong, nonatomic) IBOutlet UITableView *liste;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
