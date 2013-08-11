//
//  AffichageReglage.h
//  Portail Mines
//
//  Created by Valérian Roche on 26/01/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipSideDelegate <NSObject>

-(void)retournementTermine;

@end

@interface AffichageReglage : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) id<FlipSideDelegate> delegue;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *affichageTemps;

-(IBAction)changementValeurSlider:(UISlider *)sender;
- (IBAction)tapeDone:(UIBarButtonItem *)sender;
-(IBAction)changementSonnerie:(UIButton *)sender;
@end
