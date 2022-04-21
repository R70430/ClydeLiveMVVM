//
//  StreamerVC.swift
//  ClydeLiveMVVM
//
//  Created by ＭacR7 on 2022/4/17.
//

import AVKit
import UIKit
import FirebaseAuth
import Lottie

class StreamerVC: UIViewController {
    
    //MARK: - @Variable
    // Firebase - 監聽器
    var handle: AuthStateDidChangeListenerHandle?
    // AVPlayer - 負責控制播放器的操作
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    // AVPlayer - 管理媒體資源對象 提供播放數據來源
    var playerItem: AVPlayerItem!
    // WebSocket - 伺服器網址(不含Key
    let urlString = "wss://client-dev.lottcube.asia/ws/chat/chat:app_test?nickname="
    //wss://client-dev.lottcube.asia
    //WebSocket - Key
    var urlKeyString = "訪客"
    //WebSocket - webSocketTask
    var webSocketTask: URLSessionWebSocketTask!
    //聊天內容的Array
    var chatMessageArray = [String]()
    //進入動畫
    private var loveAnimationView: AnimationView?
    //MARK: - @IBOutlet
    //RoundButton
    @IBOutlet weak var exitRoundButton: CERoundButton!
    @IBOutlet weak var sendButton: CERoundButton!
    @IBOutlet weak var donateBikeButton: CERoundButton!
    @IBOutlet weak var chatBottomLayoutConstraint: NSLayoutConstraint!
    //TableView
    @IBOutlet weak var chatTableView: UITableView!
    //TextField
    @IBOutlet weak var chatTextField: UITextField!
    //View
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var chatViewButtomLayoutConstraint: NSLayoutConstraint!
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.transform = CGAffineTransform(rotationAngle: .pi)
        //播放影片
        playStreamerVideo()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        //初始化進入動畫
        loveAnimationView = .init(name: "loves")
        loveAnimationView!.frame = view.frame
        loveAnimationView!.contentMode = .scaleAspectFit
        //loveAnimationView?.isHidden = true
        loveAnimationView!.animationSpeed = 1
        loveAnimationView!.alpha = 0.9
        view.addSubview(loveAnimationView!)
        loveAnimationView?.play()
        //延時1秒
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.loveAnimationView?.isHidden = true
            self.loveAnimationView?.stop()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
        //新增監聽器 並且獲取用戶資料
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            //取得暱稱
            guard let dName = user?.displayName else {return}
            
