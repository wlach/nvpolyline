//
//  NVPolylineAnnotationView.m
//  nvpolyline
//
//  Created by William Lachance on 10-03-31.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import "NVPolylineAnnotationView.h"

const CGFloat POLYLINE_WIDTH = 4.0;

// we use an internal view to actually render the polyline, offset within the annotation
// view; this is so we can have an annotation view which takes up the full size of the
// map kit view, always centered (so always visible)
@interface NVPolylineInternalAnnotationView : UIView {
	NVPolylineAnnotationView* _polylineView;
	MKMapView *_mapView;
}

- (id) initWithPolylineView:(NVPolylineAnnotationView *)polylineView
					mapView:(MKMapView *)mapView;

@end

@implementation NVPolylineInternalAnnotationView

- (id) initWithPolylineView:(NVPolylineAnnotationView *)polylineView
					mapView:(MKMapView *)mapView {
	if (self = [super init]) {
		_polylineView = [polylineView retain];
		_mapView = [mapView retain];
		
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
	}
	
	return self;
}

-(void) drawRect:(CGRect)rect {

	NVPolylineAnnotation* annotation = (NVPolylineAnnotation*)_polylineView.annotation;
	if (annotation.points && annotation.points.count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
		CGContextSetAlpha(context, 0.5);
		
		CGContextSetLineWidth(context, POLYLINE_WIDTH);
		
		for (int i = 0; i < annotation.points.count; i++) {
			CLLocation* location = [annotation.points objectAtIndex:i];
			CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:self];
			
			if (i == 0)
				CGContextMoveToPoint(context, point.x, point.y);
			else
				CGContextAddLineToPoint(context, point.x, point.y);
		}
		
		CGContextStrokePath(context);
	}
}

-(void) dealloc {
	[super dealloc];
	[_mapView release];
	[_polylineView release];
}

@end


@implementation NVPolylineAnnotationView

- (id)initWithAnnotation:(NVPolylineAnnotation *)annotation
				 mapView:(MKMapView *)mapView {
    if (self = [super init]) {
        self.annotation = annotation;
		
		_mapView = [mapView retain];
		
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.frame = CGRectMake(0.0, 0.0, _mapView.frame.size.width, _mapView.frame.size.height);

		_internalView = [[[NVPolylineInternalAnnotationView alloc] initWithPolylineView:self mapView:_mapView] autorelease];
		[self addSubview:_internalView];
    }
    return self;
}

-(void) regionChanged {
	// move the internal route view. 
	
	NVPolylineAnnotation* annotation = (NVPolylineAnnotation*)self.annotation;
	CGPoint minpt, maxpt;
	for (int i = 0; i < annotation.points.count; i++)
	{
		CLLocation* location = [annotation.points objectAtIndex:i];
		CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:_mapView];	
		if (point.x < minpt.x || i == 0)
			minpt.x = point.x;
		if (point.y < minpt.y || i == 0)
			minpt.y = point.y;
		if (point.x > maxpt.x || i == 0)
			maxpt.x = point.x;
		if (point.y > maxpt.y || i == 0)
			maxpt.y = point.y;
	}
	
	CGFloat w = maxpt.x - minpt.x + (2*POLYLINE_WIDTH);
	CGFloat h = maxpt.y - minpt.y + (2*POLYLINE_WIDTH);
	
	_internalView.frame = CGRectMake(minpt.x - POLYLINE_WIDTH, minpt.y - POLYLINE_WIDTH, 
									 w, h);
	[_internalView setNeedsDisplay];
}

- (CGPoint) centerOffset {
	// HACK: use the method to get the centerOffset (called by the main mapview)
	// to reposition our annotation subview in response to zoom and motion 
	// events
	[self regionChanged];
	return [super centerOffset];
}

- (void) setCenterOffset:(CGPoint) centerOffset {
	[super setCenterOffset:centerOffset];
}

- (void)dealloc {
	[_mapView release];
	
    [super dealloc];
}

@end
