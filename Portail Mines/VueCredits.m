//
//  VueCredits.m
//  Portail Mines
//
//  Created by Valérian Roche on 07/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VueCredits.h"
#import "GestionConnexion.h"
#import "AffichageReglage.h"

@interface VueCredits ()

@end

@implementation VueCredits

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = nouveauReseau;
        listeAdresse = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"edouard.leurent@mines-paristech.fr",@"valerian.roche@mines-paristech.fr", nil] forKeys:[NSArray arrayWithObjects:@"Edouard Leurent",@"Valérian Roche", nil]];
        self.title = NSLocalizedString(@"Infos", @"Infos");
        self.tabBarItem.image = [UIImage imageNamed:@"infos.png"];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Infos";
    UIBarButtonItem *bouton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(affichageReglage)];
    [self.navigationItem setRightBarButtonItem:bouton];
    // Do any additional setup after loading the view from its nib.
}

-(void)affichageReglage {
    AffichageReglage *vueReglage = [[AffichageReglage alloc] initWithNibName:@"AffichageReglage" bundle:nil];
    vueReglage.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [vueReglage setDelegue:self];
    [self presentViewController:vueReglage animated:YES completion:nil];
}

-(void)retournementTermine {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"VueCreditsHorizontale" owner:self options:nil];
        [self viewDidLoad];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [[NSBundle mainBundle] loadNibNamed:@"VueCredits" owner:self options:nil];
        [self viewDidLoad];
    }
}

/*-(void)changeOrientation {
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"VueCreditsHorizontale" owner:self options:nil];
        [self viewDidLoad];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [[NSBundle mainBundle] loadNibNamed:@"VueCredits" owner:self options:nil];
        [self viewDidLoad];
    }
}*/

-(IBAction)envoieMail:(id)sender {
    NSString *adresse = [listeAdresse objectForKey:[(UIButton *)sender currentTitle]];
    MFMailComposeViewController *controllerMail = [[MFMailComposeViewController alloc] init];
    [controllerMail setMailComposeDelegate:self];
    [controllerMail setToRecipients:[NSArray arrayWithObject:adresse]];
    [controllerMail setSubject:@"[Portail Mines iPhone]"];
    [self presentModalViewController:controllerMail animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)deconnexion:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dejaConnecte"];
    connexion = [[GestionConnexion alloc] initWithController:self etReseau:reseau];
    [connexion deconnexion];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    reseau = nil;
    listeAdresse = nil;
    connexion = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
    if (connexion) {
        [connexion applicationWillResignActive];
    }
}

- (void)applicationDidEnterBackground {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)applicationWillEnterForeground {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)applicationDidBecomeActive {
    if (connexion)
        [connexion applicationDidBecomeActive];
}

@end
