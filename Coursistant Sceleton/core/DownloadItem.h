//
//  DownloadItem.h
//  Coursistant Sceleton
//
//  Created by Andrew on 18.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadItem : NSObject <NSCopying>

@property (nonatomic) NSString *key;

@property (nonatomic) NSString *courseTitle;

@property (nonatomic) NSString *lectureTitle;

@property (nonatomic) NSString *provider;

@property (nonatomic) NSString *category;

@property (nonatomic) NSURL *url;

@property (nonatomic) NSString *extension;

@property (nonatomic) float progress;

-(id) init:(NSString *)aKey provider:(NSString *)aProvider lectureItem:(NSDictionary *)lectureItem courseTitle:(NSString *)aCourseTitle extension:(NSString *)anExtension;

-(id) init:(NSString *)aKey provider:(NSString *)aProvider lectureTitle:(NSString *)aLectureTitle category:(NSString*)aCategory courseTitle:(NSString *)aCourseTitle extension:(NSString *)anExtension;

@end
