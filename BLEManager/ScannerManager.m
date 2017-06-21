//
//  Manager.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import "ScannerManager.h"
#import "ErrorCodes.h"
#import "ErrorHandler.h"

@interface ScannerManager()
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@property (nonatomic, strong) CBCentralManager *localCentral;
@property (nonatomic, strong) CBPeripheral *localPeriperal;

@property (nonatomic, strong) CBCharacteristic *localCharacteristic;

@property (nonatomic, strong) NSString *connectedMacAddress;
@property (nonatomic, assign) NSInteger lockCount;
@end

@implementation ScannerManager

- (id)init {
    self = [super init];
    if (self) {
        _centralManager = nil;
        _AutoConnect = YES;
        _connectedMacAddress = @"";
        _lockCount = 0;
        _RSSI_lock = -100;
        _RSSI_delay = 3;
        _RSSI_filter = -50;
        
        dispatch_queue_t centralQueu = dispatch_queue_create("com.Vancosys", NULL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:centralQueu
                                                             options: @{CBCentralManagerOptionRestoreIdentifierKey:@"VancosysCentral",
                                                                        CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
}

+ (ScannerManager *)SharedInstance {
    static ScannerManager *singleton = nil;
    if (!singleton) {
        singleton = [ScannerManager new];
    }
    return singleton;
}

- (void)Connect {
    if (_localCentral) {
        if (_localPeriperal) {
            [_localCentral connectPeripheral:_localPeriperal options:nil];
        }
        else {
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)Disconnect {
    if (_localCentral) {
        if (_localPeriperal) {
            [_localCentral cancelPeripheralConnection:_localPeriperal];
        }
        else {
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)StartScanning {
    [self Disconnect];
    if (_centralManager)
        [_centralManager scanForPeripheralsWithServices:_ServiceUUIDs options:nil];
    else
        [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_Null]];
}

- (void)StopScanning {
    if (_centralManager) {
        if ([_centralManager isScanning]) {
            [_centralManager stopScan];
        }
        [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_NotScanning]];
    }
    else {
        [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_Null]];
    }
}

- (void)ReadRSSI {
    if (_localPeriperal)
        [_localPeriperal readRSSI];
    else
        [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
}

- (void)Write:(NSData *)data {
    if (!_localCharacteristic)
        [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCharacterisitic_Null]];
    else {
        if (data) {
            if (_Logging)
                NSLog(@"bytes to write: %@", data);
            [_localPeriperal writeValue: data
                      forCharacteristic:_localCharacteristic
                                   type:CBCharacteristicWriteWithResponse];
        }
        else {
            [_delegate ErrorOccured:[self GetErrorObjectForCode:ArrayToData_Failed]];
        }
    }
}

- (NSString *)GetConnectedMacAddress {
    return _connectedMacAddress;
}
             
- (NSError *)GetErrorObjectForCode:(NSInteger )errorCode {
    return [ErrorHandler GenerateErrorWithCode:errorCode];
}

#pragma mark - Central Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [_delegate CentralStateChanged:central.state];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (!peripheral.name || [peripheral.name isEqualToString:@""]) {
        [_delegate ErrorOccured:[self GetErrorObjectForCode:DiscoveredPeripheral_Null]];
    }
    else if (!_connectedPeripheral || _connectedPeripheral.state == CBPeripheralStateDisconnected) {
        _localCentral = central;
        _localPeriperal = peripheral;
        _localPeriperal.delegate = self;
        
        if (RSSI.integerValue > _RSSI_filter) {
            [_delegate DongleFound:peripheral.identifier.UUIDString];
        }
    }
    else
        [_delegate ErrorOccured:[self GetErrorObjectForCode:Peripheral_Connected]];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _connectedMacAddress = peripheral.identifier.UUIDString;
    [central stopScan];
    
    [_localPeriperal discoverServices:_ServiceUUIDs];
    [_delegate DongleConnected];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_delegate ErrorOccured:error];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error)
        [_delegate ErrorOccured:error];
    else {
        _connectedMacAddress = @"";
        if (_AutoConnect)
            [self StartScanning];
    }
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    
}

#pragma mark - Peripheral Delegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error)
        [_delegate ErrorOccured:error];
    else if (peripheral != _localPeriperal
             || !peripheral.services
             || !peripheral.services.count) {
        [_delegate ErrorOccured:[self GetErrorObjectForCode:PeripheralService_Null]];
    }
    else {
        for (CBService *service in peripheral.services) {
            if ([_ServiceUUIDs containsObject:service.UUID])
                [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error)
        [_delegate ErrorOccured:error];
    else if (_RSSI_lock) {
        if (_Logging)
            NSLog(@"%ld", (long)RSSI.integerValue);
        if (RSSI.integerValue < _RSSI_lockValue) {
            if (_Logging)
                NSLog(@"Ready to lock device");
            _lockCount++;
            if (_lockCount >= _RSSI_delay) {
                if (_Logging)
                    NSLog(@"Should lock device");
                _lockCount = 0;
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
    if (error)
        [_delegate ErrorOccured:error];
    else if (peripheral != _localPeriperal)
        [_delegate ErrorOccured:[self GetErrorObjectForCode:Peripherals_DontMatch]];
    else {
        for (CBCharacteristic *characteristic in service.characteristics) {
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
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error)
        [_delegate ErrorOccured:error];
    else
        [_delegate DongleRecived:characteristic.value];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

@end

