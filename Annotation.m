//
//  Annotation.m
//  Vue pays
//
//  Created by Valérian Roche on 26/08/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize title, subtitle, coordinate;

-(id)initWithLocation:(CLLocationCoordinate2D)newLocation titre:(NSString *)newTitre etLieu:(NSString *)newLieu {
    coordinate = newLocation;
    title = newTitre;
    subtitle = newLieu;
    return self;
}

-(void)moveAnnotation:(CLLocationCoordinate2D)newLocation {
    coordinate = newLocation;
}

-(NSString *)title {
    return title;
}

-(NSString *)subtitle {
    return subtitle;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}


@end
