//
//  MyCustomAnnotation.h
//  mygeoapp
//
//  Created by Сергей Табунщиков on 03.08.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic,copy) NSString *userSubTitle;

-(id)initWithTitle:(NSString*)newTitle subTitle:(NSString*)newSubTitle Location:(CLLocationCoordinate2D)location;

@end
