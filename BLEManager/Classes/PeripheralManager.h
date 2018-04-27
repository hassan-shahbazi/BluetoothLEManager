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
/**
 Any changes in the device's bluetooth state make this function to be fired

 @param state New state of device's bluetooth
 */
- (void)PeripheralStateDidUpdated:(CBManagerState )state;

@optional
/**
 This function will be fired if the advertisement starts successfully
 */
- (void)PeripheralDidStartAdvertising;

/**
 Once one Central start to subscribe on one the available characteristics

 @param central The central which did subscription
 @param characteristic The characteristic which have been subscribed
 */
- (void)PeripheralDidConnect:(CBCentral *)central toCharacteristic:(CBCharacteristic *)characteristic;

/**
 Once one Central unsubscribe the characteristics

 @param central The central which did unsubscription
 @param characteristic The characteristic which have been unsubscribed
 */
- (void)PeripheralDidDisonnect:(CBCentral *)central fromCharacteristic:(CBCharacteristic *)characteristic;

/**
 Read request from a Central on one characteristic

 @param request The read request
 */
- (void)PeripheralDidGetRead:(CBATTRequest *)request;

/**
 Write request from a Central on one characteristic

 @param requests The write request
 */
- (void)PeripheralDidGetWrite:(NSArray<CBATTRequest *>*)requests;

/**
 In case of restoring peripheral object, it is called
 */
- (void)PeripheralDidRestored;
@end

@interface Peripheral : NSObject <CBPeripheralManagerDelegate>


/**
 An array of registered observers which will be notified once above functions happen
 */
@property (nonatomic, strong) NSMutableDictionary *observers;

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

/**
 Add observer for any changes on peripheral object

 @param observer The class which has implemented PeripheralManagerObserver protocol
 */
- (void)addObserver:(id<PeripheralManagerObserver>)observer;

/**
 Remove observers' of peripheral changes

 @param observer The class which has implemented PeripheralManagerObserver protocol
 */
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
