//
//  LoginVM.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/4/27.
//

import Foundation
import RxSwift

class LoginVM {

    //輸入
    let acctValid: Observable<Bool>
    let passValid: Observable<Bool>

    //輸出
    init(
        acct:Observable<String>,
        pass:Observable<String>
    ){
        acctValid = acct
            .map{ $0.count >= 5 }
            .share(replay: 1)
        passValid = pass
            .map{ $0.count >= 5 }
            .share(replay: 1)
    }
}