            self.urlKeyString = "\(dName)"
            print("取得暱稱：\(self.urlKeyString)")
        }
        DispatchQueue.main.async {
            //連接websocket
            self.webSocketConnect()
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()

        //移除監聽器
        Auth.auth().removeStateDidChangeListener(handle!)
        //停止播放
        queuePlayer.pause()
        //斷開webSocket
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //MARK: - @Function
    //增加鍵盤監聽器
    func addKeyboardObserver() {
        // 鍵盤監聽器
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //移除鍵盤監聽器
    func removeKeyboardObserver() {
        // 鍵盤監聽器
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // 播放影片
    func playStreamerVideo(){
        //影片的位址
        let videoUrl = Bundle.main.url(forResource: "hime3", withExtension: "mp4")
        //初始化媒體資源管理者
        playerItem = AVPlayerItem(url: videoUrl!)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
   
        //創建顯示影片的圖層
        let playerLayer = AVPlayerLayer.init(player: queuePlayer)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.view.frame
        self.view.layer.addSublayer(playerLayer)
        
        //播放
        queuePlayer.play()
        
        self.view.bringSubviewToFront(chatView)
        self.view.bringSubviewToFront(exitRoundButton)
    }
    //webSocket連接
    func webSocketConnect(){
        guard
            let newURLString = "\(urlString)\(urlKeyString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: newURLString)
        else {
            print("錯誤：無法創建URL")
            return
        }
        //建立request
        let request = URLRequest(url: url)
        //
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        //連接
        webSocketTask.resume()
        receive()
   
    }
    //接收
    private func receive() {
        
        webSocketTask.receive { result in
            print("有到這邊")
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                    //用解碼器解碼
                    let myJSONCodable = self.myJSONDecode(str: text)
                    guard myJSONCodable != nil else {
                        print("myJSONCodable為nil")
                        return}
                    self.getChatCodableData(codableData: myJSONCodable!)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                print(error)
            }
            self.receive()
        }
    }
    
    //JSON解碼器
    func myJSONDecode(str:String) -> ChatCodable?{
        
        //轉Data
        guard let myData = str.data(using: .utf8) else {return nil}
        //建立解碼器
        let decoder = JSONDecoder()
        
        do {
            let jsonCodable = try decoder.decode(ChatCodable.self, from: myData)
            return jsonCodable
        } catch {
            print("JSON解碼錯誤：\(error.localizedDescription)")
        }
        return nil
    }
    
    //取得聊天室需要的資料
    func getChatCodableData(codableData:ChatCodable){
        
        //檢查是否有event
        guard let eventString = codableData.event else{return}
        
        switch eventString {
            //一般發話
        case chatCodableEvent.default_message.rawValue:
            
            appendDefaultMessage(codableData: codableData)
            
            //進出更新通知
        case chatCodableEvent.sys_updateRoomStatus.rawValue:
            appendSysUpdateRoomStatus(codableData: codableData)
            break
            //系統廣播
        case chatCodableEvent.admin_all_broadcast.rawValue:
            appendAdminAllBroadcast(codableData: codableData)
            break
            //房間關閉
        case chatCodableEvent.sys_room_endStream.rawValue:
            appendSysRoomEndStream(codableData: codableData)
            break
        default:
            print("出現了未知事件！！！！")
            break
        }
        DispatchQueue.main.async {
            //重新整理cell
            self.chatTableView.reloadData()
        }
    }
    func appendDefaultMessage(codableData:ChatCodable){
        //取得暱稱與內容
        let chatNickName = codableData.body?.nickname
        let chatText = codableData.body?.text
        guard
            chatNickName != nil,
            chatText != nil
        else{
            print("『一般發話』中 ,chatNickName或chatText出現nil")
            return
        }
        //建立完整的對話String
        let myChatMessage = "\(chatNickName!)：\(chatText!)"
        chatMessageArray.append(myChatMessage)
    }
    func appendSysUpdateRoomStatus(codableData:ChatCodable){
        //取得用戶暱稱與動作
        guard
            let chatUserName = codableData.body?.entry_notice?.username,
            var chatAction = codableData.body?.entry_notice?.action
        else{
            print("『進出更新通知』中 ,chatNickName或chatText出現nil")
            return
        }
        if chatAction == "enter" {
            chatAction = "進入"
        }else if chatAction == "leave"{
            chatAction = "離開"
        }
        
        //建立完整的對話String
        let myChatMessage = "『\(chatUserName)』\(chatAction) 了聊天室～"
        chatMessageArray.append(myChatMessage)
    }
    func appendAdminAllBroadcast(codableData:ChatCodable){
        //取得系統廣播的內容
        guard
            let chatContentText = codableData.body?.content?.tw
        else{
            print("『系統廣播』中 ,chatNickName或chatText出現nil")
            return
        }
        //建立完整的對話String
        let myChatMessage = "\(chatContentText)"
        chatMessageArray.append(myChatMessage)
    }
    func appendSysRoomEndStream(codableData:ChatCodable){
        //type
        guard
            let chatType = codableData.body?.type
        else{
            print("『房間關閉』中 ,chatType沒有獲取C")
            return
        }
        if chatType == "C" {
            guard
                let chatText = codableData.body?.text
            else {
                print("『房間關閉』中 ,chatText為nil")
                return
            }
            //建立完整的對話String
            let myChatMessage = "\(chatText)"
            chatMessageArray.append(myChatMessage)
        }
    }
    //送訊息給伺服器
    func sendDataToServer(str:String){
        
        var sendJSONCodeble: sendCodable!
        
        sendJSONCodeble = sendCodable(action: "N", content: str)
        
        let encoder = JSONEncoder()
        do {
            //編碼
            let sendJSON = try encoder.encode(sendJSONCodeble)
            let webMes = URLSessionWebSocketTask.Message.data(sendJSON)
            webSocketTask.send(webMes) { err in
                if let er = err {
                    print("發送內容時發生錯誤：\(er.localizedDescription)")
                }
            }
        } catch {
            print("JSON編碼時發生錯誤：\(error.localizedDescription)")
        }
        chatTextField.text = ""

    }
    
    //鍵盤彈出時觸發
    @objc func keyboardWillShow(notification: Notification) {
        //鎖住離開按鈕
        exitRoundButton.isEnabled = false
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            // 取得鍵盤高度
            let keyboardRectHeight = keyboardFrame.cgRectValue.height
            
            if chatViewButtomLayoutConstraint.constant < (keyboardRectHeight - 54){
                chatViewButtomLayoutConstraint.constant += (keyboardRectHeight - 44)
            }
        }
    }
    //鍵盤收起時觸發
    @objc func keyboardWillHide(notification: Notification) {
        //解鎖離開按鈕
        exitRoundButton.isEnabled = true
        // 讓view回復原位
        chatViewButtomLayoutConstraint.constant = 0.0
    }
    //MARK: - @IBAction
    @IBAction func exitAction(_ sender: CERoundButton) {

        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = myStoryboard.instantiateViewController(withIdentifier: "AlertVC")
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    @IBAction func sendAction(_ sender: CERoundButton) {
        //檢查輸入框是否有內容
        guard
            let chatText = chatTextField.text
        else{return}
        //原始字符串
        let newText = chatText.replacingOccurrences(of: " ", with: "")
        guard newText.count > 0 else {
            chatTextField.text = ""
            return
            
        }
        sendDataToServer(str: chatText)
    }
    func donate(sender:UIButton,commodity:String,price:Int,animateName:String,time:Double,contentMode:UIView.ContentMode){
        sender.isEnabled = false
        let alert = UIAlertController(title: "購買\(commodity)給直播主嗎？", message: "即將使用 \(price) 泡泡幣購買\(commodity)給直播主，確定購買？", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "買下去", style: .default) { alertAction in
            //初始化動畫
            self.loveAnimationView = .init(name: animateName)
            if let ani = self.loveAnimationView {
                ani.frame = self.view.frame
                ani.contentMode = contentMode
                ani.isHidden = false
                ani.animationSpeed = 1
                ani.alpha = 0.7
            }
            self.view.addSubview(self.loveAnimationView!)
            self.loveAnimationView?.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                sender.isEnabled = true
                self.loveAnimationView?.isHidden = true
                self.loveAnimationView?.stop()
            }
        }
        alert.addAction(yesAction)
        let noAction = UIAlertAction(title: "我沒錢", style: .cancel) { alertAction in
            sender.isEnabled = true
        }
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func donateBikeAction(_ sender: UIButton) {
        donate(sender: sender, commodity: "腳踏車", price: 500, animateName: "bicycle", time: 2, contentMode: .scaleAspectFill)
    }
    
    @IBAction func donateRocketAction(_ sender: UIButton) {
        donate(sender: sender, commodity: "火箭", price: 10000000, animateName: "rocket", time: 2.5, contentMode: .scaleAspectFill)
    }
    
    @IBAction func donateHouseAction(_ sender: UIButton) {
        donate(sender: sender, commodity: "房子", price: 5000000, animateName: "house", time: 2, contentMode: .scaleAspectFit)
    }
    
    
}
//MARK: - EX - TableView
extension StreamerVC: UITableViewDelegate, UITableViewDataSource {
    
    //Cell的總數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count
    }
    //Cell要放的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //建立自定義Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellsID.ChatCell.rawValue, for: indexPath) as! StreamersChatroomTableVCell
        //旋轉Cell
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        //變更array顯示順序
        let newIndexPathRow = chatMessageArray.count - 1 - indexPath.row
        cell.chatTextView.text = "  \(chatMessageArray[newIndexPathRow])  " 
        //回傳自定義的cell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
}
struct sendCodable:Codable {
    var action:String
    var content:String
}
