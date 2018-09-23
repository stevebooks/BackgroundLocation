#import <Foundation/Foundation.h>
#import "GPS.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

@interface GPS () <CBCentralManagerDelegate>
@end

@implementation GPS
static GPS *g_;
NSTimer *timer;
EAAccessoryManager *accessoryManager;
NSNotificationCenter *notificationCenter;

+ (GPS*)get{
    if (!g_) {
        NSLog(@"Creating instance of GPS!");
        g_ = [GPS new];
    }
    return g_;
}

- (id)init{
    if (!(self = [super init]))
        return nil;
    
    //Setup the manager
    manager_ = [[CLLocationManager alloc] init];
    if (!manager_) {
        return nil;
    }
    manager_.distanceFilter = kCLDistanceFilterNone;
    manager_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    manager_.desiredAccuracy = kCLLocationAccuracyBest;
    manager_.delegate = self;
    
    
    
    [manager_ requestAlwaysAuthorization];
    
    if ([manager_ respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        manager_.pausesLocationUpdatesAutomatically = NO;
    }
    
    if ([manager_ respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        manager_.allowsBackgroundLocationUpdates = YES;
    }
    
    [manager_ startUpdatingLocation];
    [self startTimer];
    
    notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(EAAccessoryDidConnect:)
                               name:EAAccessoryDidConnectNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                        selector:@selector(EAAccessoryDidDisconnect:)
                        name:EAAccessoryDidDisconnectNotification
                        object:nil];
    
    accessoryManager = [EAAccessoryManager sharedAccessoryManager];
    [accessoryManager registerForLocalNotifications];
    
    return self;
}

- (void)EAAccessoryDidConnect:(NSNotification *)notification{
    [self writeToFile:@"EAAccessoryDidConnect"];
    EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
    [self writeToFile: [NSString stringWithFormat:@"Serial Number: %@", accessory.serialNumber]];
    [self writeToFile: [NSString stringWithFormat:@"Manufacturer: %@", accessory.manufacturer]];
    [self writeToFile: [NSString stringWithFormat:@"Name: %@", accessory.name]];
    [self writeToFile: [NSString stringWithFormat:@"Model Number: %@", accessory.modelNumber]];
}

- (void)EAAccessoryDidDisconnect:(NSNotification *)notification{
    [self writeToFile:@"EAAccessoryDidDisconnect"];
    EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
    [self writeToFile: [NSString stringWithFormat:@"Serial Number: %@", accessory.serialNumber]];
    [self writeToFile: [NSString stringWithFormat:@"Manufacturer: %@", accessory.manufacturer]];
    [self writeToFile: [NSString stringWithFormat:@"Name: %@", accessory.name]];
    [self writeToFile: [NSString stringWithFormat:@"Model Number: %@", accessory.modelNumber]];
}

- (void)applicationDidEnterBackground{
  [self writeToFile: @"applicationDidEnterBackground"];
    //[manager_ stopMonitoringSignificantLocationChanges];
    [manager_ requestAlwaysAuthorization];
    //[manager_ startMonitoringSignificantLocationChanges];
}

- (void)start{
    NSLog(@"Start Tracking");
    [manager_ startUpdatingLocation];
}

- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(recordTimer) userInfo:nil repeats:YES];
}

- (void)recordTimer{
    [manager_ requestAlwaysAuthorization];
    [self writeToFile: @"timer"];
    [self connectedPorts];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSLog(@"%f : %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [self writeToFile: @"location Update"];
    [self connectedPorts];
//    NSArray *connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
//    for (EAAccessory *accessory in connectedAccessories) {
//        [self writeToFile: [NSString stringWithFormat:@"Serial Number: %@", accessory.serialNumber]];
//        [self writeToFile: [NSString stringWithFormat:@"Manufacturer: %@", accessory.manufacturer]];
//        [self writeToFile: [NSString stringWithFormat:@"Name: %@", accessory.name]];
//        [self writeToFile: [NSString stringWithFormat:@"Model Number: %@", accessory.modelNumber]];
//    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"locationManager - didFailWithError: %@", [error localizedDescription]);
    NSLog(@"domain:%@", [error domain]);
    [self writeToFile: @"LocationManager failed"];
}

-(void)writeToFile:(NSString *)message{
    NSLog( @"%@", message);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt",
                          documentsDirectory];
    
    // check for file exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileName]) {
        
        // the file doesn't exist,we can write out the text using the  NSString convenience method
        
        NSError *error = noErr;
        BOOL success = [@"First Log" writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!success) {
            // handle the error
            NSLog(@"%@", error);
        }
        
    } else {
        
        // the file already exists, append the text to the end
        
        // get a handle
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        
        // move to the end of the file
        [fileHandle seekToEndOfFile];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        dateString = [NSString stringWithFormat:@"%@ - %@", dateString, message];
        dateString = [NSString stringWithFormat:@"%@%@", dateString, @"\n"];
        
        // convert the string to an NSData object
        NSData *textData = [dateString dataUsingEncoding:NSUTF8StringEncoding];
        
        // write the data to the end of the file
        [fileHandle writeData:textData];
        
        // clean up
        [fileHandle closeFile];
    }
}

- (void) connectedPorts{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    //NSArray *inputsForRoute = currentRoute.inputs;
    //NSArray *outputsForRoute = currentRoute.outputs;
    //AVAudioSessionPortDescription *outPortDesc = [outputsForRoute objectAtIndex:0];
    //[self writeToFile: [NSString stringWithFormat:@"Current outport type: %@", outPortDesc.portType]];
    
    //AVAudioSessionPortDescription *inPortDesc = [inputsForRoute objectAtIndex:0];
    //[self writeToFile: [NSString stringWithFormat:@"current inPort type %@", inPortDesc.portType]];
    [self writeToFile: [NSString stringWithFormat:@"currentRoute description: %@", currentRoute.description]];
}

// Core Bluetooth Delegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self writeToFile:@"didDiscoverPeriphal"];
    [self writeToFile: [NSString stringWithFormat:@"Name: %@", peripheral.name]];
}

@end
