//
//  StreamerRoomsTableCell.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/5/4.
//

import UIKit
import AVKit
//MARK: - Variable & @IBOutlet
class StreamerRoomsTableCell: UITableViewCell {
    
    // AVPlayer - 負責控制播放器的操作
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    var playerItem: AVPlayerItem!// 管理媒體資源對象，提供播放數據來源
    var videoURL = Bundle.main.url(
        forResource: "hime3", withExtension: "mp4")
    
    // Button
    @IBOutlet weak var exitButton: CERoundButton!
    @IBOutlet weak var sendButton: CERoundButton!
    // TableView
    @IBOutlet weak var chatTableView: UITableView!
    // TextField
    @IBOutlet weak var chatTextField: UITextField!
    // View
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var chatView: UIView!
    
}
//MARK: - Override
extension StreamerRoomsTableCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
  
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//MARK: - function
extension StreamerRoomsTableCell {
    
    
}
