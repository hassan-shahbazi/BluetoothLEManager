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

#define PN_StateUpdate              @"blePeripheralManagerStateDidUpdate"
#define PN_didStartAdvertising      @"blePeripheralManagerDidStartAdvertising"
#define PN_didRestore               @"blePeripheralManagerDidRestore"
#define PN_didGetReadRequest        @"blePeripheralManagerGetReadRequest"
#define PN_didGetWriteRequest       @"blePeripheralManagerGetWriteRequest"
#define PN_didConnected             @"blePeripheralManagerDidConnected"
#define PN_didDisonnected           @"blePeripheralManagerDidDisonnected"

@interface Peripheral : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBUUID *service_UUID;
@property (nonatomic, strong) NSArray *service_characteristics;
@property (nonatomic, strong) NSString *LocalName;

/**
 Shared instance of Peripheral manager

 @return Singleton instance of Peripheral object
 */
+ (Peripheral *)instance;

/**
 Add a new service to be advertised by the peripheral

 @param primary Make the service primary or secondary
 */
- (void)AddService:(BOOL )primary;


/**
 Remove currently added service

 @param uuid The UUID of service should be removed
 */
- (void)RemoveService:(CBUUID *)uuid;

/**
 Remove all available services
 */
- (void)RemoveAllServices;

/**
 Start advertising added services
 */
- (void)StartAdvertising;

/**
 Stop advertising
 */
- (void)StopAdvertising;

/**
 Convert NSString values to suitable NSData instance which can be used as the requests' responds

 @param rawValue The raw value in NSString format
 @return Converted value in NSData suitable to responding to read/write requests
 */
- (NSData *)Value:(NSString *)rawValue;

/**
 Send responds to received read/write requests

 @param request The main request which have to be responded
 @param result The result of request
 */
- (void)SendResponse:(CBATTRequest *)request WithResult:(CBATTError )result;

/**
 Notify central on its subscribed characteristics

 @param value The value of notification
 @param characterstic UUID of notification characteristic
 */
- (void)SendNotify:(NSData *)value onCharacterstic:(CBUUID *)characterstic;

@end
