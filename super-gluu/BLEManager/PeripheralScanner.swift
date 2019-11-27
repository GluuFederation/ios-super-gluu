//
//  PeripheralScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
/*
import CoreBluetooth

struct Constants {
    static let ConnectTimeout: TimeInterval = 5
    static let DidUpdateValueForPairing = "DidUpdateValueForPairing"
    static let DidUpdateValueForCharacteristic = "didUpdateValueForCharacteristic"
    static let DidWriteValueForCharacteristic = "didWriteValueForCharacteristic"
    static let DidUpdateNotificationStateForCharacteristic = "didUpdateNotificationStateForCharacteristic"
    static let DidConnectPeripheral = "didConnectPeripheral"
    static let DidDisconnectPeripheral = "didDisconnectPeripheral"
    
    static let u2fControlPoint_uuid = "F1D0FFF1-DEAA-ECEE-B42F-C9BA7ED623BB"
    static let u2fStatus_uuid = "F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB"
    static let u2fControlPointLength_uuid = "F1D0FFF3-DEAA-ECEE-B42F-C9BA7ED623BB"
    static let battery_uuid = "2A19"
    
    static let FFFD = "FFFD"
    static let Battery = "2A19"//"180F"
    static let FirmwareRevision = "2A26"
    static let HardwareRevision = "2A27"
}

class PeripheralScanner : NSObject {
    
    var centralManager: CBCentralManager!
    
    var peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
    
    var connectTimer: Timer?
    
    var serviceScanner: ServiceScanner!
    
    var valueForWrite: Data!
    var isPairing = false
    var isEnroll = false
    
    var scanning = false {
        didSet {
            
            if scanning {
                //				let uuid1 = CBUUID(string: "180A")
                //				let uuid2 = CBUUID(string: "180D")
                //				centralManager.scanForPeripheralsWithServices([uuid1, uuid2], options: nil)
                
                //Vasco u2f token device's UUID
                //                let uuid = CBUUID(string: "8610C427-C32E-4AEB-A086-D6ACF31BCF24")
                //				centralManager.scanForPeripherals(withServices: [uuid], options: nil)
                
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                NSLog("scanning...")
            } else {
                centralManager.stopScan()
                cancelConnections()
                NSLog("scanning stopped.")
            }
        }
    }
    

    override init() {
        super.init()
    }
    
    func start(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
        serviceScanner = ServiceScanner()
    }
    
    @objc
    func cancelConnections() {
        print("cancelConnections")
        for peripheralCouple in peripherals {
            centralManager.cancelPeripheralConnection(peripheralCouple.peripheral)
        }
    }
    
    func tryToDiscoverVascoToken(){
        if peripherals.count > 0 {
            //There is at least one Vasco's token
            let peripheralCouple = peripherals[0]
            let peripheral = peripheralCouple.peripheral
            //Doing service(s) connect and discovering
            serviceScanner.peripheral = peripheral
            serviceScanner.advertisementDataUUIDs = peripheralCouple.UUIDs
            serviceScanner.valueForWrite = valueForWrite
            serviceScanner.isPairing = isPairing
            serviceScanner.isEnroll = isEnroll
            NSLog("connectPeripheral \(String(describing: peripheral.name)) (\(peripheral.state))")
            centralManager.connect(peripheral, options: nil)
            connectTimer = Timer.scheduledTimer(timeInterval: Constants.ConnectTimeout, target: self, selector: #selector(PeripheralScanner.cancelConnections), userInfo: nil, repeats: false)
        }
    }
    
}


extension PeripheralScanner : CBCentralManagerDelegate{

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(centralManager.state)
        if centralManager.state != .poweredOn {
            if scanning {
                UIAlertView(title: "Unable to scan", message: "bluetooth is in \(centralManager.state.rawValue)-state", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        if centralManager.state == .poweredOn {
            let connectedDevices = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "8610C427-C32E-4AEB-A086-D6ACF31BCF24")])
            for uuid in connectedDevices {
                print("Device Found. UUID = \(uuid) and name \(String(describing: uuid.name))");
            }
        }
        scanning = centralManager.state == .poweredOn
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let contains = peripherals.contains { (peripheralInner: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?) -> Bool in
            return peripheral == peripheralInner
        }
        
        if !contains {
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                let isConnectible = advertisementData[CBAdvertisementDataIsConnectable] as! Bool
                guard let localName:String = advertisementData[CBAdvertisementDataLocalNameKey] as! String? else {
                    return
                }
                if isConnectible && localName == "SClick U2F" {
                    NSLog("discovered \(peripheral.name ?? "Noname") RSSI: \(RSSI)\n advertisementData: \(advertisementData)")
                    let UUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as! [CBUUID]
                    peripherals.append((peripheral, serviceUUIDs.count, UUIDs))
                    tryToDiscoverVascoToken()
                }
            }
//            else {
//                peripherals.append((peripheral, 0, nil))
//            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("didConnectPeripheral \(String(describing: peripheral.name))")
        
        connectTimer?.invalidate()
        peripheral.delegate = serviceScanner
        peripheral.discoverServices(nil)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidConnectPeripheral), object: ["peripheralName": peripheral.name], userInfo: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("didDisconnectPeripheral \(String(describing: peripheral.name))")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidDisconnectPeripheral), object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("\tdidFailToConnectPeripheral \(String(describing: peripheral.name))")
        UIAlertView(title: "Fail To Connect", message: nil, delegate: nil, cancelButtonTitle: "Dismiss").show()
    }
    
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        NSLog("willRestoreState \(dict)")
//    }
    
}

 */
