//
//  Manager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@protocol CentralManagerObserver <NSObject>
@required
/**
 Any changes in the device's bluetooth state make this function to be fired
 
 @param state New state of device's bluetooth
 */
- (void)CentralStateDidUpdated:(CBManagerState )state;

@optional
- (void)CentralDidFound:(NSString *)macAddress;

- (void)CentralDidConnected;

- (void)CentralDidDisconnected;

- (void)CentralDidFailed:(NSError *)error;

- (void)CentralPairedList:(NSArray *)list;

- (void)CentralDidReadRSSI:(NSNumber *)rssi;

- (void)CentralDidReadData:(NSData *)data;

- (void)CentralDidWriteData;

- (void)CentralDidRestored;
@end

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSArray *serviceUUID;

@property (nonatomic, strong) NSArray *serviceCharacteristics;

@property (nonatomic, strong) NSArray *serviceNotifyCharacteristics;

@property (nonatomic, assign) NSInteger discoveryRSSI;

/**
 An array of registered observers which will be notified once above functions happen
 */
@property (nonatomic, strong) NSMutableDictionary *observers;

+ (CentralManager *)instance;

/**
 Add observer for any central on peripheral object
 
 @param observer The class which has implemented CentralManagerObserver protocol
 */
- (void)addObserver:(id<CentralManagerObserver>)observer;

/**
 Remove observers' of central changes
 
 @param observer The class which has implemented CentralManagerObserver protocol
 */
- (void)removeObserver:(id<CentralManagerObserver>)observer;

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
