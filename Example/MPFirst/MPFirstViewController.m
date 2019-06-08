//
//  MPFirstViewController.m
//  MPFirst
//
//  Created by mohakparmar on 06/08/2019.
//  Copyright (c) 2019 mohakparmar. All rights reserved.
//

#import "MPFirstViewController.h"
#import <MPFirst/MPLocationManager.h>

@interface MPFirstViewController ()

@end

@implementation MPFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[MPLocationManager sharedInstance] StartUpdatingLocation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
