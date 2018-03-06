//
//  Manager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#define CN_StateUpdate    @"bleCentralManagerStateDidUpdate"
#define CN_didFound       @"bleCentralManagerDidFound"
#define CN_didConnect     @"bleCentralManagerDidConnect"
#define CN_didDisconnect  @"bleCentralManagerDidDisconnect"
#define CN_didFailed      @"bleCentralManagerDidFail"
#define CN_PairedList     @"bleCentralManagerDidGetPaired"
#define CN_didReadRSSI    @"bleCentralManagerDidReadRSSI"
#define CN_didWriteData   @"bleCentralManagerDidWrireData"
#define CN_didReadData    @"bleCentralManagerDidReadData"
#define CN_didRestored    @"bleCentralManagerDidRestored"

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *service_UUID;
@property (nonatomic, strong) NSArray *service_characteristic;
@property (nonatomic, strong) NSArray *service_notifyCharacteristic;
@property (nonatomic, assign) NSInteger discovery_RSSI_filter;

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
- (void)write:(NSData *)data on:(CBUUID *)Characterstic with:(CBCharacteristicWriteType )type;

- (NSString *)connectedCentralAddress;

@end
