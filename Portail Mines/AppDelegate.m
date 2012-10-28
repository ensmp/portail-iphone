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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    Reseau *reseau = [[Reseau alloc] init];
    
    // On crée les différentes fenêtres
    UIViewController *viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil andNetwork:reseau];
    UINavigationController *controllerMessages = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UIViewController *viewController2 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    UINavigationController *controllerTrombi = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UIViewController *viewController3 = [[VueEdt alloc] initWithNibName:@"VueEdt" bundle:nil andNetwork:reseau];
    UINavigationController *controllerEdt = [[UINavigationController alloc] initWithRootViewController:viewController3];
    
    // Bidons
    UIViewController *viewController4 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    UIViewController *viewController5 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    UIViewController *viewController6 = [[Trombi alloc] initWithNibName:@"Trombi" bundle:nil andNetwork:reseau];
    
    
    // On cherche le fichier de pref. Si on ne l'a pas, on le crée
    NSString *fichierDonnees = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/parametres.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierDonnees]) {
        NSDictionary *parametres = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"dejaConnecte", nil]];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/parametres.plist"];
        [parametres writeToFile:writablePath atomically:YES];
    }
    
    // On cherche le fichier contenant les prefs d'onglets
    // S'il n'existe pas, on le crée
    NSArray *dico; //Pour l'ordre des onglets
    NSString *fichierPref = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/infoApp.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fichierPref]) {
        dico = [NSArray arrayWithObjects:@"Messages",@"Trombi",@"Petits Cours",@"Médias",@"Emplois du temps",@"Blabla", nil];
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *chemin = [path objectAtIndex:0];
        NSString *writablePath = [chemin stringByAppendingString:@"/infoApp.plist"];
        [dico writeToFile:writablePath atomically:YES];
    }
    else {
        dico = [NSArray arrayWithContentsOfFile:fichierPref];
    }
    
    // On crée le tableau des onglets dans l'ordre
    dicoOnglets = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:controllerMessages,controllerTrombi,viewController5,viewController4,controllerEdt,viewController6, nil] forKeys:[NSArray arrayWithObjects:@"Messages",@"Trombi",@"Petits Cours",@"Médias",@"Emplois du temps",@"Blabla",nil]];
    
    NSMutableArray *onglets = [[NSMutableArray alloc] initWithCapacity:[dicoOnglets count]];
    for (id s in dico) {
        [onglets addObject:[dicoOnglets objectForKey:s]];
    }
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = onglets;
    self.tabBarController.delegate = self;
    self.tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tabBarController.selectedIndex = [onglets indexOfObject:controllerMessages];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

// On commence ici le delegate de la barre d'onglets
-(void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    if (changed) {
        NSMutableArray *dico = [[NSMutableArray alloc] initWithArray:viewControllers];
        for (NSString *cle in dicoOnglets) {
            [dico setObject:cle atIndexedSubscript:[viewControllers indexOfObject:[dicoOnglets objectForKey:cle]]];
        }
        NSString *fichierPref = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/infoApp.plist"];
        [dico writeToFile:fichierPref atomically:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
