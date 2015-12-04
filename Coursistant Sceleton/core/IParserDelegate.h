//
//  ParserDelegate.h
//  Coursistant
//
//  Created by Andrew on 11.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IParserDelegate <NSObject>

@required
-(void) parserUpdateFinished;

@end
