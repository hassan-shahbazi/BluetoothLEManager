//
//  MyCharacterstic.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 2018-02-06.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MyCharacterstic : NSObject

/**
 Characteristic's UUID
 */
@property (nonatomic, strong) CBUUID *uuid;
/**
 Characteristic's static value
 */
@property (nonatomic, strong) NSData *value;
/**
 Characteristic's descriptors
 */
@property (nonatomic, nullable, strong) NSArray<CBDescriptor *>* descriptor;
/**
 Characteristic's permissions
 */
@property (nonatomic, assign) CBAttributePermissions permission;
/**
 Characteristic's properties
 */
@property (nonatomic, assign) CBCharacteristicProperties property;

/**
 Get CBMutableCharacteristic object from built characteristic

 @return CBMutableCharacteristic instance
 */
- (CBMutableCharacteristic *)object;

@end
