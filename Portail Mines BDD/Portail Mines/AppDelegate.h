//
//  AppDelegate.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/09/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Modele.h"

@class Reseau;
@class FirstViewController;
@class Trombi;
@class VueEdt;
@class VueVendomes;
@class VueSondage;
@class VuePetitCours;
@class VueCalendrier;
@class VueCredits;
@class VueChat;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAccelerometerDelegate> {
    NSDictionary *dicoOnglets;
    Reseau *reseau;
    FirstViewController *messages;
    Trombi *trombi;
    VueEdt *emploiDuTemps;
    VueVendomes *vendomes;
    VueSondage *sondages;
    VuePetitCours *petitsCours;
    VueCalendrier *calendrier;
    VueCredits *credits;
    VueChat *chat;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, strong) Modele *modele;

// Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
