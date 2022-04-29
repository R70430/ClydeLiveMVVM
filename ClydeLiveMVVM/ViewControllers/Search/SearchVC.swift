//
//  SearchVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//
import SDWebImage
import UIKit
import Lottie
class SearchVC: UIViewController {
    
    //MARK: - Variable
    //全部實況主的Array
    var streamerDataArray = [StreamersCellData]()
    //熱門推薦的Array
    var hotArray = [StreamersCellData]()
    //搜尋結果的Array
    var searchResultArray = [StreamersCellData]()
    
    let serversDataVM = ServersDataViewModel()
    //進入直播間動畫
    private var enterStreamAnimationView: AnimationView?
    //MARK: - @IBOutlet
    //CollectionView
    @IBOutlet weak var streamersCollectionView: UICollectionView!
    //SearchBar
    @IBOutlet weak var StreamersSearchBar: UISearchBar!
}
//MARK: - override
extension SearchVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayoutSetting()
        settingAnimate()
        streamersCollectionView.delegate = self
        streamersCollectionView.dataSource = self
        StreamersSearchBar.delegate = self
  
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //取得全部實況主的資料
        serversDataVM.serversStreamersJSONDecode(jsonString: streamerJSONString) { dataArray in
            //檢查是否有拿到值
            guard let myDataArray = dataArray else { return }
            //指派成 streamerDataArray
            streamerDataArray = myDataArray
        }
        
        //取得熱門推薦的資料
        ServersDataViewModel().serversLightyearJSONDecode(jsonString: streamerJSONString) { dataArray in
            //檢查是否有拿到值
            guard let myDataArray = dataArray else { return }
            //指派成 hotArray
            hotArray = myDataArray
        }
        //重新整理 CollectionView
        streamersCollectionView.reloadData()
    }
    // 點選任意空白處收起鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //取消編輯狀態
        self.view.endEditing(true)
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
                width: UIScreen.main.bounds.size.width, height: 50)
            lay.footerReferenceSize = CGSize(
                width: UIScreen.main.bounds.size.width, height: 0)
            return lay
        }
        streamersCollectionView.collectionViewLayout = streamerCelllayout
        
    }
    //設定動畫
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
//MARK: - EX - CollectionView
extension SearchVC:UICollectionViewDelegate,UICollectionViewDataSource {
    
