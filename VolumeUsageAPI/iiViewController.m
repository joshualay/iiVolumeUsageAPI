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

@implementation iiViewController

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
    [volumeUsageProvider retrieveUsage];
    
    iiVolumeUsage *volumeUsage = volumeUsageProvider.volumeUsage;
    
    NSMutableString *textString = [[NSMutableString alloc] init];
    for (iiUsagePeriod *period in volumeUsage.volumeUsageBreakdown) {
        [textString appendString:period.period];
        for (iiUsageUnit *unit in period.usageUnitList) {
            [textString appendString:[NSString stringWithFormat:@" : %02f", [unit getMegaBytes]]];
        }
    }
    
    self->_label.textAlignment = UITextAlignmentCenter;
    self->_label.numberOfLines = 0;
    self->_label.text = textString;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
