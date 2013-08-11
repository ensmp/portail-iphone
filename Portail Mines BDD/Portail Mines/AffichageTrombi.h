//
//  AffichageTrombi.h
//  Portail Mines
//
//  Created by Valérian Roche on 21/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class Reseau;

@interface AffichageTrombi : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    Reseau *reseauTest;
    NSString *identifiant;
    NSDictionary *dico;
    //NSArray *elements;
    NSDictionary *elements;
    NSArray *cles;
    NSMutableArray *clesUtilisees;
    NSDateFormatter *decode;
    NSDateFormatter *recode;
    UIActionSheet *telephone;
    BOOL iOS6higher;
    // Pour le passage à une autre personne
    BOOL bascule;
    AffichageTrombi *vueDetail;
}

@property (strong, nonatomic) IBOutlet UILabel *prenom;
@property (strong, nonatomic) IBOutlet UILabel *nom;
@property (strong, nonatomic) IBOutlet UILabel *promo;
@property (strong, nonatomic) IBOutlet UIImageView *vueImage;
@property (strong, nonatomic) IBOutlet UITableView *liste;

-(BOOL)changeUsername:(NSString *)username;
-(void)majAffichage;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil etReseau:(Reseau *)reseau;
-(void)photoSelect;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
