//
//  AffichageMessage.m
//  Portail Mines
//
//  Created by Ambroise COLLON on 11/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageMessage.h"
#import "Reseau.h"
#import <QuartzCore/QuartzCore.h>

@interface AffichageMessage ()

@end

@implementation AffichageMessage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)res
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau=res;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]] ;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_Contenu setTextAlignment:NSTextAlignmentJustified];
    
    CALayer *layer = _Logo.layer;
    [layer setBorderColor: [[UIColor blackColor] CGColor]];
    [layer setBorderWidth:1.0f];
    [layer setShadowColor: [[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.6f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:3.0];
    [_Logo setClipsToBounds:NO];
    
    //_Contenu.contentInset = UIEdgeInsetsMake(-11,-8,11,8);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeDico:(NSDictionary *)dico {
    if (!dico)
    {
        return;
    }
    
    [self.navigationItem setTitle:[dico objectForKey:@"association"]];
    [_Objet setText:[dico objectForKey:@"objet"]];
    
    [_Contenu setText:[dico objectForKey:@"contenu"]];
    
    [_Expediteur setText:[@"Envoyé par " stringByAppendingString:[dico objectForKey:@"expediteur"]]];
    [_Logo setImage:[reseau getPhotoAsso:[dico objectForKey:@"association_pseudo"]]];
    
    if (message != dico) {
        [_vue scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [_Contenu scrollRangeToVisible:NSRangeFromString(@"{0,1}")];
    }
    
    if (!horizontal) {
        CGRect frame = [_Contenu frame];
        frame.size = [_Contenu contentSize];
        [_Contenu setFrame:frame];
    
        frame = [_Favori frame];
        frame.origin.y = _Contenu.frame.size.height + _Contenu.frame.origin.y + 10;
        [_Favori setFrame:frame];
    
        frame = [_Expediteur frame];
        frame.origin.y = _Favori.frame.size.height/2 + _Favori.frame.origin.y - _Expediteur.frame.size.height/2;
        [_Expediteur setFrame:frame];
    
        _vue.contentSize = CGSizeMake([self view].bounds.size.width,_Favori.bounds.size.height+_Favori.frame.origin.y+_Logo.frame.origin.y);
    }
    message=dico;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"AffichageMessageLandscape" owner:self options:nil];
        horizontal = YES;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        horizontal = NO;
        [[NSBundle mainBundle] loadNibNamed:@"AffichageMessage" owner:self options:nil];
    }
    [self viewDidLoad];
    [self changeDico:message];
}

/*-(void)changeOrientation {
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[NSBundle mainBundle] loadNibNamed:@"AffichageMessageLandscape" owner:self options:nil];
        horizontal = YES;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        horizontal = NO;
        [[NSBundle mainBundle] loadNibNamed:@"AffichageMessage" owner:self options:nil];
    }
    [self viewDidLoad];
    [self changeDico:message];
}*/

-(IBAction)tapeFavori:(id)sender {
    [reseau setFavori:![[message objectForKey:@"important"] boolValue] pourMessage:[[message objectForKey:@"id"] intValue]];
    [[NSNotificationCenter defaultCenter] addObserver:[[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count-2] selector:@selector(reponseMessage:) name:@"ClassementMessage" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)viewDidUnload {
    [self setLogo:nil];
    [self setObjet:nil];
    [self setContenu:nil];
    [self setExpediteur:nil];
    [self setFavori:nil];
    [super viewDidUnload];
}

@end
