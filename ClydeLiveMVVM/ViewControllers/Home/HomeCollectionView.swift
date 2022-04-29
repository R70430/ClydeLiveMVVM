//
//  HomeCollectionView.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/4/29.
//


import UIKit
import SDWebImage

//MARK: - EX - CollectionViewDelegate、DataSource
extension HomeVC:UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 1.要產生的Cell總數
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //回傳 streamerDataArray 的資料數
        return streamerDataArray.count
    }
    
    // 2.設定Cell內要顯示的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //連接自訂的cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsID.homeCell.rawValue, for: indexPath) as! HomesStreamerCollectionVCell
        
        //變更直播主的圖片
        let imgURL = URL(string: streamerDataArray[indexPath.row].head_photo)
        
        cell.streamerImageView.sd_setImage(
            with: imgURL,
            placeholderImage: UIImage(named: assetsImageName.paopao.rawValue))
        
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
    
    // 3.Cell被點擊時要執行的內容
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //連接自訂的cell
        selectedCell = collectionView.cellForItem(at: indexPath) as? HomesStreamerCollectionVCell
        //快照
        selectedCellImageViewSnapshot = selectedCell?.streamerImageView.snapshotView(afterScreenUpdates: false)
        //動畫開始
        enterStreamAnimationView?.isHidden = false
        enterStreamAnimationView?.play()
        //延時1秒
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            //動畫結束
            self.enterStreamAnimationView?.isHidden = true
            self.enterStreamAnimationView?.stop()
            
            //換頁
            self.presentStreamerVC(with: self.selectedCell.streamerImageView.image!)
        }
    }
}
