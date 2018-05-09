//
//  Manager.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import "CentralManager.h"

#define VANCOSYS_KEY    [[NSBundle mainBundle] bundleIdentifier]

@interface CentralManager()
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *periperal;
@property (nonatomic, strong) NSMutableArray *discoveredCharacterstics;
@end

@implementation CentralManager

- (id)init {
    self = [super init];
    if (self) {
        _discoveryRSSI = -50;
        _discoveredCharacterstics = [NSMutableArray new];
        _observers = [[NSMutableDictionary alloc] init];
        
        dispatch_queue_t queue = dispatch_queue_create("BLEManager.Central", DISPATCH_QUEUE_CONCURRENT);
        _manager = [[CBCentralManager alloc]
                    initWithDelegate:self queue: queue
                    options: @{CBCentralManagerOptionRestoreIdentifierKey: VANCOSYS_KEY,
                               CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
    
}

+ (CentralManager *)sharedInstance {
    static CentralManager *singleton = nil;
    if (!singleton) {
        singleton = [CentralManager new];
    }
    return singleton;
}

- (void)addObserver:(id<CentralManagerObserver>)observer {
    NSString *observerID = observer.debugDescription;
    if (![_observers valueForKey:observerID])
        [_observers setValue:observer forKey:observerID];
}

- (void)removeObserver:(id<CentralManagerObserver>)observer {
    NSString *observerID = observer.debugDescription;
    if (![_observers valueForKey:observerID])
        [_observers removeObjectForKey:observerID];
}

- (void)connect {
    if (_periperal) {
        _periperal.delegate = self;
        [_manager connectPeripheral:_periperal options:nil];
    }
}
- (void)connect:(CBPeripheral *)peripheral {
    _periperal = peripheral;
    [self connect];
}

- (void)getPairedList {
    NSArray *pairedPeriperhals = [_manager retrieveConnectedPeripheralsWithServices:_serviceUUID];
    [self centralManager:_manager didDiscoverPairedPeripherals: pairedPeriperhals];
}

- (void)disconnect {
    if (_periperal)
        [_manager cancelPeripheralConnection:_periperal];
}

- (void)scan {
    [self disconnect];
    [self stopScan];
    [_manager scanForPeripheralsWithServices:_serviceUUID options:nil];
}

- (void)stopScan {
    [_manager stopScan];
}

- (void)readRSSI {
    [_periperal readRSSI];
}

- (void)read:(CBUUID *)Characterstic {
    for (CBCharacteristic *characterstic in _discoveredCharacterstics)
        if ([characterstic.UUID.UUIDString isEqualToString: Characterstic.UUIDString])
            [_periperal readValueForCharacteristic: characterstic];
}

- (void)write:(NSData *)data on:(CBUUID *)Characterstic {
    [self write:data on:Characterstic with:CBCharacteristicWriteWithResponse];
}
- (void)write:(NSData *)data on:(CBUUID *)Characterstic with:(CBCharacteristicWriteType )type {
    for (CBCharacteristic *characterstic in _discoveredCharacterstics)
        if ([characterstic.UUID.UUIDString isEqualToString: Characterstic.UUIDString])
            [_periperal writeValue: data
                 forCharacteristic: characterstic
                              type: type];
}

- (NSString *)connectedCentralAddress {
    return _periperal.identifier.UUIDString;
}

#pragma mark - Cache Connected Peripheral
- (void)Save:(NSString *)peripheralMac {
    [[NSUserDefaults standardUserDefaults] setValue:peripheralMac forKey:VANCOSYS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)GetPeripheralMac {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VANCOSYS_KEY];
}
- (void)RemoveSavedPeripheralMac {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VANCOSYS_KEY];
}

#pragma mark - Central Manager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralStateDidUpdated: central.state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    _manager = central;
    _periperal = peripheral;
    _periperal.delegate = self;
    
    if (RSSI.integerValue > _discoveryRSSI && RSSI.integerValue < 0) {
        for (id<CentralManagerObserver> observer in [_observers allValues])
            [observer CentralDidFound:peripheral.identifier.UUIDString];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self Save: peripheral.identifier.UUIDString];
    [central stopScan];
    
    [_periperal discoverServices: _serviceUUID];
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralDidConnected];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralDidFailed:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self RemoveSavedPeripheralMac];
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralDidDisconnected];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSArray *restoredPeripherals = [dict valueForKey: CBCentralManagerRestoredStatePeripheralsKey];
    if (restoredPeripherals)
        for (CBPeripheral *peripheral in restoredPeripherals)
            if ([peripheral.identifier.UUIDString isEqualToString:[self GetPeripheralMac]]) {
                _manager = central;
                _periperal = peripheral;
                _periperal.delegate = self;
                for (id<CentralManagerObserver> observer in [_observers allValues])
                    [observer CentralDidRestored];
            }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPairedPeripherals:(NSArray *)peripherals {
    _manager = central;
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralPairedList:peripherals];
}

#pragma mark - Peripheral Delegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([_serviceUUID containsObject: service.UUID]) {
            [peripheral discoverCharacteristics:_serviceCharacteristics forService:service];
            [peripheral discoverCharacteristics:_serviceNotifyCharacteristics forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralDidReadRSSI:RSSI];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        BOOL duplicatedCharacterstic = false;
        for (CBCharacteristic *discovered in _discoveredCharacterstics)
            if ([discovered.UUID isEqual: characteristic.UUID])
                duplicatedCharacterstic = true;
        if (!duplicatedCharacterstic)
            [_discoveredCharacterstics addObject: characteristic];
        if ([_serviceNotifyCharacteristics containsObject:characteristic.UUID])
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (id<CentralManagerObserver> observer in [_observers allValues])
        [observer CentralDidWriteData];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (characteristic.value) {
        for (id<CentralManagerObserver> observer in [_observers allValues])
            [observer CentralDidReadData:characteristic.value];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {}

@end

