//
//  VuePetitCours.m
//  Portail Mines
//
//  Created by Valérian Roche on 16/11/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "VuePetitCours.h"
#import "Reseau.h"
#import "Annotation.h"
#import "DetailPetitCours.h"

@interface VuePetitCours ()

@end

@implementation VuePetitCours

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andNetwork:(Reseau *)nouveauReseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reseau = nouveauReseau;
        self.title = NSLocalizedString(@"Petits Cours", @"Petits Cours");
        self.tabBarItem.title = @"Petits Cours";
        self.tabBarItem.image = [UIImage imageNamed:@"petitcours.png"];
        annotationsAffichees = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [_vueGPS setDelegate:self];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[[_vueGPS annotations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(tag == 0)"]] count]) {
        Annotation *meuh = [[Annotation alloc] initWithLocation:CLLocationCoordinate2DMake(48.841608200000003, 2.3412476999999399) titre:@"Maison des Mines" etLieu:@""];
        [meuh setTag:0];
        [_vueGPS addAnnotation:meuh];
        [_vueGPS setSelectedAnnotations:[NSArray arrayWithObject:meuh]];
        region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(48.841608200000003, 2.3412476999999399), MKCoordinateSpanMake(0.027466, 0.027466));
        [_vueGPS setRegion:region];
    }
    
    listePC = [reseau getPetitsCours];
    if (!listePC) {
        [_activite startAnimating];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receptionListe:) name:@"pcTelecharge" object:nil];
    }
    else {
        [self majCarte];
    }
}

-(void)receptionListe:(NSNotification *)notif {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pcTelecharge" object:nil];
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        [self majCarte];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Attends encore" message:@"Impossible de récupérer les petits cours" delegate:nil cancelButtonTitle:@"Je demanderai par tripromal alors..." otherButtonTitles:nil] show];
    }
}

#define DECALAGE_LAT 0.01
#define DECALAGE_LONG 0.01

-(void)majCarte {
    listePC = [reseau getPetitsCours];
    for (NSDictionary *dico in annotationsAffichees) {
        if (![listePC containsObject:dico]) {
            for (Annotation *objet in [_vueGPS annotations]) {
                if ([[objet title] isEqualToString:[dico objectForKey:@"titre"]]) {
                    [annotationsAffichees removeObject:dico];
                    [_vueGPS removeAnnotation:objet];
                }
            }
        }
    }
    
    Annotation *pin;
    double i = (0.027466-0.005)/2;
    double j = (0.027466-0.005)/2;
    NSString *titre;
    NSString *lieu;
        for (NSDictionary *dico in listePC) {
        if (![annotationsAffichees containsObject:dico]) {
            titre = [dico objectForKey:@"titre"];
            if (!titre)
                titre = @"Pas de description";
            lieu = [dico objectForKey:@"adresse"];
            if (!lieu)
                lieu = @"Aucun lieu précisé";

            pin = [[Annotation alloc] initWithLocation:CLLocationCoordinate2DMake([[dico objectForKey:@"latitude"] doubleValue], [[dico objectForKey:@"longitude"] doubleValue]) titre:titre etLieu:lieu];
            [pin setTag:1];
            if (ABS([[dico objectForKey:@"latitude"] doubleValue]-48.841608200000003) > i)
                i = ABS([[dico objectForKey:@"latitude"] doubleValue]-48.841608200000003);
            if (ABS([[dico objectForKey:@"longitude"] doubleValue]-2.3412476999999399) > j)
                j = ABS([[dico objectForKey:@"longitude"] doubleValue]-2.3412476999999399);
            [annotationsAffichees addObject:dico];
            [_vueGPS addAnnotation:pin];
        }
        else {
            if (ABS([[dico objectForKey:@"latitude"] doubleValue]-48.841608200000003) > i)
                i = ABS([[dico objectForKey:@"latitude"] doubleValue]-48.841608200000003);
            if (ABS([[dico objectForKey:@"longitude"] doubleValue]-2.3412476999999399) > j)
                j = ABS([[dico objectForKey:@"longitude"] doubleValue]-2.3412476999999399);
        }
    }
    i+=DECALAGE_LAT;
    j+= DECALAGE_LONG;
    region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(48.841608200000003, 2.3412476999999399), MKCoordinateSpanMake(2*i, 2*j));
    [_vueGPS setRegion:region animated:YES];
}

-(void)detailPetitCours:(id)sender {
    NSString *titre = [[[_vueGPS selectedAnnotations] objectAtIndex:0] title];
    for (NSDictionary *dico in listePC) {
        if ([[dico objectForKey:@"titre"] isEqualToString:titre]) {
            if (!vueDetail) {
                if (self.view.bounds.size.height > 400)
                    vueDetail = [[DetailPetitCours alloc] initWithNibName:@"DetailPetitCours" bundle:nil andNetwork:reseau];
                else
                    vueDetail = [[DetailPetitCours alloc] initWithNibName:@"DetailPetitCours3.5" bundle:nil andNetwork:reseau];
            }
            [vueDetail setDico:dico];
            [self.navigationController pushViewController:vueDetail animated:YES];
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[Annotation class]]) {
        MKPinAnnotationView *pinView;
        if (((Annotation *)annotation).tag == 0) {
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationMeuh"];
            if (!pinView) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationMeuh"];
                pinView.pinColor = MKPinAnnotationColorPurple;
                pinView.animatesDrop = YES;
                pinView.draggable = NO;
                pinView.canShowCallout = YES;
            }
        }
        
        else if (((Annotation *)annotation).tag == 1) {
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationCours"];
            if (!pinView) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationCours"];
                pinView.pinColor = MKPinAnnotationColorRed;
                pinView.animatesDrop = YES;
                pinView.draggable = NO;
                pinView.canShowCallout = YES;
                UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(detailPetitCours:) forControlEvents:UIControlEventTouchUpInside];
                pinView.rightCalloutAccessoryView = rightButton;
            }
        }
        
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_vueGPS setRegion:region animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    vueDetail = nil;
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setVueGPS:nil];
    [self setActivite:nil];
    reseau = nil;
    vueDetail = nil;
    listePC = nil;
    annotationsAffichees = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)applicationWillResignActive {
}

- (void)applicationDidEnterBackground {
    [_activite stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pcTelecharge" object:nil];
    if (vueDetail) {
        [vueDetail applicationDidEnterBackground];
    }
}

- (void)applicationWillEnterForeground {
    if (vueDetail) {
        [vueDetail applicationWillEnterForeground];
    }
}

- (void)applicationDidBecomeActive {
}

@end
