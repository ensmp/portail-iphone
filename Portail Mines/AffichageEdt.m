//
//  AffichageEdt.m
//  Portail Mines
//
//  Created by Valérian Roche on 27/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageEdt.h"
#import "Reseau.h"

@interface AffichageEdt ()

@end

@implementation AffichageEdt

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  andNetwork:(Reseau *)reseauTest
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = reseauTest;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)choixEdt:(NSString *)nomEdtNouveau {
    if ([nomEdtNouveau isEqualToString:nomEdt]) {
        return;
    }
    nomEdt = nomEdtNouveau;
    NSData *fichier = [reseau getEmploiDuTemps:nomEdt];
    if (!fichier) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(edtChargement:) name:@"edtTelecharge" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afficheProgres:) name:@"progresTelechargement" object:nil];
        [_vueProgres setHidden:NO];
        [_vuePDF setHidden:YES];
        [_vueProgres setProgress:0.0f];
    }
    else {
        [_vuePDF setHidden:NO];
        [_vuePDF loadData:fichier MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    }
}

-(void)edtChargement:(NSNotification *)notif {
    if ([[[notif userInfo] objectForKey:@"nom"] isEqualToString:[[nomEdt componentsSeparatedByString:@"/"] lastObject]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"edtTelecharge" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afficheProgres:) name:@"progresTelechargement" object:nil];
        
        [_vueProgres setHidden:YES];
        if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
            NSData *fichier = [reseau getEmploiDuTemps:nomEdt];
            [_vuePDF loadData:fichier MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
            [_vuePDF setHidden:NO];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pas de chance" message:@"Impossible de télécharger l'emploi du temps" delegate:nil cancelButtonTitle:@"J'irai pas en cours alors..." otherButtonTitles:nil];
            [alert setDelegate:self];
            [alert show];
        }
    }
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

@end
