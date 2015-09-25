//
//  DetailViewController.m
//  mygeoapp
//
//  Created by Сергей Табунщиков on 03.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "DetailViewController.h"




@interface DetailViewController ()

@end




@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *venueName = self.venue.name;
    NSString *venuePrimaryCtegory = [self.venue primaryCategory];
    
    NSString *venueCountry = self.venue.location.country;
    NSString *venueState = self.venue.location.state;
    NSString *venueCity = self.venue.location.city;
    NSString *venueAddress = self.venue.location.address;
    
    NSString *mainString = [NSString stringWithFormat:@"Name: %@\nCategory: %@\n\nCountry: %@\nState: %@\nCity: %@\nAddress: %@",venueName,venuePrimaryCtegory,venueCountry,venueState, venueCity, venueAddress];
    
    self.detailLabel.text = mainString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}


@end
