//
//  FirstViewController.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "FirstViewController.h"
#import "IdentificationViewController.h"
#import "Reseau.h"
#import "AffichageMessage.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Messages", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"messages.png"];
        reseauTest = reseau;
        choixNouveau = YES;
        
        deformatter = [[NSDateFormatter alloc] init];
        [deformatter setDateFormat:@"dd'/'MM'/'yyyy' 'HH':'mm"];
        formatterJour = [[NSDateFormatter alloc] init];
        [formatterJour setDateFormat:@"dd MMMM yyyy"];
        [formatterJour setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];

    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // On met en place la barre en haut
    self.navigationItem.title = @"Messages";
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // On met le choix de tri
    choix = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Nouveaux",@"Tous",nil]];
    [choix setSegmentedControlStyle:UISegmentedControlStyleBar];
    [choix setSelectedSegmentIndex:0];
    [choix setWidth:100 forSegmentAtIndex:0];
    [choix setWidth:100 forSegmentAtIndex:1];
    [choix addTarget:self action:@selector(changementChoix) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = choix;
    
    _liste.delegate = self;
    _liste.dataSource = self;
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)) {
        UITableViewController *controller = [[UITableViewController alloc] init];
        [controller setTableView:_liste];
        refresh = [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(rechargementTable) forControlEvents:UIControlEventValueChanged];
        [controller setRefreshControl:refresh];
    }
    else {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        [self.navigationItem setRightBarButtonItem:reload];
    }
    
    if (choixNouveau && !messages) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"mTelecharge" object:nil];
        messages = [reseauTest getMessageAvecTous:NO];
        if (!messages) {
            [_activite startAnimating];
        }
        else {
            utilise = messages;
            [_liste reloadData];
        }
    }
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self testTelecharge];
}

-(void)testTelecharge {
    if (choixNouveau && !messages) {
        messages = [reseauTest getMessageAvecTous:NO];
        if (!messages) {
            [_activite startAnimating];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"mTelecharge" object:nil];
        }
        else {
            utilise = messages;
            [_liste reloadData];
        }
    }
    
    else if (!choixNouveau && !tousMessages) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"mTelecharge" object:nil];
        tousMessages = [reseauTest getMessageAvecTous:YES];
        if (!tousMessages) {
            [_activite startAnimating];
        }
        else {
            utilise = tousMessages;
            [_liste reloadData];
        }
    }
    
    else
        [_liste reloadData];
}

-(void)majTable:(NSNotification *)notif {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mTelecharge" object:nil];
    [_activite stopAnimating];

    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        if (refresh)
            [refresh endRefreshing];
        if (chargementEnCours) {
            UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
            [self.navigationItem setRightBarButtonItem:reload animated:YES];
            chargementEnCours = NO;
        }
        
        if (![[[notif userInfo] objectForKey:@"choix"] boolValue]) {
            messages = [reseauTest getMessageAvecTous:NO];
            if (messages && [choix selectedSegmentIndex] == 0) {
                utilise = messages;
                [_liste reloadData];
            }
        }
        else {
            tousMessages = [reseauTest getMessageAvecTous:YES];
            if (tousMessages && [choix selectedSegmentIndex] == 1) {
                utilise = tousMessages;
                [_liste reloadData];
            }
        }
    }
    
    else if ((!refresh || ![refresh isRefreshing]) && !chargementEnCours) {
        [[[UIAlertView alloc] initWithTitle:@"Ca picheclaque..." message:@"Impossible de télécharger les messages" delegate:nil cancelButtonTitle:@"Je vais massacrer le VP Geek!!" otherButtonTitles:nil] show];
    }
    
    else if (chargementEnCours) {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        [self.navigationItem setRightBarButtonItem:reload animated:YES];
        chargementEnCours = NO;
    }
    
    else {
        [refresh endRefreshing];
    }
}

