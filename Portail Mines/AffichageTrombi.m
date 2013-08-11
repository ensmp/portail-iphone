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
#import <MessageUI/MessageUI.h>
#import "AffichagePhoto.h"

// Pour les clés, on utilise la fonction calculCles. Il faut modifier elements (h et m), et toutes les fonctions de la table

@interface AffichageTrombi ()

@end

@implementation AffichageTrombi
@synthesize vueImage = _vueImage, prenom = _prenom, nom = _nom, promo = _promo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil etReseau:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseauTest = reseau;
        //elements = [NSArray arrayWithObjects:@"Téléphone",@"Mail",@"Chambre",@"Naissance",@"Co",@"Parrain",@"Fillot", nil];
        cles = [NSArray arrayWithObjects:@"phone",@"email",@"chambre",@"birthday",@"co",@"parrains",@"fillots", nil];
        elements = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Téléphone",@"Mail",@"Chambre",@"Naissance",@"Co",@"Parrain",@"Fillot", nil] forKeys:cles];
        clesUtilisees = [[NSMutableArray alloc] initWithCapacity:[cles count]];
        decode = [[NSDateFormatter alloc] init];
        [decode setDateFormat:@"yyyy-MM-dd"];
        recode = [[NSDateFormatter alloc] init];
        [recode setDateFormat:@"dd MMMM yyyy"];
        [recode setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        iOS6higher = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0);
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
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
    ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y+10);
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

/*-(void)changeOrientation:(NSNotification *)notif {
    [_liste sizeToFit];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) 
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y+10);
    else
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y-10);
    //[(UIScrollView *)self.view scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}*/

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_liste sizeToFit];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y+10);
    else
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y-10);
}

-(BOOL)changeUsername:(NSString *)username {
    identifiant = username;
    
    [reseauTest chercheImageOuMessage:YES pourUsername:username];
    [reseauTest chercheImageOuMessage:NO pourUsername:username];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"imageTelecharge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"messageTelecharge" object:nil];
    dico = [reseauTest getInfos:username etTelechargement:NO];
    if (!dico)
        return NO;
    else return YES;
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
                [self calculCles];
                [_liste reloadData];
                
                // On redimensionne la liste
                CGRect rect = CGRectMake(_liste.frame.origin.x, _liste.frame.origin.y, _liste.frame.size.width, _liste.contentSize.height);
                [_liste setFrame:rect];
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
                    ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y+10);
                else
                    ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y-10);
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageTelecharge" object:nil];
        }
    }
}

