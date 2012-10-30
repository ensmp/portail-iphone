//
//  Trombi.h
//  Portail Mines
//
//  Created by Valérian Roche on 14/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;
@class OverlayViewController;
@class AffichageTrombi;

@interface Trombi : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    @private
        Reseau *reseauTest;
        NSArray *trombi;
        NSMutableArray *trombiTrie;
        BOOL searching;
        BOOL peutSelect;
        IBOutlet UISearchBar *searchBar;
        NSArray *tab;
        NSMutableArray *copy;
        OverlayViewController *overlay;
        AffichageTrombi *vueDetail;
        BOOL triAlphabet;
        UISegmentedControl *control;
}

@property (strong, nonatomic) IBOutlet UITableView *liste;
@property (strong, nonatomic) IBOutlet UINavigationBar *barre;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activite;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(void)finRecherche:(id)sender;

@end
