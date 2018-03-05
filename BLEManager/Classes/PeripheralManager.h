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

+ (Peripheral *)instance;

- (void)StartAdvertising:(BOOL )primary;
- (void)StopAdvertising;

- (NSData *)Value:(NSString *)rawValue;

- (void)SendResponse:(CBATTRequest *)request WithResult:(CBATTError )result;
- (void)SendNotify:(NSData *)value onCharacterstic:(CBUUID *)characterstic;
@end
