VolumeUsageAPI
==============

>This is in no way supported by iiNet. This is code that has been written by me, for me that I'm sharing. iiNet will not support this code or is responsible for it.

### Joshua Lay <me@joshualay.net>

## About

I wanted to attempt XML Parsing with the native libraries and create an object model to use rather than relying on key references in a dictionary. The end result is an iiFeed object that represents the structure of the XML response but is far easier to work with. 

## Usage

### Files to include in your project

* Constants/*
* Models/*
* iiVolumeUsageProvider.h
* iiVolumeUsageProvider.m

### iiVolumeUsageProviderDelegate

In order to iiVolumeUsageProvider to work you must implement this protocol. There are required methods that you must implement in order for it to fetch usage data.

### Example
    @interface iiViewController : UIViewController <iiVolumeUsageProviderDelegate>
    @end
    
    ------------------------------------------------------------------------------------
    
    #import "iiViewController.h"

    #import "iiVolumeUsageProvider.h"
    #import "iiUsagePeriod.h"
    #import "iiUsageUnit.h"
    #import "iiFeed.h"

    @implementation iiViewController

    - (void)viewDidLoad {
        iiVolumeUsageProvider *volumeUsageProvider = [iiVolumeUsageProvider sharedSingleton];
        volumeUsageProvider.delegate = self;
    
        iiFeed *feed = [volumeUsageProvider retrieveUsage];
        
        // Use the data
    }
    
    #pragma mark - iiVolumeUsageProviderDelegate
    - (void)didHaveAuthenticationError:(NSString *)message {
        //
    }
     
    
    - (NSString *)accountUsername {
        // Fetch your username from Keychain, a UITextInput, etc.
    }
    
    - (NSString *)accountPassword {
        //
    }
    
    
    @end

## Legal

The MIT License (MIT)

Copyright (c) 2012 Joshua Lay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.