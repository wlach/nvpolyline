//
//  NVPolylineAnnotationView.h
//  nvpolyline
//
//  Created by William Lachance on 10-03-31.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NVPolylineAnnotation.h"


@interface NVPolylineAnnotationView : MKAnnotationView {
	MKMapView * _mapView;
	UIView * _internalView;
}

@property (nonatomic) CGPoint centerOffset;

- (id)initWithAnnotation:(NVPolylineAnnotation *)annotation
				 mapView:(MKMapView *)mapView;

@end
