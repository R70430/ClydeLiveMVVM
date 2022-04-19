//
//  HomeVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//

import FirebaseAuth
import FirebaseStorage
import SDWebImage
import UIKit
import Lottie

class HomeVC: UIViewController {
    
    //MARK: - Variable
    //Firebase 監聽器
    var handle: AuthStateDidChangeListenerHandle?
    //儲存現有直播主的資料 Array
    var streamerDataArray = [StreamersCellData]()
    //負責跟Server傳送或取得資料的ViewModel
    let serversDataVM = ServersDataViewModel()
    //進入直播間動畫
    private var enterStreamAnimationView: AnimationView?
    
    //MARK: - @IBOutlet
    //CollectionView
    @IBOutlet weak var streamersCollectionView: UICollectionView!
    //ImageView
    @IBOutlet weak var photoImageView: UIImageView!
    //Label
    @IBOutlet weak var nickNameLabel: UILabel!
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定Layout
        flowLayoutSetting()
        //設定動畫
        settingAnimate()
          
        //設定delegate
        streamersCollectionView.delegate = self
        streamersCollectionView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //添加監聽器 並取得 nickName 與 personalPhoto
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            
            //檢查 user 是否有資料
            guard
                let userData = user,
                let myNickName = userData.displayName,
                let userEmail = userData.email
            else{
                print("沒有監聽到 user 資料")
                self.nickNameLabel.text = "訪客"
                self.photoImageView.image = UIImage(named: assetsImageName.picPersonal.rawValue)
                return
            }
            self.nickNameLabel.text = myNickName
            //取得頭像
            Storage.storage().reference().child("\(userEmail)/profilePhoto.jpg").getData(maxSize: .max) { photoData, err in
                guard
                    let myData = photoData,
                    let img = UIImage(data: myData)
                else{
                    print("取得 Firebase Storage 的 profilePhoto.jpg 失敗:\(err!.localizedDescription)")
                    return
                }
                self.photoImageView.image = img
            }
        })
        //取得 實況主的資料 準備塞入Cell (streamerData是DataModel裡要解析的資料)
        serversDataVM.serversStreamersJSONDecode(jsonString: streamerJSONString) { dataArray in
            guard let myDataArray = dataArray else { return }
            //指派成要塞入Cell的Array裡
            streamerDataArray = myDataArray
            
        }
        //重新整理 CollectionView
        streamersCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //檢查是否有監聽器
        guard handle != nil else{ return }
        //移除監聽器
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    //MARK: - Function
    //設定CollectionView的Layout
    func flowLayoutSetting(){
        //聊天室cell的通用Layout
        var streamerCelllayout: UICollectionViewFlowLayout{
            //實體化
            let lay = UICollectionViewFlowLayout()
            // 設置 section 的間距 四個數值分別代表 上、左、下、右 的間距
            lay.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
            // 設置每一行的間距
            lay.minimumLineSpacing = 10
            lay.minimumInteritemSpacing = 10
            // 設置每個 cell 的尺寸
            lay.itemSize = CGSize(width: (UIScreen.main.bounds.size.width)/2-10, height: (UIScreen.main.bounds.size.width)/2-10)
            // 設置 header 及 footer 的尺寸
            lay.headerReferenceSize = CGSize(
                width: UIScreen.main.bounds.size.width, height: 0)
            lay.footerReferenceSize = CGSize(
                width: UIScreen.main.bounds.size.width, height: 0)
            return lay
        }
        streamersCollectionView.collectionViewLayout = streamerCelllayout
    }
    
    func settingAnimate(){
        //初始化進入動畫
        enterStreamAnimationView = .init(name: "openDarkDoor")
        enterStreamAnimationView!.frame = view.frame
        enterStreamAnimationView!.contentMode = .scaleAspectFit
        enterStreamAnimationView?.isHidden = true
        enterStreamAnimationView!.animationSpeed = 1.5
        enterStreamAnimationView!.alpha = 0.9
        view.addSubview(enterStreamAnimationView!)
    }
}
//MARK: - EX -- CollectionView
extension HomeVC:UICollectionViewDelegate, UICollectionViewDataSource {
    
    //要產生的Cell總數
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //回傳 streamerDataArray 的資料數
        return streamerDataArray.count
    }
    //設定Cell內要顯示的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //連接自訂的cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsID.homeCell.rawValue, for: indexPath) as! HomesStreamerCollectionVCell
        
        //變更直播主的圖片
        let imgURL = URL(string: streamerDataArray[indexPath.row].head_photo)
        cell.streamerImageView.sd_setImage(with: imgURL, placeholderImage: UIImage(named: assetsImageName.paopao.rawValue))
        //播放動畫
        cell.musicAnimationView.play()
        //變更直播間標題
        cell.titleLabel.text = streamerDataArray[indexPath.row].stream_title
        //變更人數
        cell.numButton.setTitle("\(streamerDataArray[indexPath.row].online_num)", for: .normal)
        //變更Tag
        let tagArray = streamerDataArray[indexPath.row].tags.components(separatedBy: ",")
        if tagArray.count > 1 {
            cell.firstTagLabel.text = "#\(tagArray[0])"
            cell.secondTagLabel.isHidden = false
            cell.secondTagLabel.text = "#\(tagArray[1])"
        }else{
            cell.firstTagLabel.text = "#\(streamerDataArray[indexPath.row].tags)"
        }
        //變更直播主名稱
        cell.nameLabel.text = streamerDataArray[indexPath.row].nickname
        return cell
    }
    //Cell被點擊時要執行的內容
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        enterStreamAnimationView?.isHidden = false
        enterStreamAnimationView?.play()
        //延時1秒
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.enterStreamAnimationView?.isHidden = true
            self.enterStreamAnimationView?.stop()
            let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = myStoryboard.instantiateViewController(withIdentifier: storyboardsVCsID.streamer.rawValue)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
    }
    
    
}
