//
//  Exercise.h
//  iOS-CoSpace-Fall2012
//
//  Created by Truong-An Thai on 11/11/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Exercise : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * slug;

@end
