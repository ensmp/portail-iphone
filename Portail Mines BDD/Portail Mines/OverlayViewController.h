//
//  OverlayViewController.h
//  Portail Mines
//
//  Created by Valérian Roche on 19/10/12.
//  Copyright (c) 2012 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Trombi;

@interface OverlayViewController : UIViewController {
    Trombi *rv;
}

@property (nonatomic, weak) Trombi *rv;

@end
