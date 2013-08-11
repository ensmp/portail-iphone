//
//  Trombi.m
//  Portail Mines
//
//  Created by Valérian Roche on 14/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "Trombi.h"
#import "Reseau.h"
#import "OverlayViewController.h"
#import "AffichageTrombi.h"
#import "Modele.h"
#import <EventKit/EventKit.h>

@interface Trombi ()
@property (nonatomic, getter = isAjoutCalendrierEnCours) BOOL ajoutCalendrierEnCours;
@property (nonatomic, strong) EKEventStore *store;
@property (nonatomic, strong) NSDateFormatter *decode;
@end

@implementation Trombi

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trombi", @"Trombi");
        self.tabBarItem.title = @"Trombi";
        self.tabBarItem.image = [UIImage imageNamed:@"trombi.png"];
        reseauTest = reseau;
        searching = NO;
        peutSelect = YES;
        formatter = [[NSNumberFormatter alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _barre.topItem.title = @"Trombi";
    _liste.delegate = self;
    _liste.dataSource = self;
    _liste.scrollsToTop = YES;
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // On met le choix de tri
    control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Alphabet",@"Promo",nil]];
    [control setSegmentedControlStyle:UISegmentedControlStyleBar];
    [control setSelectedSegmentIndex:0];
    [control setWidth:100 forSegmentAtIndex:0];
    [control setWidth:100 forSegmentAtIndex:1];
    [control addTarget:self action:@selector(retriTrombi) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = control;
    
    UIBarButtonItem *ajoutAnniversaire = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(ajoutCalendrier)];
    [self.navigationItem setRightBarButtonItem:ajoutAnniversaire];
    
    //trombi = [reseauTest getTrombi];
    
    // ############################### TESTS ##############################
    [[Modele modelePartage] connectionDispo];
    trombi = [[Modele modelePartage] getTrombi];
    
    
    
    trombiTrie = [[NSMutableArray alloc] initWithCapacity:27];
    tab = [NSArray arrayWithObjects:@"",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L",@"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z", nil];
    
    if (!trombi) {
        [_activite startAnimating];
        trombi = [[NSArray alloc] initWithObjects:nil];
        trombiTrie = [[NSMutableArray alloc] initWithCapacity:27];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargeTrombi) name:@"tTelecharge" object:nil];
    }
    // On crée les sous-tableaux si le trombi est chargé
    else {
        for (NSString *s in tab) {
            [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@",s]]];
        }
    }

    _liste.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    copy = [[NSMutableArray alloc] init];
    if ([trombi count] != 0) {
        [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    // Pour le basculement :
    triAlphabet = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"imageTelecharge" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selection = [_liste indexPathForSelectedRow];
    if (selection)
        [_liste deselectRowAtIndexPath:selection animated:YES];
}

-(NSDateFormatter *)decode {
    if (!_decode) {
        _decode = [[NSDateFormatter alloc] init];
        [_decode setDateFormat:@"yyyy-MM-dd"];
    }
    return _decode;
}

-(void)chargeTrombi {
    trombi = [reseauTest getTrombi];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tTelecharge" object:nil];
    if (!trombi) {
        trombi = [[NSArray alloc] initWithObjects:nil];
        [_activite stopAnimating];
        UIAlertView *alerte = [[UIAlertView alloc] initWithTitle:@"Raté!!" message:@"Impossible de télécharger le trombi" delegate:nil cancelButtonTitle:@"Dommage..." otherButtonTitles:nil];
        [alerte show];
    }
    else {
        if ([_activite isAnimating]) {
            [trombiTrie removeAllObjects];
            for (NSString *s in tab) {
                [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@",s]]];
            }
            [_liste reloadData];
            [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [_activite stopAnimating];
        }
    }
}

-(void)retriTrombi {
    /*if (([control selectedSegmentIndex] == 0) && triAlphabet) {
        return;
    }
    else if (!([control selectedSegmentIndex] == 0) && !triAlphabet) {
        return;
    }*/
    
    /*else */if ([control selectedSegmentIndex] == 0) {
        if (!trombi)
            trombi = [reseauTest getTrombi];
        
        triAlphabet = YES;
        if (![trombi count])
            return;
        
        [trombiTrie removeAllObjects];
        tab = [NSArray arrayWithObjects:@"",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L",@"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z", nil];
        for (NSString *s in tab) {
            [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@",s]]];
        }
        [_liste reloadData];
        [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else {
        if (!trombi)
            trombi = [reseauTest getTrombi];
        
        triAlphabet = NO;
        
        if (![trombi count])
            return;
        
        [trombiTrie removeAllObjects];
        NSMutableArray *temp = [NSMutableArray arrayWithObject:@""];
        [temp addObjectsFromArray:[[[NSSet setWithArray:[trombi valueForKey:@"promo"]] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:NO selector:@selector(compare:)]]]];
        if ([temp containsObject:[NSNull null]]) {
            [temp removeObject:[NSNull null]];
        }
        tab = temp;

        for (NSNumber *s in tab) {
            [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"promo == %d",[s intValue]]]];
        }
        [_liste reloadData];
        [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(void)majImage:(NSNotification *)notif {
    if ([[notif userInfo] objectForKey:@"succes"]) {
        if (!trombi)
            trombi = [reseauTest getTrombi];
        
        NSIndexSet *set = [trombi indexesOfObjectsPassingTest:^BOOL(id objet, NSUInteger idx, BOOL *test) {
            if ([[objet objectForKey:@"username"] isEqualToString:[[notif userInfo] objectForKey:@"username"]])
                return YES;
            else return NO;
        }];
        
        NSIndexPath *indexPath;
        if (!searching) {
            int i = 0;
            while (![[trombiTrie objectAtIndex:i] containsObject:[trombi objectAtIndex:[set firstIndex]]]) {
                i++;
                if (i == [trombiTrie count])
                    return;
            }
            indexPath = [NSIndexPath indexPathForRow:[[trombiTrie objectAtIndex:i] indexOfObject:[trombi objectAtIndex:[set firstIndex]]] inSection:i];
            [_liste reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            int i = [copy indexOfObject:[trombi objectAtIndex:[set firstIndex]]];
            if (i <= [trombi count]) {
                indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [_liste reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

-(IBAction)ajoutCalendrier {
    self.ajoutCalendrierEnCours = ![self isAjoutCalendrierEnCours];
    if ([self isAjoutCalendrierEnCours]) {
        UIBarButtonItem *annuler = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(ajoutCalendrier)];
        [self.navigationItem setRightBarButtonItem:annuler];
        [self.navigationItem setTitleView:nil];
        [self.navigationItem setTitle:@"Ajout Calendrier"];
        
        NSMutableArray *temp = [NSMutableArray arrayWithObject:@""];
        [temp addObjectsFromArray:[[[NSSet setWithArray:[trombi valueForKey:@"promo"]] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:NO selector:@selector(compare:)]]]];
        if ([temp containsObject:[NSNull null]]) {
            [temp removeObject:[NSNull null]];
        }
        else if ([temp containsObject:@""])
                 [temp removeObject:@""];
        [temp sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]];
        copy = [temp copy];
        [UIView animateWithDuration:0.4f
                         animations:^{[_liste reloadData];
                         }];
    }
    else {
        UIBarButtonItem *ajout = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(ajoutCalendrier)];
        [self.navigationItem setRightBarButtonItem:ajout];
        self.navigationItem.titleView = control;
        [self.navigationItem setTitle:@"Trombi"];
        [self retriTrombi];
    }
}

-(void)ajoutCalendrierSurIphone:(NSNumber *)promo {
    if (!self.store) {
        self.store = [[EKEventStore alloc] init];
        
        if (!([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)) {
            [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError *error) {
                [self ajoutCalendrierSurIphone:promo];
            }];
            return;
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 || [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        
        EKCalendar *calendrier;
        
        NSArray *calendriers;
        if ([self.store respondsToSelector:@selector(calendarsForEntityType:)]) {
            calendriers = [self.store calendarsForEntityType:EKEntityTypeEvent];
        }
        else
            calendriers = [self.store calendars];
        for (EKCalendar *calend in calendriers) {
            if ([[calend title] isEqualToString:@"Anniversaire Mines"]) {
                calendrier = calend;
            }
        }
        if (!calendrier) {
            
            if ([self.store respondsToSelector:@selector(calendarForEntityType:eventStore:)]) {
                calendrier = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.store];
            }
            else
                calendrier = [EKCalendar calendarWithEventStore:self.store];
            [calendrier setTitle:@"Anniversaire Mines"];
            [calendrier setCGColor:(__bridge CGColorRef)([UIColor greenColor])];
            
            EKSource *source;
            for (EKSource *newSource in [self.store sources]) {
                if ([newSource sourceType] == EKSourceTypeCalDAV && [[newSource title] isEqualToString:@"iCloud"]) {
                    source = newSource;
                }
            }
            if (!source) {
                for (EKSource *newSource in [self.store sources]) {
                    if ([newSource sourceType] == EKSourceTypeLocal) {
                        source = newSource;
                    }
                }
                
            }
            [calendrier setSource:source];
            
            NSError *error;
            if (![self.store saveCalendar:calendrier commit:YES error:&error])
                NSLog(@"Echec sauvegarde calendrier");
        }
        
        NSArray *personnes = [trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"promo == %d",[promo intValue]]];
        if (!personnes || ![personnes count])
            return;
        
        
        NSDateComponents *composants = nil;
        NSDate *date = nil;
        EKRecurrenceRule *recurrence;
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        int annee = [[gregorian components:NSYearCalendarUnit fromDate:[NSDate date]] year];
        
        /////////////
        NSDictionary *dico = [reseauTest getInfos:[[personnes objectAtIndex:0] objectForKey:@"username"] etTelechargement:NO];
        composants = [gregorian components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[self.decode dateFromString:[dico objectForKey:@"birthday"]]];
        [composants setYear:annee];
        date = [gregorian dateFromComponents:composants];
        NSPredicate *predicate = [self.store predicateForEventsWithStartDate:[date dateByAddingTimeInterval:-10000]
                                                                     endDate:[date dateByAddingTimeInterval:10000]
                                                                   calendars:[NSArray arrayWithObject:calendrier]];
        NSArray *evenements = [self.store eventsMatchingPredicate:predicate];
        if ([evenements count]) {
            BOOL trouve = NO;
            for (EKEvent *evenement in evenements) {
                if ([[evenement title] isEqualToString:[NSString stringWithFormat:@"Anniversaire de %@ %@",[[personnes objectAtIndex:0] objectForKey:@"first_name"],[[personnes objectAtIndex:0] objectForKey:@"last_name"]]])
                    trouve = YES;
            }
            if (trouve) {
                UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Anniversaires" message:@"Promo déjà ajoutée" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                return;
            }
        }
        //////
        for (NSDictionary *personne in personnes) {
            NSDictionary *dico = [reseauTest getInfos:[personne objectForKey:@"username"] etTelechargement:NO];
            
            composants = [gregorian components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[self.decode dateFromString:[dico objectForKey:@"birthday"]]];
            [composants setYear:annee];
            date = [gregorian dateFromComponents:composants];
            
            /*NSPredicate *predicate = [self.store predicateForEventsWithStartDate:date
                                                                         endDate:date
                                                                       calendars:[NSArray arrayWithObject:calendrier]];
            NSArray *evenements = [self.store eventsMatchingPredicate:predicate];
            if ([evenements count]) {
                BOOL trouve = NO;
                for (EKEvent *evenement in evenements) {
                    if ([[evenement title] isEqualToString:[NSString stringWithFormat:@"Anniversaire de %@ %@",[personne objectForKey:@"first_name"],[personne objectForKey:@"last_name"]]])
                        trouve = YES;
                }
                if (trouve)
                    continue;
            }*/
            //else {
                recurrence = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:nil];
                EKEvent *event = [EKEvent eventWithEventStore:self.store];
                [event setTimeZone:[NSTimeZone systemTimeZone]];
                [event addRecurrenceRule:recurrence];
                [event setTitle:[NSString stringWithFormat:@"Anniversaire de %@ %@",[personne objectForKey:@"first_name"],[personne objectForKey:@"last_name"]]];
                [event setCalendar:calendrier];
                
                [event setStartDate:date];
                [event setEndDate:date];
                [event setAvailability:EKEventAvailabilityFree];
                [event setAllDay:YES];
                NSError *error;
                [self.store saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
            }
            
        //}
        //NSError *error;
        if (YES) {//[self.store commit:&error]) {
            UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Anniversaires" message:@"Anniversaires ajoutés" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
        else {
            UIAlertView *vue = [[UIAlertView alloc] initWithTitle:@"Anniversaires" message:@"Erreur lors de l'ajout" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [vue performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Opération impossible" message:@"Accès au calendrier interdit" delegate:nil cancelButtonTitle:@"J'avais qu'à ne pas refuser..." otherButtonTitles:nil] show];
    }
}

// Pour l'affichage des utilisateurs dans le chat
-(BOOL)affichagePersonne:(NSString *)username {
    [self.navigationController popToRootViewControllerAnimated:NO];
    if (!vueDetail) {
        vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
    }
    if (![vueDetail changeUsername:username])
        return NO;
    [vueDetail majAffichage];
    [self.navigationController pushViewController:vueDetail animated:NO];
    return YES;
}

// A partir d'ici, gestion de la table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searching || [self isAjoutCalendrierEnCours]) {
        return 1;
    }
    else if ([trombiTrie count] == 0)
        return 0;
    return [tab count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searching || [self isAjoutCalendrierEnCours]) {
        return @"";
    }
    
    if (triAlphabet) {
        return [tab objectAtIndex:section];
    }
    else if (section == 0) {
        return @"";
    }
    else {
        if ([[tab objectAtIndex:section] intValue] < 10) {
            return [NSString stringWithFormat:@"P0%d",[[tab objectAtIndex:section] intValue]];
        }
        else
            return [NSString stringWithFormat:@"P%d",[[tab objectAtIndex:section] intValue]];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching || [self isAjoutCalendrierEnCours]) {
        return [copy count];
    }
    if (section == 0 || [trombiTrie count] == 0) {
        return 0;
    }
    return [[trombiTrie objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (searching && [copy count]) {
        NSDictionary *tableau = [copy objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [tableau objectForKey:@"last_name"];
        cell.detailTextLabel.text = [tableau objectForKey:@"first_name"];
        cell.imageView.image = [reseauTest getImage:[tableau objectForKey:@"username"]];
    }
    else if ([self isAjoutCalendrierEnCours] && [copy count]) {
        NSString *promo;
        if ([[copy objectAtIndex:[indexPath indexAtPosition:1]] intValue] < 10) {
            promo = [NSString stringWithFormat:@"P0%d",[[copy objectAtIndex:[indexPath indexAtPosition:1]] intValue]];
        }
        else
            promo = [NSString stringWithFormat:@"P%d",[[copy objectAtIndex:[indexPath indexAtPosition:1]] intValue]];
        [cell.textLabel setText:promo];
        [cell.detailTextLabel setText:@""];
        [cell.imageView setImage:nil];
    }
    else {
    
        NSDictionary *tableau = [[trombiTrie objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [tableau objectForKey:@"last_name"];
        cell.detailTextLabel.text = [tableau objectForKey:@"first_name"];
        UIImage *image = [reseauTest getImage:[tableau objectForKey:@"username"]];
        if (image) {
            cell.imageView.image = image;
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"trombi.png"];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *username;
    if (searching) {
        username = [[copy objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"username"];
    }
    else if ([self isAjoutCalendrierEnCours]) {
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^{[self ajoutCalendrierSurIphone:[copy objectAtIndex:[indexPath indexAtPosition:1]]];});
        [_liste deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    else {
        username = [[[trombiTrie objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"username"];
        
    }
    if (!vueDetail) {
        vueDetail = [[AffichageTrombi alloc] initWithNibName:@"AffichageTrombi" bundle:[NSBundle mainBundle] etReseau:reseauTest];
    }
    [vueDetail changeUsername:username];
    [vueDetail majAffichage];
    [self.navigationController pushViewController:vueDetail animated:YES];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([searchBar isFirstResponder] || [self isAjoutCalendrierEnCours]) {
        return nil;
    }
    else if ([trombiTrie count] == 0)
        return nil;
    
    if (triAlphabet) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:tab];
        [array replaceObjectAtIndex:0 withObject:UITableViewIndexSearch];
        return array;
    }
    
    // A partir d'ici, on remplace les nombres par des chaines pour les promos et on rajoute des bullet points pour remplir la barre
    else {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:UITableViewIndexSearch];
        for (int i=1;i<[tab count];i++) {
            [array addObject:@"\u2022"];
            if ([[tab objectAtIndex:i] intValue] < 10) {
                [array addObject:[NSString stringWithFormat:@"0%d",[[tab objectAtIndex:i] intValue]]];
            }
            else
                [array addObject:[NSString stringWithFormat:@"%d",[[tab objectAtIndex:i] intValue]]];
        }
        
        return array;
    }
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (searching) {
        return -1;
    }
    // Si on sélectionne la loupe, on remonte la barre le plus haut possible.
    else if (index == 0) {
        [_liste setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    else if (triAlphabet) {
        return index;
    }
    // Si l'on est en promo, on doit diviser par 2 pour enlever les points.
    else {
        return index/2;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)newSearchBar {
    if ([trombiTrie count]) {
        if ([[newSearchBar text] length] == 0) {
            [copy removeAllObjects];
            searching = YES;
            peutSelect = NO;
            _liste.scrollEnabled = NO;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [newSearchBar setShowsCancelButton:YES animated:YES];
            [_liste reloadSectionIndexTitles];
    
            if (!overlay) {
                overlay = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:[NSBundle mainBundle]];
                CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
                CGFloat width = self.view.frame.size.width;
                CGFloat height = self.view.frame.size.height;
                CGRect frame = CGRectMake(0, yaxis, width, height);
                overlay.view.frame = frame;
                overlay.view.backgroundColor = [UIColor grayColor];
                overlay.view.alpha = 0.5;
                [overlay setRv:self];
            }
            [_liste insertSubview:overlay.view aboveSubview:_liste];
        }
        else {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
    else {
        [searchBar resignFirstResponder];
    }
    //[_liste reloadData];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finRecherche:)];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [copy removeAllObjects];
    
    if ([searchText length] != 0) {
        [overlay.view removeFromSuperview];
        searching = YES;
        peutSelect = YES;
        _liste.scrollEnabled = YES;
        [_liste scrollRectToVisible:CGRectMake(0,0, 1, 1) animated:NO];
        [self searchTableView];
    }
    else {
        searching = NO;
        peutSelect = NO;
        _liste.scrollEnabled = NO;
        [_liste insertSubview:overlay.view aboveSubview:_liste];
    }
    [_liste reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)newSearchBar {
    [self searchTableView];
    [newSearchBar resignFirstResponder];
}

-(void)searchTableView {
    NSString *searchText = searchBar.text;
    
    NSString *chaine;
    if ([formatter numberFromString:searchText] && [searchText characterAtIndex:[searchText length]-1] != ' ') {
        
        NSMutableString *chaineTemp = [[NSMutableString alloc] init];
        //[chaineTemp setString:@""];
        
        NSRange range;
        for (int i = 0; i<([searchText length]-1)/2+1;i++) {
            if ((int)([searchText length]-2*(i+1)) >= 0) {
                range.length = 2;
            }
            else
                range.length = 2 - [searchText length]%2;
            range.location = 2*i;
            [chaineTemp appendString:[NSString stringWithFormat:@"%@ ",[searchText substringWithRange:range]]];
        }
        
        chaine = [chaineTemp substringToIndex:[chaineTemp length]-1];
        
        chaineTemp = nil;
    }
    else { 
        chaine = searchText;
    }
    if (!trombi)
        trombi = [reseauTest getTrombi];
    
    [copy addObjectsFromArray:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(last_name CONTAINS[cd] %@) OR (first_name CONTAINS[cd] %@) OR (username CONTAINS[cd] %@) OR (phone CONTAINS[cd] %@)", searchText, searchText,searchText,chaine]]];
    
}

-(void)finRecherche:(id)sender {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [overlay.view removeFromSuperview];
    
    peutSelect = YES;
    searching = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationItem.rightBarButtonItem = nil;
    _liste.scrollEnabled = YES;
    
    [_liste reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self finRecherche:nil];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (peutSelect)
        return indexPath;
    else
        // Peut-être problématique
        [self finRecherche:nil];
        return nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [reseauTest didReceiveMemoryWarning];
    if (!searching && peutSelect) {
        [copy removeAllObjects];
        overlay = nil;
    }
    trombi = nil;
    vueDetail = nil;
    self.store = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)viewDidUnload {
    [self setActivite:nil];
    [self setListe:nil];
    [self setBarre:nil];
    reseauTest = nil;
    trombi = nil;
    trombiTrie = nil;
    searchBar = nil;
    tab = nil;
    copy = nil;
    overlay = nil;
    vueDetail = nil;
    control = nil;
    formatter = nil;
    self.decode = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tTelecharge" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageTelecharge" object:nil];
    if (vueDetail)
        [vueDetail applicationWillResignActive];
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
    if (![trombiTrie count]) {
        trombi = [reseauTest getTrombi];
        if (!trombi) {
            [_activite startAnimating];
            trombi = [[NSArray alloc] initWithObjects:nil];
            trombiTrie = [[NSMutableArray alloc] initWithCapacity:27];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargeTrombi) name:@"tTelecharge" object:nil];
        }
        else {
            for (NSString *s in tab) {
                [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@",s]]];
            }
        }
        triAlphabet = YES;
        [control setSelectedSegmentIndex:0];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majImage:) name:@"imageTelecharge" object:nil];
    if (vueDetail)
        [vueDetail applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive {
}

@end
