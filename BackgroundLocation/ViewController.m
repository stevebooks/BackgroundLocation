//
//  ViewController.m
//  BackgroundLocation
//
//  Created by Steven Books on 12/4/14.
//  Copyright (c) 2014 Steve Books. All rights reserved.
//

#import "ViewController.h"
#import "GPS.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GPS *gps = [GPS get];
    [gps start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
