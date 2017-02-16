//
//  MainViewController.swift
//  BlueDemo
//
//  Created by Chensh on 2017/2/14.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit
import CoreBluetooth

let  VScaleUUID  = CBUUID.init(string: "F433BD80-75B8-11E2-97D9-0002A5D5C51B")


class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier: String = "PeripheralTableViewCell"
    var dataArray: [CBPeripheral] = []
    
    var centralManager: CBCentralManager!
    var aPeripheral: CBPeripheral!
    
    @IBOutlet weak var tableView: UITableView!
    
    override var nibName: String?
    {
    
        return "MainViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.title = "蓝牙搜索"
        
        //
        let nib = UINib.init(nibName: cellIdentifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        
        //
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // =======================================================
    // =======================================================
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PeripheralTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PeripheralTableViewCell
        
        let peripheral: CBPeripheral = self.dataArray[indexPath.row]
        cell.nameLabel.text = peripheral.name
        cell.identifierLabel.text = peripheral.identifier.uuidString
        cell.stateLabel.text = CBPeripheralStateString(state: peripheral.state)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    func CBPeripheralStateString(state: CBPeripheralState) -> String {
       
            switch state {
            case .disconnected:
            return "disconnected"
            case .connecting:
            return "connecting"
            case .connected:
            return "connected"
            default:
            return "disconnecting"
            }
        
    }
    
    
    // =======================================================
    // =======================================================
    
    
    // 初始化后回调
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown")
            break
        case .resetting:
            print("CBCentralManager state:", "resetting")
            break
        case .unsupported:
            print("CBCentralManager state:", "unsupported")
            break
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized")
            break
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
            break
        case .poweredOn:
            print("CBCentralManager state:", "poweredOn")
            
            // 蓝牙开启扫描
            // services： 通过服务筛选
            // dict: 通过条件筛选
           centralManager.scanForPeripherals(withServices:nil , options: nil)
            
            break
        }
    }
    
    // 搜索外围设备
    // advertisementData： 外设携带的数据
    // rssi: 外设的蓝牙信号强度
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       
        print(#function, #line)
        
        if peripheral.identifier.description == "D7CF07B8-70F1-465F-865A-BBF189CDAE0A"
        {
            print(central)
            print(peripheral)
            print(advertisementData)
            print(RSSI)
            print(advertisementData["kCBAdvDataServiceUUIDs"] as? NSArray)
    
            peripheral.delegate = self
           // [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
           // peripheral.discoverServices([SmartScaleService_UUID1, SmartScaleService_UUID1])
            centralManager.connect(peripheral, options: nil)
            self.tableView.reloadData()
            centralManager.stopScan()
            
        }
        

        
        /*
         
         * peripheral:
         <CBPeripheral: 0x15fd951b0, identifier = 2DE9CDCF-64B7-C7CA-302F-13EF73A61CDB, name = Chensh的MacBook Pro, state = disconnected>
         
         * advertisementData:
         ["kCBAdvDataIsConnectable": 1, "kCBAdvDataLocalName": MI, "kCBAdvDataManufacturerData": <5701002c 9b349956 7afbaf5a 21000655 07c61200 880f107e c4c4>, "kCBAdvDataServiceUUIDs": <__NSArrayM 0x14f542de0>(
         FEE0,
         FEE7
         )
         , "kCBAdvDataServiceData": {
         FEE0 = <0b000000>;
         }]
         
         */
        
        // 判断是否已经存在列表里
        var exist: Bool = false
        for pItem in self.dataArray {
            if pItem.identifier.uuidString == peripheral.identifier.uuidString {
                exist = true
                let index: Int = self.dataArray.index(of: pItem)!
                self.dataArray.replaceSubrange(index...index, with: [peripheral])
            }
        }
        if !exist {
            self.dataArray.append(peripheral)
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        
        if peripheral.identifier.description == "D7CF07B8-70F1-465F-865A-BBF189CDAE0A"
        {
            //print(peripheral)
            peripheral.discoverServices(nil)
            
           //peripheral.discoverServices([CBUUID.init(string: "f433bd80-75b8-11e2-97d9-0002a5d5c51b")])

        }

    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        if peripheral.identifier.description == "D7CF07B8-70F1-465F-865A-BBF189CDAE0A"
        {
           // print(peripheral)
            
        }
    }
    
    //MARK:   
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
  
        print(#function, #line)
        for var service in peripheral.services!
        {
           peripheral.discoverCharacteristics([CBUUID.init(string: "1A2EA400-75B9-11E2-BE05-0002A5D5C51B")], for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(#function, #line)
        for var characteristic in service.characteristics!
        {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print(#function, #line)

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print(#function, #line)
        if characteristic.value != nil &&  characteristic.value!.count > 1
        {
            
            //let result = String.init(data: characteristic.value!, encoding: .utf32BigEndian)
            print("characteristic result \(characteristic.value!.count)")
         
            let v1 = Int(characteristic.value![4]) << 8
            let v2 = Int(characteristic.value![5])
            let result = String.init(format:"%0.2f", Float(v1+v2)/10)
            
            //let v1 = CFSwapInt32BigToHost(characteristic.value!)
            print("characteristic.value \(v1)")
            print("characteristic.value \(v2)")
            print("characteristic.value \(Float(v1+v2)/10)Kg")

            print("characteristic.value \(characteristic)")
           
            
            self.centralManager.cancelPeripheralConnection(peripheral) //拿到数据后自己断掉连接。
        }

    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        //print(characteristic)
        if characteristic.value != nil
        {
            let result = String.init(data: characteristic.value!, encoding: .utf8)

        }
      //  print("characteristic.value\(characteristic)")

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?)
    {
        print(#function, #line)

    }
    
}
