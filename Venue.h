//
//  Venue.h
//  mygeoapp
//
//  Created by Сергей Табунщиков on 02.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Venue : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSArray *categories;

-(NSString*)primaryCategory;

@end
