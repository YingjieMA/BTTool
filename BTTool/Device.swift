/*
 由于外设的设备名称与广播的名称不同
 
 搜索到设备的 回调方法里  设备的广播名字和设备对象是两个不同的参数
 
 为了将设备的广播名字与外设对象相对应，新建一个BLEdevice类 这个类拥有两个存储属性
 1. 外设对象 peripheral
 2. 外设对象的广播名字 advName
 
 */
import UIKit
import CoreBluetooth
class Device: NSObject {
    
    var advName : AnyObject?;
    var peripheral : CBPeripheral?;
    

}
