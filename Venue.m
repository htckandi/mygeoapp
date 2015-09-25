//
//  Venue.m
//  mygeoapp
//
//  Created by Сергей Табунщиков on 02.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "Venue.h"

@implementation Venue

-(NSString*)primaryCategory {
    NSPredicate *predicatePrimary = [NSPredicate predicateWithFormat:@"primary == 1"];
    NSArray *filteredArray = [self.categories filteredArrayUsingPredicate:predicatePrimary];
    return (NSString*)[filteredArray.firstObject valueForKey:@"name"];
}

@end
