//
//  AffichagePhoto.m
//  Portail Mines
//
//  Created by Valérian Roche on 27/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichagePhoto.h"

@interface AffichagePhoto ()

@end

@implementation AffichagePhoto

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

-(void)resize {
    UIImageView *vue = [[[self view] subviews] objectAtIndex:0];
    int largeur = [self view].bounds.size.height * ([vue bounds].size.width/[vue bounds].size.height);
    int marge = ([self view].bounds.size.width - largeur)/2;
    [vue setFrame:CGRectMake(marge, 0, largeur, [self view].bounds.size.height)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
