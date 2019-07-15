//
//  ServiceScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceScanner: NSObject {
    
    var discovering = true
    var peripheral: CBPeripheral!
    var advertisementDataUUIDs: [CBUUID]?
    
    var characteristicScanner : CharacteristicScanner!
    
    var valueForWrite: Data!//Data for write to device
    var enrollResponseData: Data!//Data received from device
    var isPairing = false
    var isEnroll = false
    
    var isErrorSent = false
    var isAuthSent = false
    var nilCount = 0
    
//    let scanner = BackgroundScanner.defaultScanner
    
    override init() {
        super.init()
        enrollResponseData = Data.init()
    }
    
}

extension ServiceScanner : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            NSLog("didDiscoverServices error: \(error.localizedDescription)")
        } else {
            NSLog("didDiscoverServices \(String(describing: peripheral.services?.count))")
        }
        discovering = false
        isAuthSent = false
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            NSLog("didDiscoverCharacteristicsForService error: \(error.localizedDescription)")
        } else {
            //read characteristics
            characteristicScanner = CharacteristicScanner()
            characteristicScanner.peripharal = self.peripheral
            characteristicScanner.service = service
            characteristicScanner.valueForWrite = valueForWrite
            characteristicScanner.discoverCharacteristics(isEnroll: isEnroll, isPairing: isPairing)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["error": error.localizedDescription], userInfo: nil)
        } else {
            if self.isEnroll {
                if self.isPairing {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForPairing), object: nil)
                } else {
                    handleResult(characteristic: characteristic)
                }
            } else {
                handleAuthResult(characteristic: characteristic)}
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didWriteValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            print("Characteristic write value : \(String(describing: characteristic.value)) with ID \(characteristic.uuid.uuidString)");
            if characteristic.value == nil && characteristic.uuid.uuidString == "F1D0FFF1-DEAA-ECEE-B42F-C9BA7ED623BB" && nilCount > 5 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["error": "error",
                                                                                                                                       "isEnroll" : isEnroll])
                nilCount += 1
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic.value)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateNotificationStateForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            print("Characteristic notification value : \(String(describing: characteristic.value)) with ID \(characteristic.uuid.uuidString)");
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic)
        }
    }
    
    func handleResult(characteristic: CBCharacteristic){
        let value = String(data: characteristic.value!, encoding: String.Encoding.utf8)
        if characteristic.uuid.uuidString == Constants.u2fStatus_uuid {
            //We should split all response packets (34 by 20 bytes and last one 9 bytes)
            let startIndex = enrollResponseData.count == 0 ? 3 : 1
            let range:Range<Int> = startIndex..<characteristic.value!.count
            let newPacketBytes = characteristic.value!.subdata(in: range)
            enrollResponseData.append(contentsOf: newPacketBytes)
            print("got response from F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB -- \(String(describing: characteristic.value?.count)) ---- \(String(describing: characteristic.value))")
            if (characteristic.value?.count)! >= 7 && (characteristic.value?.count)! <= 10 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["responseData" : enrollResponseData,
                                                                "isEnroll" : isEnroll])
                isErrorSent = !isErrorSent
            } else if (characteristic.value?.count)! <= 4 && !isErrorSent {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["error": "error",
                                                               "isEnroll" : isEnroll])
                isErrorSent = !isErrorSent
            }
        } else {
            print("Characteristic value : \(String(describing: value)) with ID \(characteristic.uuid.uuidString)")
        }
    }

    func handleAuthResult(characteristic: CBCharacteristic){
        let value = String(data: characteristic.value!, encoding: String.Encoding.utf8)
        if characteristic.uuid.uuidString == Constants.u2fStatus_uuid {
            //We should check is response is short (keyHandle generated not using SecureClick) or long (keyHandle generated using SecureClick)
            print("got response from F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB --- \(String(describing: characteristic.value))")
            if characteristic.value?.count == 5 && enrollResponseData.count == 0 {//Short response
                enrollResponseData.append(contentsOf: characteristic.value!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["responseData" : enrollResponseData,
                                                                                                                                       "isEnroll" : self.isEnroll])
                isErrorSent = !isErrorSent
            } else {//Long response
                let startIndex = enrollResponseData.count == 0 ? 3 : 1
                let range:Range<Int> = startIndex..<characteristic.value!.count
                let newPacketBytes = characteristic.value!.subdata(in: range)
                enrollResponseData.append(contentsOf: newPacketBytes)
                if (characteristic.value?.count)! <= 6 && !isAuthSent {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["responseData" : enrollResponseData,
                                                                                                                                           "isEnroll" : self.isEnroll.description])
                    print("Authentication response sent!!!!!!")
                    isAuthSent = !isAuthSent
                }
            }
        } else {
            print("Characteristic value : \(UInt8(strtoul(value, nil, 16))) with ID \(characteristic.uuid.uuidString)");
        }
    }

    
}
