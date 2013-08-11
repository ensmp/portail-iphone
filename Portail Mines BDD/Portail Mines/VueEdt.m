//
//  VueEdt.m
//  Portail Mines
//
//  Created by Valérian Roche on 27/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VueEdt.h"
#import "Reseau.h"
#import "AffichageEdt.h"

@interface VueEdt ()

@end

@implementation VueEdt

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseauTest
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Emploi du temps", @"Emploi du temps");
        self.tabBarItem.title = @"Emploi du temps";
        self.tabBarItem.image = [UIImage imageNamed:@"edt.png"];
        reseau = reseauTest;
        edts = [NSArray arrayWithObjects:@"Première année",@"Deuxième année", @"Troisième année",@"Le début...",@"La campagne",@"Les responsabilités",@"Le stress des stages",@"Le début de l'aigritude", @"L'aigritude à son paroxisme", @"Pour les ptits nouveaux de 3A", nil];
        nomEdt = [NSArray arrayWithObjects:@"Semaine/Encours1A.pdf",@"Semaine/Encours2A.pdf",@"Semaine/Encours3A.pdf",@"Semaine/Prochain1A.pdf",@"Semaine/Prochain2A.pdf",@"Semaine/Prochain3A.pdf", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [_liste setDelegate:self];
    [_liste setDataSource:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selection = [_liste indexPathForSelectedRow];
    if (selection)
        [_liste deselectRowAtIndexPath:selection animated:YES];
}

// On s'occupe de la table contenant les différents edts

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Cette semaine";
    }
    else if (section == 1) {
        return @"Semaine prochaine";
    }
    else if (section == 2) {
        return @"Emploi du temps semestriels";
    }
    else return nil;
}

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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 3;
    }
    else {
        return 7;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([indexPath indexAtPosition:0] == 0 || [indexPath indexAtPosition:0] == 1)
        [[cell textLabel] setText:[edts objectAtIndex:[indexPath indexAtPosition:1]]];
    else {
        [[cell textLabel] setText:[edts objectAtIndex:3+[indexPath indexAtPosition:1]]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!affichage) {
        affichage = [[AffichageEdt alloc] initWithNibName:@"AffichageEdt" bundle:[NSBundle mainBundle] andNetwork:reseau];
    }

    [self.navigationController pushViewController:affichage animated:YES];
    
    if ([indexPath indexAtPosition:0] == 0 || [indexPath indexAtPosition:0] == 1) {
        [affichage choixEdt:[nomEdt objectAtIndex:[indexPath indexAtPosition:0]*3+[indexPath indexAtPosition:1]]];
    }
    else if (!([indexPath indexAtPosition:1] == 6)) {
        int annee = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]] year];
        if ([[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:[NSDate date]] month] < 9) {
            annee--;
        }
        NSString *chaine = [NSString stringWithFormat:@"%d/S%d_%d_%d.pdf",annee,[indexPath indexAtPosition:1]+1,annee%1000,annee%1000+1];
        [affichage choixEdt:chaine];
    }
    else {
        int annee = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]] year];
        NSString *chaine = [NSString stringWithFormat:@"%d/VS.pdf",annee];
        [affichage choixEdt:chaine];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    affichage = nil;
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)viewDidUnload {
    [self setListe:nil];
    reseau = nil;
    edts = nil;
    nomEdt = nil;
    affichage = nil;
    [super viewDidUnload];
}

- (void)applicationWillResignActive {
    if (affichage)
        [affichage applicationWillResignActive];
}

- (void)applicationDidEnterBackground {
    
}

- (void)applicationWillEnterForeground {
    if (affichage)
        [affichage applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive {
}

@end
