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

- (CBMutableCharacteristic *)GetObject {
    return [[CBMutableCharacteristic alloc] initWithType:_UUID properties:_Property value: _Value permissions:_Permission];
}

@end
