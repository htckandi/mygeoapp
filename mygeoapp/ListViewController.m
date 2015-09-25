//
//  ListViewController.m
//  mygeoapp
//
//  Created by Сергей Табунщиков on 02.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "ListViewController.h"
#import "InfoViewController.h"
#import "ConnectViewController.h"
#import "Reachability.h"
#import "Venue.h"




@interface ListViewController () <CLLocationManagerDelegate>

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UILabel *systemMessageLabel;

@end




@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foursquareAuthorizationChanged) name:kFoursquareAuthorizationChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self addObserver:self forKeyPath:@"venues" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self configureRestKit];
    [self configureLocationManager];
    [self configureInternetReachability];
    [self configureSystemMessage];
    
    [self.locationManager startUpdatingLocation];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"venues"];
    [self removeObserver:self forKeyPath:@"currentLocation"];
    self.locationManager.delegate = nil;
}




#pragma mark - Foursquare Authorization

-(BOOL)foursquareAuthorizationStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFoursquareAccessToken] != nil;
}

-(void)foursquareAuthorizationChanged {
    [self configureSystemMessage];
    [self loadVenues];
}

- (IBAction)authenticationEvent:(UIBarButtonItem *)sender {
    if ([self foursquareAuthorizationStatus] == NO) {
        UINavigationController *navController = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFoursquareAccessToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFoursquareAuthorizationChangedNotification object:nil];
    }
}




#pragma mark - Load Venues

- (void)loadVenues {
    
    [self configureSystemMessage];
    
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    BOOL locationAuthorizationStatus = (currentStatus != kCLAuthorizationStatusRestricted && currentStatus != kCLAuthorizationStatusDenied);
    BOOL internetReachability = self.internetReachability.currentReachabilityStatus != NotReachable;
    
    if (internetReachability == YES && locationAuthorizationStatus == YES) {
        
        NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
        NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
        NSString *coordinate = [NSString stringWithFormat:@"%f,%f",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
        NSString *accessToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:kFoursquareAccessToken];
        
        NSDictionary *queryParams;
        
        if (accessToken != nil) {
            queryParams = @{@"ll":coordinate, @"oauth_token":accessToken, @"v":@"20150801", @"limit":@"100", @"intent": @"browse", @"radius":@"500"};
        } else {
            queryParams = @{@"ll":coordinate, @"client_id":clientID, @"client_secret":clientSecret, @"v":@"20150801", @"limit":@"100", @"intent": @"browse", @"radius":@"500"};
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSSortDescriptor *sortDistance = [[NSSortDescriptor alloc] initWithKey:@"location.distance" ascending:YES];
            self.venues = [mappingResult.array sortedArrayUsingDescriptors:@[sortDistance]];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSLog(@"Error: %@", error);
        }];
    }
}




#pragma mark - Configuration

-(void)configureLocationManager {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100.0;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)configureInternetReachability {
    self.internetReachability = [Reachability reachabilityForInternetConnection];
}

- (void)configureRestKit
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name",@"categories"]];
    
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"state", @"distance", @"lat", @"lng"]];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping method:RKRequestMethodGET pathPattern:@"/v2/venues/search" keyPath:@"response.venues" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
}

-(void)configureSystemMessage {
    
    NSString *newSystemMessage = @"";
    
    if ([self foursquareAuthorizationStatus] == NO) {
        self.navigationItem.leftBarButtonItem.title = @"Login";
        newSystemMessage = @"Пользователь не авторизован.";
    } else {
        self.navigationItem.leftBarButtonItem.title = @"Logout";
        newSystemMessage = @"Пользователь авторизован.";
    }
    
    BOOL internetReachability = (self.internetReachability.currentReachabilityStatus != NotReachable);
    
    CLAuthorizationStatus currentLocationAuthStatus = [CLLocationManager authorizationStatus];
    BOOL locationAuthStatus = (currentLocationAuthStatus != kCLAuthorizationStatusRestricted && currentLocationAuthStatus != kCLAuthorizationStatusDenied);
    
    NSLog(@"%d", locationAuthStatus);
    
    if (internetReachability == YES && locationAuthStatus == YES && self.venues.count < 1) {
        newSystemMessage = [newSystemMessage stringByAppendingString:@"\nНет данных."];
    } else {
        if (locationAuthStatus == NO) {
            newSystemMessage = [newSystemMessage stringByAppendingString:@"\nОтсутствует доступ к службе определения местоположения."];
        }
        if (internetReachability == NO) {
            newSystemMessage = [newSystemMessage stringByAppendingString:@"\nОтсутствует доступ к сети Интернет."];
        }
    }
    
    self.systemMessageLabel.text = newSystemMessage;
}




#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"venues"]) {
        [self configureSystemMessage];
        [self.tableView reloadData];
    }
    
    if ([keyPath isEqualToString:@"currentLocation"]) {
        [self loadVenues];
    }
}




#pragma mark - Location's events

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self configureSystemMessage];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self.locationManager stopUpdatingLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = (CLLocation*)locations.lastObject;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self configureSystemMessage];
    if ([error code] != kCLErrorLocationUnknown) {
        [self.locationManager stopUpdatingLocation];
    }
}




#pragma mark - Reachability events

- (void) reachabilityChanged:(NSNotification *)note {
    [self updateInterfaceWithReachability:(Reachability*)note.object];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    
    [self configureSystemMessage];
    
    if (reachability == self.internetReachability)
    {
        BOOL reachable = YES;
        switch (reachability.currentReachabilityStatus) {
            case NotReachable:      {
                reachable = NO;
                break;
            }
            case ReachableViaWWAN:  {
                break;
            }
            case ReachableViaWiFi:  {
                break;
            }
        }
        
        self.navigationItem.leftBarButtonItem.enabled = reachable;
        if (reachable == YES) {
            [self loadVenues];
        }
    }
}




#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    Venue *currentVenue = (Venue*)self.venues[indexPath.row];
    
    UIFont *fontName = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *fontCategory = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    UIColor *colorName = [UIColor blackColor];
    UIColor *colorCategory = [UIColor grayColor];
   
    NSAttributedString *stringName = [[NSAttributedString alloc] initWithString:currentVenue.name attributes:@{NSFontAttributeName: fontName, NSForegroundColorAttributeName: colorName}];
    
    NSMutableAttributedString *maString = [[NSMutableAttributedString alloc] initWithAttributedString:stringName];

    NSString *primaryCategoryName = [currentVenue primaryCategory];
    
    NSAttributedString *stringCategory = [[NSAttributedString alloc] initWithString:primaryCategoryName attributes:@{NSFontAttributeName: fontCategory, NSForegroundColorAttributeName: colorCategory}];
    [maString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [maString appendAttributedString:stringCategory];
    
    cell.textLabel.attributedText =  maString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ м", currentVenue.location.distance];
    return cell;
}




#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showInfo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        InfoViewController *viewController = (InfoViewController*)segue.destinationViewController;
        viewController.venue = self.venues[indexPath.row];
    }
}




@end
