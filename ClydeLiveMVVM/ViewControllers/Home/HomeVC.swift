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

//MARK: - Variable
class HomeVC: UIViewController {
    //Firebase 監聽器
    var handle: AuthStateDidChangeListenerHandle?
    //儲存現有直播主的資料 Array
    var streamerDataArray = [StreamersCellData]()
    //被點擊的Cell
    var selectedCell: HomesStreamerCollectionVCell!
    //被點擊的Cell的快照
    var homeSelectedCellSnapshot: UIView?
    //負責跟Server傳送或取得資料的ViewModel
    let serversDataVM = ServersDataViewModel()
    //進入直播間動畫
    var enterStreamAnimationView: AnimationView?
    //快照轉場動畫
    var snapShotTrans:SnapShotZoomInTrans?
    
    //CollectionView
    @IBOutlet weak var homeCollectionView: UICollectionView!
    //ImageView
    @IBOutlet weak var photoImageView: UIImageView!
    //Label
    @IBOutlet weak var nickNameLabel: UILabel!
}


//MARK: - Override
extension HomeVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定delegate
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        //設定Layout
        flowLayoutSetting()
        //設定動畫
        settingAnimate()
        
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
        homeCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if handle != nil {
            //移除監聽器
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
}


//MARK: - Function
extension HomeVC {
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
        homeCollectionView.collectionViewLayout = streamerCelllayout
    }
    
    //設定動畫
    func settingAnimate(){
        //初始化進入動畫
        enterStreamAnimationView = AnimationView(name: "openDarkDoor")
        if let av = enterStreamAnimationView{
            av.frame = view.frame
            av.contentMode = .scaleAspectFit
            av.isHidden = true
            av.animationSpeed = 1.5
            av.alpha = 0.9
        }
        view.addSubview(enterStreamAnimationView!)
    }
    
    //換頁到直播間
    func presentStreamerVC(with image:UIImage){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardsVCsID.streamer.rawValue) as! StreamerVC
        vc.transitioningDelegate = self
        vc.transImage = image
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}






