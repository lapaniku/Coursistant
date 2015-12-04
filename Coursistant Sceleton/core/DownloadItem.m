//
//  DownloadItem.m
//  Coursistant Sceleton
//
//  Created by Andrew on 18.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "DownloadItem.h"

@implementation DownloadItem

NSString * const kKey = @"key";
NSString * const kLectureTitle = @"lectureTitle";
NSString * const kProvider = @"provider";
NSString * const kCourseTitle = @"courseTitle";
NSString * const kCategory = @"category";
NSString * const kProgress = @"progress";
NSString * const kURL = @"url";
NSString * const kExtension = @"extension";

@synthesize key, courseTitle, lectureTitle, provider, category, progress, url, extension;

-(id) init:(NSString *)aKey provider:(NSString *)aProvider lectureItem:(NSDictionary *)lectureItem courseTitle:(NSString *)aCourseTitle extension:(NSString *)anExtension {
    
    self = [super init];
    self.key = aKey;
    self.lectureTitle = [lectureItem valueForKey:@"title"];
    self.provider = aProvider;
    self.courseTitle = aCourseTitle;
    self.category = [lectureItem valueForKeyPath:@"category"];
    self.progress = 0;
    self.extension = anExtension;
    return self;
}

-(id) init:(NSString *)aKey provider:(NSString *)aProvider lectureTitle:(NSString *)aLectureTitle category:(NSString*)aCategory courseTitle:(NSString *)aCourseTitle extension:(NSString *)anExtension {
    
    self = [super init];
    self.key = aKey;
    self.lectureTitle = aLectureTitle;
    self.provider = aProvider;
    self.courseTitle = aCourseTitle;
    self.category = aCategory;
    self.progress = 0;
    self.extension = anExtension;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:key forKey:kKey];
    [coder encodeObject:lectureTitle forKey:kLectureTitle];
    [coder encodeObject:provider forKey:kProvider];
    [coder encodeObject:courseTitle forKey:kCourseTitle];
    [coder encodeObject:category forKey:kCategory];
    [coder encodeFloat:progress forKey:kProgress];
    [coder encodeObject:url forKey:kURL];
    [coder encodeObject:extension forKey:kExtension];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        key = [coder decodeObjectForKey:kKey];
        lectureTitle = [coder decodeObjectForKey:kLectureTitle];
        provider = [coder decodeObjectForKey:kProvider];
        courseTitle = [coder decodeObjectForKey:kCourseTitle];
        category = [coder decodeObjectForKey:kCategory];
        progress = [coder decodeFloatForKey:kProgress];
        url = [coder decodeObjectForKey:kURL];
        extension = [coder decodeObjectForKey:kExtension];
    }
    return self;
}

-(id) mutableCopyWithZone: (NSZone *) zone {
    DownloadItem *itemCopy = [[DownloadItem allocWithZone: zone] init:key provider:provider lectureTitle:lectureTitle category:category courseTitle:courseTitle extension:extension];
    
    return itemCopy;
}


@end
