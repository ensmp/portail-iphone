//
//  VuePetitCours.h
//  Portail Mines
//
//  Created by Valérian Roche on 16/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class Reseau;
@class DetailPetitCours;

@interface VuePetitCours : UIViewController <MKMapViewDelegate> {
    @private
    Reseau *reseau;
    DetailPetitCours *vueDetail;
    NSArray *listePC;
    NSMutableArray *annotationsAffichees;
    MKCoordinateRegion region;
}

@property (strong, nonatomic) IBOutlet MKMapView *vueGPS;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
