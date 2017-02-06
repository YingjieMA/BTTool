/*
 
 APP与蓝牙连接的工具类
 
 会在这里实现所有与外设进行数据交互的func
 
 */
import UIKit
import CoreBluetooth
import Foundation
//定义当前使用的服务和特征的UUID.(根据自己的硬件修改)
let SERVICE_UUID = "EEEF0";
let CHAR_RX_UUID = "FFE1";
let CHAR_TX_UUID = "FFE2";



class Tool: NSObject,CBPeripheralDelegate,CBCentralManagerDelegate {

    
    var centralManager : CBCentralManager?
    var peripheral : CBPeripheral?
    var characteristicTx : CBCharacteristic?
    var characteristicRx : CBCharacteristic?
    var peripheralArray:Array = [Device]();
    
    let uuidService = CBUUID.init(string: SERVICE_UUID);
    let uuidCharTx = CBUUID.init(string: CHAR_TX_UUID);
    let uuidCharRx = CBUUID.init(string: CHAR_RX_UUID);
    
    // 初始化蓝牙
    func initBlueTooth() {
        
        centralManager = CBCentralManager.init(delegate: self, queue: nil);
    }
    
    // 扫描外设
    func scanDevice() {
        peripheralArray.removeAll()
        centralManager!.scanForPeripherals(withServices: nil, options: nil);
    }
    
    // 停止扫描外设
    func stopScanDevice() {
        centralManager!.stopScan();
    }
    
    //  连接设备
    func connectDevice(per:CBPeripheral) {
        centralManager!.connect(per, options: nil);
        peripheral = per;
    }
    
    //  断开连接
    func disConnectDevice(per:CBPeripheral) {
        centralManager!.cancelPeripheralConnection(per);
    }
    //MARK:
    //MARK:      centralManager代理方法
    //    回调方法
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            NSLog("蓝牙状态已经打开！")
        default:
            break;
        }
    }
    //    已经扫描到外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("已经扫描到了外设！")
        let device = Device();
        device.peripheral = peripheral;
        device.advName = advertisementData["kCBAdvDataLocalName"] as AnyObject?
        if peripheralArray.count>0 {
            
            filterDevice(per: peripheral)
        }
        peripheralArray.append(device)
        
    }
    //  过滤扫描到的外设
    func filterDevice(per: CBPeripheral) {
        for i in 0..<peripheralArray.count {
            if peripheralArray[i].peripheral == per {
                peripheralArray.remove(at: i)
                break
            }
        }
    }
    // 连接外设成功回调        如果连接成功扫描服务
     func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已经连接上了外设！")
        stopScanDevice()
        
        peripheral.delegate = self
        
        peripheral.discoverServices([uuidService])
        
    }
    // 外设已经断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("已经与外设断开了连接")
    }
    // 外设连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("与外设连接失败！失败原因：\(error!)")
        
    }
    
    // 已经发现了服务    发现服务之后去扫描特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("发现服务失败！失败原因：\(error!)")
        }
        
        for service:CBService in peripheral.services! {
            
            print("发现了服务！UUID=\(service.uuid)")
            
            if ((service.uuid.isEqual(CBUUID.init(string: SERVICE_UUID)))) {
                
                peripheral.discoverCharacteristics(nil, for: service)
                print("现在开始去搜寻服务UUID=\(service.uuid)中的特征！")
            }
        }
    }
    
    //    已经发现了特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("发现特征失败！失败原因:\(error!)")
        }else{
            didFindCharacteristic(chaArry: service.characteristics!)
            
        }
    }
    //    属性的读写特征分配
    func didFindCharacteristic(chaArry:[CBCharacteristic]) -> Void {
        
        characteristicTx = nil;
        characteristicRx = nil;
        
        for cha:CBCharacteristic in chaArry {
            switch cha.properties {
            case CBCharacteristicProperties.read:
                print("特征\(cha)的读写属性为=====读")
                break
            case CBCharacteristicProperties.write:
                print("特征\(cha)的读写属性为=====写")
                break
            case CBCharacteristicProperties.notify:
                print("特征\(cha)的读写属性为=====订阅")
                break
                
            default:
                break
            }
            
            if cha.uuid.isEqual(uuidCharTx) {
                characteristicTx = cha
                peripheral?.setNotifyValue(true, for: cha)//发现订阅特征之后，进行注册
            }
            
            if cha.uuid.isEqual(uuidCharRx) {
                characteristicRx = cha
            }
            
        }
    }
    
    //   订阅是否成功的回调
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("注册订阅通知失败!失败原因：\(error)")
        }else{
            print("注册订阅成功！")
        }
        
    }
    
    // 接收从外设发来的数据   不管是通知还是读取都是从以下方法中获取数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("接收数据时发生错误！错误原因：\(error)")
        }else{
            if characteristic.uuid.isEqual(CBUUID.init(string: CHAR_TX_UUID)) {
                let allData = characteristic.value;
                
                let reportData = (allData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: allData!.count)
                 print("接收到从外设发来的数据了！")
                for i in 0..<allData!.count {
                    
                    print("数据为：\(reportData[i])！")

                }
                
                }
        }
    }
    
    func APPsendData(data:Data) -> Void {
        peripheral?.writeValue(data, for: characteristicRx!, type: CBCharacteristicWriteType.withResponse)
        }
    //  向外设写入数据成功的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("为名字为：\(peripheral.name)的设备，UUID为\(characteristic.uuid)的特征写入数据时失败！失败原因：\(error)")
        }else{
            
            print("为名字为：\(peripheral.name)的设备，UUID为\(characteristic.uuid)的特征写入数据成功！")
            peripheral.readValue(for: characteristic)
        }
    }


}
