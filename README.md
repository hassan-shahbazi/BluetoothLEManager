# BluetoothLEManager
![build status](https://travis-ci.org/Hassaniiii/BluetoothLEManager.svg?branch=master)
![cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)
![Licence](https://img.shields.io/github/license/Hassaniiii/BluetoothLEManager.svg)

Most completed library to deal with BLE-related implementations (Central, Peripheral)


## Features

### Easy to use
No need to dive into complex delegates and configurations of **CoreBluetooth** anymore. You can start your bluetooth role easily in a few lines.

### Comprehensive
It supports both Central and Peripheral modes with simple and easy-to-implement callbacks. You do not need to add seperate libraries for Central or Peripheral anymore.

### Stable
It is written in *Objective-c* usable in both *Objective-c* and *Swift*. It is stable and you do not need to update your library with every updates on Swift and Xcode.

## Getting Started
These instructions will help you to add `BluetoothLEManager` to your current Xcode project in a few lines

### Installation
#### Cocoapods
The easiest way to import *BluetoothLEManager* to your current project is to use `Cocoapods`. Just add the following to your `Podfile`

`pod 'BluetoothLEManager'`

#### Manual
You can also download the whole code manually and copy the following classes to your project based on your needs
```
CentralManager.h
CentralManager.m
PeripheralManager.h
PeripheralManager.m
MyCharacteristic.h
MyCharacteristic.m
```

## Usage
This library is using *Observer Protocol pattern*. You can get callbacks in more than one class and you do not need to keep refrences to delegates.


#### Central
You can start using application with adding observer classes. The classes you want to get callbacks by them
```swift
CentralManager.sharedInstance().addObserver(self)
```

Then, add `CentralManagerObserver` protocol to your controller class.
```swift
extension BluetoothController: CentralManagerObserver {
    func centralStateDidUpdated(_ state: CBManagerState)
    func centralDidFound(_ macAddress: String!)
    func centralDidConnected()
    func centralDidDisconnected()
    func centralDidRead(_ data: Data!)
    func centralDidReadRSSI(_ rssi: NSNumber!)
    func centralPairedList(_ list: [Any]!)
    func centralDidWriteData()
    func centralDidFailed(_ error: Error!)
    func centralDidRestored()
}
```
Now, you have to add your targets' services and characteristics. Please add the 'Notify' ones to `serviceNotifyCharacteristics` if you want to subscibe on them
```swift
CentralManager.sharedInstance().serviceUUID = [CBUUID(string: "180F")]
CentralManager.sharedInstance().serviceCharacteristics = [CBUUID(string: "212A")]
CentralManager.sharedInstance().serviceNotifyCharacteristics = [CBUUID(string: "212A")]
```

Then, you can start scanning for nearby peripehral devices which makes the `func centralDidFound(_ macAddress: String!)` to be fired
```swift
CentralManager.sharedInstance().scan()
```

#### Peripheral
Just like `Central` configuration, start by adding observer classes which has implemented `PeripheralManagerObserver` protocols
```swift
Peripheral.sharedInstance().addObserver(self)

extension BluetoothController: PeripheralManagerObserver {
    func peripheralStateDidUpdated(_ state: CBManagerState)
    func peripheralDidStartAdvertising()
    func peripheralDidConnect(_ central: CBCentral!, to characteristic: CBCharacteristic!)
    func peripheralDidDisonnect(_ central: CBCentral!, from characteristic: CBCharacteristic!)
    func peripheralDidGetRead(_ request: CBATTRequest!)
    func peripheralDidGetWrite(_ requests: [CBATTRequest]!)
}
```
Then, you have to add services you want to advertise..
```swift
Peripheral.sharedInstance().serviceUUID = CBUUID(string: string: "180F")
```
and the characteristics you want to add to your service in the format of `MyCharacterstic`
```swift
let characteristic = MyCharacterstic()
characteristic.uuid = CBUUID(string: "180F")
characteristic.permission = [.readEncryptionRequired, .writeEncryptionRequired]
characteristic.property = [.read, .write, .notify]

Peripheral.sharedInstance().serviceCharacteristics = [characteristic]
```
Now your advertisement can be started. Specify a name for it and start advertisement process
```swift
Peripheral.sharedInstance().localName = YOUR_NAME
Peripheral.sharedInstance().startAdvertising()
```
You might need to remove services you had added before, or you may want to stop advertisement
```swift
Peripheral.sharedInstance().removeService(CBUUID(string: string: "180F"))
Peripheral.sharedInstance().stopAdvertising()
```

## Contribution
Please ensure your pull request adheres to the following guidelines:

* Alphabetize your entry.
* Search previous suggestions before making a new one, as yours may be a duplicate.
* Suggested READMEs should be beautiful or stand out in some way.
* Make an individual pull request for each suggestion.
* New categories, or improvements to the existing categorization are welcome.
* Keep descriptions short and simple, but descriptive.
* Start the description with a capital and end with a full stop/period.
* Check your spelling and grammar.
* Make sure your text editor is set to remove trailing whitespace.

Thank you for your suggestions!

## Authors

* **Hassan Shahbazi** - [Hassaniiii](https://github.com/Hassaniiii)

## License
This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/Hassaniiii/BLEManager/blob/master/LICENSE.md) file for details
