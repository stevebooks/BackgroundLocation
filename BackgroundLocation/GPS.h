#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>


@interface GPS : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *manager_;
}

+ (GPS*)get;
- (id)init;
- (void)start;
- (void)applicationDidEnterBackground;
@end
