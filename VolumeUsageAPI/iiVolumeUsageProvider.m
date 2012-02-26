//
//  iiVolumeUsageProvider.m
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 24/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "iiVolumeUsageProvider.h"


@implementation iiVolumeUsageProvider

@synthesize error       = _error;
@synthesize delegate    = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        self->_errorFlagged = NO;
        self->_error = nil;
        self->_volumeUsage = nil;
        self->_accountInfo = nil;
        self->_feed = nil;
    }
    return self;
}

+ (iiVolumeUsageProvider *)sharedSingleton {
    static iiVolumeUsageProvider *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[iiVolumeUsageProvider alloc] init];
        
        return sharedSingleton;
    }
}

- (iiFeed *)retrieveUsage {
    if ([self.delegate respondsToSelector:@selector(didBeginRetrieveUsage)])
        [self.delegate didBeginRetrieveUsage];
    
    // Check cache; return if it hasn't expired yet
    
    //TODO - Store the credentials in key chain
    
    NSURL *toolboxURL = [NSURL URLWithString:@"https://toolbox.iinet.net.au/cgi-bin/new/volume_usage_xml.cgi?action=login&username=fake&password=dddddd"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:toolboxURL];
    
    NSURLResponse *urlResponse;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error != nil) {
        if ([self.delegate respondsToSelector:@selector(didHaveConnectionError:)])
            [self.delegate didHaveConnectionError:[error localizedDescription]];
    }
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseData];
    
    if (xmlParser != nil) {
        xmlParser.delegate = self;
        BOOL parsingResult = [xmlParser parse];
        if (!parsingResult) {
            NSError *parsingError = [xmlParser parserError];
            if ([self.delegate respondsToSelector:@selector(didHaveParsingError:)])
                [self.delegate didHaveParsingError:[parsingError localizedDescription]];
        }
        else {
            if (self->_errorFlagged) {
                if ([self->_error isEqualToString:@"Authentication failure"]) 
                    [self.delegate didHaveAuthenticationError:self->_error];
            }
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didHaveXMLConstructionError)]) {
            [self.delegate didHaveXMLConstructionError];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishRetrieveUsage)]) 
        [self.delegate didFinishRetrieveUsage];
    
    self->_feed = [[iiFeed alloc] initFeedWith:self->_accountInfo volumeUsage:self->_volumeUsage connection:self->_connection];
    return self->_feed;
}

- (BOOL)setUserCredentials:(NSString *)username withPassword:(NSString *)password {
        
    return YES;
}

- (BOOL)doesHaveUserCredentials {
    return YES;
}

- (void)resetUserCredentials {
    
}


