//
//  iiVolumeUsageProvider.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 24/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiAccountInfo.h"
#import "iiQuotaReset.h"
#import "iiTraffic.h"
#import "iiVolumeUsage.h"
#import "iiUsageUnit.h"
#import "iiTrafficType.h"
#import "iiUsagePeriod.h"

@protocol iiVolumeUsageProviderDelegate

@optional
- (void)didHaveConnectionError:(NSString *)message;
- (void)didHaveCredentialError:(NSString *)message;
- (void)didHaveParsingError:(NSString *)message;

@end


@interface iiVolumeUsageProvider : NSObject <NSXMLParserDelegate> {
    id<iiVolumeUsageProviderDelegate> _delegate;
    
    NSMutableString *_currentStringValue;

    NSString *_stateTracking;
    NSString *_secondTierStateTracking;   

    iiAccountInfo *_accountInfo;
    iiVolumeUsage *_volumeUsage;

    iiTraffic *_trafficUnit;
    iiUsagePeriod *_usagePeriod;
    iiUsageUnit *_usageUnit;

    BOOL _errorFlagged;
    NSString *_error;
}

@property (nonatomic, strong) id delegate;

@property (readonly) iiVolumeUsage *volumeUsage;
@property (readonly) iiAccountInfo *accountInfo;
@property (readonly) NSString *error;

+ (iiVolumeUsageProvider *)sharedSingleton;

- (void)retrieveUsage;
- (BOOL)setUserCredentials:(NSString *)username withPassword:(NSString *)password;
- (BOOL)doesHaveUserCredentials;

@end
