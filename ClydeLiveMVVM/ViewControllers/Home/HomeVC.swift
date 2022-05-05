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
    
    let firebaseVM = FirebaseViewModel()
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
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //取得 nickMame
        firebaseVM.getFirebaseUsersDisplayName { nickName in

            guard nickName != nil else {
                self.nickNameLabel.text = "訪客"
                return
            }

            self.nickNameLabel.text = nickName
        }
        //取得 頭像
        firebaseVM.getFirebaseUsersProfilePhoto { image in
            guard image != nil else { return }
            self.photoImageView.image = image
        }
        
        
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
        
        
        //移除 Firebase 監聽器
        guard handle != nil else {return}
        Auth.auth().removeStateDidChangeListener(handle!)
        
    }
}


//MARK: - Function
extension HomeVC {
    // 配置 CollectionView
    func configureCollectionView(){
        //設定 delegate
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        //設定 Layout
        homeCollectionView.collectionViewLayout = configureFlowLayout()
    }
    // 配置 CollectionView 的 FlowLayout
    func configureFlowLayout() -> UICollectionViewFlowLayout{
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
        return streamerCelllayout
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






