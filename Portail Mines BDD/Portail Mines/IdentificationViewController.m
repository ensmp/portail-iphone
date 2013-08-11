//
//  IdentificationViewController.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "IdentificationViewController.h"
#import "GestionConnexion.h"
#import "Reseau.h"

@interface IdentificationViewController ()

@end

@implementation IdentificationViewController

@synthesize /*delegue=_delegue,*/ password=_password, username=_username, label=_label, boutton=_boutton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = nouveauReseau;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self blocageReseau:@"Chargement"];
    _password.secureTextEntry = YES;
    
    UIToolbar *barreBouttons = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [barreBouttons setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *espace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    /*UIBarButtonItem *previous = [[UIBarButtonItem alloc] initWithTitle:@"Précédent" style:UIBarButtonItemStyleBordered target:self action:@selector(tapeBouttonBarre:)];*/
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(disparitionClavier)];
                             
    nextPrevious = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Précédent",@"Suivant", nil]];
    [nextPrevious setSegmentedControlStyle:UISegmentedControlStyleBar];
    [nextPrevious setTintColor:[UIColor blackColor]];
    [nextPrevious setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    [nextPrevious setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [nextPrevious addTarget:self action:@selector(tapeBouttonBarre:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *previousNext = [[UIBarButtonItem alloc] initWithCustomView:nextPrevious];
    
    [barreBouttons setItems:[NSArray arrayWithObjects:previousNext,espace,done, nil]];
    [_username setInputAccessoryView:barreBouttons];
    [_password setInputAccessoryView:barreBouttons];
    barreBouttons = nil;
    espace = nil;
    previousNext = nil;
    done = nil;
    
    [_username addTarget:self action:@selector(selectionChamp:) forControlEvents:UIControlEventEditingDidBegin];
    [_password addTarget:self action:@selector(selectionChamp:) forControlEvents:UIControlEventEditingDidBegin];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Pas de reseau" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"NoCookie" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Cookie" object:nil];
    
    [self dispo];
}

-(void)blocageReseau:(NSString *)chaine {
    [_password setEnabled:NO];
    [_username setEnabled:NO];
    [_label setText:chaine];
    [_boutton setEnabled:NO];
}

-(void)message:(NSString *)chaine etFixe:(BOOL)repete {
    [_label setText:chaine];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(effaceMessage) userInfo:nil repeats:repete];
}

-(void)effaceMessage {
    [_label setText:@""];
}

-(void)connecte {
    [_activite stopAnimating];
    [_password setEnabled:YES];
    [_username setEnabled:YES];
    [_label setText:@""];
    [_boutton setEnabled:YES];
    [_username becomeFirstResponder];
}

// ##################### Gère la connexion #########################

-(void)dispo {
    [_activite startAnimating];
    [reseau connectionDispo];
    [reseau getToken];
}

-(BOOL)reponse:(NSNotification *)notif {
    if ([[notif name] isEqualToString:@"Cookie"]) {
        if (timer) {
            [timer invalidate];
        }
        [self connecte];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Cookie" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoCookie" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pas de reseau" object:nil];
    }
    else {
        [_activite stopAnimating];
        if ([[notif name] isEqualToString:@"Pas de reseau"]) {
            [self blocageReseau:@"Pas de réseau"];
        }
        if ([[notif name] isEqualToString:@"NoCookie"]) {
            [self blocageReseau:@"Le site ne répond pas"];
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(dispo) userInfo:nil repeats:NO];
    }
    return YES;
}

-(void)identification:(NSString *)username andPassword:(NSString *)password {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(supprimerVue) name:@"Ok" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echec) name:@"Non" object:nil];
    
    [reseau identification:username andPassword:password];
}

-(void)echec {
    [_activite stopAnimating];
    [self message:@"Identifiant/Mdp incorrect" etFixe:NO];
}

// ##################### Fin de la connexion #######################

-(void)supprimerVue {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Ok" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Non" object:nil];
    [_activite stopAnimating];
    [reseau getMessageAvecTous:NO];
    [reseau getTrombi];
    [_delegue supprimerController];
}




// ###################### Utilitaire clavier ###################### //
-(IBAction)dismiss:(id)sender {
    if ([_username isFirstResponder]) {
        [_username resignFirstResponder];
    }
    else {
        [_password resignFirstResponder];    
    }
    [_activite startAnimating];
    [self identification:[_username text] andPassword:[_password text]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _password) {
        if (![_username.text isEqualToString:@""]) {
            [self dismiss:nil];
        }
        else {
            [_username becomeFirstResponder];
        }
    }
    else {
        if (![_password.text isEqualToString:@""]) {
            [self dismiss:nil];
        }
        else {
            [_password becomeFirstResponder];
        }
    }
    return YES;
}

-(IBAction)tapeBouttonBarre:(id)sender {
    if ([_username isFirstResponder]) {
        [_password becomeFirstResponder];
    }
    else {
        [_username becomeFirstResponder];
    }
}

-(IBAction)selectionChamp:(id)sender {
    if (sender == _username) {
        [nextPrevious setSelectedSegmentIndex:0];
    }
    else
        [nextPrevious setSelectedSegmentIndex:1];
}

-(void)disparitionClavier {
    [_username resignFirstResponder];
    [_password resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return (orientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidUnload {
    [self setActivite:nil];
    [self setBoutton:nil];
    [self setDelegue:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setLabel:nil];
    nextPrevious = nil;
    reseau = nil;
    timer = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Cookie" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoCookie" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pas de reseau" object:nil];
    [_activite stopAnimating];
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
}

- (void)applicationDidBecomeActive {
    if ([[_username text] isEqualToString:@""] && [[_password text] isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Pas de reseau" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"NoCookie" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponse:) name:@"Cookie" object:nil];
        [self dispo];
    }
}

@end
