//
//  Personne.h
//  Portail Mines
//
//  Created by Valérian Roche on 22/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Personne;

@interface Personne : NSManagedObject

@property (nonatomic, retain) NSString * nom;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSNumber * promo;
@property (nonatomic, retain) NSString * date_naissance;
@property (nonatomic, retain) NSString * prenom;
@property (nonatomic, retain) NSString *mail;
@property (nonatomic, retain) NSString *chambre;
@property (nonatomic, retain) NSSet *co;
@property (nonatomic, retain) NSSet *parrain;
@property (nonatomic, retain) NSSet *fillot;
@end

@interface Personne (CoreDataGeneratedAccessors)

- (void)addCoObject:(Personne *)value;
- (void)removeCoObject:(Personne *)value;
- (void)addCo:(NSSet *)values;
- (void)removeCo:(NSSet *)values;

- (void)addParrainObject:(Personne *)value;
- (void)removeParrainObject:(Personne *)value;
- (void)addParrain:(NSSet *)values;
- (void)removeParrain:(NSSet *)values;

- (void)addFillotObject:(Personne *)value;
- (void)removeFillotObject:(Personne *)value;
- (void)addFillot:(NSSet *)values;
- (void)removeFillot:(NSSet *)values;

@end
