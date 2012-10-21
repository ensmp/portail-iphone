//
//  OverlayViewController.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "OverlayViewController.h"
#import "Trombi.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController
@synthesize rv = _rv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_rv finRecherche:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
