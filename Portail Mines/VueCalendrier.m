//
//  VueCalendrier.m
//  Portail Mines
//
//  Created by Valérian Roche on 17/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VueCalendrier.h"
#import "Reseau.h"
#import "AffichageEvenement.h"

@interface VueCalendrier ()

@end

@implementation VueCalendrier

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = nouveauReseau;
        self.title = NSLocalizedString(@"Calendrier", @"Calendrier");
        self.tabBarItem.title = @"Calendrier";
        self.tabBarItem.image = [UIImage imageNamed:@"calendrier.png"];
        
        deformatter = [[NSDateFormatter alloc] init];
        [deformatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM yyyy"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        formatterJour = [[NSDateFormatter alloc] init];
        [formatterJour setDateFormat:@"dd MMMM yyyy"];
        [formatterJour setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        calendrierTriee = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [_liste setDelegate:self];
    [_liste setDataSource:self];
    calendrier = [reseau getCalendrier];
    if (calendrier) {
        [self triCalendrier];
    }
    else {
        [_activite startAnimating];
        calendrier = [[NSArray alloc] init];
        [self triCalendrier];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargementCalendrier:) name:@"calendrierTelecharge" object:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selection = [_liste indexPathForSelectedRow];
    if (selection)
        [_liste deselectRowAtIndexPath:selection animated:YES];
    
    [reseau getCalendrier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargementCalendrier:) name:@"calendrierTelecharge" object:nil];
}

-(void)triCalendrier {
    [calendrierTriee removeAllObjects];
    int i = 0;
    NSDate *date;
    NSString *dateFormattee;
    while (i<[calendrier count]) {
        date = [deformatter dateFromString:[[calendrier objectAtIndex:i] objectForKey:@"start"]];
        
        if ([[deformatter dateFromString:[[calendrier objectAtIndex:i] objectForKey:@"end"]] compare:[NSDate date]] == NSOrderedDescending) {
            dateFormattee = [formatter stringFromDate:date];
            if ([[calendrierTriee objectForKey:dateFormattee] count]) {
                [[calendrierTriee objectForKey:dateFormattee] insertObject:[calendrier objectAtIndex:i] atIndex:0];
            }
            else {
                NSMutableArray *tab = [NSMutableArray arrayWithObject:[calendrier objectAtIndex:i]];
                [calendrierTriee setObject:tab forKey:dateFormattee];
            }
        }
        i++;
    }
    listeMoisTriee = [[calendrierTriee allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return ([[formatter dateFromString:obj1] compare:[formatter dateFromString:obj2]]);
    }];
}

-(void)chargementCalendrier:(NSNotification *)notif {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"calendrierTelecharge" object:nil];
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        [_activite stopAnimating];
        calendrier = [reseau getCalendrier];
        [self triCalendrier];
        [_liste reloadData];
    }
    else if ([_activite isAnimating]) {
        [_activite stopAnimating];
        [[[UIAlertView alloc] initWithTitle:@"Pas de messages..." message:@"Impossible de télécharger le calendrier" delegate:nil cancelButtonTitle:@"Pas de nouvelles, pas de palais..." otherButtonTitles:nil] show];
    }
}

// ####################### Délégué ####################### //
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [calendrierTriee count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[calendrierTriee objectForKey:[listeMoisTriee objectAtIndex:section]] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[listeMoisTriee objectAtIndex:section] capitalizedString];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *dico = [[calendrierTriee objectForKey:[listeMoisTriee objectAtIndex:[indexPath indexAtPosition:0]]] objectAtIndex:[indexPath indexAtPosition:1]];

    [[cell textLabel] setText:[dico objectForKey:@"title"]];
    
    NSString *chaine = [formatterJour stringFromDate:[deformatter dateFromString:[dico objectForKey:@"start"]]];
    [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
    if (![chaine isEqualToString:[formatterJour stringFromDate:[deformatter dateFromString:[dico objectForKey:@"end"]]]]) {
        chaine = [chaine stringByAppendingString:@" - "];
        chaine = [chaine stringByAppendingString:[formatterJour stringFromDate:[deformatter dateFromString:[dico objectForKey:@"end"]]]];
    }
    else if ([chaine isEqualToString:[formatterJour stringFromDate:[NSDate date]]]) {
        chaine = @"Aujourd'hui";
        [[cell detailTextLabel] setTextColor:[UIColor redColor]];
    }
    [[cell detailTextLabel] setText:chaine];
    
    UIImage *image = [reseau getPhotoAsso:[[dico objectForKey:@"auteur_slug"] lowercaseString]];
    if (image)
        [[cell imageView] setImage:image];
    else
        [[cell imageView] setImage:nil];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!vueDetail) {
        vueDetail = [[AffichageEvenement alloc] initWithNibName:@"AffichageEvenement" bundle:nil];
    }
    
    [vueDetail changeDico:[[calendrierTriee objectForKey:[listeMoisTriee objectAtIndex:[indexPath indexAtPosition:0]]] objectAtIndex:[indexPath indexAtPosition:1]]];
    [self.navigationController pushViewController:vueDetail animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    vueDetail = nil;
    calendrier = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)viewDidUnload {
    [self setListe:nil];
    [self setActivite:nil];
    reseau = nil;
    vueDetail = nil;
    calendrier = nil;
    deformatter = nil;
    formatter = nil;
    formatterJour = nil;
    deformatterMois = nil;
    listeMoisTriee = nil;
    calendrierTriee = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
}

- (void)applicationDidEnterBackground {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"calendrierTelecharge" object:nil];
}

- (void)applicationWillEnterForeground {
}

- (void)applicationDidBecomeActive {
    if (![self isViewLoaded])
        return;
    calendrier = [reseau getCalendrier];
    if (calendrier) {
        [self triCalendrier];
    }
    else {
        [_activite startAnimating];
        calendrier = [[NSArray alloc] init];
        [self triCalendrier];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargementCalendrier:) name:@"calendrierTelecharge" object:nil];
    
}

@end
