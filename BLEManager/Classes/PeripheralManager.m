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
@property (nonatomic, strong) CBMutableService *mainService;
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) NSMutableArray *subscribedCharacterstics;
@end

@implementation Peripheral

- (id)init {
    self = [super init];
    if (self) {
        _observers = [[NSMutableDictionary alloc] init];
        _subscribedCharacterstics = [[NSMutableArray alloc] init];
        _services = [[NSMutableArray alloc] init];
        
        dispatch_queue_t queue = dispatch_queue_create("BLEManager.Peripheral", DISPATCH_QUEUE_CONCURRENT);
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue];
    }
    return self;
}

+ (Peripheral *)sharedInstance {
    static Peripheral *singleton = nil;
    if (!singleton) {
        singleton = [Peripheral new];
    }
    return singleton;
}

- (void)addObserver:(id<PeripheralManagerObserver>)observer {
    NSString *observerID = observer.debugDescription;
    if (![_observers valueForKey:observerID])
        [_observers setValue:observer forKey:observerID];
}

- (void)removeObserver:(id<PeripheralManagerObserver>)observer {
    NSString *observerID = observer.debugDescription;
    if (![_observers valueForKey:observerID])
        [_observers removeObjectForKey:observerID];
}

- (void)addService:(BOOL )primary {
    CBMutableService *Service = [[CBMutableService alloc] initWithType:_serviceUUID primary:primary];
    if (primary)
        _mainService = Service;
    
    NSMutableArray *characteristics = [[NSMutableArray alloc] init];
    for (MyCharacterstic *characteristic in _serviceCharacteristics)
        [characteristics addObject: [characteristic object]];
    Service.characteristics = characteristics;
    [_manager addService: Service];
}

- (void)removeService:(CBUUID *)uuid {
    CBMutableService *Service = [CBMutableService new];
    for (CBMutableService *service in _services)
        if ([service.UUID isEqual:uuid])
            Service = service;
    [_manager removeService:Service];
}

- (void)removeAllServices {
    [_manager removeAllServices];
}

- (void)startAdvertising {
    _mainService.includedServices = _services;
    [_manager startAdvertising:@{CBAdvertisementDataLocalNameKey: _localName,
                                 CBAdvertisementDataServiceUUIDsKey: @[_mainService.UUID]}];
}

- (void)stopAdvertising {
    [_manager stopAdvertising];
}

- (NSData *)value:(NSString *)rawValue {
    if (rawValue) {
        return [[NSData alloc] initWithBase64EncodedString:[self convertStringToBase64:rawValue] options: NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return nil;
}

- (NSString *)convertStringToBase64:(NSString *)plain {
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    return base64String;
}

- (void)sendResponse:(CBATTRequest *)request withResult:(CBATTError )result {
    [_manager respondToRequest:request withResult:result];
}

- (void)sendNotify:(NSData *)value onCharacterstic:(CBUUID *)characterstic {
    CBMutableCharacteristic *NotifyCharacterstic = nil;
    for (CBMutableCharacteristic *subscribed in _subscribedCharacterstics)
        if ([subscribed.UUID isEqual:characterstic])
            NotifyCharacterstic = subscribed;
    
    if (NotifyCharacterstic)
        [_manager updateValue:value forCharacteristic:NotifyCharacterstic onSubscribedCentrals: nil];
}

#pragma mark - Peripheral Manager Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    for (id<PeripheralManagerObserver> observer in [_observers allValues])
        [observer PeripheralStateDidUpdated: peripheral.state];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (![_services containsObject:service])
        [_services addObject:service];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    for (id<PeripheralManagerObserver> observer in [_observers allValues])
        [observer PeripheralDidStartAdvertising];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict {}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if (request)
        for (id<PeripheralManagerObserver> observer in [_observers allValues])
            [observer PeripheralDidGetRead:request];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    if (requests.count)
        for (id<PeripheralManagerObserver> observer in [_observers allValues])
            [observer PeripheralDidGetWrite:requests];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (![_subscribedCharacterstics containsObject:characteristic])
        [_subscribedCharacterstics addObject:(CBMutableCharacteristic *)characteristic];
    
    for (id<PeripheralManagerObserver> observer in [_observers allValues])
        [observer PeripheralDidConnect:central toCharacteristic:characteristic];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if ([_subscribedCharacterstics containsObject:characteristic])
        [_subscribedCharacterstics removeObject:(CBMutableCharacteristic *)characteristic];
    
    for (id<PeripheralManagerObserver> observer in [_observers allValues])
        [observer PeripheralDidDisonnect:central fromCharacteristic:characteristic];
}
@end
