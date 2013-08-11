//
//  AffichageVendome.m
//  Portail Mines
//
//  Created by Valérian Roche on 09/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageVendome.h"
#import "Reseau.h"

@interface AffichageVendome ()

@end

@implementation AffichageVendome
@synthesize vuePDF = _vuePDF;

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
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Ouvrir..." style:UIBarButtonItemStyleBordered target:self action:@selector(afficheOuvrir)];
    [[self navigationItem] setRightBarButtonItem:button animated:NO];
    [button setEnabled:NO];
    
    // Pour le plein écran
    UITapGestureRecognizer *tapUnique = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapeSurVue)];
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] init];
    [tapUnique setNumberOfTapsRequired:1];
    [tapDouble setNumberOfTapsRequired:2];
    [tapUnique setDelaysTouchesBegan:YES];
    [tapDouble setDelaysTouchesBegan:YES];
    [tapUnique requireGestureRecognizerToFail:tapDouble];
    [self.view addGestureRecognizer:tapUnique];
    [self.view addGestureRecognizer:tapDouble];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ];
    // Do any additional setup after loading the view from its nib.
}

-(void)tapeSurVue {
    if (![self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
        [UIView animateWithDuration:0.2
                     animations:^{
                         //[self.navigationController setNavigationBarHidden:YES animated:YES];
                         CGRect fenetre = self.view.window.bounds;
                         if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                             CGRect tabFrame = self.tabBarController.tabBar.frame;
                             tabFrame.origin.y = CGRectGetMaxY(fenetre);
                             self.tabBarController.tabBar.frame = tabFrame;
                             ((UIView *) [self.tabBarController.tabBar.superview.subviews objectAtIndex:0]).frame = fenetre;
                         }
                         else {
                             CGRect tabFrame = self.tabBarController.tabBar.frame;
                             tabFrame.origin.y = CGRectGetMaxX(fenetre);
                             self.tabBarController.tabBar.frame = tabFrame;
                             ((UIView *) [self.tabBarController.tabBar.superview.subviews objectAtIndex:0]).frame = CGRectMake(fenetre.origin.x, fenetre.origin.y, fenetre.size.height, fenetre.size.width);;

                         }
                     }];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.2
                         animations:^{
                             //[self.navigationController setNavigationBarHidden:NO animated:YES];
                             CGRect fenetre = self.view.window.bounds;
                             if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                                 CGRect tabFrame = self.tabBarController.tabBar.frame;
                                 tabFrame.origin.y = CGRectGetMaxY(fenetre) - tabFrame.size.height;
                                 self.tabBarController.tabBar.frame = tabFrame;
                                 CGRect contentFrame = fenetre;
                                 contentFrame.size.height -= tabFrame.size.height;
                                 ((UIView *) [self.tabBarController.tabBar.superview.subviews objectAtIndex:0]).frame = contentFrame;
                             }
                             else {
                                 CGRect tabFrame = self.tabBarController.tabBar.frame;
                                 tabFrame.origin.y = CGRectGetMaxX(fenetre) - tabFrame.size.height;
                                 self.tabBarController.tabBar.frame = tabFrame;
                                 CGRect contentFrame = fenetre;
                                 contentFrame = CGRectMake(fenetre.origin.x, fenetre.origin.y, fenetre.size.height, fenetre.size.width - tabFrame.size.height);
                                 ((UIView *) [self.tabBarController.tabBar.superview.subviews objectAtIndex:0]).frame = contentFrame;
                             }
                         }];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController isNavigationBarHidden]) {
        [self tapeSurVue];
    }
}

-(void)choixVendome:(NSDictionary *)dicoVendome {
    if (dicoVendomeActuel == dicoVendome) {
        return;
    }
    
    dicoVendomeActuel = dicoVendome;
    
    NSData *fichier = [reseau getVendome:[dicoVendome objectForKey:@"fichier"]];
    if (!fichier) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vendomeChargement:) name:@"vendomeTelecharge" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afficheProgres:) name:@"progresTelechargement" object:nil];
        self.navigationItem.title = @"Chargement...";
        [_vueProgres setHidden:NO];
        [_vuePDF setHidden:YES];
        [_vueProgres setProgress:0.0f];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    }
    else {
        [_vuePDF setHidden:NO];
        [_vueProgres setHidden:YES];
        self.navigationItem.title = [dicoVendomeActuel objectForKey:@"titre"];
        [_vuePDF loadData:fichier MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
}

-(void)vendomeChargement:(NSNotification *)notif {
    if ([[[notif userInfo] objectForKey:@"nom"] isEqualToString:[[[dicoVendomeActuel objectForKey:@"fichier"] componentsSeparatedByString:@"/"] lastObject]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"vendomeTelecharge" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"progresTelechargement" object:nil];
        
        [_vueProgres setHidden:YES];
        if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
            NSData *fichier = [reseau getVendome:[dicoVendomeActuel objectForKey:@"fichier"]];
            [_vuePDF loadData:fichier MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
            [_vuePDF setHidden:NO];
            self.navigationItem.title = [dicoVendomeActuel objectForKey:@"titre"];
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
            
        }
        else if ([_vuePDF isHidden]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pas de chance" message:@"Impossible de télécharger le vendôme" delegate:nil cancelButtonTitle:@"Bah je vais aller en cours..." otherButtonTitles:nil];
            [alert setDelegate:self];
            [alert show];
            dicoVendomeActuel = nil;
        }
    }
}

-(void)afficheOuvrir {
    NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:[[[dicoVendomeActuel objectForKey:@"fichier"] componentsSeparatedByString:@"/"] lastObject]]];
    
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fichierVendome]];
    [controller setUTI:@"public.pdf"];
    [controller presentOpenInMenuFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
}

-(void)afficheProgres:(NSNotification *)notif {
    [_vueProgres setProgress:[[[notif userInfo] objectForKey:@"progres"] floatValue] animated:YES];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)viewDidUnload {
    [self setVuePDF:nil];
    [self setVueProgres:nil];
    reseau = nil;
    dicoVendomeActuel = nil;
    [super viewDidUnload];
}

@end
