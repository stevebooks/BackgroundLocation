//
//  AppDelegate.m
//  BackgroundLocation
//
//  Created by Steven Books on 12/4/14.
//  Copyright (c) 2014 Steve Books. All rights reserved.
//

#import "AppDelegate.h"
#import "GPS.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
  GPS *gps;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound
//                                                                                                              categories:nil]];
    //}
    [self prepareAudioSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myInterruptionSelector:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myRouteChangeSelector:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    gps = [GPS get];
    [gps start];
    
    ViewController * vc = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:vc animated:YES completion:NULL];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App did enter background");
    [gps applicationDidEnterBackground];
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:60];
//    notification.alertBody = @"Alert";
//    notification.repeatInterval=kCFCalendarUnitHour;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)prepareAudioSession {
    
    // deactivate session
    BOOL success = [[AVAudioSession sharedInstance] setActive:NO error: nil];
    if (!success) {
        NSLog(@"deactivationError");
    }
    
    // set audio session category AVAudioSessionCategoryPlayAndRecord options AVAudioSessionCategoryOptionAllowBluetooth
    success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    if (!success) {
        NSLog(@"setCategoryError");
    }
    
    // activate audio session
    success = [[AVAudioSession sharedInstance] setActive:YES error: nil];
    if (!success) {
        NSLog(@"activationError");
    }
    
    return success;
    
}

- (void)myRouteChangeSelector:(NSNotification*)notification {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *inputsForRoute = currentRoute.inputs;
    NSArray *outputsForRoute = currentRoute.outputs;
    AVAudioSessionPortDescription *outPortDesc = [outputsForRoute objectAtIndex:0];
    NSLog(@"current outport type %@", outPortDesc.portType);
    AVAudioSessionPortDescription *inPortDesc = [inputsForRoute objectAtIndex:0];
    NSLog(@"current inPort type %@", inPortDesc.portType);
}

- (void)myInterruptionSelector:(NSNotification*)notification {
    NSLog(@"myInterruptionSelector");
}

@end
