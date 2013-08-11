//
//  AffichageReglage.m
//  Portail Mines
//
//  Created by Valérian Roche on 26/01/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "AffichageReglage.h"
#import <AVFoundation/AVFoundation.h>

@interface AffichageReglage ()
@property (weak, nonatomic) IBOutlet UINavigationBar *barreHaute;
@property (nonatomic,strong) NSDictionary *listeSons;
@property (weak, nonatomic) IBOutlet UIButton *affichageTitre;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation AffichageReglage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.listeSons = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"bell-ringing-05",@"water-droplet-1",@"zippo-close-1",@"Rien", nil] forKeys:[NSArray arrayWithObjects:@"Son de cloches",@"Goutte d'eau", @"Briquet",@"Aucun son", nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.slider setContinuous:NO];
    int valeurActuelle = [[NSUserDefaults standardUserDefaults] integerForKey:@"tempsRaffraichissement"];
    [self.slider setValue:valeurActuelle];
    [self.affichageTemps setText:[NSString stringWithFormat:@"%ds",valeurActuelle]];
    [self.affichageTitre setTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"SonnerieChat"] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)changementValeurSlider:(UISlider *)sender {
    [self.affichageTemps setText:[NSString stringWithFormat:@"%ds",(int)sender.value]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapeDone:(UIBarButtonItem *)sender {
    [self.delegue retournementTermine];
}

-(IBAction)changementSonnerie:(UIButton *)sender {
    if (![self.view.subviews containsObject:self.picker]) {
        if (!self.picker) {
            self.picker = [[UIPickerView alloc] init];
            [self.picker setDataSource:self];
            [self.picker setDelegate:self];
            [self.picker setShowsSelectionIndicator:YES];
            [self.picker setFrame:CGRectMake(0, self.view.bounds.size.height-self.barreHaute.bounds.size.height+self.barreHaute.frame.size.height, self.view.bounds.size.width, self.picker.frame.size.height)];
            int rang = [[self.listeSons allKeys] indexOfObject:self.affichageTitre.titleLabel.text];
            if (rang < [[self.listeSons allKeys] count])
                [self.picker selectRow:rang inComponent:0 animated:NO];
        }
        [self.view addSubview:self.picker];
        [UIView animateWithDuration:0.2 animations:^void {
            [self.picker setFrame:CGRectMake(0, self.view.bounds.size.height-self.barreHaute.bounds.size.height+self.barreHaute.frame.size.height-self.picker.frame.size.height, self.view.bounds.size.width, self.picker.frame.size.height)];
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^void {
            [self.picker setFrame:CGRectMake(0, self.view.bounds.size.height-self.barreHaute.bounds.size.height+self.barreHaute.frame.size.height, self.view.bounds.size.width, self.picker.frame.size.height)];
        } completion:^(BOOL finished){[self.picker removeFromSuperview];}];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setInteger:(int)self.slider.value forKey:@"tempsRaffraichissement"];
    [[NSUserDefaults standardUserDefaults] setObject:self.affichageTitre.titleLabel.text forKey:@"SonnerieChat"];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.picker removeFromSuperview];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.listeSons.allKeys.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.listeSons allKeys] objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.affichageTitre setTitle:[[self.listeSons allKeys] objectAtIndex:row] forState:UIControlStateNormal];
    NSString *nomSon = [self.listeSons objectForKey:[[self.listeSons allKeys] objectAtIndex:row]];
    if (![nomSon isEqualToString:@"Rien"]) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:nomSon withExtension:@"mp3"];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self.player play];
    }
}

- (void)viewDidUnload {
    [self setSlider:nil];
    [self setAffichageTemps:nil];
    [self setBarreHaute:nil];
    [self setAffichageTitre:nil];
    [super viewDidUnload];
}
@end
