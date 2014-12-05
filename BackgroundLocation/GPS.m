#import <Foundation/Foundation.h>
#import "GPS.h"

@implementation GPS
static GPS *g_;

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
    if ([manager_ respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        manager_.pausesLocationUpdatesAutomatically = NO;
    }
    [manager_ requestAlwaysAuthorization];
    [manager_ startUpdatingLocation];
    
    return self;
}

- (void)start{
    NSLog(@"Start Tracking");
    [manager_ startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    NSLog(@"Location updated: %@", newLocation);
    [self writeToFile];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"locationManager - didFailWithError: %@", [error localizedDescription]);
    NSLog(@"domain:%@", [error domain]);
    NSLog(@"code:%i", [error code]);
    [self writeToFile];
}

-(void)writeToFile{
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
        BOOL success = [@"log" writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
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
        
        // convert the string to an NSData object
        NSData *textData = [@"append" dataUsingEncoding:NSUTF8StringEncoding];
        
        // write the data to the end of the file
        [fileHandle writeData:textData];
        
        // clean up
        [fileHandle closeFile];
    }
}

@end