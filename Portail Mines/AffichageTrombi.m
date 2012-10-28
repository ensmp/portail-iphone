//
//  AffichageTrombi.m
//  Portail Mines
//
//  Created by Valérian Roche on 21/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageTrombi.h"
#import "Reseau.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import "AffichagePhoto.h"

@interface AffichageTrombi ()

@end

@implementation AffichageTrombi
@synthesize vueImage = _vueImage, prenom = _prenom, nom = _nom, promo = _promo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil etReseau:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseauTest = reseau;
        elements = [NSArray arrayWithObjects:@"Téléphone",@"Mail",@"Chambre",@"Naissance",@"Parrain",@"Fillot", nil];
        cles = [NSArray arrayWithObjects:@"phone",@"email",@"chambre",@"birthday",@"parrain",@"fillot", nil];
        decode = [[NSDateFormatter alloc] init];
        [decode setDateFormat:@"yyyy-MM-dd"];
        recode = [[NSDateFormatter alloc] init];
        [recode setDateFormat:@"dd MMMM yyyy"];
        [recode setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        iOS6higher = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

-(void)changeOrientation:(NSNotification *)notif {
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width, _liste.bounds.size.height-20);
}

-(void)changeUsername:(NSString *)username {
    identifiant = username;
    
    [reseauTest chercheImage:username pourImage:YES];
    [reseauTest chercheImage:username pourImage:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"imageTelecharge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"messageTelecharge" object:nil];
    dico = [reseauTest getInfos:username etTelechargement:NO];
}

-(void)majImage:(NSNotification *)notif {
    if ([[[notif userInfo] objectForKey:@"username"] isEqualToString:identifiant]) {
        if ([[[notif userInfo] objectForKey:@"image"] boolValue]) {
            [_vueImage setImage:[reseauTest getImage:identifiant]];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageTelecharge" object:nil];
        }
        else {
            dico = [reseauTest getInfos:identifiant etTelechargement:NO];
            if (dico) {
                [_liste reloadData];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageTelecharge" object:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CALayer *layer = _vueImage.layer;
    [layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:5.0f];
    [layer setShadowColor: [[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.9f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:4.0];
    ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width, _liste.bounds.size.height-20);
    [_vueImage setClipsToBounds:NO];
    [_liste setDelegate:self];
    [_liste setDataSource:self];
    [_liste setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    UIBarButtonItem *boutton = [[UIBarButtonItem alloc] initWithTitle:@"Ajouter" style:UIBarButtonItemStyleBordered target:self action:@selector(ajoutContact)];
    [self.navigationItem setRightBarButtonItem:boutton animated:NO];
    [self majAffichage];
    [_vueImage setUserInteractionEnabled:YES];
    [_vueImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoSelect)]];
}

-(void)majAffichage {
    [_vueImage setImage:[reseauTest getImage:identifiant]];
    if (dico) {
        [self.navigationItem setTitle:identifiant];
        [_prenom setText:[dico objectForKey:@"first_name"]];
        [_nom setText:[dico objectForKey:@"last_name"]];
        int i = [(NSNumber *)[dico objectForKey:@"promo"] intValue];
        if (i < 10) {
            [_promo setText:[@"P" stringByAppendingString:[NSString stringWithFormat:@"0%d",i]]];
        }
        else {
            [_promo setText:[@"P" stringByAppendingString:[NSString stringWithFormat:@"%d",i]]];
        }
        [_liste reloadData];
    }
    [(UIScrollView *)self.view scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

// Affichage de la photo en grand
-(void)photoSelect {
    AffichagePhoto *controller = [[AffichagePhoto alloc] init];
    UIImageView *vue = [[UIImageView alloc] initWithImage:[reseauTest getImage:identifiant]];
    int largeur = [self view].bounds.size.height * ([vue bounds].size.width/[vue bounds].size.height);
    int marge = ([self view].bounds.size.width - largeur)/2;
    [vue setFrame:CGRectMake(marge, 0, largeur, [self view].bounds.size.height)];
    [[controller view] addSubview:vue];
    [self.navigationController pushViewController:controller animated:YES];
}

//###################### Ajout du contact au carnet d'adresses #######################
-(void)ajoutContact {
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);

    if (iOS6higher) {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressbook,^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self ajoutContact];
                }
            });
            return;
        }
    }
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFArrayRef trouve = ABAddressBookCopyPeopleWithName(addressbook, (__bridge CFStringRef)([dico objectForKey:@"last_name"]));
        
        // On regarde si le contact existe déjà ou non
        ABRecordRef nouveau = ABPersonCreate();
        CFErrorRef error;
        
        for (int i = 0; i< CFArrayGetCount(trouve);i++) {
            if ([(__bridge NSString *)ABRecordCopyValue((ABRecordRef)CFArrayGetValueAtIndex(trouve, i),kABPersonFirstNameProperty) isEqualToString:[dico objectForKey:@"first_name"]]) {
                CFRelease(nouveau);
                nouveau = CFArrayGetValueAtIndex(trouve, i);
            }
        }
        
        // On ajoute nom et prénom
        ABRecordSetValue(nouveau, kABPersonFirstNameProperty, (__bridge CFTypeRef)([dico objectForKey:@"first_name"]), NULL);
        ABRecordSetValue(nouveau, kABPersonLastNameProperty, (__bridge CFTypeRef)([dico objectForKey:@"last_name"]), NULL);
        
        // On ajoute le numéro de téléphone
        if ([dico objectForKey:@"phone"]) {
            ABMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMultiValueAddValueAndLabel(phones, (__bridge CFTypeRef)([dico objectForKey:@"phone"]),kABPersonPhoneMobileLabel, NULL);
            ABRecordSetValue(nouveau, kABPersonPhoneProperty, phones, NULL);
            CFRelease(phones);
        }
        
        //On ajoute l'adresse mail
        ABMultiValueRef mails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(mails, (__bridge CFTypeRef)([dico objectForKey:@"email"]),kABWorkLabel, NULL);
        ABRecordSetValue(nouveau, kABPersonEmailProperty, mails, NULL);
        CFRelease(mails);
        
        // On ajoute la photo
        UIImage *image = [reseauTest getImage:identifiant];
        if (image) {
            ABPersonSetImageData(nouveau, (__bridge CFDataRef)UIImageJPEGRepresentation(image, 1.0f), NULL);
        }
        
        // On ajoute la date de naissance
        if (![[dico objectForKey:@"birthday"] isEqualToString:@""]) {
            ABRecordSetValue(nouveau, kABPersonBirthdayProperty, (__bridge CFTypeRef)([decode dateFromString:[dico objectForKey:@"birthday"]]), NULL);
        }
        
        // On sauvegarde les changements
        
        ABAddressBookAddRecord(addressbook, nouveau, NULL);
        ABAddressBookSave(addressbook, &error);
        [[[UIAlertView alloc] initWithTitle:@"Contact" message:@"Contact ajouté" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        CFRelease(nouveau);
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Opération impossible" message:@"Accès aux contacts interdit" delegate:nil cancelButtonTitle:@"Dans ma gueule..." otherButtonTitles:nil] show];
    }
    CFRelease(addressbook);
    
}

//###################### A partir d'ici, gestion de la table ######################
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (dico) {
        return [elements count];
    }
    else return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.textLabel setText:[elements objectAtIndex:[indexPath indexAtPosition:0]]];
    if ([indexPath indexAtPosition:0] == 3) {
        NSString *date = [dico objectForKey:[cles objectAtIndex:3]];
        NSDate *dateFormat = [decode dateFromString:date];
        
        [cell.detailTextLabel setText:[recode stringFromDate:dateFormat]];
    }
    else {
        [cell.detailTextLabel setText:[dico objectForKey:[cles objectAtIndex:[indexPath indexAtPosition:0]]]];
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath indexAtPosition:0] == 0) {
        if (![[dico objectForKey:@"phone"] isEqualToString:@""]) {
            telephone = [[UIActionSheet alloc] initWithTitle:@"Appeler?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:nil otherButtonTitles:@"Appeler",@"Envoyer un SMS", nil];
            [telephone showFromTabBar:self.tabBarController.tabBar];
        }
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if (![[dico objectForKey:@"email"] isEqualToString:@""]) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Mail?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:nil otherButtonTitles:@"Envoyer un mail", nil];
            [sheet showFromTabBar:self.tabBarController.tabBar];
        }
    }
    else if ([indexPath indexAtPosition:0] == 4 || [indexPath indexAtPosition:0] == 5) {
        
        if (([indexPath indexAtPosition:0] == 4 && ![[dico objectForKey:@"parrain"] isEqualToString:@""]) || ([indexPath indexAtPosition:0] == 5 && ![[dico objectForKey:@"fillot"] isEqualToString:@""])) {
            
            AffichageTrombi *vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
            
            if ([indexPath indexAtPosition:0] == 4) {
                [vueDetail changeUsername:[dico objectForKey:@"parrain"]];
            }
            else {
                [vueDetail changeUsername:[dico objectForKey:@"fillot"]];
            }
            [vueDetail majAffichage];
            
            // Début de l'animation
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [self.navigationController pushViewController:vueDetail animated:YES];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                             }
                             completion:^(BOOL finished){
                                 NSMutableArray *tableau = [self.navigationController.viewControllers mutableCopy];
                                 [tableau removeObjectAtIndex:[tableau count]-2];
                                 [self.navigationController setViewControllers:tableau];
                             }];
            //[self pushViewController:vueDetail animated:YES completion:nil];
        }
    }
    [_liste deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == telephone) {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[[dico objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@",[[dico objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    else {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[dico objectForKey:@"email"]]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [indexPath indexAtPosition:0];
    if (index > 1 && index <4) {
        return nil;
    }
    else {
        return indexPath;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
