//
//  CharacteristicScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/10/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicScanner: NSObject {
    
    var peripharal: CBPeripheral!
    var service: CBService!
    
    var characteristicObserver : CharacteristicObserver!
    
    var valueForWrite: Data!
    
    func discoverCharacteristics(isEnroll: Bool, isPairing: Bool){
        characteristicObserver = CharacteristicObserver()
        for characteristic in service.characteristics! {
            let character = characteristic as CBCharacteristic
            let type = getTypeOfCharacteristic(character)
            
            //Read characteristics for throwing pairing
            if isPairing {
                if characteristic.uuid.uuidString == Constants.FirmwareRevision ||
                    characteristic.uuid.uuidString == Constants.Battery ||
                    characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid ||
                    characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid {
                    valueForWrite = Data.init(bytes: [0x03])
                    if characteristic.uuid.uuidString == Constants.Battery {
                        let batteryValueData = characteristic.value
                        if batteryValueData != nil {
                            let batteryValue = batteryValueData?.hexEncodedString()
                            let batteryLevel = UInt8(strtoul(batteryValue, nil, 16))
                            print("Battery Level -- \(batteryLevel)")
                        }
                    }
                    self.startDiscover(characteristic, type: type, isPairing: isPairing, isEnroll: isEnroll)
                    print("Doing pairing")
                }
            } else if characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid ||
                characteristic.uuid.uuidString == Constants.u2fStatus_uuid ||
                characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid {
                self.startDiscover(characteristic, type: type, isPairing: isPairing, isEnroll: isEnroll)
            }
        }
    }
    
    private func startDiscover(_ character : CBCharacteristic, type: CBCharacteristicProperties, isPairing: Bool, isEnroll: Bool){
        characteristicObserver.peripharal = peripharal
        characteristicObserver.characteristic = character
        characteristicObserver.valueForWrite = valueForWrite
        characteristicObserver.prop = type
        characteristicObserver.isEnroll = isEnroll
        characteristicObserver.doAction(isPairing: isPairing)
    }
    
    
    fileprivate func getTypeOfCharacteristic(_ characteristic : CBCharacteristic)-> CBCharacteristicProperties{
        if characteristic.properties.contains(.read) {
            return .read
        } else if characteristic.properties.contains(.write) {
            return .write
        }else if characteristic.properties.contains(.notify) {
            return .notify
        }
        return CBCharacteristicProperties()
    }
    
}


class CharacteristicObserver: NSObject {
    
    var peripharal: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    var prop: CBCharacteristicProperties!
    
    var valueForWrite: Data!
    
    var isEnroll = false
    
    func doAction(isPairing: Bool) {
        switch prop {
        case CBCharacteristicProperties.read:
            print("Trying to read value for -- \(characteristic)")
            peripharal.readValue(for: characteristic)
        case CBCharacteristicProperties.write:
            if let value = valueForWrite {
                print("Trying to write for -- \(characteristic)")
                if isPairing {
                    peripharal.writeValue(value, for: characteristic, type: .withResponse)
                } else {
                    let dataArray = self.splitDataByPackets(data: value)
                    for data in dataArray {
                        print("---write packet--- data ---- \(data)")
                        peripharal.writeValue(data, for: characteristic, type: .withResponse)
                    }
                }
            }
        case CBCharacteristicProperties.notify:
            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
            peripharal.setNotifyValue(true, for: characteristic)
        default: break
        }
    }
    
    func splitDataByPackets(data: Data)->[Data]{
        //We should write value via packets data by 20 bytes each frame (APDU)
        var resultDataArray = [Data]()
        if isEnroll {
            resultDataArray = U2FMessageCoder.sharedInstance.separateEnrolMessage(data: data)
        } else {
            resultDataArray = U2FMessageCoder.sharedInstance.separateAuthMessage(data: data)
        }
        print("resultDataArray - \(resultDataArray)")
        return resultDataArray
    }
    
}