#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (self->_errorFlagged)
        return;
    
     
    if ([elementName isEqualToString:@"error"]) {
        self->_errorFlagged = YES;
        return;
    }
    
    if ([elementName isEqualToString:@"account_info"]) {
        self->_accountInfo = [[iiAccountInfo alloc] init];        
        self->_stateTracking = @"account_info";
        
        return;
    }
    
    if ([elementName isEqualToString:@"volume_usage"] && self->_volumeUsage == nil) {
        self->_volumeUsage = [[iiVolumeUsage alloc] init];
        self->_stateTracking = @"top_level_volume_usage";
        return;
    }
    
    if ([self->_stateTracking isEqualToString:@"top_level_volume_usage"]) {
        if ([elementName isEqualToString:@"quota_reset"]) {
            self->_volumeUsage.quotaReset = [[iiQuotaReset alloc] init];
            self->_secondTierStateTracking = @"quota_reset";
            
            return;
        }
        if ([elementName isEqualToString:@"expected_traffic_types"]) {
            self->_volumeUsage.expectedTrafficList = [[NSMutableArray alloc] init];
            self->_secondTierStateTracking = @"expected_traffic_types";
            
            return;
        }
        if ([elementName isEqualToString:@"volume_usage"]) {
            self->_volumeUsage.volumeUsageBreakdown = [[NSMutableArray alloc] init];
            self->_secondTierStateTracking = @"volume_usage";
        }
        
        
        
        
        if ([self->_secondTierStateTracking isEqualToString:@"expected_traffic_types"]) {
            if ([elementName isEqualToString:@"type"]) {
                self->_trafficUnit = nil;
                self->_trafficUnit = [[iiTraffic alloc] init];
                self->_trafficUnit.trafficType = [[attributeDict objectForKey:@"classification"] iiTrafficTypeFromString];
                self->_trafficUnit.used = [[attributeDict objectForKey:@"used"] integerValue];
            }
        }
        if ([self->_secondTierStateTracking isEqualToString:@"volume_usage"]) {
            if ([elementName isEqualToString:@"day_hour"]) {
                self->_usagePeriod = nil;
                self->_usagePeriod = [[iiUsagePeriod alloc] init];
                
                self->_usagePeriod.period = [attributeDict objectForKey:@"period"];
                self->_usagePeriod.usageUnitList = [[NSMutableArray alloc] init];
            }
            if ([elementName isEqualToString:@"usage"]) {                
                self->_usageUnit = nil;
                self->_usageUnit = [[iiUsageUnit alloc] init];
                
                self->_usageUnit.trafficType = [[attributeDict objectForKey:@"type"] iiTrafficTypeFromString];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self->_currentStringValue) {
        self->_currentStringValue = [[NSMutableString alloc] init];
    }
    
    [self->_currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self->_errorFlagged && ![self->_error isEqualToString:@""])
        return;
    
    if (self->_errorFlagged && [elementName isEqualToString:@"error"])
        self->_error = self->_currentStringValue;
    
    
    NSString *currentStringValue = [self->_currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self->_currentStringValue = nil;
    
    
    if ([self->_stateTracking isEqualToString:@"account_info"]) {
        if ([elementName isEqualToString:@"plan"])
            self->_accountInfo.plan = currentStringValue;
        
        if ([elementName isEqualToString:@"product"])
            self->_accountInfo.product = currentStringValue;
        
        return;
    }
    
    if ([self->_stateTracking isEqualToString:@"top_level_volume_usage"]) {
        if ([elementName isEqualToString:@"offpeak_start"])
            self->_volumeUsage.offPeakStart = currentStringValue;
        if ([elementName isEqualToString:@"offpeak_end"]) 
            self->_volumeUsage.offPeakEnd = currentStringValue;
        
        if ([self->_secondTierStateTracking isEqualToString:@"quota_reset"]) {
            if ([elementName isEqualToString:@"anniversary"])       
                self->_volumeUsage.quotaReset.anniversary = [currentStringValue  integerValue];
            
            if ([elementName isEqualToString:@"days_so_far"])
                self->_volumeUsage.quotaReset.daysSoFar = [currentStringValue integerValue];
            
            if ([elementName isEqualToString:@"days_remaining"])
                self->_volumeUsage.quotaReset.daysRemaining = [currentStringValue integerValue];
            
            if ([elementName isEqualToString:@"quota_reset"])
                self->_secondTierStateTracking = @"";
            
            return;
        }
        
        if ([self->_secondTierStateTracking isEqualToString:@"expected_traffic_types"]) {
            if ([elementName isEqualToString:@"quota_allocation"])
                self->_trafficUnit.quota = [currentStringValue integerValue];
            if ([elementName isEqualToString:@"is_shaped"])
                self->_trafficUnit.isShaped = ([currentStringValue isEqualToString:@"true"]) ? YES : NO;
            
            if ([elementName isEqualToString:@"type"])
                [self->_volumeUsage.expectedTrafficList addObject:self->_trafficUnit];
            
            if ([elementName isEqualToString:@"expected_traffic_types"]) 
                self->_secondTierStateTracking = @"";
            
            return;
        }
        
        if ([self->_secondTierStateTracking isEqualToString:@"volume_usage"]) {
            if ([elementName isEqualToString:@"usage"]) {
                self->_usageUnit.bytes = [currentStringValue integerValue];
                [self->_usagePeriod.usageUnitList addObject:self->_usageUnit];
            }
            
            if ([elementName isEqualToString:@"day_hour"]) {
                [self->_volumeUsage.volumeUsageBreakdown addObject:self->_usagePeriod];
            }
        }
        
        
        if ([self->_secondTierStateTracking isEqualToString:@""] && [elementName isEqualToString:@"volume_usage"])
            self->_stateTracking = @"";
        
        return;
    }
    
    if ([self->_stateTracking isEqualToString:elementName]) {
        self->_stateTracking = @"";
    }
}


@end
