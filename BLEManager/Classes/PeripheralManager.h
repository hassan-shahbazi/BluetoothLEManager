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

@protocol BLEPeripheralManagerDelegate <NSObject>
@optional
- (void)PeripheralStateChanged:(CBManagerState )state;
- (void)PeripheralStartAdvertising;
- (void)Error:(NSError *)error;
- (void)PeripheralDidReceivedRead:(CBATTRequest *)request;
- (void)PeripheralDidReceivedWrite:(NSArray<CBATTRequest *> *)requests;

@end

@interface PeripheralManager : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBUUID *ServiceUUID;
@property (nonatomic, strong) NSArray *ServiceCharacteristics;
@property (nonatomic, strong) NSString *LocalName;
@property (nonatomic, weak) id<BLEPeripheralManagerDelegate> delegate;

+ (PeripheralManager *)SharedInstance;

- (void)StartAdvertising;

- (NSData *)PrepareValue:(NSString *)rawValue;

@end
