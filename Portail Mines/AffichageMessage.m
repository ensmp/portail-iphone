//
//  AffichageMessage.m
//  Portail Mines
//
//  Created by Ambroise COLLON on 11/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageMessage.h"
#import "Reseau.h"

@interface AffichageMessage ()

@end

@implementation AffichageMessage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)res
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau=res;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]] ;
    }
    
    return self;
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

- (void)viewDidUnload {
    [self setLogo:nil];
    [self setObjet:nil];
    [self setContenu:nil];
    [self setExpediteur:nil];
    [self setFavori:nil];
    [super viewDidUnload];
}

- (IBAction)mettreEnFavori:(id)sender {
}

- (void) changeDico:(NSDictionary *)dico {
    if (!dico)
    {
        return;
    }
    message=dico;
    [_Objet setText:[dico objectForKey:@"objet"]];
    [_Contenu setText:[dico objectForKey:@"contenu"]];
    [_Expediteur setText:[@"Envoyé par " stringByAppendingString:[dico objectForKey:@"expediteur"]]];
    [_Logo setImage:[reseau getPhotoAsso:[dico objectForKey:@"association_pseudo"]]];
}

-(void)changeOrientation {
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"AffichageMessageLandscape" owner:self options:nil];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [[NSBundle mainBundle] loadNibNamed:@"AffichageMessage" owner:self options:nil];
    }
    [self changeDico:message];
}
@end
