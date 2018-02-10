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

@property (nonatomic, strong) CBUUID *UUID;
@property (nonatomic, strong) NSString *Value;
@property (nonatomic, assign) CBAttributePermissions Permission;
@property (nonatomic, assign) CBCharacteristicProperties Property;

- (CBMutableCharacteristic *)GetObject;

@end
