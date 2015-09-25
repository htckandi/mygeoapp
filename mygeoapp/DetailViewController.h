//
//  DetailViewController.h
//  mygeoapp
//
//  Created by Сергей Табунщиков on 03.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Venue *venue;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
