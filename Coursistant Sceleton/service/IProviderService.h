//
//  IProviderService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 07.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginManager.h"
#import "IProfileManager.h"
#import "IContentManager.h"

@protocol IProviderService <NSObject>

@required

- (id<ILoginManager>) loginManager:(id<ILoginDelegate>)delegate;

- (id<IProfileManager>) profileManager:(id<IProfileDelegate>)delegate;

- (id<IContentManager>) coursewareManager:(id<IContentDelegate>)delegate;

- (id<IContentManager>) lectureManager:(id<IContentDelegate>)delegate;

@end
