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
#import "iiFeed.h"

@protocol iiVolumeUsageProviderDelegate
@required
- (void)didHaveAuthenticationError:(NSString *)message;

@optional
- (void)didHaveConnectionError:(NSString *)message;
- (void)didHaveCredentialError:(NSString *)message;
- (void)didHaveParsingError:(NSString *)message;
- (void)didHaveXMLConstructionError;
- (void)didHaveToolboxUnderLoadError:(NSString *)message;
- (void)didHaveGenericError:(NSString *)messageOrNil;

- (void)didUseCachedResult;

- (void)didBeginRetrieveUsage;
- (void)didFinishRetrieveUsage;
@end


@interface iiVolumeUsageProvider : NSObject <NSXMLParserDelegate> {
    id<iiVolumeUsageProviderDelegate> _delegate;
    
    NSMutableString *_currentStringValue;

    NSString *_stateTracking;
    NSString *_secondTierStateTracking;   

    iiAccountInfo *_accountInfo;
    iiVolumeUsage *_volumeUsage;
    iiConnection *_connection;

    iiTraffic *_trafficUnit;
    iiUsagePeriod *_usagePeriod;
    iiUsageUnit *_usageUnit;
    
    iiFeed *_feed;
    
    BOOL _errorFlagged;
    NSString *_error;
    
    NSString *_username;
    NSString *_password;
}

@property (nonatomic, strong) id delegate;
@property (readonly) NSString *error;

+ (iiVolumeUsageProvider *)sharedSingleton;

- (iiFeed *)retrieveUsage;
- (BOOL)setUserCredentials:(NSString *)username withPassword:(NSString *)password;
- (void)resetUserCredentials;
- (BOOL)doesHaveUserCredentials;

@end
