//
//  Manager.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import "CentralManager.h"
#import "ErrorCodes.h"
#import "ErrorHandler.h"

@interface CentralManager()
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@property (nonatomic, strong) CBCentralManager *localCentral;
@property (nonatomic, strong) CBPeripheral *localPeriperal;

@property (nonatomic, strong) CBCharacteristic *localCharacteristic;

@property (nonatomic, strong) NSString *connectedMacAddress;
@property (nonatomic, assign) NSInteger lockCount;

@end

@implementation CentralManager

- (id)init {
    self = [super init];
    if (self) {
        _centralManager = nil;
        _connectedMacAddress = @"";
        _lockCount = 0;
        _RSSI_lock = -100;
        _RSSI_delay = 3;
        _RSSI_filter = -50;
        _AutoConnectDongles = [NSMutableArray new];
        
        
        dispatch_queue_t centralQueu = dispatch_queue_create("com.Vancosys", NULL);
        self.centralManager = [[CBCentralManager alloc]
                               initWithDelegate:self
                               queue:centralQueu
                               options: @{CBCentralManagerOptionRestoreIdentifierKey:@"VancosysCentral",
                                          CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
}

+ (CentralManager *)SharedInstance {
    static CentralManager *singleton = nil;
    if (!singleton) {
        singleton = [[CentralManager alloc] init];
    }
    return singleton;
}

- (void)Connect {
    if (_localCentral) {
        if (_localPeriperal) {
            [_localCentral connectPeripheral:_localPeriperal options:nil];
        }
        else {
            if ([_delegate respondsToSelector:@selector(Error:)])
                [_delegate Error:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)GetPairedList {    
    if (_centralManager) {
        [self centralManager:_centralManager didDiscoverPairedPeripherals:[_centralManager retrieveConnectedPeripheralsWithServices:_ServiceUUIDs]];
    }
    else if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:CentralManager_Null]];
}

- (void)Disconnect {
    if (_localCentral) {
        if (_localPeriperal) {
            [_localCentral cancelPeripheralConnection:_localPeriperal];
        }
        else {
            if ([_delegate respondsToSelector:@selector(Error:)])
                [_delegate Error:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)StartScanning {
    [self Disconnect];
    [self StopScanning];
    if (_centralManager)
        [_centralManager scanForPeripheralsWithServices:_ServiceUUIDs options:nil];
    else
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:CentralManager_Null]];
}

- (void)StopScanning {
    if (_centralManager) {
        if ([_centralManager isScanning]) {
            [_centralManager stopScan];
        }
        else if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:CentralManager_NotScanning]];
    }
    else {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:CentralManager_Null]];
    }
}

- (void)ReadRSSI {
    if (_localPeriperal)
        [_localPeriperal readRSSI];
    else
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:LocalPeripheral_Null]];
}

- (void)TestPairing {
    [self Read:_localCharacteristic];
    
}

- (void)Read:(CBCharacteristic *)Characterstic {
    if (_localPeriperal)
        [_localPeriperal readValueForCharacteristic:Characterstic];
    else
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:LocalPeripheral_Null]];
}

- (void)Write:(NSData *)data {
    if (!_localCharacteristic) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:LocalCharacterisitic_Null]];
    }
    else {
        if (data) {
            if (_Logging)
                NSLog(@"bytes to write: %@", data);
            [_localPeriperal writeValue: data
                      forCharacteristic:_localCharacteristic
                                   type:CBCharacteristicWriteWithResponse];
        }
        else {
            if ([_delegate respondsToSelector:@selector(Error:)])
                [_delegate Error:[self GetErrorObjectForCode:ArrayToData_Failed]];
        }
    }
}

- (NSString *)GetConnectedMacAddress {
    return _connectedMacAddress;
}
             
- (NSError *)GetErrorObjectForCode:(NSInteger )errorCode {
    return [ErrorHandler GenerateErrorWithCode:errorCode];
}