-(void)changementChoix {
    if ([choix selectedSegmentIndex] == 0) {
        choixNouveau = YES;
        utilise = messages;
    }
    else {
        choixNouveau = NO;
        utilise = tousMessages;
    }
    
    if (refresh)
        [refresh endRefreshing];
    else if (chargementEnCours) {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        [self.navigationItem setRightBarButtonItem:reload animated:YES];
        chargementEnCours = NO;
    }
    
    [self testTelecharge];
}

-(void)rechargementTable {
    if (choixNouveau) {
        [reseauTest getMessageAvecTous:NO etTelechargement:YES];
    }
    else {
        [reseauTest getMessageAvecTous:YES etTelechargement:YES];
    }
    if (!refresh) {
        UIActivityIndicatorView *affichageChargement =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        [affichageChargement startAnimating];
                
        UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:affichageChargement];
        [activityItem setStyle:UIBarButtonItemStyleBordered];
        
        [self.navigationItem setRightBarButtonItem:activityItem animated:YES];
        chargementEnCours = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majTable:) name:@"mTelecharge" object:nil];
}

-(void)reponseMessage:(NSNotification *)notif {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClassementMessage" object:nil];
    if ([[[notif userInfo] objectForKey:@"Lu"] boolValue]) {
        if ([[[notif userInfo] objectForKey:@"Succes"] boolValue]) {
            int ident = [[[notif userInfo] objectForKey:@"Id"] intValue];
            NSMutableArray *nouveauTableau = [messages mutableCopy];
            int index = [messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
                if ([[obj objectForKey:@"id"] intValue] == ident) {
                    return YES;
                }
                else
                    return NO;
            }];
            if (index < [messages count]) {
                [nouveauTableau removeObjectAtIndex:index];
                //messages = nil;
                //messages = [nouveauTableau copy];
                messages = [nouveauTableau copy];
                [reseauTest ecrireMessage:messages avecTous:NO];
                
            }
            
            NSMutableArray *nouveauTableauTous = [tousMessages mutableCopy];
            index = [tousMessages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
                if ([[obj objectForKey:@"id"] intValue] == ident) {
                    return YES;
                }
                else
                    return NO;
            }];
            if (index < [tousMessages count]) {
                NSMutableDictionary *temp = [[tousMessages objectAtIndex:index] mutableCopy];
                [temp setObject:[NSNumber numberWithBool:YES] forKey:@"lu"];
                [nouveauTableauTous replaceObjectAtIndex:index withObject:[temp copy]];
                //tousMessages = [nouveauTableauTous copy];
                tousMessages = [nouveauTableauTous copy];
                [reseauTest ecrireMessage:tousMessages avecTous:YES];
            }
            if ([choix selectedSegmentIndex] == 0)
                utilise = messages;
            else
                utilise = tousMessages;
            [_liste reloadData];
        }
    }
    
    else {
        if ([[[notif userInfo] objectForKey:@"Succes"] boolValue]) {
            int ident = [[[notif userInfo] objectForKey:@"Id"] intValue];
            NSMutableArray *nouveauTableau = [messages mutableCopy];
            int index = [messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
                if ([[obj objectForKey:@"id"] intValue] == ident) {
                    return YES;
                }
                else
                    return NO;
            }];
            if (index < [messages count]) {
                NSMutableDictionary *temp = [[messages objectAtIndex:index] mutableCopy];
                [temp setObject:[NSNumber numberWithBool:YES] forKey:@"important"];
                [nouveauTableau replaceObjectAtIndex:index withObject:[temp copy]];
                messages = [nouveauTableau copy];
                [reseauTest ecrireMessage:messages avecTous:NO];
                nouveauTableau = nil;
            }
            
            NSMutableArray *nouveauTableauTous = [tousMessages mutableCopy];
            index = [tousMessages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
                if ([[obj objectForKey:@"id"] intValue] == ident) {
                    return YES;
                }
                else
                    return NO;
            }];
            if (index < [tousMessages count]) {
                NSMutableDictionary *temp = [[tousMessages objectAtIndex:index] mutableCopy];
                [temp setObject:[NSNumber numberWithBool:![[temp objectForKey:@"important"] boolValue]] forKey:@"important"];
                [nouveauTableauTous replaceObjectAtIndex:index withObject:[temp copy]];
                tousMessages = [nouveauTableauTous copy];
                [reseauTest ecrireMessage:tousMessages avecTous:YES];
            }
            
            if ([choix selectedSegmentIndex] == 0)
                utilise = messages;
            else
                utilise = tousMessages;
            [_liste reloadData];
        }
        else {
            if (self.isFirstResponder)
                [[[UIAlertView alloc] initWithTitle:@"Favori?" message:@"Erreur de communication pour le message" delegate:nil cancelButtonTitle:@"Je vais massacrer le VP Geek" otherButtonTitles:nil] show];
        }
    }
}

