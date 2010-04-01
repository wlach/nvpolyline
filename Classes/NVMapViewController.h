//
//  NVMapViewController.h
//  nvpolyline
//
//  Created by William Lachance on 10-03-30.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NVMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *_mapView;
}

@end
