/*
 
 * 这个界面用于展示搜索到的设备
 
 * 使用tableview进行展示
 
 * 点击想要进行连接的设备名称，连接对应的蓝牙外设
 
 * 跳转到主界面进行数据展示
 
 */
import UIKit

class ViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource
 {
    @IBOutlet weak var deviceList: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    
    let tool = Tool();
    var timer:Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        tool.initBlueTooth();
        deviceList.delegate = self
        deviceList.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func btnClick(_ sender: Any) {
        //        点击搜索设备
        tool.scanDevice();
        timer = Timer.scheduledTimer(timeInterval: 3,target:self,selector:#selector(ViewController.myTimer),userInfo:nil,repeats:false)
        searchBtn.setTitle("正在扫描.....", for:.normal)

    }
    func myTimer() {
        deviceList.reloadData()
        searchBtn.setTitle("点击扫描设备", for:.normal)
        timer.invalidate()
        timer = nil;
    }
    
    // MARK:
    // MARK: tableview代理方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return tool.peripheralArray.count;
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if tool.peripheralArray.count > 0
        {
            let device = tool.peripheralArray[indexPath.row]
            
            if device.advName != nil {
                
                cell.textLabel!.text = device.advName as?String
                
            }else{
                
                cell.textLabel!.text = "UnKnownDevice"
            }
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if tool.peripheralArray.count>0 {
            
            let mainVC = MainViewContorller()
            let device = tool.peripheralArray[indexPath.row]
            
            mainVC.tool = tool
            mainVC.peripheral = device.peripheral
        
            tool.connectDevice(per: device.peripheral!)
            self.present(mainVC, animated: true, completion: nil)
            
        }
    }

}

