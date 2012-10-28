//
//  VueEdt.h
//  Portail Mines
//
//  Created by Valérian Roche on 27/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;
@class AffichageEdt;

@interface VueEdt : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    @private
        Reseau *reseau;
        NSArray *edts;
        NSArray *nomEdt;
        AffichageEdt *affichage;
}

@property (strong,nonatomic) IBOutlet UITableView *liste;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;

@end
