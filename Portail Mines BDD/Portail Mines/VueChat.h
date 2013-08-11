//
//  VueChat.h
//  Portail Mines
//
//  Created by Valérian Roche on 24/01/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface VueChat : UIViewController <UITextViewDelegate, UITextFieldDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReseau:(Reseau *)reseau;

-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;

@end
