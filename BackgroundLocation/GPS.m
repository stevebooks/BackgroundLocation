#import <Foundation/Foundation.h>
#import "GPS.h"

@implementation GPS
static GPS *g_;
NSTimer *timer;

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
    [self startTimer];
    
    return self;
}

- (void)applicationDidEnterBackground{
  [self writeToFile: @"applicationDidEnterBackground"];
}

- (void)start{
    NSLog(@"Start Tracking");
    [manager_ startUpdatingLocation];
}

- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(recordTimer) userInfo:nil repeats:YES];
}

- (void)recordTimer{
    [manager_ requestAlwaysAuthorization];
    [self writeToFile: @"timer"];
    //[[UIApplication sharedApplication] backgroundTimeRemaining];
    //[manager_ stopUpdatingLocation];
    //[manager_ startUpdatingLocation];
    
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSLog(@"%f : %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [self writeToFile: @"location Update"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"locationManager - didFailWithError: %@", [error localizedDescription]);
    NSLog(@"domain:%@", [error domain]);
    //NSLog(@"code:%i", [error code]);
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

@end
