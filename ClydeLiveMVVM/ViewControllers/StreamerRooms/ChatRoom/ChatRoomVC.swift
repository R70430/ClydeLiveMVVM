//
//  ChatRoomVC.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/5/3.
//

import UIKit

class ChatRoomVC: UIViewController {
    var chatMessageArray = ["0","1","2"]
}
extension ChatRoomVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
extension ChatRoomVC: UITableViewDelegate {
    
}
extension ChatRoomVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomTableCell
        return cell
    }
    
    
}
