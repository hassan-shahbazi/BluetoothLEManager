//
//  PeripheralManager.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/25/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEPeripheralManagerDelegate <NSObject>
@optional
- (void)PeripheralStateChanged:(CBManagerState )state;
- (void)PeripheralStartAdvertising;
- (void)Error:(NSError *)error;
@end

@interface PeripheralManager : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBUUID *ServiceUUID;
@property (nonatomic, strong) NSArray *ServiceCharacteristics;
@property (nonatomic, strong) NSString *LocalName;
@property (nonatomic, weak) id<BLEPeripheralManagerDelegate> delegate;

+ (PeripheralManager *)SharedInstance;

- (void)StartAdvertising;

@end


@interface Characteristic : NSObject
@property (nonatomic, strong) NSString *Value;
@property (nonatomic, strong) CBUUID *UUID;
@property (nonatomic, assign) CBAttributePermissions Attribute;
@end
