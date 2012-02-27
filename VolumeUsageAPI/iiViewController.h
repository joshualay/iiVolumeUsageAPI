//
//  iiViewController.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 21/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iiVolumeUsageProvider.h"

@interface iiViewController : UIViewController <iiVolumeUsageProviderDelegate>

@property (nonatomic, strong) IBOutlet UILabel *connectionLabel;
@property (nonatomic, strong) IBOutlet UILabel *accountLabel;
@property (nonatomic, strong) IBOutlet UILabel *trafficLabel;

@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *button;

- (IBAction)getVolumeUsage:(id)sender;

@end
