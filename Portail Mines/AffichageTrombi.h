//
//  AffichageTrombi.h
//  Portail Mines
//
//  Created by Valérian Roche on 21/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface AffichageTrombi : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate> {
    Reseau *reseauTest;
    NSString *identifiant;
    NSDictionary *dico;
    NSArray *elements;
    NSArray *cles;
    NSDateFormatter *decode;
    NSDateFormatter *recode;
    UIActionSheet *telephone;
    BOOL iOS6higher;
}

@property (strong, nonatomic) IBOutlet UILabel *prenom;
@property (strong, nonatomic) IBOutlet UILabel *nom;
@property (strong, nonatomic) IBOutlet UILabel *promo;
@property (strong, nonatomic) IBOutlet UIImageView *vueImage;
@property (strong, nonatomic) IBOutlet UITableView *liste;

-(void)changeUsername:(NSString *)username;
-(void)majAffichage;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil etReseau:(Reseau *)reseau;

@end