    //Section的數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        //依照 searchResultArray 是否有內容決定 Section 的數量
        switch searchResultArray.count {
        case 0:
            return 1
        default:
            return 2
        }
    }
    
    //cell的數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //如果 searchResultArray 中沒有資料，只顯示 hotArray 的內容
        guard searchResultArray.count != 0 else{
            return hotArray.count
        }
        
        switch section {
        case 0:
            return searchResultArray.count
        case 1:
            return hotArray.count
        default:
            return 0
        }
    }
    //將內容放入Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsID.SearchCell.rawValue, for: indexPath) as! SearchsStreamerCollectionVCell
        
        //
        if searchResultArray.count == 0 {
            //變更直播主的圖片 在熱門推薦
            let imgURL = URL(string: hotArray[indexPath.row].head_photo)
            cell.streamerImageView.sd_setImage(with: imgURL, placeholderImage: UIImage(named: assetsImageName.paopao.rawValue))
            //播放動畫
            cell.musicAnimationView.play()
            //變更標題
            cell.titleLabel.text = hotArray[indexPath.row].stream_title
            //變更人數
            cell.numButton.setTitle("\(hotArray[indexPath.row].online_num)", for: .normal)
            //變更Tag
            let tagArray = hotArray[indexPath.row].tags.components(separatedBy: ",")
            if tagArray.count > 1 {
                cell.firstTagLabel.text = "#\(tagArray[0])"
                cell.secondTagLabel.isHidden = false
                cell.secondTagLabel.text = "#\(tagArray[1])"
            }else{
                cell.firstTagLabel.text = "#\(hotArray[indexPath.row].tags)"
            }
            //變更暱稱
            cell.nameLabel.text = hotArray[indexPath.row].nickname
            return cell
        }else {
            if indexPath.section == 0 {
                //變更直播主的圖片 在搜尋結果
                let imgURL = URL(string: searchResultArray[indexPath.row].head_photo)
                cell.streamerImageView.sd_setImage(with: imgURL, placeholderImage: UIImage(named: assetsImageName.paopao.rawValue))
                //播放動畫
                cell.musicAnimationView.play()
                //變更標題
                cell.titleLabel.text = searchResultArray[indexPath.row].stream_title
                //變更人數
                cell.numButton.setTitle("\(searchResultArray[indexPath.row].online_num)", for: .normal)
                //變更Tag
                let tagArray = searchResultArray[indexPath.row].tags.components(separatedBy: ",")
                if tagArray.count > 1 {
                    cell.firstTagLabel.text = "#\(tagArray[0])"
                    cell.secondTagLabel.isHidden = false
                    cell.secondTagLabel.text = "#\(tagArray[1])"
                }else{
                    cell.firstTagLabel.text = "#\(searchResultArray[indexPath.row].tags)"
                }
                //變更暱稱
                cell.nameLabel.text = searchResultArray[indexPath.row].nickname
                return cell
            }else if indexPath.section == 1{
                //變更直播主的圖片 在熱門推薦
                let imgURL = URL(string: hotArray[indexPath.row].head_photo)
                cell.streamerImageView.sd_setImage(with: imgURL, placeholderImage: UIImage(named: assetsImageName.paopao.rawValue))
                //播放動畫
                cell.musicAnimationView.play()
                //變更標題
                cell.titleLabel.text = hotArray[indexPath.row].stream_title
                //變更人數
                cell.numButton.setTitle("\(hotArray[indexPath.row].online_num)", for: .normal)
                //變更Tag
                let tagArray = hotArray[indexPath.row].tags.components(separatedBy: ",")
                if tagArray.count > 1 {
                    cell.firstTagLabel.text = "#\(tagArray[0])"
                    cell.secondTagLabel.isHidden = false
                    cell.secondTagLabel.text = "#\(tagArray[1])"
                }else{
                    cell.firstTagLabel.text = "#\(hotArray[indexPath.row].tags)"
                }
                //變更暱稱
                cell.nameLabel.text = hotArray[indexPath.row].nickname
                return cell
            }
        }
        return cell
    }
    //被點擊時的功能
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
    //hearder
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

   
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headCell", for: indexPath) as! SearchHeaderView

           
        switch searchResultArray.count {
        case 0:
            print("只有熱門推薦")
            headerView.headerLabel.text = "熱門推薦"
            return headerView
        default:
            print("有搜尋")
            if indexPath.section == 0 {
                headerView.headerLabel.text = "搜尋結果"
                return headerView
            }else if indexPath.section == 1{
                headerView.headerLabel.text = "熱門推薦"
                return headerView
            }else{
                return headerView
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
  
}

//MARK: - EX - SearchBar
extension SearchVC:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 如果搜尋條件為空字串，清空searchResultArray。否則就顯示搜尋後結果。
        if searchText.isEmpty {
            searchResultArray.removeAll()
        }else{
            searchResultArray.removeAll()
            //
            for i in 0...streamerDataArray.count - 1 {
                //檢查暱稱 有包含 searchText 的字元
                let checkNickName = streamerDataArray[i].nickname.uppercased().contains(searchText.uppercased())
                let checkTag = streamerDataArray[i].tags.uppercased().contains(searchText.uppercased())
                let checkTitle = streamerDataArray[i].stream_title.uppercased().contains(searchText.uppercased())
                
                if (checkNickName)||(checkTag)||(checkTitle) {
                    searchResultArray.append(streamerDataArray[i])
                }
            }
        }
        print("測試")
        //重新整理CollectionView
        streamersCollectionView.reloadData()
    }
}
