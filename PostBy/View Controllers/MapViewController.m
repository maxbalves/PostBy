//
//  MapViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Frameworks
#import <MapKit/MapKit.h>

// View Controllers
#import "MapViewController.h"

// Views
#import "Post.h"

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL didZoomOnUser;

@property (strong, nonatomic) NSArray *postsArray;
@property (nonatomic) int MAX_POSTS_SHOWN;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default to Seattle - Coordinates
    // ~ one degree of latitude/longitude is approximately 111 kilometers (69 miles) at all times.
    [self setMapToRegionWithLat:47.6062 WithLong:-122.3321 WithSpan:0.1];
    
    self.didZoomOnUser = NO;
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
    
    self.MAX_POSTS_SHOWN = 10;
    [self refreshPosts];
}

- (void)refreshPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.limit = self.MAX_POSTS_SHOWN;
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"author"]];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postsArray = posts;
            [self addAnnotationsFromPosts];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) addAnnotationsFromPosts {
    for (Post *post in self.postsArray) {
        if (!post.latitude || !post.longitude)
            continue;
        
        MKPointAnnotation *pin = [MKPointAnnotation new];
        pin.coordinate = CLLocationCoordinate2DMake(post.latitude.floatValue, post.longitude.floatValue);
        pin.title = post.objectId;
        [self.mapView addAnnotation:pin];
    }
}

- (void) setMapToRegionWithLat:(double)latitude WithLong:(double)longitude WithSpan:(double)span {
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(span, span));
    [self.mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.didZoomOnUser) {
        double latitude = manager.location.coordinate.latitude;
        double longitude = manager.location.coordinate.longitude;
        
        [self setMapToRegionWithLat:latitude WithLong:longitude WithSpan:0.01];
        
        self.didZoomOnUser = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
}

@end
