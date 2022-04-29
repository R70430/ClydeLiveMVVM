//
//  SnapShotTransition.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/4/29.
//

import Foundation
import UIKit

//MARK: - Present(放大)
class SnapShotZoomInTrans:NSObject ,UIViewControllerAnimatedTransitioning {
    
    static let durationTime = 0.5
    //所需的屬性
    private let type: PresentationType
    private let firstVC: HomeVC
    private let secondVC: StreamerVC
    private let selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    //初始化，
    init?(type: PresentationType, firstViewController: HomeVC, secondViewController: StreamerVC, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstVC = firstViewController
        self.secondVC = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        
        guard
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedCell
        else { return nil }
        
        // B2 - 11
        self.cellImageViewRect = selectedCell.streamerImageView.convert(selectedCell.streamerImageView.bounds, to: window)
    }
    
    
    // 持續時間
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.durationTime
    }
    // 效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //處理轉場時的View
        let myContainerView = transitionContext.containerView
        
        // 將終點視圖放入myContainerView內
        
        guard
            let toView = secondVC.view
        else {
            print("失敗了")
            return
        }
        myContainerView.addSubview(toView)
        
        guard
            let mySelectedCell = firstVC.selectedCell,
            let window = firstVC.view.window ?? secondVC.view.window,
            let cellImageSnapShot = mySelectedCell.streamerImageView.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapShot = secondVC.view.snapshotView(afterScreenUpdates: true)
        else {
            
            transitionContext.completeTransition(true)
            return
        }
        //
        let isPresenting = type.isPresenting
        let imageViewSnapshot:UIView
        if isPresenting {
            imageViewSnapshot = cellImageSnapShot
        } else {
            imageViewSnapshot = controllerImageSnapShot
        }
        
        toView.alpha = 0
        
        [imageViewSnapshot].forEach { myContainerView.addSubview($0) }
        
        let controllerImageViewRect = secondVC.view.convert(secondVC.view.bounds, to: window)
        
        [imageViewSnapshot].forEach { $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect }
        
        // B3 - 27
        UIView.animateKeyframes(withDuration: Self.durationTime, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                // B3 - 28
                imageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
            }
        }, completion: { _ in
            // B3 - 29
            imageViewSnapshot.removeFromSuperview()
            
            // B3 - 30
            toView.alpha = 1
            
            // B3 - 31
            transitionContext.completeTransition(true)
        })
        
    }
    
}

//定義是要用 present 還是 dismiss
enum PresentationType {
    case present
    case dismiss
    var isPresenting: Bool {
        return self == .present
    }
}
