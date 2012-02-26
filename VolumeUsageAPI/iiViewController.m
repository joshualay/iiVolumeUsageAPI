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

- (IBAction)getVolumeUsage:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    iiVolumeUsageProvider *volumeUsageProvider = [iiVolumeUsageProvider sharedSingleton];
    volumeUsageProvider.delegate = self;
    
    iiFeed *feed = [volumeUsageProvider retrieveUsage];
    
    iiConnection *connection = feed.connection;
    iiIpAddress *ipAddress = [connection.ipList lastObject];
    
    NSString *textString = [NSString stringWithFormat:@"%@, %@", ipAddress.connectedSinceDate, ipAddress.ipAddress];
    
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.text = textString;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.passwordTextField.secureTextEntry = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - iiVolumeUsageProviderDelegate 
- (void)didHaveAuthenticationError:(NSString *)message {
    
}

- (NSString *)accountUsername {
    return self.usernameTextField.text;
}

- (NSString *)accountPassword {
    return self.passwordTextField.text;
}

@end
