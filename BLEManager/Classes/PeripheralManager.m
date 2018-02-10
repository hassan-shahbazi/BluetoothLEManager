//
//  PeripheralManager.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/25/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import "PeripheralManager.h"

@interface PeripheralManager()
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *bluetoothService;
@end

@implementation PeripheralManager

- (id)init {
    self = [super init];
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc]  initWithDelegate:self queue:nil];
    }
    return self;
}

+ (PeripheralManager *)SharedInstance {
    static PeripheralManager *singleton = nil;
    if (!singleton) {
        singleton = [PeripheralManager new];
    }
    return singleton;
}

- (void)StartAdvertising {
    _bluetoothService = [[CBMutableService alloc] initWithType:_ServiceUUID primary:YES];
    NSMutableArray *characteristics = [[NSMutableArray alloc] init];
    for (MyCharacterstic *characteristic in _ServiceCharacteristics) {
        [characteristics addObject: [characteristic GetObject]];
    }
    _bluetoothService.characteristics = characteristics;
    [_peripheralManager addService:_bluetoothService];
}

- (NSData *)PrepareValue:(NSString *)rawValue {
    if (rawValue) {
        return [[NSData alloc] initWithBase64EncodedString:[self ConvertStringToBase64:rawValue]
                                                   options: NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return nil;
}

- (NSString *)ConvertStringToBase64:(NSString *)plain {
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    return base64String;
}

- (void)PeripheralSendResponse:(CBATTRequest *)request WithResult:(CBATTError )result {
    [_peripheralManager respondToRequest:request withResult:result];
}

#pragma mark - Peripheral Manager Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [_delegate PeripheralStateChanged:peripheral.state];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error != nil) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else
        [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey: _LocalName,
                                               CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error != nil) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else
        [_delegate PeripheralStartAdvertising];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict {
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if ([_delegate respondsToSelector:@selector(PeripheralDidReceivedRead:)])
        [_delegate PeripheralDidReceivedRead:request];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    if ([_delegate respondsToSelector:@selector(PeripheralDidReceivedWrite:)])
        [_delegate PeripheralDidReceivedWrite:requests];
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    
}
@end
