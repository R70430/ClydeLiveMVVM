//
//  StreamerRoomsVC.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/5/3.
//

import UIKit
import AVKit
import RxCocoa
import RxSwift
//MARK: - Variable
class StreamerRoomsVC: UIViewController {
    
    var videoArray = [1,2,3,4,5,6,7,8,9]
    var oldAndNewIndices = (0,0)
    @objc dynamic var currentIndex = 0
    // AVPlayer - 負責控制播放器的操作
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    var playerItem: AVPlayerItem!// 管理媒體資源對象，提供播放數據來源
    var videoURL = Bundle.main.url(
        forResource: "hime3", withExtension: "mp4")
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var streamerRoomsTableView: UITableView!
    
}
//MARK: - Override
extension StreamerRoomsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
}
//MARK: - Function
extension StreamerRoomsVC {
    //配置TableView
    func configureTableView(){
        if let vw = streamerRoomsTableView {
            //設定cell高
            vw.rowHeight = UIScreen.main.bounds.height
            vw.estimatedRowHeight = UIScreen.main.bounds.height
            vw.separatorStyle = .none// 分隔線樣式
            vw.estimatedSectionHeaderHeight = CGFloat.leastNormalMagnitude
            vw.sectionHeaderHeight = CGFloat.leastNormalMagnitude
            vw.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
            vw.sectionFooterHeight = CGFloat.leastNormalMagnitude
            vw.contentInsetAdjustmentBehavior = .never
            vw.delegate = self
            vw.dataSource = self
        }
    }
    
}

//MARK: - TableViewDelegate & DataSource
extension StreamerRoomsVC:UITableViewDelegate,UITableViewDataSource {
    
    
    // cell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    // cell內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellsID.StreamerRoomsCell.rawValue, for: indexPath) as! StreamerRoomsTableCell
        // 添加離開功能
        cell.exitButton.rx.tap
            .subscribe(onNext: {[weak self] in
                self!.toExitAlert()
            })
            .disposed(by: disposeBag)
        
        // 要移到最前方的 element
        let frontArray = [cell.exitButton,cell.chatView]
        // 配置影片
        configureVideo(videoView: cell.videoView, viewsToFrontArray: frontArray)
        
        return cell
    }
    
    
    
    //配置影片
    func configureVideo(videoView: UIView,viewsToFrontArray:[UIView?]){
        
        //初始化媒體資源管理者
        playerItem = AVPlayerItem(url: videoURL!)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(
            player: queuePlayer, templateItem: playerItem)
        
        //創建顯示影片的圖層
        let playerLayer = AVPlayerLayer.init(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = videoView.frame
        
        videoView.layer.addSublayer(playerLayer)
        
        if viewsToFrontArray.count > 0{
            for i in 0...viewsToFrontArray.count - 1 {
                videoView.bringSubviewToFront(viewsToFrontArray[i]!)
            }
        }
        queuePlayer.volume = 0// 靜音
        //播放
        queuePlayer.play()
    }
    
    func toExitAlert(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
}


