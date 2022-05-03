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
    
    static let durationTime = 0.6
    //所需的屬性(轉場種類，起始視圖、終點視圖、所選Cell的快照、所選Cell的座標
    private let type: PresentationType
    private let firstVC: HomeVC
    private let secondVC: StreamerVC
    private var selectedCellSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    //初始化(取得以上所需的屬性
    init?(type: PresentationType, firstViewController: HomeVC, secondViewController: StreamerVC, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstVC = firstViewController
        self.secondVC = secondViewController
        self.selectedCellSnapshot = selectedCellImageViewSnapshot
        
        guard
            //取得視窗、首頁被點擊的cell
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedCell
        else { return nil }
        
        // 取得被點擊的Cell的座標
        self.cellImageViewRect = selectedCell.streamerImageView.convert(selectedCell.streamerImageView.bounds, to: window)
    }
    
    
    // 持續時間
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(Self.durationTime)
    }
    
    //MARK: - 效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //處理轉場時的View
        let myContainerView = transitionContext.containerView
        
        // 將終點視圖放入myContainerView內
        
        guard
            let toView = secondVC.view
        else {
            print("取得toView時發生錯誤，使用基本轉場。")
            transitionContext.completeTransition(false)
            return
        }
        myContainerView.addSubview(toView)
        
        //(被點擊的cell、視窗、cell的圖片快照、直播間的快照
        guard
            let mySelectedCell = firstVC.selectedCell,
            let window = firstVC.view.window ?? secondVC.view.window,
            let cellImageSnapShot = mySelectedCell.streamerImageView.snapshotView(afterScreenUpdates: true),
            let controllerSnapShot = secondVC.view.snapshotView(afterScreenUpdates: true)
        else {
            print("取得各種SnapShot時發生錯誤，使用基本轉場。")
            transitionContext.completeTransition(true)
            return
        }
        //
        let isPresenting = type.isPresenting// 轉場的種類
        let backgroundView: UIView// 背景
        let fadeView = UIView(frame: myContainerView.bounds)// 淡出視圖
        
        //present的話，快照設為cellImageSnapShot
        if isPresenting{
            selectedCellSnapshot = cellImageSnapShot
            backgroundView = UIView(frame: myContainerView.bounds)
            fadeView.alpha = 0
        }else{
            backgroundView = firstVC.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }
        
        
        //初始透明度為0
        toView.alpha = 0
        
        [backgroundView,selectedCellSnapshot,controllerSnapShot]
            .forEach { myContainerView.addSubview($0) }
        
        let controllerImageViewRect = secondVC.view.convert(secondVC.view.bounds, to: window)
        
        [selectedCellSnapshot,controllerSnapShot]
            .forEach {
                $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
                $0.layer.cornerRadius = isPresenting ? 12 : 0
                $0.layer.masksToBounds = true
            }
        controllerSnapShot.alpha = isPresenting ? 0 : 1
        selectedCellSnapshot.alpha = isPresenting ? 1 : 0
        
        // 動畫關鍵幀
        UIView.animateKeyframes(
            withDuration: TimeInterval(Self.durationTime),
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                //第一幀
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                    // 為true，轉成 controllerImageViewRect ; 為false，轉成 cellImageViewRect
                    self.selectedCellSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                    controllerSnapShot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                    
                    fadeView.alpha = isPresenting ? 1 : 0
                    
                    [controllerSnapShot, self.selectedCellSnapshot].forEach {
                        $0.layer.cornerRadius = isPresenting ? 0 : 12
                    }
                }
                //第二幀
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                    // 被點選的Cell淡出
                    self.selectedCellSnapshot.alpha = isPresenting ? 0 : 1
                    // 第二頁的視圖截圖淡入
                    controllerSnapShot.alpha = isPresenting ? 1 : 0
                }
            }, completion: { _ in
                self.selectedCellSnapshot.removeFromSuperview()
                controllerSnapShot.removeFromSuperview()
                backgroundView.removeFromSuperview()
                toView.alpha = 1
                transitionContext.completeTransition(true)
            }
        )
    }
}

//定義是要用於 present 還是 dismiss
enum PresentationType {
    case present
    case dismiss
    var isPresenting: Bool {
        return self == .present
    }
}
