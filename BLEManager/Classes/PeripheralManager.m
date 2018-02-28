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

+ (PeripheralManager *)instance {
    static PeripheralManager *singleton = nil;
    if (!singleton) {
        singleton = [PeripheralManager new];
    }
    return singleton;
}

- (void)StartAdvertising {
    _bluetoothService = [[CBMutableService alloc] initWithType:_service_UUID primary:YES];
    NSMutableArray *characteristics = [[NSMutableArray alloc] init];
    for (MyCharacterstic *characteristic in _service_characteristics) {
        [characteristics addObject: [characteristic GetObject]];
    }
    _bluetoothService.characteristics = characteristics;
    [_peripheralManager addService:_bluetoothService];
}

- (void)StopAdvertising {
    [_peripheralManager stopAdvertising];
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
- (void)PeripheralNotify:(NSData *)value on:(NSArray *)centrals for:(CBMutableCharacteristic *)characterstic {
    [_peripheralManager updateValue: value
                  forCharacteristic: characterstic
               onSubscribedCentrals: centrals];
}

#pragma mark - Peripheral Manager Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithInt:peripheral.state] forKey:@"State"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_StateUpdate object:nil userInfo:userInfo];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey: _LocalName,
                                           CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
        
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_didStartAdvertising object:nil];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict {}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if (request) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:request forKey:@"Request"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_getReadRequest object:nil userInfo:userInfo];
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    if (requests.count) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:requests forKey:@"Requests"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_getWriteRequest object:nil userInfo:userInfo];
    }
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:central forKey:@"Central"];
    [userInfo setObject:characteristic forKey:@"Characteristic"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_didConnected object:nil userInfo:userInfo];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:central forKey:@"Central"];
    [userInfo setObject:characteristic forKey:@"Characteristic"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Peripheral_Notification_didDisonnected object:nil userInfo:userInfo];
}
@end
