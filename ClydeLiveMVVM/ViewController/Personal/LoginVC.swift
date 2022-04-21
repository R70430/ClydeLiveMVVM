//
//  LoginVC.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//
import FirebaseAuth
import Lottie
import UIKit

class LoginVC: UIViewController {
    //MARK: - Variable
    // 是否記住使用者
    var rememberStatus = false
    // 使用者默認
    let userDefault = UserDefaults()
    // Firebase 監聽器
    var handle: AuthStateDidChangeListenerHandle?
    //登入動畫
    private var loginAnimateView: AnimationView?
    //MARK: - @IBOutlet
    //Button
    @IBOutlet weak var forgetPassButton: UIButton!
    @IBOutlet weak var loginButton: CERoundButton!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var rememberButton: UIButton!
    @IBOutlet weak var seeButton: UIButton!
    //Label
    @IBOutlet weak var errorLabel: UILabel!
    //TextField
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        settingAnimate()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("進入了 LoginVC 的 viewWillAppear")
        //新增監聽器 若是登入狀態則跳轉到用戶資訊頁面
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = myStoryboard.instantiateViewController(withIdentifier: "PersonalInfoVC")
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        //取得記住我的資料
        getRemLoginData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //移除監聽器
        guard handle != nil else{ return }
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    // 點選任意空白處收起鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //MARK: - Function
    //儲存登入資訊 讓『記住我』使用
    func saveLoginInfoToUserDefault(account:String,password:String){
        
        let remCodable = rememberLoginInfoCodable(
            rememberLoginInfoAccount: account,
            rememberLoginInfoPassword: password,
            rememberLoginInfoStatus: rememberStatus)
        //建立編碼器
        let encoder = JSONEncoder()
        //執行編碼
        do {
            //編碼成JSON Data型別
            let remJsonData = try encoder.encode(remCodable)
            //儲存至userDefault
            userDefault.setValue(remJsonData, forKey: userDefaultKeys.rememberData.rawValue)
        } catch {
            print("記住資料時發生錯誤：\(error.localizedDescription)")
        }
    }
    // 取得記住我功能的登入資料
    func getRemLoginData(){
        //從UserDefault取得資料
        guard let loginData = userDefault.value(forKey: userDefaultKeys.rememberData.rawValue) as? Data else {
            accountTextField.text = ""
            passwordTextField.text = ""
            print("沒有可取得的資料")
            return
        }
        print("有儲存的登入資料")
        
        do {
            let myLoginCadeble = try JSONDecoder().decode(rememberLoginInfoCodable.self, from: loginData)
            //檢查是否有勾住『記住我』
            rememberStatus = myLoginCadeble.rememberLoginInfoStatus
            switch rememberStatus {
            case true :
                print("有記住")
                //變更圖片
                rememberButton.setBackgroundImage(UIImage(named: assetsImageName.remCheckSelected.rawValue), for: .normal)
                accountTextField.text = myLoginCadeble.rememberLoginInfoAccount
                passwordTextField.text = myLoginCadeble.rememberLoginInfoPassword
            default:
                print("沒記住")
                accountTextField.text = ""
                passwordTextField.text = ""
            }
            
        } catch {
            print("解析Json時發生錯誤：\(error.localizedDescription)")
        }
    }
    
    func settingAnimate(){
        loginAnimateView = AnimationView(name: "login")
        if let ani = loginAnimateView {
            ani.frame = view.frame
            ani.contentMode = .scaleAspectFit
            ani.isHidden = true
            ani.loopMode = .loop
            ani.animationSpeed = -1.5
            ani.alpha = 0.9
        }
        view.addSubview(loginAnimateView!)
    }
    
    
    //MARK: - IBAction
    
    //忘記密碼
    @IBAction func forgetPassAction(_ sender: UIButton) {
    }
    //登入
    @IBAction func loginAction(_ sender: UIButton) {
        guard
            let account = accountTextField.text,
            account != "",
            let password = passwordTextField.text,
            password != ""
        else{
            errorLabel.textColor = .red
            errorLabel.text = "*帳號或密碼不得為空"
            errorLabel.isHidden = false
            return
        }
        errorLabel.isHidden = true
        //登入FireBase
        let accountEmail = "\(account)@clmail.com"
        //執行FireBase登入
        //執行動畫
        loginAnimateView?.isHidden = false
        loginAnimateView?.play()
        
        Auth.auth().signIn(withEmail: accountEmail, password: password) { user,err in
            //解除小鍵盤
            self.view.endEditing(true)
            //檢查是否有登入錯誤
            guard err == nil else {
                //停止動畫
                self.loginAnimateView?.isHidden = false
                self.loginAnimateView?.stop()
                let alert = UIAlertController(title: "firebase登入時發生錯誤", message: "錯誤訊息：『\(err!.localizedDescription)』", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                return
            }
            //確定登入成功，儲存資訊讓『記住我』適用
            self.saveLoginInfoToUserDefault(account: account, password: password)
            //跳出訊息Alert
            //停止動畫
            self.loginAnimateView?.isHidden = false
            self.loginAnimateView?.stop()
            let alert = UIAlertController(title: "登入成功", message: "即將跳轉至首頁", preferredStyle: .alert)
            self.present(alert, animated: true)
            
            //延時1秒
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
               
                //跳轉到首頁
                self.tabBarController?.selectedIndex = 0
                self.dismiss(animated: false)
            }
        }
    }
    //註冊
    @IBAction func registAction(_ sender: UIButton) {
        //鎖起來以防連點
        sender.isEnabled = false
        loginButton.isEnabled = false
        //跳轉到註冊頁面
        
        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = myStoryboard.instantiateViewController(withIdentifier: storyboardsVCsID.register.rawValue)
        self.navigationController?.pushViewController(vc, animated: true)
        sender.isEnabled = true
        self.loginButton.isEnabled = true
    }
    //記住資料
    @IBAction func rememberAction(_ sender: UIButton) {
        switch rememberStatus {
        case true:
            rememberStatus = false
            rememberButton.setBackgroundImage(UIImage(named: assetsImageName.remCheck.rawValue), for: .normal)
        default:
            rememberStatus = true
            rememberButton.setBackgroundImage(UIImage(named: assetsImageName.remCheckSelected.rawValue), for: .normal)
        }
    }
    //檢視密碼
    @IBAction func seeAction(_ sender: UIButton) {
        
        switch passwordTextField.isSecureTextEntry {
        case true:
            passwordTextField.isSecureTextEntry = false
            seeButton.setBackgroundImage(UIImage(named: assetsImageName.iconEyesShow.rawValue), for: .normal)
        default:
            passwordTextField.isSecureTextEntry = true
            seeButton.setBackgroundImage(UIImage(named: assetsImageName.iconEyesHidden.rawValue), for: .normal)
        }
    }
    

}
//記住我要記住的個人資訊(要轉成json儲存)
struct rememberLoginInfoCodable: Codable {
    var rememberLoginInfoAccount:String
    var rememberLoginInfoPassword:String
    var rememberLoginInfoStatus:Bool
}
