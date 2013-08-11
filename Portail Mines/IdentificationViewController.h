//
//  IdentificationViewController.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;
@class GestionConnexion;

@interface IdentificationViewController : UIViewController <UITextFieldDelegate> {
    @private
    UISegmentedControl *nextPrevious;
    Reseau *reseau;
    NSTimer *timer;
}

@property (nonatomic, strong) GestionConnexion *delegue;
@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *boutton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(IBAction)dismiss:(id)sender;
-(void)message:(NSString *)chaine etFixe:(BOOL)repete;
-(void)blocageReseau:(NSString *)chaine;
-(void)connecte;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
