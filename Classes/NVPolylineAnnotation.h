//
//  NVPolylineAnnotation.h
//  nvpolyline
//
//  Created by William Lachance on 10-03-31.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface NVPolylineAnnotation : NSObject<MKAnnotation> {
	NSMutableArray* _points; 
	MKMapView* _mapView;

}

-(id) initWithPoints:(NSArray*) points mapView:(MKMapView *)mapView;

@property (nonatomic, retain) NSArray* points;

@end
