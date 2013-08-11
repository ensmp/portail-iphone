//
//  AffichageVendome.h
//  Portail Mines
//
//  Created by Valérian Roche on 09/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface AffichageVendome : UIViewController <UIAlertViewDelegate> {
    @private
        Reseau *reseau;
        NSDictionary *dicoVendomeActuel;
}

@property (strong, nonatomic) IBOutlet UIWebView *vuePDF;
@property (strong, nonatomic) IBOutlet UIProgressView *vueProgres;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(void)choixVendome:(NSDictionary *)dicoVendome;


@end
