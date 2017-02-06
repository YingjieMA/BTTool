/*
 这是整个应用程序的主界面
 
 用于显示主要的数据
 
 以及和蓝牙进行数据的交互
 
 */

import UIKit
import CoreBluetooth
class MainViewContorller: UIViewController {
    var tool :Tool!
    var peripheral :CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blue
        
        
        
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
