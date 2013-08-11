//
//  Personne.h
//  Portail Mines
//
//  Created by Valérian Roche on 28/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Personne;

@interface Personne : NSManagedObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * chambre;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * promo;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *co;
@property (nonatomic, retain) NSSet *fillots;
@property (nonatomic, retain) NSSet *parrains;
@property (nonatomic, retain) NSManagedObject *trombi;
@end

@interface Personne (CoreDataGeneratedAccessors)

- (void)addCoObject:(Personne *)value;
- (void)removeCoObject:(Personne *)value;
- (void)addCo:(NSSet *)values;
- (void)removeCo:(NSSet *)values;

- (void)addFillotsObject:(Personne *)value;
- (void)removeFillotsObject:(Personne *)value;
- (void)addFillots:(NSSet *)values;
- (void)removeFillots:(NSSet *)values;

- (void)addParrainsObject:(Personne *)value;
- (void)removeParrainsObject:(Personne *)value;
- (void)addParrains:(NSSet *)values;
- (void)removeParrains:(NSSet *)values;

@end
