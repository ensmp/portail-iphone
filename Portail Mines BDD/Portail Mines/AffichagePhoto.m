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
    }
    return self;
}

-(void)resize {
    UIImageView *vue = [[[self view] subviews] objectAtIndex:0];
    int largeur = [self view].bounds.size.height * ([vue bounds].size.width/[vue bounds].size.height);
    int marge = ([self view].bounds.size.width - largeur)/2;
    [vue setFrame:CGRectMake(marge, 0, largeur, [self view].bounds.size.height)];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

@end
