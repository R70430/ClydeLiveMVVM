//
//  RegisterVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Lottie

class RegisterVC: UIViewController {
    //MARK: - Variable
    //圖片選擇器
    let picker = UIImagePickerController()
    //尚未換過圖片
    var changedPhoto = false
    //已選擇的頭像
    var selectedImage = UIImage()
    //起始位置
    var startLocation = CGFloat()
    //註冊中動畫
    private var registingAnimationView: AnimationView?
    //註冊成功動畫
    private var registSuccessAnimationView: AnimationView?
    //MARK: - @IBOutlet
    //ImageView
    @IBOutlet weak var photoImageView: UIImageView!
    //TextField
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //Label
    @IBOutlet weak var errorLabel: UILabel!
    //LayoutConstraint
    @IBOutlet weak var textFieldsLayoutConstraint: NSLayoutConstraint!
    //StackView
    @IBOutlet weak var tfStackView: UIStackView!
    
}
//MARK: - Override
extension RegisterVC {
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocation = textFieldsLayoutConstraint.constant
        print("原本的位置\(startLocation)")
        
        //變更Navigation返回鍵
        let backItem = UIBarButtonItem(
            image: UIImage(named: "titlebarBack")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backItemAction(_:))
        )
        self.navigationItem.leftBarButtonItem = backItem
        
        picker.delegate = self
        settingAnimate()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    // 點選任意空白處收起鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //取消編輯狀態
        self.view.endEditing(true)
    }
    //MARK: - Function
    //上傳圖片到 Firebase 的 Storage
    func updateImageToFirebaseStorage(imgFileName:String,img:UIImage,imgName:String){
        //建立storage服務
        let storageRef = FirebaseStorage.Storage.storage().reference().child(imgFileName).child(imgName)
        //將UIImage轉成Data
        if let imgData = img.jpegData(compressionQuality: 0.8){
            storageRef.putData(imgData, metadata: nil) { storageMetaData, error in
                guard
                    error == nil
                else{
                    print("updateImageToFirebaseStorage上傳個人頭像失敗")
                    return
                }
                print("updateImageToFirebaseStorage上傳個人頭像成功")
            }
        }else{
            print("updateImageToFirebaseStorage圖片轉檔失敗")
        }
    }
    //註冊中動畫
    func settingAnimate(){
        //初始化註冊中動畫
        registingAnimationView = AnimationView(name: "registing")
        if let ani = registingAnimationView {
            ani.frame = view.frame
            ani.contentMode = .scaleAspectFit
            ani.backgroundColor = .gray
            ani.isHidden = true
            ani.animationSpeed = 1
            ani.alpha = 0.8
        }
        view.addSubview(registingAnimationView!)
        
        //註冊成功動畫
        registSuccessAnimationView = AnimationView(name: "approved")
        if let ani = registSuccessAnimationView {
            ani.frame = view.frame
            ani.contentMode = .scaleAspectFit
            ani.isHidden = true
            ani.animationSpeed = 1
        }
        view.addSubview(registSuccessAnimationView!)
    }
    //檢查照片
    func checkPhoto() -> String?{
        guard changedPhoto == true else {
            return "＊請確認是否已設置頭像"
        }
        return nil
    }
    //檢查暱稱
    func checkNickName() -> String?{
        guard
            let nic = nickNameTextField.text,
            nic != "",
            nic.count < 9,
            nic.count > 1
        else {
            return "＊請確認『暱稱』是否正確填寫"
        }
        return nil
    }
    //檢查帳號
    func checkAccount() -> String?{
        guard
            let acc = accountTextField.text,
            acc != "",
            acc.count < 21,
            acc.count > 3
        else {
            return "＊請確認『帳號』是否正確填寫"
        }
        return nil
    }
    //檢查密碼
    func checkPassword() -> String?{
        guard
            let pas = accountTextField.text,
            pas != "",
            pas.count < 21,
            pas.count > 3
        else {
            return "＊請確認『密碼』是否正確填寫"
        }
        return nil
    }
    
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
    
    //MARK: - IBAction
    //修改圖片
    @IBAction func editImageAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "設置頭像", message: nil, preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "從相簿選取", style: .default) { alertAction in
            // 調用相簿
            self.picker.allowsEditing = true
            self.picker.sourceType = .savedPhotosAlbum
            self.present(self.picker, animated: true)
        }
        alert.addAction(albumAction)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { alertAction in
            // 調用相機
            self.picker.allowsEditing = true
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        }
        alert.addAction(cameraAction)
        let cancelAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    //送出
    @IBAction func sendAction(_ sender: UIButton) {
        //檢查頭像
        guard checkPhoto() == nil else {
            errorLabel.isHidden = false
            errorLabel.text = checkPhoto()
            return
        }
        //檢查暱稱
        guard checkNickName() == nil else {
            errorLabel.isHidden = false
            errorLabel.text = checkNickName()
            return
        }
        //檢查帳號
        guard checkAccount() == nil else {
            errorLabel.isHidden = false
            errorLabel.text = checkAccount()
            return
        }
        //檢查密碼
        guard checkPassword() == nil else {
            errorLabel.isHidden = false
            errorLabel.text = checkPassword()
            return
        }
        let account = accountTextField.text!
        let password = passwordTextField.text!
        let nickName = nickNameTextField.text!
        
        errorLabel.isHidden = true
        //註冊Firebase
        //開啟動畫
        registingAnimationView?.isHidden = false
        registingAnimationView?.play()
        let accountEmail = "\(account)@clmail.com"
        Auth.auth().createUser(withEmail: accountEmail, password: password) { user, err in
            //檢查是否發生錯誤
            guard err == nil else {
                //關閉動畫
                self.registingAnimationView?.isHidden = true
                self.registingAnimationView?.stop()
                let alert = UIAlertController(title: "註冊時發生錯誤", message: "錯誤訊息：『\(err!.localizedDescription)』", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                return
            }
            // 儲存個人資料
            guard let changRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
                //關閉動畫
                self.registingAnimationView?.isHidden = true
                self.registingAnimationView?.stop()
                let alert = UIAlertController(title: "儲存暱稱時發生錯誤", message: "錯誤訊息：『\(err!.localizedDescription)』", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                return
            }
            //增加暱稱
            changRequest.displayName = nickName
            //提交修改
            changRequest.commitChanges { err in
                guard err == nil else {
                    //關閉動畫
                    self.registingAnimationView?.isHidden = true
                    self.registingAnimationView?.stop()
                    print("更改個人訊息時發生錯誤:『\(err!)』")
                    return
                }
            }
            // 儲存個人頭像到Storage
            self.updateImageToFirebaseStorage(imgFileName: "\(account)@clmail.com", img: self.photoImageView.image!, imgName: "profilePhoto.jpg")
            
            //登出
            do{
                try Auth.auth().signOut()
            }catch{
                //關閉動畫
                self.registingAnimationView?.isHidden = true
                self.registingAnimationView?.stop()
                print("錯誤訊息：『\(error.localizedDescription)』")
                return
            }
            //關閉註冊中動畫
            self.registingAnimationView?.isHidden = true
            self.registingAnimationView?.stop()
            self.registSuccessAnimationView?.isHidden = false
            self.registSuccessAnimationView?.play()
            //返回主線程
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                self.registSuccessAnimationView?.isHidden = true
                self.registSuccessAnimationView?.stop()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    // MARK: - @objc
    //Navigation返回鍵的功能
    @objc func backItemAction(_ sender:UIBarButtonItem){
        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    //鍵盤彈出時觸發
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            // 取得鍵盤高度
            let keyboardRectHeight = keyboardFrame.cgRectValue.height
            view.frame.origin.y = -keyboardRectHeight+tfStackView.frame.height
        } else {
            view.frame.origin.y = -view.frame.height / 3
        }
    }
    //鍵盤收起時觸發
    @objc func keyboardWillHide(notification: Notification) {
        // 讓view回復原位
        view.frame.origin.y = 0
    }
    
}
//MARK: - EX - UIImagePickerController
extension RegisterVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
        //確認已設置過頭像
        self.changedPhoto = true
        dismiss(animated: true, completion: nil)
    }
    
}



