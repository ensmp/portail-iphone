//
//  AffichageEvenement.h
//  Portail Mines
//
//  Created by Valérian Roche on 17/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface AffichageEvenement : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSDictionary *dico;
    NSArray *cle;
    NSDictionary *affichageCle;
    NSDateFormatter *deformatter;
    NSDateFormatter *formatter;
    EKEventStore *store;
}

@property (strong, nonatomic) IBOutlet UITableView *liste;

-(void)changeDico:(NSDictionary *)dico;

@end
