//
//  HomeTransition.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/4/29.
//

import Foundation
import UIKit
//MARK: - EX - UIViewControllerTransitioningDelegate
extension HomeVC: UIViewControllerTransitioningDelegate {
    
    //Persent
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        guard
            let secondVC = presented as? StreamerVC,
            let snapShot = homeSelectedCellSnapshot
        else{
            return nil
        }
        
        snapShotTrans = SnapShotZoomInTrans(type: .present, firstViewController: self, secondViewController: secondVC, selectedCellImageViewSnapshot: snapShot)
        
        return snapShotTrans
    }
    
    
    //Dismiss
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard
            let secondVC = dismissed as? StreamerVC,
            let snapShot = homeSelectedCellSnapshot
        else{
            return nil
        }
        snapShotTrans = SnapShotZoomInTrans(type: .dismiss, firstViewController: self, secondViewController: secondVC, selectedCellImageViewSnapshot: snapShot)
        return snapShotTrans
    }
    
}
