//
//  AffichageEdt.h
//  Portail Mines
//
//  Created by Valérian Roche on 27/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface AffichageEdt : UIViewController <UIAlertViewDelegate> {
    @private
    Reseau *reseau;
    NSString *nomEdt;
}

@property (strong, nonatomic) IBOutlet UIWebView *vuePDF;
@property (strong, nonatomic) IBOutlet UIProgressView *vueProgres;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
-(void)choixEdt:(NSString *)nomEdt;

@end
