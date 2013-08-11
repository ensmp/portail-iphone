//
//  DetailPetitCours.m
//  Portail Mines
//
//  Created by Valérian Roche on 16/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "DetailPetitCours.h"
#import "Reseau.h"

@interface DetailPetitCours ()

@end

@implementation DetailPetitCours

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = nouveauReseau;
        rotation = NO;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    NSString *description = [dico objectForKey:@"description"];
    if (!description)
        description = @"Pas de description";
    NSString *adresse = [dico objectForKey:@"adresse"];
    if (!adresse)
        adresse = @"Pas d'adresse";
    NSString *matiere = [dico objectForKey:@"matiere"];
    if (!matiere)
        matiere = @"Matière non spécifiée";
    NSString *niveau = [dico objectForKey:@"niveau"];
    if (!niveau)
        niveau = @"Niveau non spécifié";
    [_affichageDescription setText:description];
    [_affichageLieu setText:adresse];
    [_affichageMatiere setText:matiere];
    [_affichageNiveau setText:niveau];
}

-(void)setDico:(NSDictionary *)nouveauDico {
    dico = nouveauDico;
    if ([dico objectForKey:@"titre"])
        [self.navigationItem setTitle:[dico objectForKey:@"titre"]];
    else
        [self.navigationItem setTitle:@"Petit cours"];
}

- (void)viewDidLoad
{
    if (!UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]) && !rotation) {
        rotation = YES;
        [self changeOrientation:[[UIDevice currentDevice] orientation]];
    }
    else {
        [super viewDidLoad];
        _affichageDescription.contentInset = UIEdgeInsetsMake(-11,-8,0,0);
        _affichageLieu.contentInset = UIEdgeInsetsMake(-11,-8,0,0);
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self changeOrientation:toInterfaceOrientation];
}

-(void)changeOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"DetailPetitCoursLandscape" owner:self options:nil];
        [self viewDidLoad];
        [self viewWillAppear:NO];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        if (self.view.bounds.size.width > 480)
            [[NSBundle mainBundle] loadNibNamed:@"DetailPetitCours" owner:self options:nil];
        else
            [[NSBundle mainBundle] loadNibNamed:@"DetailPetitCours3.5" owner:self options:nil];
        [self viewDidLoad];
        [self viewWillAppear:NO];
    }
}

-(IBAction)demandeCours:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Demande du cours?" delegate:self cancelButtonTitle:@"Pfff... Pas pour moi" destructiveButtonTitle:nil otherButtonTitles:@"Moi d'abord !!!!", nil] showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [reseau demanderPC:[[dico objectForKey:@"id"] intValue]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultatVote:) name:@"demandePC" object:nil];
        [_activite startAnimating];
    }
}

-(void)resultatVote:(NSNotification *)notif {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"demandePC" object:nil];
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue])
        [[[UIAlertView alloc] initWithTitle:@"C'est fait !!" message:@"Demande enregistrée" delegate:nil cancelButtonTitle:@"Je l'ai !!!!" otherButtonTitles:nil] show];
    else {
        [[[UIAlertView alloc] initWithTitle:@"Et non..." message:@"Demande non enregistrée" delegate:nil cancelButtonTitle:@"Paie ton tripromal !!!" otherButtonTitles:nil] show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAffichageDescription:nil];
    [self setAffichageLieu:nil];
    [self setAffichageMatiere:nil];
    [self setAffichageNiveau:nil];
    [self setActivite:nil];
    reseau = nil;
    dico = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)applicationWillResignActive {
}

- (void)applicationDidEnterBackground {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"demandePC" object:nil];
    [_activite stopAnimating];
}

- (void)applicationWillEnterForeground {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)applicationDidBecomeActive {
}

@end
