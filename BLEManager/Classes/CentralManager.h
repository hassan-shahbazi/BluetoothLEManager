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
/**
 Central did found peripherals which are advertising the same service UUID it is searching for.

 @param macAddress Mac address of peripherals
 */
- (void)CentralDidFound:(NSString *)macAddress;

/**
 Fired when central connected to the peripheral successfully
 */
- (void)CentralDidConnected;

/**
 Fired when central discconnected to the peripheral successfully
 */
- (void)CentralDidDisconnected;

/**
 Connecting to peripheral failed with a error

 @param error Error object of connection issue
 */
- (void)CentralDidFailed:(NSError *)error;

/**
 Return a list of paired BLE devices to iOS device with the service UUID

 @param list Contain a list of peripheral objects
 */
- (void)CentralPairedList:(NSArray *)list;

/**
 Return the actual value of RSSI after connection with a peripheral

 @param rssi Number of RSSI
 */
- (void)CentralDidReadRSSI:(NSNumber *)rssi;

/**
 When central asks for reading data or when periphreral wants to notify the central

 @param data Request's data
 */
- (void)CentralDidReadData:(NSData *)data;

/**
 When central successfully write data on the connected peripehral
 */
- (void)CentralDidWriteData;

/**
 In case of restoring central object, it is called
 */
- (void)CentralDidRestored;
@end

@interface CentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 UUID of main service which central is searching for.
 */
@property (nonatomic, strong) NSArray *serviceUUID;

/**
 Characteristics which central is looking for and are available on the main service
 */
@property (nonatomic, strong) NSArray *serviceCharacteristics;

/**
 Characteristics with "Notify" property which central is looking for and are available on the main service
 */
@property (nonatomic, strong) NSArray *serviceNotifyCharacteristics;

/**
 The RSSI filter of peripheral discovery. Default value is: -50
 */
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

/**
 Connect to peripheral if there is only one peripheral available
 */
- (void)connect;

/**
 Connect to a specific peripheral if there is more than one available

 @param peripheral Peripheral object
 */
- (void)connect:(CBPeripheral *)peripheral;

/**
 Make the CentralPairedList: function to be called with a list of paired ble devices to iOS device
 */
- (void)getPairedList;

/**
 Disconnect from the connected peripheral
 */
- (void)disconnect;

/**
 Start scanning for main service UUID
 */
- (void)scan;

/**
 Stop scanning progress
 */
- (void)stopScan;

/**
 Read current value of RSSI which results in calling CentralDidReadRSSI: function
 */
- (void)readRSSI;

/**
 Read value of a specific characteristic

 @param Characterstic UUID of target characteristic
 */
- (void)read:(CBUUID *)Characterstic;

/**
 Write data on a specific characteristic

 @param data The data central wants to write
 @param Characterstic UUID of target chracteristic
 */
- (void)write:(NSData *)data on:(CBUUID *)Characterstic;

/**
 Write data on a specific characteristic with specific writing type

 @param data The data central wants to write
 @param Characterstic UUID of target chracteristic
 @param type Writing type on the characteristic
 */
- (void)write:(NSData *)data on:(CBUUID *)Characterstic with:(CBCharacteristicWriteType )type;

/**
 Get the mac address of connected peripehral

 @return Mac address of peripheral
 */
- (NSString *)connectedCentralAddress;

@end
