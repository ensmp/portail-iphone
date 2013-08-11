//
//  VueSondage.h
//  Portail Mines
//
//  Created by Valérian Roche on 10/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface VueSondage : UIViewController {
    Reseau *reseau;
    NSMutableDictionary *dicoSondages;
    
    NSDate *dateAffichee;
    NSDateComponents *jourComposant;
    
    NSDateFormatter *formatter;
    NSDateFormatter *deformatter;
    NSDateFormatter *compareDate;
}

@property (strong, nonatomic) IBOutlet UILabel *affichageDate;
@property (strong, nonatomic) IBOutlet UIButton *allerSuivant;
@property (strong, nonatomic) IBOutlet UIButton *allerPrecedent;
@property (strong, nonatomic) IBOutlet UITextView *affichageQuestion;
@property (strong, nonatomic) IBOutlet UIButton *boutton1;
@property (strong, nonatomic) IBOutlet UIButton *boutton2;
@property (strong, nonatomic) IBOutlet UIProgressView *proportion1;
@property (strong, nonatomic) IBOutlet UIProgressView *proportion2;
@property (strong, nonatomic) IBOutlet UITextView *affichageReponse1;
@property (strong, nonatomic) IBOutlet UITextView *affichageReponse2;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;
@property (strong, nonatomic) IBOutlet UILabel *pourcentage1;
@property (strong, nonatomic) IBOutlet UILabel *pourcentage2;
@property (strong, nonatomic) IBOutlet UILabel *affichageTotalVote;
@property (strong, nonatomic) IBOutlet UILabel *affichageVotes1;
@property (strong, nonatomic) IBOutlet UILabel *affichageVotes2;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(IBAction)afficherPrecedent:(id)sender;
-(IBAction)afficherSuivant:(id)sender;
-(IBAction)choixVote:(id)sender;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
