//
//  startTBVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/21.
//

import UIKit

class startTBVC: UITabBarController {
    
    
    
    //MARK: -  Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tabBar.tintColor = .black
    }
    // 當點擊tabBar的時候，自動執行此func
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //使用枚舉遍歷,判斷選中的tabBarItem等於Array中的第幾個
        for (k,v) in (tabBar.items?.enumerated())! {
            if v == item {
                // print出選中的item圖示
                print(k)
                // 將圖示傳入動畫function
                animationWithIndex(index: k)
            }
        }
    }
    
    //----------------------------------------------------
    // 動畫方法
    func animationWithIndex(index:Int){
        
        // 不知為何，無法設定Array的類型為UITabBarButton，所以設定成Any
        var tabbarbuttonArray:[Any] = [Any]()
        
        for tabBarBtn in self.tabBar.subviews {
            if tabBarBtn.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabbarbuttonArray.append(tabBarBtn)
            }
        }
        //----------------------------------------------------
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        pulse.duration = 0.08
        pulse.repeatCount = 1
        pulse.autoreverses = true
        pulse.fromValue = 0.7
        pulse.toValue = 1.5
        
        //給tabBar添加動畫效果
        let tabBarLayer = (tabbarbuttonArray[index] as AnyObject).layer
        tabBarLayer?.add(pulse, forKey: nil)
        
    }
    
    
    
}
