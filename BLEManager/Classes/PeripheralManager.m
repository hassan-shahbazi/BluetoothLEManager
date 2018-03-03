//
//  PeripheralManager.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/25/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import "PeripheralManager.h"

@interface Peripheral()
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, strong) NSMutableArray *subscribedCharacterstics;
@end

@implementation Peripheral

- (id)init {
    self = [super init];
    if (self) {
        _subscribedCharacterstics = [[NSMutableArray alloc] init];
        dispatch_queue_t queue = dispatch_queue_create("BLEManager.Peripheral", DISPATCH_QUEUE_CONCURRENT);
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue];
    }
    return self;
}

+ (Peripheral *)instance {
    static Peripheral *singleton = nil;
    if (!singleton) {
        singleton = [Peripheral new];
    }
    return singleton;
}

- (void)StartAdvertising {
    CBMutableService *bluetoothService = [[CBMutableService alloc] initWithType:_service_UUID primary:YES];
    NSMutableArray *characteristics = [[NSMutableArray alloc] init];
    for (MyCharacterstic *characteristic in _service_characteristics)
        [characteristics addObject: [characteristic GetObject]];
    bluetoothService.characteristics = characteristics;
    [_manager addService:bluetoothService];
}

- (void)StopAdvertising {
    [_manager stopAdvertising];
}

- (NSData *)Value:(NSString *)rawValue {
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

- (void)SendResponse:(CBATTRequest *)request WithResult:(CBATTError )result {
    [_manager respondToRequest:request withResult:result];
}
- (void)SendNotify:(NSData *)value onCharacterstic:(CBUUID *)characterstic {
    CBMutableCharacteristic *NotifyCharacterstic = nil;
    for (CBMutableCharacteristic *subscribed in _subscribedCharacterstics)
        if ([subscribed.UUID isEqual: characterstic])
            NotifyCharacterstic = subscribed;
    
    if (NotifyCharacterstic)
        [_manager updateValue: value
                      forCharacteristic: NotifyCharacterstic
                   onSubscribedCentrals: nil];
}

#pragma mark - Peripheral Manager Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithInt:peripheral.state] forKey:@"State"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PN_StateUpdate object:nil userInfo:userInfo];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [_manager startAdvertising:@{CBAdvertisementDataLocalNameKey: _LocalName,
                                 CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
        
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:PN_didStartAdvertising object:nil];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict {}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if (request) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:request forKey:@"Request"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PN_didGetReadRequest object:nil userInfo:userInfo];
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    if (requests.count) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:requests forKey:@"Requests"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PN_didGetWriteRequest object:nil userInfo:userInfo];
    }
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (![_subscribedCharacterstics containsObject:characteristic])
        [_subscribedCharacterstics addObject:(CBMutableCharacteristic *)characteristic];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:central forKey:@"Central"];
    [userInfo setObject:characteristic forKey:@"Characteristic"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PN_didConnected object:nil userInfo:userInfo];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if ([_subscribedCharacterstics containsObject:characteristic])
        [_subscribedCharacterstics removeObject:(CBMutableCharacteristic *)characteristic];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:central forKey:@"Central"];
    [userInfo setObject:characteristic forKey:@"Characteristic"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PN_didDisonnected object:nil userInfo:userInfo];
}
@end
