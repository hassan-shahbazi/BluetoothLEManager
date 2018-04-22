//
//  MyCharacterstic.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 2018-02-06.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

#import "MyCharacterstic.h"
#import "PeripheralManager.h"

@interface MyCharacterstic()

@end

@implementation MyCharacterstic

- (CBMutableCharacteristic *)object {
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:_uuid properties:_property value: _value permissions:_permission];
    characteristic.descriptors = _descriptor;
    return characteristic;
}

@end
