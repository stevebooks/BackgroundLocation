//
//  ViewController.h
//  BackgroundLocation
//
//  Created by Steven Books on 12/4/14.
//  Copyright (c) 2014 Steve Books. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

-(void)connectToDeviceButtonClicked:(UIButton *)button;
-(void)devicesConnectedButtonClicked: (UIButton *)button;

- (void) centralManagerDidUpdateState:(CBCentralManager *)central;
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;
- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;

@end

