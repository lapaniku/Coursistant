//
//  CoursistantIAPHelper.h
//  Coursistant
//
//  Created by Andrei Lapanik on 01.04.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface CoursistantIAPHelper  : IAPHelper

+ (CoursistantIAPHelper *)sharedInstance;

+(NSString *) allLanguagesProductKey;

@property (strong, nonatomic) SKProduct * allLanguagesProduct;

-(BOOL) isAllLanguagesAvailable;

@end
