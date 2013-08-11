//
//  AffichageMessage.h
//  Portail Mines
//
//  Created by Ambroise COLLON on 11/12/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reseau;

@interface AffichageMessage : UIViewController
{
    Reseau *reseau;
    NSDictionary *message;
    BOOL horizontal;
}

@property (weak, nonatomic) IBOutlet UIImageView *Logo;
@property (weak, nonatomic) IBOutlet UILabel *Objet;
@property (weak, nonatomic) IBOutlet UITextView *Contenu;
@property (weak, nonatomic) IBOutlet UILabel *Expediteur;
@property (weak, nonatomic) IBOutlet UIButton *Favori;
@property (weak, nonatomic) IBOutlet UIScrollView *vue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau;
- (void)changeDico:(NSDictionary *)dico;
-(IBAction)tapeFavori:(id)sender;

@end
