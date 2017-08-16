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

@property (nonatomic, assign) BOOL ScanAgain;
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
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:centralQueu
                                                             options: @{CBCentralManagerOptionRestoreIdentifierKey:@"VancosysCentral",
                                                                        CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
}

+ (CentralManager *)SharedInstance {
    static CentralManager *singleton = nil;
    if (!singleton) {
        singleton = [CentralManager new];
    }
    return singleton;
}

- (void)Connect {
    if (_localCentral) {
        if (_localPeriperal) {
            _ScanAgain = true;
            [_localCentral connectPeripheral:_localPeriperal options:nil];
        }
        else {
            if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
                [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)GetPairedList {    
    if (_centralManager) {
        if ([_delegate respondsToSelector:@selector(PairedDongles:)])
            [_delegate PairedDongles:[_centralManager retrieveConnectedPeripheralsWithServices:_ServiceUUIDs]];
    }
    else
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_Null]];
}

- (void)Disconnect {
    if (_localCentral) {
        if (_localPeriperal) {
            _ScanAgain = false;
            [_localCentral cancelPeripheralConnection:_localPeriperal];
        }
        else {
            if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
                [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCentral_Null]];
    }
}

- (void)StartScanning {
    [self Disconnect];
    [self StopScanning];
    if (_centralManager)
        [_centralManager scanForPeripheralsWithServices:_ServiceUUIDs options:nil];
    else
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_Null]];
}

- (void)StopScanning {
    if (_centralManager) {
        if ([_centralManager isScanning]) {
            [_centralManager stopScan];
        }
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_NotScanning]];
    }
    else {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:CentralManager_Null]];
    }
}

- (void)ReadRSSI {
    if (_localPeriperal)
        [_localPeriperal readRSSI];
    else
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
}

- (void)TestPairing {
    if (_localPeriperal)
        [_localPeriperal readValueForCharacteristic:_localCharacteristic];
    else
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalPeripheral_Null]];
}

- (void)Write:(NSData *)data {
    if (!_localCharacteristic) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:LocalCharacterisitic_Null]];
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
            if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
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

#pragma mark - Central Manager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([_delegate respondsToSelector:@selector(CentralStateChanged:)])
        [_delegate CentralStateChanged:(CBCentralManagerState )central.state];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (!peripheral.name || [peripheral.name isEqualToString:@""]) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:DiscoveredPeripheral_Null]];
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
            if ([_delegate respondsToSelector:@selector(DongleFound:)])
                [_delegate DongleFound:peripheral.identifier.UUIDString];
        }
        else {
            [self StartScanning];
        }
    }
    else
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:Peripheral_Connected]];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _connectedMacAddress = peripheral.identifier.UUIDString;
    [central stopScan];
    
    [_localPeriperal discoverServices:_ServiceUUIDs];
    if ([_delegate respondsToSelector:@selector(DongleConnected)])
        [_delegate DongleConnected];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
        [_delegate ErrorOccured:error];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error)
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:error];
    _connectedMacAddress = @"";
    if ([_AutoConnectDongles count] && _ScanAgain)
        [self StartScanning];
    
    if ([_delegate respondsToSelector:@selector(DongleDisconnected)])
        [_delegate DongleDisconnected];
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    
}

#pragma mark - Peripheral Delegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:error];
    }
    else if (peripheral != _localPeriperal
             || !peripheral.services
             || !peripheral.services.count) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
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
    if (error) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:error];
    }
    else {
        if ([_delegate respondsToSelector:@selector(RSSIRead:)])
            [_delegate RSSIRead:RSSI.integerValue];
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
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:error];
    }
    else if (peripheral != _localPeriperal) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:[self GetErrorObjectForCode:Peripherals_DontMatch]];
    }
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
    if (error) {
        if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
            [_delegate ErrorOccured:error];
    }
    else
        if ([_delegate respondsToSelector:@selector(DataTransfered)])
            [_delegate DataTransfered];
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error)
        if (error == [ErrorHandler PairingError]) {
            if ([_delegate respondsToSelector:@selector(DonglePairingFailed)])
                [_delegate DonglePairingFailed];
        }
        else {
            if ([_delegate respondsToSelector:@selector(ErrorOccured:)])
                [_delegate ErrorOccured:error];
        }
    else
        if ([_delegate respondsToSelector:@selector(DongleRecived:)])
            [_delegate DongleRecived:characteristic.value];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

@end

