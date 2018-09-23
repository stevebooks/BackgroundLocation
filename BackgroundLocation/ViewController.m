//
//  ViewController.m
//  BackgroundLocation
//
//  Created by Steven Books on 12/4/14.
//  Copyright (c) 2014 Steve Books. All rights reserved.
//

#import "ViewController.h"
#import "GPS.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <CBCentralManagerDelegate>
@end

@implementation ViewController

CBCentralManager *centralManager;

- (void)viewDidLoad {
    NSLog(@"view did load!");
    [super viewDidLoad];
    
    // Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(devicesConnectedButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Scan for connected devices" forState:UIControlStateNormal];
    button.frame = CGRectMake(60.0, 100.0, 250.0, 40.0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor: UIColor.redColor];
    [self.view addSubview:button];
    
    // Button
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(connectToDeviceButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Connect Device" forState:UIControlStateNormal];
    button.frame = CGRectMake(60.0, 200.0, 160.0, 40.0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor: UIColor.redColor];
    [self.view addSubview:button];
    
    // Button
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(scanForBLE:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"BLE Scan" forState:UIControlStateNormal];
    button.frame = CGRectMake(60.0, 300.0, 160.0, 40.0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor: UIColor.redColor];
    [self.view addSubview:button];
    
    // Button
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(connectedPorts:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Connected Ports" forState:UIControlStateNormal];
    button.frame = CGRectMake(60.0, 400.0, 160.0, 40.0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor: UIColor.redColor];
    [self.view addSubview:button];
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

-(void)connectToDeviceButtonClicked:(UIButton *)button {
    NSLog(@"connectToDeviceButtonClicked");
    [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:nil];
}

- (void)devicesConnectedButtonClicked:(UIButton *)button {
    NSLog(@"devicesConnectedButtonClicked");
    NSArray *connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    for (EAAccessory *accessory in connectedAccessories) {
        NSLog(@"Serial Number: %@", accessory.serialNumber);
       // [self writeToFile: [NSString stringWithFormat:@"Manufacturer: %@", accessory.manufacturer]];
       // [self writeToFile: [NSString stringWithFormat:@"Name: %@", accessory.name]];
       // [self writeToFile: [NSString stringWithFormat:@"Model Number: %@", accessory.modelNumber]];
    }
}

- (void)scanForBLE :(UIButton *)button{
    NSLog(@"scanForBLE");
    
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    //[centralManager retrieveConnectedPeripheralsWithServices:<#(nonnull NSArray<CBUUID *> *)#>]
}

- (void) connectedPorts: (UIButton *)button{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *inputsForRoute = currentRoute.inputs;
    NSArray *outputsForRoute = currentRoute.outputs;
    AVAudioSessionPortDescription *outPortDesc = [outputsForRoute objectAtIndex:0];
    NSLog(@"current outport type %@", outPortDesc.portType);
    AVAudioSessionPortDescription *inPortDesc = [inputsForRoute objectAtIndex:0];
    NSLog(@"current inPort type %@", inPortDesc.portType);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// CBCentralManagerDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            [centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"didDiscoverPeripheral");
    //CBPeripheral* currentPer = peripheral;
    //NSLog(@"description: %@", advertisementData.description);
    //NSLog(@"name: %@", peripheral.name);
    //[centralManager connectPeripheral:peripheral options:nil];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
    NSLog(@"name: %@", peripheral.name);
}



@end