#pragma mark - Central Manager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([_delegate respondsToSelector:@selector(CentralStateChanged:)])
        [_delegate CentralStateChanged:central.state];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (!peripheral.name || [peripheral.name isEqualToString:@""]) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:DiscoveredPeripheral_Null]];
    }
    else if (!_connectedPeripheral || _connectedPeripheral.state == CBPeripheralStateDisconnected) {
        _localCentral = central;
        _localPeriperal = peripheral;
        _localPeriperal.delegate = self;

        if ([_AutoConnectDongles containsObject:peripheral.identifier.UUIDString]) {
            [central connectPeripheral:peripheral options:nil];
            [self StopScanning];
        }
        else if (RSSI.integerValue > _RSSI_filter && RSSI.integerValue < 0) {
            if ([_delegate respondsToSelector:@selector(CentralDidFound:)])
                [_delegate CentralDidFound:peripheral.identifier.UUIDString];
        }
        else {
            [self StartScanning];
        }
    }
    else
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:Peripheral_Connected]];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _connectedMacAddress = peripheral.identifier.UUIDString;
    [central stopScan];
    
    [_localPeriperal discoverServices:nil];
    if ([_delegate respondsToSelector:@selector(CentralDidConnected)])
        [_delegate CentralDidConnected];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(Error:)])
        [_delegate Error:error];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    _connectedMacAddress = @"";
    if ([_delegate respondsToSelector:@selector(CentralDidDisconnected)])
        [_delegate CentralDidDisconnected];
    if ([_AutoConnectDongles count])
        [self StartScanning];

}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    if ([dict valueForKey:CBCentralManagerRestoredStatePeripheralsKey] != nil) {
        
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPairedPeripherals:(NSArray *)peripherals {
    _localCentral = central;
    _localPeriperal = [peripherals firstObject];
    _localPeriperal.delegate = self;
    
    if ([_delegate respondsToSelector:@selector(PairedCentral:)])
        [_delegate PairedCentral:peripherals];
}

#pragma mark - Peripheral Delegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else if (peripheral != _localPeriperal
             || !peripheral.services
             || !peripheral.services.count) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:PeripheralService_Null]];
    }
    else {
        for (CBService *service in peripheral.services) {
            NSLog(@"Service: %@", service);
            if ([_ServiceUUIDs containsObject:service.UUID])
                [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else {
        if ([_delegate respondsToSelector:@selector(CentralDidReadRSSI:)])
            [_delegate CentralDidReadRSSI:RSSI.integerValue];
        if (_RSSI_lock && (RSSI.integerValue < _RSSI_lockValue)) {
            _lockCount++;
            if (_lockCount >= _RSSI_delay) {
                _lockCount = 0;
                if ([_delegate respondsToSelector:@selector(ShouldLockDevice)])
                    [_delegate ShouldLockDevice];
            }
        }
        else {
            _lockCount = 0;
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else if (peripheral != _localPeriperal) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:[self GetErrorObjectForCode:Peripherals_DontMatch]];
    }
    else {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"Characterstics: %@", characteristic);
            if ([characteristic.UUID.UUIDString isEqualToString:_ServiceCharacteristic.UUIDString])
                _localCharacteristic = characteristic;
            if ([characteristic.UUID.UUIDString isEqualToString:_ServiceNotifyCharacteristic.UUIDString])
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        if ([_delegate respondsToSelector:@selector(Error:)])
            [_delegate Error:error];
    }
    else
        if ([_delegate respondsToSelector:@selector(CentralDataDidTransfered)])
            [_delegate CentralDataDidTransfered];
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error)
        if (error == [ErrorHandler PairingError]) {
            if ([_delegate respondsToSelector:@selector(CentralPairingFailed)])
                [_delegate CentralPairingFailed];
        }
        else {
            if ([_delegate respondsToSelector:@selector(Error:)])
                [_delegate Error:error];
        }
    else
        if ([_delegate respondsToSelector:@selector(CentralDidRecived:)])
            [_delegate CentralDidRecived:characteristic.value];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

@end

