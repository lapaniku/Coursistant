//
//  ICoursewareParser.h
//  Coursistant Sceleton
//
//  Created by Andrew on 14.01.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IContentParser <NSObject>

@required

-(NSArray *) parseContent:(NSString *)content;

-(NSArray *) parseArray:(NSArray *)array;


@end
