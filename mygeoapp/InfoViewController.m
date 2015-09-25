//
//  InfoViewController.m
//  mygeoapp
//
//  Created by Сергей Табунщиков on 03.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "InfoViewController.h"
#import "DetailViewController.h"

#import "MyCustomAnnotation.h"




@interface InfoViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) BOOL firstAppear;

@end




@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstAppear = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake(self.venue.location.lat.doubleValue, self.venue.location.lng.doubleValue);
    MyCustomAnnotation *currentAnnotation = [[MyCustomAnnotation alloc] initWithTitle:self.venue.name subTitle:[self.venue primaryCategory] Location:annotationCoordinate];
    [self.mapView addAnnotation:currentAnnotation];
    [self.mapView selectAnnotation:currentAnnotation animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Map View Delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (self.firstAppear == YES) {
        CLLocationCoordinate2D location = self.mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 700.0, 700.0);
        [self.mapView setRegion:viewRegion animated:NO];
        self.firstAppear = NO;
    }
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MyCustomAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MyCustomAnnotation"];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyCustomAnnotation"];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    UINavigationController *controller = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    
    DetailViewController *detailController = (DetailViewController*)controller.topViewController;
    detailController.venue = self.venue;

    [self presentViewController:controller animated:YES completion:nil];
}




#pragma mark - Segues

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}




@end
