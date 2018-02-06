//
//  MyCharacterstic.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 2018-02-06.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

#import "MyCharacterstic.h"

@interface MyCharacterstic()

@end

@implementation MyCharacterstic

- (CBMutableCharacteristic *)GetObject {
    CBUUID *UUID = [CBUUID UUIDWithString: _UUID];
    NSData *Value = nil;
    if (_Value != NULL) {
        Value = [[NSData alloc] initWithBase64EncodedString:[self ConvertStringToBase64:_Value] options: NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return [[CBMutableCharacteristic alloc] initWithType:UUID properties:_Property value:Value permissions:_Permission];
}

- (NSString *)ConvertStringToBase64:(NSString *)plain {
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    return base64String;
}

@end
