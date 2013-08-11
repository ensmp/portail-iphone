//
//  DetailPetitCours.h
//  Portail Mines
//
//  Created by Valérian Roche on 16/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface DetailPetitCours : UIViewController <UIActionSheetDelegate> {
    Reseau *reseau;
    NSDictionary *dico;
    BOOL rotation;
}
@property (strong, nonatomic) IBOutlet UITextView *affichageDescription;
@property (strong, nonatomic) IBOutlet UITextView *affichageLieu;
@property (strong, nonatomic) IBOutlet UILabel *affichageMatiere;
@property (strong, nonatomic) IBOutlet UILabel *affichageNiveau;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(void)setDico:(NSDictionary *)dico;
-(IBAction)demandeCours:(id)sender;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
