//
//  iiViewController.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 21/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iiVolumeUsageProvider.h"

@interface iiViewController : UIViewController <iiVolumeUsageProviderDelegate> {    
    IBOutlet UILabel *_label;
}

@end
