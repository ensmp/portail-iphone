//
//  AppDelegate.m
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"

#import "Trombi.h"

#import "Reseau.h"

#import "VueEdt.h"

#import "VueVendomes.h"

#import "VueSondage.h"

#import "VuePetitCours.h"

#import "VueCalendrier.h"

#import "GestionConnexion.h"

#import "VueCredits.h"  

#import "VueChat.h"

#import <CoreData/CoreData.h>

@implementation AppDelegate

// Core Data
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    reseau = [[Reseau alloc] init];
    

    // Core Data
    NSManagedObjectContext *context = [self managedObjectContext];
    reseau.context = context;
    self.modele = [Modele modelePartage:context];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // On crée les différentes fenêtres
    messages = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil andNetwork:reseau];
    UINavigationController *controllerMessages = [[UINavigationController alloc] initWithRootViewController:messages];
    
    trombi = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    UINavigationController *controllerTrombi = [[UINavigationController alloc] initWithRootViewController:trombi];
    
    emploiDuTemps = [[VueEdt alloc] initWithNibName:@"VueEdt" bundle:nil andNetwork:reseau];
    UINavigationController *controllerEdt = [[UINavigationController alloc] initWithRootViewController:emploiDuTemps];
    
    vendomes = [[VueVendomes alloc] initWithNibName:@"VueVendomes" bundle:nil andNetwork:reseau];
    UINavigationController *controllerVendome = [[UINavigationController alloc] initWithRootViewController:vendomes];
    
    sondages = [[VueSondage alloc] initWithNibName:@"VueSondage" bundle:nil andNetwork:reseau];
    UINavigationController *controllerSondage = [[UINavigationController alloc] initWithRootViewController:sondages];
    
    petitsCours = [[VuePetitCours alloc] initWithNibName:@"VuePetitCours" bundle:nil andNetwork:reseau];
    UINavigationController *controllerPetitsCours = [[UINavigationController alloc] initWithRootViewController:petitsCours];
    
    calendrier = [[VueCalendrier alloc] initWithNibName:@"VueCalendrier" bundle:nil andNetwork:reseau];
    UINavigationController *controllerCalendrier = [[UINavigationController alloc] initWithRootViewController:calendrier];
    
    chat = [[VueChat alloc] initWithNibName:@"VueChat" bundle:nil andReseau:reseau];
    UINavigationController *controllerChat = [[UINavigationController alloc] initWithRootViewController:chat];
    
    credits = [[VueCredits alloc] initWithNibName:@"VueCredits" bundle:nil andNetwork:reseau];
    UINavigationController *controllerCredits = [[UINavigationController alloc] initWithRootViewController:credits];

    
    // On cherche le fichier de pref. Si on ne l'a pas, on le crée
    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDonnees]) {
        NSDictionary *parametres = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"Non choisi", nil] forKeys:[NSArray arrayWithObjects:@"dejaConnecte",@"ChoixCalendrier", nil]];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/parametres.plist"];
        [parametres writeToFile:writablePath atomically:YES];
    }
    
    
    // On initialise les données par défaut
    NSUserDefaults *donneesDefaut = [NSUserDefaults standardUserDefaults];
    if (![donneesDefaut objectForKey:@"SonnerieChat"]) {
        if (![donneesDefaut objectForKey:@"ChoixCalendrier"]) {
            [donneesDefaut setBool:NO forKey:@"dejaConnecte"];
            [donneesDefaut setObject:@"Non choisi" forKey:@"ChoixCalendrier"];
            [donneesDefaut setObject:[NSArray arrayWithObjects:@"Messages",@"Trombi",@"Sondage",@"Petits Cours",@"Emplois du temps",@"Vendomes",@"Calendrier",@"Chat",@"Infos", nil] forKey:@"Onglets"];
            [donneesDefaut setInteger:10 forKey:@"tempsRaffraichissement"];
            [donneesDefaut setObject:@"Son de cloches" forKey:@"SonnerieChat"];
            [donneesDefaut synchronize];
        }
        else if (![[donneesDefaut objectForKey:@"Onglets"] containsObject:@"Chat"]) {
            NSMutableArray *nouveau = [[NSMutableArray alloc] initWithArray:[donneesDefaut objectForKey:@"Onglets"]];
            [nouveau addObject:@"Chat"];
            [donneesDefaut setObject:nouveau forKey:@"Onglets"];
        }
        else if (![donneesDefaut objectForKey:@"SonnerieChat"]) {
            [donneesDefaut setObject:@"Son de cloches" forKey:@"SonnerieChat"];
        }
    }
    
    // On cherche le fichier contenant les prefs d'onglets
    // S'il n'existe pas, on le crée
    NSArray *dico; //Pour l'ordre des onglets
   
    /*NSString *fichierPref = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/infoApp.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierPref]) {
        dico = [NSArray arrayWithObjects:@"Messages",@"Trombi",@"Sondage",@"Petits Cours",@"Emplois du temps",@"Vendomes",@"Calendrier",@"Infos", nil];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/infoApp.plist"];
        [dico writeToFile:writablePath atomically:YES];
    }
    else {
        dico = [NSArray arrayWithContentsOfFile:fichierPref];
    }
    */
    
    dico = [donneesDefaut arrayForKey:@"Onglets"];
    
    // On crée le tableau des onglets dans l'ordre
    dicoOnglets = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:controllerMessages,controllerTrombi,controllerSondage,controllerPetitsCours,controllerEdt, controllerVendome, controllerCalendrier,controllerChat,controllerCredits, nil] forKeys:[NSArray arrayWithObjects:@"Messages",@"Trombi",@"Sondage",@"Petits Cours",@"Emplois du temps",@"Vendomes",@"Calendrier",@"Chat",@"Infos",nil]];
    
    NSMutableArray *onglets = [[NSMutableArray alloc] initWithCapacity:[dicoOnglets count]];
    for (id s in dico) {
        [onglets addObject:[dicoOnglets objectForKey:s]];
    }
    
    // On crée les dossiers pour stocker les infos
    NSString *dosImages = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/photos/"];
    NSString *donnees = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/trombi/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:donnees]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:donnees withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dosImages]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dosImages withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    NSString *edt = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/edt/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:edt]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:edt withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    NSString *vendome = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/vendome/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:vendome]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:vendome withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    
    NSString *dossierSondages = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/sondages/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dossierSondages]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dossierSondages withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    
    NSString *dossierPhotoAssos = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/photos-assoces/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dossierPhotoAssos]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dossierPhotoAssos withIntermediateDirectories:YES attributes:nil error: NULL];
    }
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = onglets;
    self.tabBarController.delegate = self;
    
    //self.tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    if (![reseau dejaConnecte]) {
        GestionConnexion *deconnexion = [[GestionConnexion alloc] initWithController:_tabBarController etReseau:reseau];
        [deconnexion afficherControllerAvecAnimation:NO];
        deconnexion = nil;
    }
    else {
        [reseau connectionDispo];
    }
    
    return YES;
}

