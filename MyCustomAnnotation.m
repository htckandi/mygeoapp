//
//  MyCustomAnnotation.m
//  mygeoapp
//
//  Created by Сергей Табунщиков on 03.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "MyCustomAnnotation.h"

@implementation MyCustomAnnotation

-(id)initWithTitle:(NSString *)newTitle subTitle:(NSString *)newSubTitle Location:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        self.title = newTitle;
        self.userSubTitle = newSubTitle;
        self.coordinate = location;
    }
    return  self;
}

-(NSString*)subtitle {
    return self.userSubTitle;
}

@end
