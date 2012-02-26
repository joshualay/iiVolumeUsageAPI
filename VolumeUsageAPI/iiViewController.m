//
//  iiViewController.m
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 21/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "iiViewController.h"

#import "iiVolumeUsageProvider.h"
#import "iiUsagePeriod.h"
#import "iiUsageUnit.h"
#import "iiFeed.h"

@implementation iiViewController

@synthesize label, button, usernameTextField, passwordTextField;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    iiVolumeUsageProvider *volumeUsageProvider = [[iiVolumeUsageProvider alloc] init];
    iiFeed *feed = [volumeUsageProvider retrieveUsage];
    
    iiVolumeUsage *volumeUsage = feed.volumeUsage;
    
    NSMutableString *textString = [[NSMutableString alloc] init];
    for (iiUsagePeriod *period in volumeUsage.volumeUsageBreakdown) {
        [textString appendString:period.period];
        for (iiUsageUnit *unit in period.usageUnitList) {
            [textString appendString:[NSString stringWithFormat:@" : %02f", [unit getMegaBytes]]];
        }
    }
    
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.text = textString;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - iiVolumeUsageProviderDelegate 
- (void)didHaveAuthenticationError:(NSString *)message {
    
}

@end
