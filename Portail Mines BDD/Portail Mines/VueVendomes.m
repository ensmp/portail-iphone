//
//  VueVendomes.m
//  Portail Mines
//
//  Created by Valérian Roche on 09/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VueVendomes.h"
#import "Reseau.h"
#import "AffichageVendome.h"

@interface VueVendomes ()

@end

@implementation VueVendomes
@synthesize liste = _liste;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)newReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Vendômes", @"Vendômes");
        self.tabBarItem.title = @"Vendôme";
        self.tabBarItem.image = [UIImage imageNamed:@"vendome.png"];
        reseau = newReseau;
        vendomeTelecharge = [[NSMutableArray alloc] init];
        edition = NO;
        
        decode = [[NSDateFormatter alloc] init];
        [decode setDateFormat:@"yyyy-MM"];
        recode = [[NSDateFormatter alloc] init];
        [recode setDateFormat:@"MMMM yyyy"];
        [recode setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [_liste setDelegate:self];
    [_liste setDataSource:self];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editionListe)]];
    
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)) {
        UITableViewController *controller = [[UITableViewController alloc] init];
        [controller setTableView:_liste];
        refresh = [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(rechargementTable) forControlEvents:UIControlEventValueChanged];
        [controller setRefreshControl:refresh];
    }
    else {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        //
        NSMutableArray *tableau = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
        [tableau addObject:reload];
        [self.navigationItem setRightBarButtonItems:tableau animated:NO];
        //[self.navigationItem setLeftBarButtonItem:reload];
    }
    
    listeVendome = [reseau listeVendomes];
    if (!listeVendome) {
        [_activite startAnimating];
        listeVendome = [[NSArray alloc] init];
    }
    else
        [self triTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"vendomeTelecharge" object:nil];
}

-(void)rechargementTable {
    [reseau listeVendomesAvecTelechargement];
    if (!refresh) {
        UIActivityIndicatorView *affichageChargement =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        [affichageChargement startAnimating];
        
        UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:affichageChargement];
        [activityItem setStyle:UIBarButtonItemStyleBordered];
        
        //
        NSMutableArray *tableau = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
        [tableau replaceObjectAtIndex:[tableau count]-1 withObject:activityItem];
        [self.navigationItem setRightBarButtonItems:tableau animated:NO];
        
        //[self.navigationItem setLeftBarButtonItem:activityItem animated:YES];
        chargementEnCours = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"vendomeTelecharge" object:nil];
}

-(void)majTable:(NSNotification *)notif {
    if ([[[notif userInfo] objectForKey:@"nom"] isEqualToString:@"liste"]) {
        [_activite stopAnimating];
        
        if (refresh)
            [refresh endRefreshing];
        if (chargementEnCours) {
            UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
            //
            NSMutableArray *tableau = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
            [tableau replaceObjectAtIndex:[tableau count]-1 withObject:reload];
            [self.navigationItem setRightBarButtonItems:tableau animated:NO];
            //[self.navigationItem setLeftBarButtonItem:reload animated:YES];
            chargementEnCours = NO;
        }
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"vendomeTelecharge" object:nil];
        
        listeVendome = [reseau listeVendomes];
        if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
            [self triTable];
            [vendomeTelecharge removeAllObjects];
            [_liste reloadData];
        }
        else if (!listeVendome || ![listeVendome count]) {
            UIAlertView *alerte = [[UIAlertView alloc] initWithTitle:@"Raté!!" message:@"Impossible de télécharger les vendômes" delegate:nil cancelButtonTitle:@"Pas de chance..." otherButtonTitles:nil];
            [alerte show];
        }
    }
    else if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        [_liste reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    if ([listeTriee count]) {
        [super viewWillAppear:animated];
        NSIndexPath *selection = [_liste indexPathForSelectedRow];
        if (selection)
            [_liste deselectRowAtIndexPath:selection animated:YES];
    }
    else {
        if (!listeVendome || ![listeVendome count]) {
            [_activite startAnimating];
            listeVendome = [[NSArray alloc] init];
        }
        else {
            [self triTable];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"vendomeTelecharge" object:nil];
    }
}

-(void)triTable {
    NSMutableArray *mois = [[NSMutableArray alloc] init];
    NSMutableArray *tab = [[NSMutableArray alloc] init];
    NSString *chaine;
    for (int i = 0; i<[listeVendome count] ; i++) {
        chaine = [[[listeVendome objectAtIndex:i] objectForKey:@"date"] substringToIndex:7];
        if (![mois containsObject:chaine]) {
            [mois addObject:chaine];
            [tab addObject:[[NSMutableArray alloc] init]];
        }
        [[tab lastObject] addObject:[listeVendome objectAtIndex:i]];
    }
    listeMois = [mois copy];
    listeTriee = [tab copy];
    if ([[listeTriee objectAtIndex:0] count] == 1)
        decalage = 1;
    else
        decalage = 0;
    mois = nil;
    tab = nil;
}