// ##################### Délégué de la liste #######################

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (utilise && [utilise count])
        return [utilise count];
    else
        return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *dico = [utilise objectAtIndex:[indexPath indexAtPosition:1]];
    
    [[cell textLabel] setText:[dico objectForKey:@"objet"]];
    
    NSString *chaine = [formatterJour stringFromDate:[deformatter dateFromString:[dico objectForKey:@"date"]]];
    [[cell detailTextLabel] setTextColor:[UIColor grayColor]];

    if ([chaine isEqualToString:[formatterJour stringFromDate:[NSDate date]]]) {
        chaine = @"Aujourd'hui";
        [[cell detailTextLabel] setTextColor:[UIColor redColor]];
    }
    [[cell detailTextLabel] setText:chaine];
    
    UIImage *image = [reseauTest getPhotoAsso:[[dico objectForKey:@"association_pseudo"] lowercaseString]];
    if (image)
        [[cell imageView] setImage:image];
    else
        [[cell imageView] setImage:nil];

    if ([[dico objectForKey:@"important"] boolValue]) {
        UIImageView *vue = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Favori.png"]];
        [vue setFrame:CGRectMake(0, 0, 23, 23)];
        [cell setAccessoryView:vue];
    }
    else if ([[dico objectForKey:@"lu"] boolValue]) {
        UIImageView *vue = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check.png"]];
        [vue setFrame:CGRectMake(0, 0, 23, 23)];
        [cell setAccessoryView:vue];
    }
    else {
        [cell setAccessoryView:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!vueDetail) {
        vueDetail = [[AffichageMessage alloc] initWithNibName:@"AffichageMessage" bundle:nil andNetwork:reseauTest];
        [self.navigationController pushViewController:vueDetail animated:YES];
        if (choixNouveau) {
            [vueDetail changeDico:[messages objectAtIndex:[indexPath indexAtPosition:1]]];
        }
        else {
            [vueDetail changeDico:[tousMessages objectAtIndex:[indexPath indexAtPosition:1]]];
        }
    }
    else {
        if (choixNouveau) {
            [vueDetail changeDico:[messages objectAtIndex:[indexPath indexAtPosition:1]]];
        }
        else {
            [vueDetail changeDico:[tousMessages objectAtIndex:[indexPath indexAtPosition:1]]];
        }
        [self.navigationController pushViewController:vueDetail animated:YES];
    }
    
    if (choixNouveau) {
        [reseauTest setLu:YES pourMessage:[[[messages objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"id"] intValue]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reponseMessage:) name:@"ClassementMessage" object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (choixNouveau) {
        tousMessages = nil;
    }
    else
        messages = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void)viewDidUnload {
    [self setActivite:nil];
    [self setListe:nil];
    vueDetail = nil;
    reseauTest = nil;
    messages = nil;
    tousMessages = nil;
    utilise = nil;
    choix = nil;
    refresh = nil;
    deformatter = nil;
    formatterJour = nil;
    [super viewDidUnload];
}

-(void)applicationWillResignActive {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mTelecharge" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClassementMessage" object:nil];
    if (refresh)
        [refresh endRefreshing];
    if (chargementEnCours) {
        UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rechargementTable)];
        [self.navigationItem setRightBarButtonItem:reload animated:YES];
        chargementEnCours = NO;
    }
}
-(void)applicationDidEnterBackground {}
-(void)applicationWillEnterForeground {}
-(void)applicationDidBecomeActive {}

@end
