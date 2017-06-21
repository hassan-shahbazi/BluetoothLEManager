//
//  Manager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@protocol BLEScannerManagerDelegate <NSObject>
@optional
- (void)CentralStateChanged:(CBCentralManagerState )state;
- (void)DongleFound:(NSString *)macAddress;
- (void)DongleConnected;
- (void)DongleRecived:(NSData *)data;
- (void)ErrorOccured:(NSError *)error;
- (void)ShouldLockDevice;

@end

@interface ScannerManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *ServiceUUIDs;
@property (nonatomic, strong) CBUUID *ServiceCharacteristic;
@property (nonatomic, strong) CBUUID *ServiceNotifyCharacteristic;
@property (nonatomic, assign) BOOL RSSI_lock;
@property (nonatomic, assign) NSInteger RSSI_lockValue;
@property (nonatomic, assign) NSInteger RSSI_delay;
@property (nonatomic, assign) NSInteger RSSI_filter;
@property (nonatomic, assign) BOOL AutoConnect;
@property (nonatomic, assign) BOOL Logging;
@property (nonatomic, weak) id<BLEScannerManagerDelegate> delegate;

+ (ScannerManager *)SharedInstance;

- (void)Connect;
- (void)Disconnect;
- (void)StartScanning;
- (void)StopScanning;
- (void)ReadRSSI;
- (void)Write:(NSData *)data;

- (NSString *)GetConnectedMacAddress;

@end
