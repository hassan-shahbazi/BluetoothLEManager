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
- (void)CentralStateChanged:(CBManagerState )state;
- (void)CentralDidFound:(NSString *)macAddress;
- (void)PairedCentral:(NSArray *)pairedList;
- (void)CentralDidConnected;
- (void)CentralDidDisconnected;
- (void)CentralDidRecived:(NSData *)data;
- (void)CentralPairingFailed;
- (void)Error:(NSError *)error;
- (void)ShouldLockDevice;
- (void)CentralDidReadRSSI:(NSInteger )RSSI;
- (void)CentralDataDidTransfered;
@end

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *ServiceUUIDs;
@property (nonatomic, strong) CBUUID *ServiceCharacteristic;
@property (nonatomic, strong) CBUUID *ServiceNotifyCharacteristic;
@property (nonatomic, assign) BOOL RSSI_lock;
@property (nonatomic, assign) NSInteger RSSI_lockValue;
@property (nonatomic, assign) NSInteger RSSI_delay;
@property (nonatomic, assign) NSInteger RSSI_filter;
@property (nonatomic, strong) NSMutableArray *AutoConnectDongles;
@property (nonatomic, assign) BOOL Logging;
@property (nonatomic, weak) id<BLECentralManagerDelegate> delegate;

+ (CentralManager *)SharedInstance;

- (void)Connect;

- (void)GetPairedList;

- (void)Disconnect;

- (void)StartScanning;

- (void)StopScanning;

- (void)ReadRSSI;

- (void)TestPairing;

- (void)Read:(CBCharacteristic *)Characterstic;

- (void)Write:(NSData *)data;

- (NSString *)GetConnectedMacAddress;

@end
