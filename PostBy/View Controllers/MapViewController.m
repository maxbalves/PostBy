//
//  MapViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Frameworks
@import MapKit;

// View Controllers
#import "DetailsViewController.h"
#import "MapViewController.h"

// Views
#import "MapPin.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL didZoomOnUser;

@property (strong, nonatomic) NSArray *postVMsArray;
@property (nonatomic) int MAX_POSTS_SHOWN;

@property (nonatomic) double CLOSE_ZOOM;
@property (nonatomic) double MEDIUM_ZOOM;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set span values to use (smaller value == closer zoom)
    self.CLOSE_ZOOM = 0.01;
    self.MEDIUM_ZOOM = 0.1;
    
    // Default to Seattle - Coordinates
    [self setMapToRegionWithLat:47.6062 WithLong:-122.3321 WithSpan:self.MEDIUM_ZOOM];
    
    self.didZoomOnUser = NO;
    
    // If we are segueing from Details page, we will have set a post to show.
    // This checks that, and if so zooms in on the post instead of the user's location
    if (self.postVMtoShow != nil) {
        double latitude = self.postVMtoShow.latitude;
        double longitude = self.postVMtoShow.longitude;
        [self setMapToRegionWithLat:latitude WithLong:longitude WithSpan:self.CLOSE_ZOOM];
        self.didZoomOnUser = YES;
    }
    
    self.mapView.delegate = self;
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
    
    self.MAX_POSTS_SHOWN = 10;
    
    NSArray *areaRect = [self getViewAreaFromMap];
    [self refreshPostsInside:areaRect];
}

- (IBAction)userLocationButtonTap:(id)sender {
    // Zoom in on user's location again
    double latitude = self.locationManager.location.coordinate.latitude;
    double longitude = self.locationManager.location.coordinate.longitude;
    [self setMapToRegionWithLat:latitude WithLong:longitude WithSpan:self.CLOSE_ZOOM];
}

- (IBAction)refreshMapTap:(id)sender {
    NSArray *allMapPins = self.mapView.annotations;
    [self.mapView removeAnnotations:allMapPins];
    
    NSArray *areaRect = [self getViewAreaFromMap];
    [self refreshPostsInside:areaRect];
}

- (void)refreshPostsInside:(NSArray *)areaRect {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.limit = self.MAX_POSTS_SHOWN;
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"author"]];
    
    PFGeoPoint *bottomLeft = areaRect[0];
    PFGeoPoint *topRight = areaRect[1];
    [query whereKey:@"location" withinGeoBoxFromSouthwest:bottomLeft toNortheast:topRight];
    [query whereKey:@"hideLocation" equalTo:@NO];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postVMsArray = [PostViewModel postVMsWithArray:posts];
            [self addAnnotationsFromPosts];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) addAnnotationsFromPosts {
    for (PostViewModel *postVM in self.postVMsArray) {
        if (!postVM.post.location || postVM.hideLocation)
            continue;
        
        MapPin *pin = [MapPin createPinFromPostVM:postVM];
        
        [self.mapView addAnnotation:pin];
    }
}

- (NSArray *) getViewAreaFromMap {
    MKMapRect areaOnScreen = self.mapView.visibleMapRect;
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(areaOnScreen);
    
    double latitude = region.center.latitude;
    double longitude = region.center.longitude;
    
    double latDelta = region.span.latitudeDelta;
    double longDelta = region.span.longitudeDelta;
    
    // Sanity check must be done so that latitude nor longitude
    // are out of bounds due to innacuracy errors.
    double bottomLeftLat = [self checkLatitude:(latitude - latDelta)];
    double bottomLeftLong = [self checkLongitude:(longitude - longDelta)];
    double topRightLat = [self checkLatitude:(latitude + latDelta)];
    double topRightLong = [self checkLongitude:(longitude + longDelta)];
    
    PFGeoPoint *bottomLeft = [PFGeoPoint geoPointWithLatitude:bottomLeftLat longitude:bottomLeftLong];
    PFGeoPoint *topRight = [PFGeoPoint geoPointWithLatitude:topRightLat longitude:topRightLong];
    
    NSArray *rectangle = @[bottomLeft, topRight];
    return rectangle;
}

- (double) checkLatitude:(double)latitude {
    if (latitude < -90.0)
        return -90.0;
    if (latitude > 90.0)
        return 90.0;
    return latitude;
}

- (double) checkLongitude:(double)longitude {
    if (longitude < -180.0)
        return -180.0;
    if (longitude > 180.0)
        return 180.0;
    return longitude;
}

// Change pin/annotation look
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If the annotation is the user location, don't change it
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // refer to this generic annotation as our more specific PhotoAnnotation
    MapPin *mapPin = (MapPin *)annotation;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        annotationView.canShowCallout = true;
        
        // Every pin will hold an image of the user's profile pic
        double width = mapPin.profilePic.size.width;
        double height = mapPin.profilePic.size.height;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        
        // create 'i' button
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = infoButton;
    }

    UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    
    [imageView setImage:mapPin.profilePic]; // set the image into the callout imageview

    return annotationView;
}

// When pin's button is clicked, perform segue to details page
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"MapShowDetails" sender:view.annotation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.didZoomOnUser) {
        double latitude = manager.location.coordinate.latitude;
        double longitude = manager.location.coordinate.longitude;
        [self setMapToRegionWithLat:latitude WithLong:longitude WithSpan:self.CLOSE_ZOOM];
        self.didZoomOnUser = YES;
    }
}

- (void) setMapToRegionWithLat:(double)latitude WithLong:(double)longitude WithSpan:(double)span {
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(span, span));
    [self.mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapShowDetails"]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        MapPin *pin = sender;
        detailsVC.postVM = pin.postVM;
    }
}

@end
