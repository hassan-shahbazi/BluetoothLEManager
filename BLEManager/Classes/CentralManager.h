//
//  Manager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#define BLE_Notification_StateUpdate    @"bleCentralManagerStateDidUpdate"
#define BLE_Notification_didFound       @"bleCentralManagerDidFound"
#define BLE_Notification_didConnect     @"bleCentralManagerDidConnect"
#define BLE_Notification_didDisconnect  @"bleCentralManagerDidDisconnect"
#define BLE_Notification_didFailed      @"bleCentralManagerDidFail"
#define BLE_Notification_PairedList     @"bleCentralManagerDidGetPaired"
#define BLE_Notification_didReadRSSI    @"bleCentralManagerDidReadRSSI"
#define BLE_Notification_didWriteData   @"bleCentralManagerDidWrireData"
#define BLE_Notification_didReadData    @"bleCentralManagerDidReadData"
#define BLE_Notification_didRestored    @"bleCentralManagerDidRestored"

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *service_UUID;
@property (nonatomic, strong) NSArray *service_characteristic;
@property (nonatomic, strong) NSArray *service_notifyCharacteristic;
@property (nonatomic, assign) NSInteger RSSI_filter;

+ (CentralManager *)instance;

- (void)connect;
- (void)connect:(CBPeripheral *)peripheral;

- (void)getPairedList;

- (void)disconnect;

- (void)scan;

- (void)stopScan;

- (void)readRSSI;

- (void)read:(CBUUID *)Characterstic;

- (void)write:(NSData *)data on:(CBUUID *)Characterstic;

- (NSString *)connectedCentralAddress;

@end
