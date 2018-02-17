//
//  Manager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@protocol BLECentralManagerDelegate <NSObject>
@optional
- (void)BLECentralManagerStateDidUpdate:(CBManagerState )state isRestored:(BOOL )restored;
- (void)BLECentralManagerDidFind:(NSString *)macAddress;
- (void)BLECentralManagerDidGetPaired:(NSArray *)list;
- (void)BLECentralManagerDidConnect;
- (void)BLECentralManagerDidDisconnect;
- (void)BLECentralManagerDidRecieve:(NSData *)data;
- (void)BLECentralManagerDidFailToPair;
- (void)BLECentralManagerDidFail:(NSString *)error;
- (void)BLECentralManagerShouldLockDevice;
- (void)BLECentralManagerDidReadRSSI:(NSInteger )RSSI;
- (void)BLECentralManagerDidTransferData;
@end

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *service_UUID;
@property (nonatomic, strong) NSArray *service_characteristic;
@property (nonatomic, strong) NSArray *service_notifyCharacteristic;
@property (nonatomic, assign) NSInteger RSSI_filter;
@property (nonatomic, weak) id<BLECentralManagerDelegate> delegate;

+ (CentralManager *)instance;

- (void)connect;

- (void)getPairedList;

- (void)disconnect;

- (void)scan;

- (void)stopScan;

- (void)readRSSI;

- (void)read:(CBUUID *)Characterstic;

- (void)write:(NSData *)data on:(CBUUID *)Characterstic;

- (NSString *)connectedCentralAddress;

@end
