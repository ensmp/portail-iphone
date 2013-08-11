//
//  VueSondage.m
//  Portail Mines
//
//  Created by Valérian Roche on 10/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VueSondage.h"
#import "Reseau.h"

@interface VueSondage ()

@end

@implementation VueSondage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Sondage", @"Sondage");
        self.tabBarItem.title = @"Sondage";
        self.tabBarItem.image = [UIImage imageNamed:@"sondages.png"];
        
        reseau = nouveauReseau;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        deformatter = [[NSDateFormatter alloc] init];
        [deformatter setDateFormat:@"dd/MM/yyyy"];
        compareDate = [[NSDateFormatter alloc] init];
        [compareDate setDateFormat:@"MMddyyyy"];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[_boutton1 titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [[_boutton2 titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [[_boutton1 titleLabel] setTextAlignment:UITextAlignmentCenter];
    [[_boutton2 titleLabel] setTextAlignment:UITextAlignmentCenter];
    [_affichageQuestion addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [_affichageQuestion setText:@"Chargement..."];
    if (dicoSondages) {
        if ([dicoSondages count])
            [self afficheSondage];
        if ([[formatter stringFromDate:[NSDate date]] isEqualToString:[formatter stringFromDate:dateAffichee]])
            [_allerSuivant setHidden:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    if (!dicoSondages) {
        dicoSondages = [[NSMutableDictionary alloc] init];
        jourComposant = [[NSDateComponents alloc] init];
        [jourComposant setDay:1];
        dateAffichee = [NSDate date];
        [_activite startAnimating];
        
        NSArray *resultat = [reseau obtenirSondage:[NSDate date] etPrecedent:YES];
        [_allerSuivant setHidden:YES];
        
        if (!resultat || ![resultat count]) {
            [_activite startAnimating];
        }
        else {
            NSDictionary *sondage = [resultat objectAtIndex:0];
            [dicoSondages setObject:sondage forKey:[resultat objectAtIndex:1]];
            dateAffichee = [resultat objectAtIndex:1];
            [self afficheSondage];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majSondage:) name:@"sondageTelecharge" object:nil];
    }
    
    else if (_affichageQuestion && [[_affichageQuestion text] isEqualToString:@"Chargement..."]) {
        dicoSondages = nil;
        [self viewWillAppear:animated];
    }
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [_affichageQuestion removeObserver:self forKeyPath:@"contentSize"];
        [[NSBundle mainBundle] loadNibNamed:@"VueSondageHorizontale" owner:self options:nil];
        [self viewDidLoad];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [_affichageQuestion removeObserver:self forKeyPath:@"contentSize"];
        [[NSBundle mainBundle] loadNibNamed:@"VueSondage" owner:self options:nil];
        [self viewDidLoad];
    }
}

/*-(void)changeOrientation {
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [_affichageQuestion removeObserver:self forKeyPath:@"contentSize"];
        [[NSBundle mainBundle] loadNibNamed:@"VueSondageHorizontale" owner:self options:nil];
        [self viewDidLoad];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [_affichageQuestion removeObserver:self forKeyPath:@"contentSize"];
        [[NSBundle mainBundle] loadNibNamed:@"VueSondage" owner:self options:nil];
        [self viewDidLoad];
    }
}*/

-(void)obtenirSondage:(BOOL)suivant {
    if ([(NSDate *)[NSDate date] compare:dateAffichee] == NSOrderedAscending) {
        dateAffichee = [NSDate date];
    }
    
    NSArray *resultat = [reseau obtenirSondage:dateAffichee etPrecedent:!suivant];
    if (![resultat count]) {
        [jourComposant setDay:1];
        dateAffichee = [[NSCalendar currentCalendar] dateByAddingComponents:jourComposant toDate:dateAffichee options:0];
        [[[UIAlertView alloc] initWithTitle:@"Non mais ça va oui!" message:@"Impossible de télécharger le sondage" delegate:nil cancelButtonTitle:@"J'arrête de picheclaquer alors..." otherButtonTitles:nil] show];
        return;
    }
    
    if (![[formatter stringFromDate:[resultat objectAtIndex:1]] isEqualToString:[formatter stringFromDate:dateAffichee]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majSondage:) name:@"sondageTelecharge" object:nil];
        NSDictionary *sondage = [resultat objectAtIndex:0];
        dateAffichee = [resultat objectAtIndex:1];
        [dicoSondages setObject:sondage forKey:dateAffichee];
        [_activite startAnimating];
    }
    
    else {
        NSDictionary *sondage = [resultat objectAtIndex:0];
        dateAffichee = [resultat objectAtIndex:1];
        [dicoSondages setObject:sondage forKey:dateAffichee];
        [self afficheSondage];
    }
}

-(void)majSondage:(NSNotification *)notif {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sondageTelecharge" object:nil];
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        [_activite stopAnimating];
        NSArray *resultat = [reseau obtenirSondage:[[notif userInfo] objectForKey:@"date"] etPrecedent:YES];
        NSDictionary *sondage = [resultat objectAtIndex:0];
        dateAffichee = [resultat objectAtIndex:1];
        [dicoSondages setObject:sondage forKey:dateAffichee];
        [self afficheSondage];
    }
    else {
        if ([[formatter stringFromDate:[[notif userInfo] objectForKey:@"date"]] isEqualToString:[formatter stringFromDate:[NSDate date]]]) {
            [_activite stopAnimating];
            [[[UIAlertView alloc] initWithTitle:@"Tu ne voteras pas!" message:@"Impossible de télécharger le sondage" delegate:nil cancelButtonTitle:@"J'arrête de picheclaquer alors..." otherButtonTitles:nil] show];
        }
        else {
            [_activite stopAnimating];
            [self afficheSondage];
            //[[[UIAlertView alloc] initWithTitle:@"Non mais ça va oui!" message:@"Impossible de télécharger le sondage" delegate:nil cancelButtonTitle:@"J'arrête de picheclaquer alors..." otherButtonTitles:nil] show];
        }
    }
}

-(void)afficheSondage {
    NSDictionary *dico = [dicoSondages objectForKey:dateAffichee];
    
    [_affichageDate setText:[formatter stringFromDate:[deformatter dateFromString:[dico objectForKey:@"date_parution"]]]];
    
    [_affichageQuestion setText:[dico objectForKey:@"question"]];
    
    BOOL jourMeme = [[formatter stringFromDate:[NSDate date]] isEqualToString:[formatter stringFromDate:dateAffichee]];
    if (jourMeme) {
        [_allerSuivant setHidden:YES];
    }
    else {
        [_allerSuivant setHidden:NO];
    }
    if ([[dico objectForKey:@"is_dernier"] boolValue]) {
        [_allerPrecedent setHidden:YES];
    }
    else {
        [_allerPrecedent setHidden:NO];
    }
    if (jourMeme && ![dico objectForKey:@"nombre_reponse_1"]) {
        [_boutton1 setTitle:[dico objectForKey:@"reponse1"] forState:UIControlStateNormal];
        [_boutton2 setTitle:[dico objectForKey:@"reponse2"] forState:UIControlStateNormal];
        [_proportion1 setHidden:YES];
        [_proportion2 setHidden:YES];
        [_pourcentage1 setHidden:YES];
        [_pourcentage2 setHidden:YES];
        [_affichageReponse1 setHidden:YES];
        [_affichageReponse2 setHidden:YES];
        [_affichageTotalVote setHidden:YES];
        [_affichageVotes1 setHidden:YES];
        [_affichageVotes2 setHidden:YES];
        [_boutton1 setHidden:NO];
        [_boutton2 setHidden:NO];
    }
    else if ([dico objectForKey:@"nombre_reponse_1"]) {
        int total = [[dico objectForKey:@"nombre_reponse"] intValue];
        float resultat1 = 0.5f;
        float resultat2 = 0.5f;
        if (total != 0) {
            resultat1 = (float)[[dico objectForKey:@"nombre_reponse_1"] intValue]/total;
            resultat2 = (float)[[dico objectForKey:@"nombre_reponse_2"] intValue]/total;
        }
        
        [_pourcentage1 setText:[NSString stringWithFormat:@"%ld%%",lround(resultat1*100)]];
        [_pourcentage2 setText:[NSString stringWithFormat:@"%ld%%",lround(resultat2*100)]];
        
        [_proportion1 setProgress:resultat1 animated:YES];
        [_proportion2 setProgress:resultat2 animated:YES];
        
        [_affichageReponse1 setText:[dico objectForKey:@"reponse1"]];
        [_affichageReponse2 setText:[dico objectForKey:@"reponse2"]];
        
        if (lround(resultat1*100) <= 30) {
            [_proportion1 setProgressTintColor:[UIColor redColor]];
            [_proportion2 setProgressTintColor:[UIColor greenColor]];
        }
        else if (lround(resultat1*100) >= 70) {
            [_proportion1 setProgressTintColor:[UIColor greenColor]];
            [_proportion2 setProgressTintColor:[UIColor redColor]];
        }
        else {
            [_proportion1 setProgressTintColor:[UIColor orangeColor]];
            [_proportion2 setProgressTintColor:[UIColor orangeColor]];
        }
        
        [_affichageTotalVote setText:[NSString stringWithFormat:@"Nombre de votants : %d",[[dico objectForKey:@"nombre_reponse"] intValue]]];
        [_affichageVotes1 setText:[NSString stringWithFormat:@"%d votes",[[dico objectForKey:@"nombre_reponse_1"] intValue]]];
        [_affichageVotes2 setText:[NSString stringWithFormat:@"%d votes",[[dico objectForKey:@"nombre_reponse_2"] intValue]]];
        
        [_proportion1 setHidden:NO];
        [_proportion2 setHidden:NO];
        [_pourcentage1 setHidden:NO];
        [_pourcentage2 setHidden:NO];
        [_affichageReponse1 setHidden:NO];
        [_affichageReponse2 setHidden:NO];
        [_affichageTotalVote setHidden:NO];
        [_affichageVotes1 setHidden:NO];
        [_affichageVotes2 setHidden:NO];
        [_boutton1 setHidden:YES];
        [_boutton2 setHidden:YES];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majSondage:) name:@"sondageTelecharge" object:nil];
        [_affichageReponse1 setText:@"Réponses non chargées..."];
        [_proportion1 setHidden:YES];
        [_proportion2 setHidden:YES];
        [_pourcentage1 setHidden:YES];
        [_pourcentage2 setHidden:YES];
        [_affichageReponse1 setHidden:NO];
        [_affichageReponse2 setHidden:YES];
        [_affichageTotalVote setHidden:YES];
        [_affichageVotes1 setHidden:YES];
        [_affichageVotes2 setHidden:YES];
        [_boutton1 setHidden:YES];
        [_boutton2 setHidden:YES];
    }
}

