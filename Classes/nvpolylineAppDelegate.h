//
//  nvpolylineAppDelegate.h
//  nvpolyline
//
//  Created by William Lachance on 10-03-30.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import <UIKit/UIKit.h>
#import "NVMapViewController.h"

@interface nvpolylineAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	NVMapViewController *mapViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

