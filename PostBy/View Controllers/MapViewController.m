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

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: Will code & refactor this feature on next commit (likely) :)
    [self.locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
        
        // TODO: Set map to location
        
    } else {
        // TODO: default to seattle
        
    }
}

@end
