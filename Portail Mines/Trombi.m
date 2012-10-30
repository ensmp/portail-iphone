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

@interface Trombi ()

@end

@implementation Trombi

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trombi", @"Trombi");
        self.tabBarItem.title = @"Trombi";
        self.tabBarItem.image = [UIImage imageNamed:@"second.png"];
        reseauTest = reseau;
        searching = NO;
        peutSelect = YES;
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // On met le choix de tri
    control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Alphabet",@"Promo",nil]];
    [control setSegmentedControlStyle:UISegmentedControlStyleBar];
    [control setSelectedSegmentIndex:0];
    [control setWidth:100 forSegmentAtIndex:0];
    [control setWidth:100 forSegmentAtIndex:1];
    [control addTarget:self action:@selector(retriTrombi) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = control;
    
    trombi = [reseauTest getTrombi];
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

-(void)chargeTrombi {
    trombi = [reseauTest getTrombi];
    if (!trombi) {
        trombi = [[NSArray alloc] initWithObjects:nil];
        [_activite stopAnimating];
        UIAlertView *alerte = [[UIAlertView alloc] initWithTitle:@"Raté!!" message:@"Impossible de télécharger le trombi" delegate:nil cancelButtonTitle:@"Dommage..." otherButtonTitles:nil];
        [alerte show];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tTelecharge" object:nil];
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
    if (([control selectedSegmentIndex] == 0) && triAlphabet) {
        return;
    }
    else if (!([control selectedSegmentIndex] == 0) && !triAlphabet) {
        return;
    }
    else if ([control selectedSegmentIndex] == 0) {
        triAlphabet = YES;
        [trombiTrie removeAllObjects];
        tab = [NSArray arrayWithObjects:@"",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L",@"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z", nil];
        for (NSString *s in tab) {
            [trombiTrie addObject:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@",s]]];
        }
        [_liste reloadData];
        [_liste scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else {
        triAlphabet = NO;
        [trombiTrie removeAllObjects];
        NSMutableArray *temp = [NSMutableArray arrayWithObject:@""];
        [temp addObjectsFromArray:[[[NSSet setWithArray:[trombi valueForKey:@"promo"]] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:NO selector:@selector(compare:)]]]];
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


// A partir d'ici, gestion de la table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searching) {
        return 1;
    }
    else if ([trombiTrie count] == 0)
        return 0;
    return [tab count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searching) {
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
    if (searching) {
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
    else {
    
        NSDictionary *tableau = [[trombiTrie objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [tableau objectForKey:@"last_name"];
        cell.detailTextLabel.text = [tableau objectForKey:@"first_name"];
        UIImage *image = [reseauTest getImage:[tableau objectForKey:@"username"]];
        if (image) {
            cell.imageView.image = image;
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"first.png"];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *username;
    if (searching) {
        username = [[copy objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"username"];
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
    if ([searchBar isFirstResponder]) {
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchTableView];
}

-(void)searchTableView {
    NSString *searchText = searchBar.text;
    
    [copy addObjectsFromArray:[trombi filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(last_name CONTAINS[cd] %@) OR (first_name CONTAINS[cd] %@) OR (username CONTAINS[cd] %@)", searchText, searchText,searchText]]];
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
    // Dispose of any resources that can be recreated.
}

@end