// On commence ici le delegate de la barre d'onglets
-(void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    if (changed) {
        NSMutableArray *dico = [[NSMutableArray alloc] initWithArray:viewControllers];
        for (NSString *cle in dicoOnglets) {
            [dico setObject:cle atIndexedSubscript:[viewControllers indexOfObject:[dicoOnglets objectForKey:cle]]];
        }
        /*NSString *fichierPref = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/infoApp.plist"];
        [dico writeToFile:fichierPref atomically:NO];*/
        
        [[NSUserDefaults standardUserDefaults] setObject:dico forKey:@"Onglets"];
        
        // Pour le changement de couleur de la barre du haut
        /*for (int i = 0;i<4;i++) {
            ((UINavigationController *)[viewControllers objectAtIndex:i]).navigationBar.barStyle = UIBarStyleBlack;
        }*/
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*-(void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    id modalViewCtrl = [[[tabBarController view] subviews] objectAtIndex:1];
    if([modalViewCtrl isKindOfClass:NSClassFromString(@"UITabBarCustomizeView")] == YES)
        ((UINavigationBar*)[[modalViewCtrl subviews] objectAtIndex:0]).tintColor = [UIColor blackColor];
}*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [credits applicationWillResignActive];
    [reseau applicationWillResignActive];
    [sondages applicationWillResignActive];
    [emploiDuTemps applicationWillResignActive];
    [trombi applicationWillResignActive];
    [messages applicationWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [reseau applicationDidEnterBackground];
    [calendrier applicationDidEnterBackground];
    [petitsCours applicationDidEnterBackground];
    [sondages applicationDidEnterBackground];
    [vendomes applicationDidEnterBackground];
    [chat applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [sondages applicationWillEnterForeground];
    [vendomes applicationWillEnterForeground];
    [emploiDuTemps applicationWillEnterForeground];
    [trombi applicationWillEnterForeground];
    [chat applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [credits applicationDidBecomeActive];
    [reseau applicationDidBecomeActive];
    [calendrier applicationDidBecomeActive];
    [petitsCours applicationDidBecomeActive];
    [sondages applicationDidBecomeActive];
    [vendomes applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

// Core Data
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Test.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