-(void)editionListe {
    if (edition) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editionListe)]];
        [_liste setEditing:NO animated:YES];
        edition = NO;
    }
    else {
        edition = YES;
        [_liste setEditing:YES animated:YES];
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editionListe)]];
    }
}

// ################### Délégué ################### //

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([listeTriee count])
        if (decalage)
            return [listeTriee count];
        else 
            return [listeTriee count]+1;
        //return 2;
    else
        return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Le petit dernier!";
    else {
        //return @"Les antiques...";
        NSDate *dateFormat;
        if (decalage)
            dateFormat = [decode dateFromString:[listeMois objectAtIndex:section]];
        else
            dateFormat = [decode dateFromString:[listeMois objectAtIndex:section-1]];
        return [[recode stringFromDate:dateFormat] capitalizedString];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    if (decalage) {
        return [[listeTriee objectAtIndex:section] count];
    }
    else {
        //return [listeVendome count] - 1;
        if (section == 1)
            return [[listeTriee objectAtIndex:section-1] count]-1;
        else
            return [[listeTriee objectAtIndex:section-1] count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([listeTriee count]) {
        NSDictionary *dico = [self obtenirDico:indexPath];
        
        [[cell textLabel] setText:[dico objectForKey:@"titre"]];
        
        NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:[[[dico objectForKey:@"fichier"] componentsSeparatedByString:@"/"] lastObject]]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fichierVendome]) {
            [vendomeTelecharge addObject:indexPath];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-big-04.png"]]];
        }
        else {
            [cell setAccessoryView:nil];
        }
    }
    
    else {
        [[cell textLabel] setText:@"Rien pour l'instant..."];
    }
    
    return cell;
}

-(NSDictionary *)obtenirDico:(NSIndexPath *)indexPath {
    NSDictionary *dico;
    if ([indexPath indexAtPosition:0] == 0) {
        dico = [[listeTriee objectAtIndex:0] objectAtIndex:0];
    }
    else {
        if (decalage)
            dico = [[listeTriee objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
        else if (!decalage && [indexPath indexAtPosition:0] == 1) {
            dico = [[listeTriee objectAtIndex:[indexPath indexAtPosition:0]-1] objectAtIndex:[indexPath indexAtPosition:1]+1];
        }
        else
            dico = [[listeTriee objectAtIndex:[indexPath indexAtPosition:0]-1] objectAtIndex:[indexPath indexAtPosition:1]];
    }
    return dico;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!affichage) {
        affichage = [[AffichageVendome alloc] initWithNibName:@"AffichageVendome" bundle:[NSBundle mainBundle] andNetwork:reseau];
    }
    
    [self.navigationController pushViewController:affichage animated:YES];
    [affichage choixVendome:[self obtenirDico:indexPath]];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([vendomeTelecharge containsObject:indexPath])
        return YES;
    else
        return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fichierVendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[@"/vendome/" stringByAppendingString:[[[[self obtenirDico:indexPath] objectForKey:@"fichier"] componentsSeparatedByString:@"/"] lastObject]]];
        [[NSFileManager defaultManager] removeItemAtPath:fichierVendome error:NULL];
        [_liste reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [vendomeTelecharge removeObject:indexPath];
        [[_liste cellForRowAtIndexPath:indexPath] setEditing:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    affichage = nil;
    listeVendome = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)viewDidUnload {
    [self setListe:nil];
    [self setActivite:nil];
    reseau = nil;
    affichage = nil;
    listeVendome = nil;
    listeTriee = nil;
    listeMois = nil;
    vendomeTelecharge = nil;
    decode = nil;
    recode = nil;
    refresh = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
}

- (void)applicationDidEnterBackground {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"vendomeTelecharge" object:nil];
    if (refresh)
        [refresh endRefreshing];
    if (chargementEnCours) {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        //
        NSMutableArray *tableau = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
        [tableau replaceObjectAtIndex:[tableau count]-1 withObject:reload];
        [self.navigationItem setRightBarButtonItems:tableau animated:NO];
        //[self.navigationItem setLeftBarButtonItem:reload animated:YES];
        chargementEnCours = NO;
    }
}

- (void)applicationWillEnterForeground {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"vendomeTelecharge" object:nil];
}

- (void)applicationDidBecomeActive {
    if ([self isViewLoaded] && !listeVendome) {
        [_activite startAnimating];
        listeVendome = [[NSArray alloc] init];
    }
}

@end
