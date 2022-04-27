//
//  AlertVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/19.
//

import UIKit
import RxCocoa
import RxSwift
import AVFAudio

class AlertVC: UIViewController {
    
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    let disposeBag = DisposeBag()
}
//MARK: - Override
extension AlertVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        //離開按鈕
        leaveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        //留下按鈕
        cancelButton.rx.tap
            .subscribe(onNext: {[weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