-(IBAction)afficherSuivant:(id)sender {
    [jourComposant setDay:1];
    dateAffichee = [[NSCalendar currentCalendar] dateByAddingComponents:jourComposant toDate:dateAffichee options:0];
    [self obtenirSondage:YES];
}

-(IBAction)afficherPrecedent:(id)sender {
    [jourComposant setDay:-1];
    dateAffichee = [[NSCalendar currentCalendar] dateByAddingComponents:jourComposant toDate:dateAffichee options:0];
    [self obtenirSondage:NO];
};

-(IBAction)choixVote:(id)sender {
    if (sender == _boutton1)
        [reseau voteSondage:1];
    else
        [reseau voteSondage:2];
    [_boutton1 setEnabled:NO];
    [_boutton2 setEnabled:NO];
    [_activite startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultatVote:) name:@"voteSondage" object:nil];
}

-(void)resultatVote:(NSNotification *)notif {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"voteSondage" object:nil];
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        [[[UIAlertView alloc] initWithTitle:@"A voté!" message:@"Vote enregistré" delegate:nil cancelButtonTitle:@"J'ai fait mon devoir, Monsieur" otherButtonTitles:nil] show];
        dateAffichee = [NSDate date];
        [self obtenirSondage:YES];
        [_boutton1 setEnabled:YES];
        [_boutton2 setEnabled:YES];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"On n'en veut pas de ton vote" message:@"Impossible de voter" delegate:nil cancelButtonTitle:@"Je me vengerai!" otherButtonTitles:nil] show];
        [_boutton1 setEnabled:YES];
        [_boutton2 setEnabled:YES];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat topCorrect = ([_affichageQuestion bounds].size.height - [_affichageQuestion contentSize].height * [_affichageQuestion zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    _affichageQuestion.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)viewDidUnload {
    [self setAffichageDate:nil];
    [self setAllerSuivant:nil];
    [self setAllerPrecedent:nil];
    [self setAffichageQuestion:nil];
    [self setBoutton1:nil];
    [self setBoutton2:nil];
    [self setProportion1:nil];
    [self setProportion2:nil];
    [self setActivite:nil];
    [self setPourcentage1:nil];
    [self setPourcentage2:nil];
    [self setAffichageReponse1:nil];
    [self setAffichageReponse2:nil];
    [self setAffichageTotalVote:nil];
    [self setAffichageVotes1:nil];
    [self setAffichageVotes2:nil];
    reseau = nil;
    dicoSondages = nil;
    dateAffichee = nil;
    jourComposant = nil;
    formatter = nil;
    deformatter = nil;
    compareDate = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
    if ([_affichageQuestion observationInfo] != nil)
        [_affichageQuestion removeObserver:self forKeyPath:@"contentSize"];
}

- (void)applicationDidEnterBackground {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"voteSondage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sondageTelecharge" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)applicationWillEnterForeground {
    [_affichageQuestion addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)applicationDidBecomeActive {
    
}

@end
