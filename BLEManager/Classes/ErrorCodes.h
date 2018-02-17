//
//  ErrorCodes.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/20/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#ifndef ErrorCodes_h
#define ErrorCodes_h

//General errors starts with 1
#define LocalCharacterisitic_Null   -881001
#define ArrayToData_Failed          -881002

//Central errors starts with 2
#define LocalCentral_Null           -882001
#define CentralManager_Null         -882002
#define CentralManager_NotScanning  -882003

//Peripheral erros starts with 3
#define LocalPeripheral_Null        -883001
#define DiscoveredPeripheral_Null   -883002
#define Peripheral_Connected        -883003
#define PeripheralService_Null      -883004
#define Peripherals_DontMatch       -883005

#endif /* ErrorCodes_h */
