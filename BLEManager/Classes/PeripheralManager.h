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


@protocol PeripheralManagerObserver <NSObject>
@required
- (void)PeripheralStateDidUpdated:(CBManagerState )state;

@optional
- (void)PeripheralDidStartAdvertising;

- (void)PeripheralDidConnect:(CBCentral *)central toCharacteristic:(CBCharacteristic *)characteristic;

- (void)PeripheralDidDisonnect:(CBCentral *)central fromCharacteristic:(CBCharacteristic *)characteristic;

- (void)PeripheralDidGetRead:(CBATTRequest *)request;

- (void)PeripheralDidGetWrite:(CBATTRequest *)requests;

- (void)PeripheralDidRestored;
@end

#define PN_StateUpdate              @"blePeripheralManagerStateDidUpdate"
#define PN_didStartAdvertising      @"blePeripheralManagerDidStartAdvertising"
#define PN_didRestore               @"blePeripheralManagerDidRestore"
#define PN_didGetReadRequest        @"blePeripheralManagerGetReadRequest"
#define PN_didGetWriteRequest       @"blePeripheralManagerGetWriteRequest"
#define PN_didConnected             @"blePeripheralManagerDidConnected"
#define PN_didDisonnected           @"blePeripheralManagerDidDisonnected"


@interface Peripheral : NSObject <CBPeripheralManagerDelegate>


@property (nonatomic, assign) NSDictionary *observers;
/**
 UUID of main service
 */
@property (nonatomic, strong) CBUUID *serviceUUID;
/**
 Characteristics available on the main service
 */
@property (nonatomic, strong) NSArray *serviceCharacteristics;
/**
 Advertisement local name
 */
@property (nonatomic, strong) NSString *localName;

/**
 Shared instance of Peripheral manager

 @return Singleton instance of Peripheral object
 */
+ (Peripheral *)sharedInstance;

- (void)addObserver:(id<PeripheralManagerObserver>)observer;

- (void)removeObserver:(id<PeripheralManagerObserver>)observer;

/**
 Add a new service to be advertised by the peripheral

 @param primary Make the service primary or secondary
 */
- (void)addService:(BOOL )primary;


/**
 Remove currently added service

 @param uuid The UUID of service should be removed
 */
- (void)removeService:(CBUUID *)uuid;

/**
 Remove all available services
 */
- (void)removeAllServices;

/**
 Start advertising added services
 */
- (void)startAdvertising;

/**
 Stop advertising
 */
- (void)stopAdvertising;

/**
 Convert NSString values to suitable NSData instance which can be used as the requests' responds

 @param rawValue The raw value in NSString format
 @return Converted value in NSData suitable to responding to read/write requests
 */
- (NSData *)value:(NSString *)rawValue;

/**
 Send responds to received read/write requests

 @param request The main request which have to be responded
 @param result The result of request
 */
- (void)sendResponse:(CBATTRequest *)request withResult:(CBATTError )result;

/**
 Notify central on its subscribed characteristics

 @param value The value of notification
 @param characterstic UUID of notification characteristic
 */
- (void)sendNotify:(NSData *)value onCharacterstic:(CBUUID *)characterstic;

@end
