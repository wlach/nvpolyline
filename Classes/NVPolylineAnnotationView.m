//
//  NVPolylineAnnotationView.m
//  nvpolyline
//
//  Created by William Lachance on 10-03-31.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//
//  Further development by Joerg Polakowski (www.mobile-melting.de)

#import "NVPolylineAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

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
	
	// for debugging only to check when and how the polyline annotation view is updated
	/*
	CALayer *infoLayer = [self layer];
	[infoLayer setBorderWidth:2];
	[infoLayer setBorderColor:[[UIColor greenColor] CGColor]];
	*/
	return self;
}

-(void) drawRect:(CGRect)rect {
	
	NVPolylineAnnotation* annotation = (NVPolylineAnnotation*)_polylineView.annotation;
	if (!self.hidden && annotation.points && annotation.points.count > 0) {
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
		CGContextSetAlpha(context, 0.5);
		
		CGContextSetLineWidth(context, POLYLINE_WIDTH);
		
		for (int i = 0; i < annotation.points.count; i++) {
			CLLocation* location = [annotation.points objectAtIndex:i];
			CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:self];
			
			BOOL contains = CGRectContainsPoint(rect, point);
			if (contains) {
				CGPoint prevPoint = CGPointZero;
				@try {
					CLLocation *prevLocation = [annotation.points objectAtIndex:(i - 1)];
					prevPoint = [_mapView convertCoordinate:prevLocation.coordinate 
											  toPointToView:self];					
					if (!CGRectContainsPoint(rect, prevPoint)) { // outside
						CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
					}
				}
				@catch(NSException *ex) { 
					prevPoint = CGPointZero;
				}
				
				if (!CGPointEqualToPoint(prevPoint, CGPointZero)) { // prevPoint outside
					CGContextAddLineToPoint(context, point.x, point.y);
				}
				else { // prevPoint inside
					CGContextMoveToPoint(context, point.x, point.y);
				}
				
				CGPoint nextPoint = CGPointZero;
				@try {
					CLLocation *nextLocation = [annotation.points objectAtIndex:(i + 1)];
					nextPoint = [_mapView convertCoordinate:nextLocation.coordinate 
											  toPointToView:self];					
					if (!CGRectContainsPoint(rect, nextPoint)) { // outside
						CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
					}
					else {
						nextPoint = CGPointZero;
					}
				}
				@catch(NSException *ex) { 
					nextPoint = CGPointZero;
				}
			}
			else {
				// if current point is outside the drawing rect, check if the line drawn
				// between current point and next point intersects with the drawing rect				
				CGPoint nextPoint = CGPointZero;
				@try {
					CLLocation *nextLocation = [annotation.points objectAtIndex:(i + 1)];
					nextPoint = [_mapView convertCoordinate:nextLocation.coordinate 
											  toPointToView:self];					
					if (!CGRectContainsPoint(rect, nextPoint)) { // outside, check intersection
						CGMutablePathRef myPath = CGPathCreateMutable();
						CGPathMoveToPoint(myPath, NULL, point.x, point.y );
						CGPathAddLineToPoint(myPath, NULL, nextPoint.x, nextPoint.y);
						CGPathCloseSubpath(myPath);
						
						CGRect lineRect = CGPathGetBoundingBox(myPath);
						
						if (CGRectIntersectsRect(rect, lineRect)) {
							CGContextMoveToPoint(context, point.x, point.y);
							CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
						}
						CGPathRelease(myPath);
					}
				}
				@catch(NSException *ex) { 
					nextPoint = CGPointZero;
				}				
			}
		}		
		CGContextStrokePath(context);
	}
}

- (BOOL) lineIntersectsRect:(CGRect)rect from:(CGPoint)a to:(CGPoint)b {
	float lineSlope = (b.y - a.y) / (b.x - a.x);
	float yIntercept = a.y - lineSlope * a.x;
	float leftY = lineSlope * CGRectGetMinX(rect) + yIntercept;
	float rightY = lineSlope * CGRectGetMaxX(rect) + yIntercept;
	
	if (leftY >= CGRectGetMinY(rect) && leftY <= CGRectGetMaxY(rect)) {
		return YES;
	}
	if (rightY >= CGRectGetMinY(rect) && rightY <= CGRectGetMaxY(rect)) {
		return YES;
	}
	return NO;
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
	
	/* In iOS version 4.0 and above we need to calculate the new frame. Before iOS 4 setting
	 the view's frame to the mapview's frame was sufficient*/
	NSString *reqSysVer = @"4.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
		CGPoint origin = CGPointMake(0, 0);
		origin = [_mapView convertPoint:origin toView:self];	
		_internalView.frame = CGRectMake(origin.x, origin.y, _mapView.frame.size.width, _mapView.frame.size.height);
	}
	else { // iOS < 4.0
		_internalView.frame = _mapView.frame;
	}
	
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
