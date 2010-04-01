//
//  nvpolylineAppDelegate.m
//  nvpolyline
//
//  Created by William Lachance on 10-03-30.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import "nvpolylineAppDelegate.h"

@implementation nvpolylineAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	mapViewController = [[NVMapViewController alloc] init];
	
	[window addSubview:mapViewController.view];
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [mapViewController release];
	[window release];
    [super dealloc];
}


@end
