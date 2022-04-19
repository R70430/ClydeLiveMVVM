//
//  PersonalInfoVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/18.
//
import FirebaseAuth
import FirebaseStorage
import UIKit


class PersonalInfoVC: UIViewController {
    //MARK: - Variable
    //圖片選擇器
    let picker = UIImagePickerController()
    // Firebase 監聽器
    var handle: AuthStateDidChangeListenerHandle?
    //已選擇的頭像
    var selectedImage = UIImage()
    //MARK: - @IBOutlet
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        //隱藏返回按鍵
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            
            guard
                let dName = user?.displayName,
                let email = user?.email
            else {
                print("在 PersonalInfoVC 的 Firebase 監聽器沒有監聽到登入資料")
                return
            }
            self.nickNameLabel.text = "暱稱：\(dName)"
            //刪除 @ 以後的內容
            var myAccount = ""
            if let index = email.range(of: "@")?.lowerBound {
                let substring = email[..<index]
                myAccount = String(substring)
            }
            
            self.accountLabel.text = "帳號：\(myAccount)"
            //利用email取得頭像
            Storage.storage().reference().child("\(email)/profilePhoto.jpg").getData(maxSize: .max) { data, err in
                guard let photoData = data,
                      let photoImage = UIImage(data: photoData)
                else{
                    print("沒有拿到頭像\(err!.localizedDescription)")
                    return
                }
                self.photoImageView.image = photoImage
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    //MARK: - Function
    //登出功能
    func logout(){
        do{
            try Auth.auth().signOut()
            let alert = UIAlertController(title: "帳號已登出", message: "即將跳轉回登入頁面", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default) { alertAction in
                self.dismiss(animated: true)
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: storyboardsVCsID.login.rawValue) as? LoginVC {
                    controller.modalPresentationStyle = .currentContext
                    self.navigationController?.viewControllers = [controller]
                }
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
        }catch{
            let alert = UIAlertController(title: "登出發生錯誤", message: "錯誤訊息：『\(error.localizedDescription)』", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
    }
    
    //MARK: - @Action
    //修改照片
    @IBAction func editImageAction(_ sender: UIButton) {
    }
    //登出按鈕
    @IBAction func logoutAction(_ sender: UIButton) {
        logout()
    }
   
    
}
//MARK: - EX - ImagePicker

extension PersonalInfoVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // 選取照片時，會實作此function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImage = editedImage
            photoImageView.image = selectedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            photoImageView.image = selectedImage
        }
       
        dismiss(animated: true, completion: nil)
        
        
    }
}