-(void)majAffichage {
    [_vueImage setImage:[reseauTest getImage:identifiant]];
    if (dico) {
        [self calculCles];
        [self.navigationItem setTitle:identifiant];
        
        if ([identifiant isEqualToString:@"11benssy"])
            [_prenom setText:@"Piche"];
        else if ([identifiant isEqualToString:@"11collon"])
            [_prenom setText:@"La cochonne"];
        else if ([identifiant isEqualToString:@"12caruel"])
            [_prenom setText:@"La folle !"];
        else
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
    CGRect rect = CGRectMake(_liste.frame.origin.x, _liste.frame.origin.y, _liste.frame.size.width, _liste.contentSize.height);
    [_liste setFrame:rect];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y+10);
    else
        ((UIScrollView *)self.view).contentSize = CGSizeMake([self view].bounds.size.width,_liste.bounds.size.height+[_liste frame].origin.y-10);
    [(UIScrollView *)self.view scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

// Pour le calcul des champs
-(void)calculCles {
    [clesUtilisees removeAllObjects];
    for (NSString *key in cles) {
        if ([[dico objectForKey:key] isKindOfClass:[NSString class]]) {
            if (![[dico objectForKey:key] isEqualToString:@""]) {
                [clesUtilisees addObject:key];
            }
        }
        else if ([[dico objectForKey:key] isKindOfClass:[NSArray class]]) {
            if ([[dico objectForKey:key] count] != 0) {
                [clesUtilisees addObject:key];
            }
        }
    }
}

// Affichage de la photo en grand
-(void)photoSelect {
    AffichagePhoto *controller = [[AffichagePhoto alloc] init];
    
    [[controller view] setBackgroundColor:[UIColor blackColor]];
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [[controller view] addGestureRecognizer:gesture];
    
    UIImageView *vue;
    /*if ([identifiant isEqualToString:@"11maire"]) {
        vue = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Romain.jpg"]];
    }
    else*/
        vue = [[UIImageView alloc] initWithImage:[reseauTest getImage:identifiant]];
    int largeur = [self view].bounds.size.height * ([vue bounds].size.width/[vue bounds].size.height);
    int marge = ([self view].bounds.size.width - largeur)/2;
    [vue setFrame:CGRectMake(marge, 0, largeur, [self view].bounds.size.height)];
    [[controller view] addSubview:vue];
    
    [controller.navigationItem setTitle:identifiant];
    [self.navigationController pushViewController:controller animated:YES];
}

//###################### Ajout du contact au carnet d'adresses #######################
-(void)ajoutContact {

    ABAddressBookRef addressbook;
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)) {
        addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressbook,^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self ajoutContact];
                }
            });
            return;
        }
    }
    else {
        addressbook = ABAddressBookCreate();
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFArrayRef trouve = ABAddressBookCopyPeopleWithName(addressbook, (__bridge CFStringRef)([dico objectForKey:@"last_name"]));
        
        // On regarde si le contact existe déjà ou non
        ABRecordRef nouveau = ABPersonCreate();
        CFErrorRef error;
        
        for (int i = 0; i< CFArrayGetCount(trouve);i++) {
            if ([(__bridge NSString *)ABRecordCopyValue((ABRecordRef)CFArrayGetValueAtIndex(trouve, i),kABPersonFirstNameProperty) isEqualToString:[dico objectForKey:@"first_name"]]) {
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
        CFRelease(nouveau);
        [[[UIAlertView alloc] initWithTitle:@"Contact" message:@"Contact ajouté" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Opération impossible" message:@"Accès aux contacts interdit" delegate:nil cancelButtonTitle:@"Dans ma gueule..." otherButtonTitles:nil] show];
    }
    CFRelease(addressbook);
}

//###################### A partir d'ici, gestion de la table ######################
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (dico) {
        
        return [clesUtilisees count];
        //return [elements count];
    }
    else return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([[dico objectForKey:[clesUtilisees objectAtIndex:section]] isKindOfClass:[NSArray class]]) {
        return MAX([[dico objectForKey:[clesUtilisees objectAtIndex:section]] count],1);
    }
    else {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell.textLabel setText:[elements objectForKey:[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]]]];
    
    if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"phone"] || [[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"email"] || [[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"chambre"])
    {
        [cell.detailTextLabel setText:[dico objectForKey:[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]]]];
    }
    else if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"birthday"]) {
        NSString *date = [dico objectForKey:@"birthday"];
        NSDate *dateFormat = [decode dateFromString:date];
        
        [cell.detailTextLabel setText:[recode stringFromDate:dateFormat]];
    }
    else {
        if (![[dico objectForKey:[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]]] count]) {
            [cell.detailTextLabel setText:@""];
        }
        else {
            [cell.detailTextLabel setText:[[dico objectForKey:[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]]] objectAtIndex:[indexPath indexAtPosition:1]]];
        }
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    bascule = NO;
    
    if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"phone"]) {
        //if (![[dico objectForKey:@"phone"] isEqualToString:@""]) {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]]) {
                    telephone = [[UIActionSheet alloc] initWithTitle:@"Téléphone?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:nil otherButtonTitles:@"Appeler",@"Envoyer un SMS", nil];
                }
                else {
                    telephone = [[UIActionSheet alloc] initWithTitle:@"SMS?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:nil otherButtonTitles:@"Envoyer un SMS", nil];
                }
            [telephone showFromTabBar:self.tabBarController.tabBar];
        //}
    }
    else if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"email"]) {
        //if (![[dico objectForKey:@"email"] isEqualToString:@""]) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Mail?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:nil otherButtonTitles:@"Envoyer un mail", nil];
            [sheet showFromTabBar:self.tabBarController.tabBar];
        //}
    }
    //else if ([indexPath indexAtPosition:0] > 3 ) {
    else if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"co"]) {
        if (!vueDetail) {
            vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
        }
        [vueDetail changeUsername:[[dico objectForKey:@"co"] objectAtIndex:[indexPath indexAtPosition:1]]];
        bascule = YES;
    }
    
    else if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"parrains"]) {
        if (!vueDetail) {
            vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
        }
        [vueDetail changeUsername:[[dico objectForKey:@"parrains"] objectAtIndex:[indexPath indexAtPosition:1]]];
        bascule = YES;
    }
    
    else if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"fillots"]) {
        if (!vueDetail) {
            vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
        }
        [vueDetail changeUsername:[[dico objectForKey:@"fillots"] objectAtIndex:[indexPath indexAtPosition:1]]];
        bascule = YES;
    }
    
        if (bascule) {
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
            
        }
    //}
    [_liste deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == telephone) {
        if (buttonIndex == 0 && [actionSheet numberOfButtons] == 3) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[[dico objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else if ((buttonIndex == 1 && [actionSheet numberOfButtons] == 3) || (buttonIndex == 0 && [actionSheet numberOfButtons] == 2)) {
            
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *controllerSMS = [[MFMessageComposeViewController alloc] init];
                [controllerSMS setMessageComposeDelegate:self];
            
                [controllerSMS setRecipients:[NSArray arrayWithObject:[[dico objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
                [self presentModalViewController:controllerSMS animated:YES];
            }
        }
    }
    else {
        if (buttonIndex == 0) {
                        
            MFMailComposeViewController *controllerMail = [[MFMailComposeViewController alloc] init];
            [controllerMail setMailComposeDelegate:self];
            [controllerMail setToRecipients:[NSArray arrayWithObject:[dico objectForKey:@"email"]]];
            [self presentModalViewController:controllerMail animated:YES];
        }
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"birthday"] || [[clesUtilisees objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"chambre"]) {
        return nil;
    }
    else
        return indexPath;
}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    vueDetail = nil;
    if (![telephone isVisible]) {
        telephone = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)viewDidUnload {
    [self setPrenom:nil];
    [self setListe:nil];
    [self setNom:nil];
    [self setPromo:nil];
    [self setVueImage:nil];
    reseauTest = nil;
    identifiant = nil;
    dico = nil;
    elements = nil;
    elements = nil;
    cles = nil;
    clesUtilisees = nil;
    decode = nil;
    recode = nil;
    telephone = nil;
    vueDetail = nil;
    [super viewDidUnload];
}

-(void)applicationWillResignActive {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageTelecharge" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageTelecharge" object:nil];
}
-(void)applicationDidEnterBackground {}
-(void)applicationWillEnterForeground {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}
-(void)applicationDidBecomeActive {}

@end
