//
//  MapViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// Frameworks
@import MapKit;

// View Controllers
#import "DetailsViewController.h"
#import "MapViewController.h"

// Views
#import "MapPin.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, DetailsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL didZoomOnUser;
@property (strong, nonatomic) IBOutlet UIButton *numPostsShownButton;

@property (strong, nonatomic) NSMutableArray *postVMsArray;
@property (nonatomic) int POSTS_SHOWN_LIMIT;
@property (nonatomic) int MAX_POSTS_SHOWN;
@property (nonatomic) int ADDITIONAL_POSTS;

@property (nonatomic) double CLOSE_ZOOM;
@property (nonatomic) double MEDIUM_ZOOM;

@property (nonatomic) double LATITUDE_MAX;
@property (nonatomic) double LATITUDE_MIN;

@property (nonatomic) double LONGITUDE_MAX;
@property (nonatomic) double LONGITUDE_MIN;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Latitude & longitude boundaries
    self.LATITUDE_MAX = 90.0;
    self.LATITUDE_MIN = -90.0;
    self.LONGITUDE_MAX = 180.0;
    self.LONGITUDE_MIN = -180.0;
    
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
    
    self.POSTS_SHOWN_LIMIT = 100;
    self.MAX_POSTS_SHOWN = 10;
    self.ADDITIONAL_POSTS = 5;
    
    NSArray *areaRect = [self getViewAreaFromMap];
    [self refreshPostsInside:areaRect];
}

- (IBAction)increaseMaxPostsTap:(id)sender {
    self.MAX_POSTS_SHOWN += self.ADDITIONAL_POSTS;
    if (self.MAX_POSTS_SHOWN > self.POSTS_SHOWN_LIMIT) {
        [self showOkAlertWithTitle:@"Map Pin Limit" Message:@"A maximum of 100 posts can be displayed at a time."];
        
        self.MAX_POSTS_SHOWN = self.POSTS_SHOWN_LIMIT;
    }
    [self updateNumPostsShownButton];
}

- (IBAction)decreaseMaxPostsTap:(id)sender {
    self.MAX_POSTS_SHOWN -= self.ADDITIONAL_POSTS;
    if (self.MAX_POSTS_SHOWN < 0)
        self.MAX_POSTS_SHOWN = 0;
    [self updateNumPostsShownButton];
}

- (void) updateNumPostsShownButton {
    NSString *title = [NSString stringWithFormat:@"%lu/%d", self.postVMsArray.count, self.MAX_POSTS_SHOWN];
    [self.numPostsShownButton setTitle:title forState:UIControlStateNormal];
    [self.numPostsShownButton sizeToFit];
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
    PFQuery *query = [PFQuery queryWithClassName:POST_CLASS];
    query.limit = self.MAX_POSTS_SHOWN;
    [query orderByDescending:@"createdAt"];
    [query includeKey:AUTHOR_FIELD];
    
    PFGeoPoint *bottomLeft = areaRect[0];
    PFGeoPoint *topRight = areaRect[1];
    [query whereKey:LOCATION_FIELD withinGeoBoxFromSouthwest:bottomLeft toNortheast:topRight];
    [query whereKey:@"hideLocation" equalTo:@NO];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postVMsArray = [PostViewModel postVMsWithArray:posts];
            [self updateNumPostsShownButton];
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
    if (latitude < self.LATITUDE_MIN)
        return self.LATITUDE_MIN;
    if (latitude > self.LATITUDE_MAX)
        return self.LATITUDE_MAX;
    return latitude;
}

- (double) checkLongitude:(double)longitude {
    if (longitude < self.LONGITUDE_MIN)
        return self.LONGITUDE_MIN;
    if (longitude > self.LONGITUDE_MAX)
        return self.LONGITUDE_MAX;
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

    // Animate pins
    
    // Make pins have no size
    annotationView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    double durationInSeconds = 0.3;
    [UIView animateWithDuration:durationInSeconds animations:^{
        // Increase pin size with animation
        annotationView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
    
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

- (void) accessedBadPostVM:(PostViewModel *)postVM {
    NSInteger count = [self.postVMsArray count];
    for (NSInteger index = (count - 1); index >= 0; index--) {
        PostViewModel *p = self.postVMsArray[index];
        if ([p.post.objectId isEqualToString:postVM.post.objectId]) {
            [self.postVMsArray removeObjectAtIndex:index];
        }
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateNumPostsShownButton];
    [self addAnnotationsFromPosts];
}

- (void) updatePostVMWith:(PostViewModel *)updatedVM {
    NSInteger count = [self.postVMsArray count];
    for (NSInteger index = (count - 1); index >= 0; index--) {
        PostViewModel *p = self.postVMsArray[index];
        if ([p.post.objectId isEqualToString:updatedVM.post.objectId]) {
            p.post = updatedVM.post;
            [p setPropertiesFromPost:p.post];
            
            // Likes / Dislikes
            p.isLiked = updatedVM.isLiked;
            p.isDisliked = updatedVM.isDisliked;
            [p reloadLikeDislikeData];
        }
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateNumPostsShownButton];
    [self addAnnotationsFromPosts];
}

- (void) showOkAlertWithTitle:(NSString *)title Message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapShowDetails"]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        MapPin *pin = sender;
        detailsVC.delegate = self;
        detailsVC.postVM = pin.postVM;
    }
}

@end
