//
//  AffichageEvenement.m
//  Portail Mines
//
//  Created by Valérian Roche on 17/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AffichageEvenement.h"
#import <EventKit/EventKit.h>

@interface AffichageEvenement ()

@end

@implementation AffichageEvenement

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        cle = [[NSArray alloc] initWithObjects:@"title",@"body",@"start",@"end",@"auteur",nil];
        affichageCle = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"Titre",@"Evènement",@"Début",@"Fin",@"Assoce", nil] forKeys:cle];
        
        deformatter = [[NSDateFormatter alloc] init];
        [deformatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM yyyy, HH:mm"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
    }
    return self;
}

-(void)changeDico:(NSDictionary *)nouveauDico {
    dico = nouveauDico;
    self.navigationItem.title = [dico objectForKey:@"title"];
    [_liste reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_liste setDataSource:self];
    [_liste setDelegate:self];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(ajoutCalendrier)];
    [[self navigationItem] setRightBarButtonItem:button animated:NO];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:recognizer];
}

-(void)ajoutCalendrier {
    if (!store) {
        store = [[EKEventStore alloc] init];
    
        if (!([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)) {
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError *error) {
                [self ajoutCalendrier];
            }];
            return;
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 || [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        NSPredicate *predicate = [store predicateForEventsWithStartDate:[deformatter dateFromString:[dico objectForKey:@"start"]]
                                                                endDate:[deformatter dateFromString:[dico objectForKey:@"end"]]
                                                              calendars:nil];
        NSArray *evenements = [store eventsMatchingPredicate:predicate];
        if ([evenements count]) {
            for (EKEvent *event in evenements) {
                if ([[event title] isEqualToString:[dico objectForKey:@"title"]]) {
                    UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Encore ???" message:@"Cet évènement est déjà enregistré" delegate:nil cancelButtonTitle:@"Ca va c'est bon..." otherButtonTitles:nil];
                    [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                    return;
                }
            }
        }
        
        // Gestion des calendriers. On indique ici le calendrier utilisé, et on demande la première fois.
        // On prend alors celui par défaut ou celui Portail Mines (ou on crée ce dernier)
        EKCalendar *calendrier;
        
        /*NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
        if ([[[NSDictionary dictionaryWithContentsOfFile:fichierDonnees] objectForKey:@"ChoixCalendrier"] isEqualToString:@"Non choisi"]) {*/
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ChoixCalendrier"] isEqualToString:@"Non choisi"]) {
            UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Calendrier" message:@"Enregistrer dans le calendrier par défaut ou dans un nouveau?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Par défaut",@"Nouveau calendrier",nil];
            [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            return;
        }
        //else if ([[[NSDictionary dictionaryWithContentsOfFile:fichierDonnees] objectForKey:@"ChoixCalendrier"] isEqualToString:@"Nouveau"]) {
        else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ChoixCalendrier"] isEqualToString:@"Nouveau"]) {
            NSArray *calendriers;
            if ([store respondsToSelector:@selector(calendarForEntityType:)])
                calendriers = [store calendarsForEntityType:EKEntityTypeEvent];
            else {
                calendriers = [store calendars];
            }
            for (EKCalendar *calend in calendriers) {
                if ([[calend title] isEqualToString:@"Portail Mines"]) {
                    calendrier = calend;
                }
            }
            if (!calendrier) {
                if ([store respondsToSelector:@selector(calendarForEntityType:eventStore:)])
                    calendrier = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:store];
                else
                    calendrier = [EKCalendar calendarWithEventStore:store];
                [calendrier setTitle:@"Portail Mines"];
                [calendrier setCGColor:(__bridge CGColorRef)([UIColor greenColor])];
                
                EKSource *source;
                for (EKSource *newSource in [store sources]) {
                    if ([newSource sourceType] == EKSourceTypeCalDAV && [[newSource title] isEqualToString:@"iCloud"]) {
                        source = newSource;
                    }
                }
                if (!source) {
                    for (EKSource *newSource in [store sources]) {
                        if ([newSource sourceType] == EKSourceTypeLocal) {
                            source = newSource;
                        }
                    }
 
                }
                [calendrier setSource:source];
                
                NSError *error;
                if (![store saveCalendar:calendrier commit:YES error:&error])
                    NSLog(@"Echec sauvegarde calendrier");
            }
        }
        else {
            calendrier = [store defaultCalendarForNewEvents];
        }
    
        EKEvent *event = [EKEvent eventWithEventStore:store];
        [event setTitle:[dico objectForKey:@"title"]];
        [event setStartDate:[deformatter dateFromString:[dico objectForKey:@"start"]]];
        [event setEndDate:[deformatter dateFromString:[dico objectForKey:@"end"]]];
        [event setTimeZone:[NSTimeZone systemTimeZone]];
        [event setCalendar:calendrier];
        NSError *error;
        if ([store saveEvent:event span:EKSpanThisEvent commit:YES error:&error]) {
            UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Evènement" message:@"Message enregistré" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
        else {
            NSLog(@"Echec sauvegarde évènement");
            UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Evènement" message:@"Echec lors de l'enregistrement" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Opération impossible" message:@"Accès au calendrier interdit" delegate:nil cancelButtonTitle:@"J'avais qu'à ne pas refuser..." otherButtonTitles:nil] show];
    }
}

// ################## Délégué ################## //
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [cle count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float padding;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        padding = 208.0f;
    }
    else {
        padding = self.view.bounds.size.width - 112.0f;
    }
    
    if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"body"]) {
        return [[dico objectForKey:@"body"] sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(padding, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 25;
    }
    else if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"title"]) {
        return [[dico objectForKey:@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(padding, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 25;
    }
    else
        return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell textLabel] setText:[[affichageCle objectForKey:[cle objectAtIndex:[indexPath indexAtPosition:0]] ] capitalizedString]];

    if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"start"]) {
        [[cell detailTextLabel] setText:[formatter stringFromDate:[deformatter dateFromString:[dico objectForKey:@"start"]]]];
    }
    
    else if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"end"]) {
        [[cell detailTextLabel] setText:[formatter stringFromDate:[deformatter dateFromString:[dico objectForKey:@"end"]]]];
    }
    
    else if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"auteur"])
        [[cell detailTextLabel] setText:[dico objectForKey:@"auteur"]];
    
    else if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"title"]) {
        [[cell detailTextLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [[cell detailTextLabel] setNumberOfLines:0];
        [[cell detailTextLabel] setText:[dico objectForKey:@"title"]];
    }
    
    else if ([[cle objectAtIndex:[indexPath indexAtPosition:0]] isEqualToString:@"body"]) {
        [[cell detailTextLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [[cell detailTextLabel] setNumberOfLines:0];
        [[cell detailTextLabel] setText:[dico objectForKey:@"body"]];
    }
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    /*NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:fichierDonnees];
    if (buttonIndex == 0) {
        [temp setObject:@"Default" forKey:@"ChoixCalendrier"];
    }
    else {
        [temp setObject:@"Nouveau" forKey:@"ChoixCalendrier"];
    }
    [temp writeToFile:fichierDonnees atomically:NO];*/
    NSString *chaine;
    if (buttonIndex == 0)
        chaine = @"Default";
    else
        chaine = @"Nouveau";
    [[NSUserDefaults standardUserDefaults] setObject:chaine forKey:@"ChoixCalendrier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self ajoutCalendrier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    store = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)viewDidUnload {
    [self setListe:nil];
    dico = nil;
    cle = nil;
    affichageCle = nil;
    deformatter = nil;
    formatter = nil;
    store = nil;
    [super viewDidUnload];
}

@end
