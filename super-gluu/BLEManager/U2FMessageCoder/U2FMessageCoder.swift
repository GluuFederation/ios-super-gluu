//
//  U2FMessageCoder.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/27/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import Foundation

class U2FMessageCoder {
    
    static let sharedInstance: U2FMessageCoder = U2FMessageCoder()
    
    
    func separateEnrolMessage(data: Data)->[Data]{
        var dataArray = [UInt8]()
        var resultDataArray = [Data]()
        for i in 0...3 {
            dataArray.append(contentsOf: makePoket(index: i, data: data))
        }
        let endRange = 20
        for i in 0...3 {
            var range:Range<Int>!
            if i == 0 {
                range = i..<endRange //0..<20
            } else if i == 3 {
                range = i*endRange..<i*endRange + endRange - 1//60..<79
            }else {
                range = i*endRange..<i*endRange + endRange//20..<40
            }
            
            let dataAr = Data(bytes: dataArray)
            let pocket = dataAr.subdata(in: range)
            resultDataArray.append(pocket)
        }
        return resultDataArray
    }
    
    private func makePoket(index:Int, data: Data)->[UInt8]{
        var firstParameter : [UInt8]!
        var range:Range<Int>!
        switch index {
        case 0:
            range = 0..<10
            firstParameter = [0x83, 0x00, 0x49, 0x00, 0x01, 0x03, 0x00, 0x00, 0x00, 0x40]
        case 1:
            range = 10..<29
            firstParameter = [UInt8(bitPattern: Int8(index-1))]
        case 2:
            range = 29..<48
            firstParameter = [0x01]
        case 3:
            range = 48..<64
            firstParameter = [0x02]
        default:
            print("none")
        }
        let pocket = data.subdata(in: range)
        if index == 3 {
            let endParameter : [UInt8] = [0x00, 0x00]
            firstParameter.append(contentsOf: pocket)
            firstParameter.append(contentsOf: endParameter)
        } else {
            firstParameter.append(contentsOf: pocket)
        }
        
        return firstParameter
    }
    
    //----------- Authentication methods -----------------------------------------
    
    func separateAuthMessage(data: Data)->Array<Data>{
        let dataArray = U2FMessageCoder.sharedInstance.makeAuthBytes(data: data)
        
        return dataArray
    }
    
    private func makeAuthBytes(data: Data)->Array<Data>{
        //data - 152-151
        let tempRange:Range<Int> = 0..<data.count
        let tempData = makePoket(data: data, range:tempRange)
        print("tempData -- \(tempData)")
        var dataArray = Array<Data>()
        let count = data.count/19
        var index = 0
        for i in 0...count {
            var firstParameter : Data!
            var range:Range<Int>!
            if i == 0 {
                range = 0..<10
                firstParameter = Data.init(bytes: [0x83, 0x00, 0x9a, 0x00, 0x02, 0x03, 0x00, 0x00, 0x00, 0x91])
            } else if i == 1 {
                firstParameter = Data.init(bytes: [UInt8(bitPattern: Int8(i-1))])
                index = i*20+9
                range = 10..<index//29
            } else {
                firstParameter = Data.init(bytes: [UInt8(bitPattern: Int8(i-1))])
                var index2 = index+19
                index2 = index2 >= data.count ? data.count : index2
                range = index..<index2
                index = index2
            }
            print("range -- \(range)") //Should be removed after testing
            firstParameter.append(contentsOf: makePoket(data: data, range:range))
            dataArray.append(firstParameter)
        }
        let range:Range<Int> = index..<data.count
        print("range -- \(range)") //Should be removed after testing
        var firstParameter = Data.init(bytes: [UInt8(bitPattern: Int8(count))])
        firstParameter.append(makePoket(data: data, range:range))
        firstParameter.append(contentsOf: Data.init(bytes: [0x00, 0x00]))
        dataArray.append(firstParameter)
        print("dataArray -- \(dataArray)")
        
        return dataArray
    }
    
    private func makePoket(data: Data, range: Range<Int>)->Data{
        var firstParameter = Data()
        let pocket = data.subdata(in: range)
        
        firstParameter.append(pocket)
        
        return firstParameter
    }

    
}
