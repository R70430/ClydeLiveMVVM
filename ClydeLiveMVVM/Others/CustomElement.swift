//
//  RoundButton.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/16.
//

import Foundation
import UIKit

//圓角按鈕
class CERoundButton :UIButton{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height * 0.5
    }
}
//圓角圖片
class CERoundImageView: UIImageView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height * 0.1
    }
}
//正圓圖片
class CECircleImageView: UIImageView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height * 0.5
    }
}
//圓角輸入框
class CERoundTextField: UITextField{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height * 0.5
        self.attributedPlaceholder = NSAttributedString(string: "   一起聊個天吧...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        self.textColor = .white
    }
}
//圓角輸入框
class CERoundTextView: UITextView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height * 0.5
    }
}
//圓角標籤
class CERoundLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height * 0.5
    }
}
class CERoundView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height * 0.5
    }
}
