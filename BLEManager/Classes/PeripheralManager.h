//
//  PeripheralManager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/25/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MyCharacterstic.h"

#define Peripheral_Notification_StateUpdate    @"blePeripheralManagerStateDidUpdate"
#define Peripheral_Notification_didStartAdvertising    @"blePeripheralManagerDidStartAdvertising"
#define Peripheral_Notification_didRestore    @"blePeripheralManagerDidRestore"
#define Peripheral_Notification_getReadRequest    @"blePeripheralManagerGetReadRequest"
#define Peripheral_Notification_getWriteRequest    @"blePeripheralManagerGetWriteRequest"
#define Peripheral_Notification_didConnected    @"blePeripheralManagerDidConnected"
#define Peripheral_Notification_didDisonnected    @"blePeripheralManagerDidDisonnected"

@interface PeripheralManager : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBUUID *service_UUID;
@property (nonatomic, strong) NSArray *service_characteristics;
@property (nonatomic, strong) NSString *LocalName;

+ (PeripheralManager *)instance;

- (void)StartAdvertising;
- (void)StopAdvertising;

- (NSData *)PrepareValue:(NSString *)rawValue;

- (void)PeripheralSendResponse:(CBATTRequest *)request WithResult:(CBATTError )result;
- (void)PeripheralNotify:(NSData *)value on:(NSArray *)centrals for:(CBMutableCharacteristic *)characterstic;
@end
