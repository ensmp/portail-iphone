//
//  Annotation.h
//  Vue pays
//
//  Created by Valérian Roche on 26/08/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) int tag;

-(id)initWithLocation:(CLLocationCoordinate2D)newLocation titre:(NSString *)newTitre etLieu:(NSString *)newLieu;
-(void)moveAnnotation:(CLLocationCoordinate2D)newLocation;
-(NSString *)title;
-(NSString *)subtitle;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
