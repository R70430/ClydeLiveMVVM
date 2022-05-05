//
//  HomeViewModel.swift
//  ClydeLiveMVVM
//
//  Created by Clyde_Cho on 2022/5/5.
//
import FirebaseAuth
import FirebaseStorage
import Foundation

class FirebaseViewModel {
    
    // Firebase 監聽器
    private var handle: AuthStateDidChangeListenerHandle?
    private var userEmail:String?
    private var userNickName:String?
    private var profilePhoto:UIImage?
    
    //取得 FireBase 使用者帳號
    func getFirebaseUsersEmail(completionHandler:@escaping(_ :String?) -> Void){
        
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard let Email = user?.email else {
                print("HomeVM 沒有獲取 userEmail")
                return
            }
            self.userEmail = Email
            completionHandler(Email)
        })
        
        //移除 Firebase 監聽器
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    //取得 FireBase 使用者暱稱
    func getFirebaseUsersDisplayName(completionHandler:@escaping(_ nickName:String?) -> Void){
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard let displayName = user?.displayName else {
                print("HomeVM 沒有獲取 userDisplayName")
                return
            }
            print("HomeVM 有獲取 userDisplayName")
            self.userNickName = displayName
            completionHandler(self.userNickName)
        })
        //移除 Firebase 監聽器
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
    //取得 FireBase 使用者頭像
    func getFirebaseUsersProfilePhoto(completionHandler:@escaping(UIImage?) -> Void){
        
        //取得Email
        getFirebaseUsersEmail { email in
            guard email != nil else { return }
            //使用 Email 取得 profilePhoto
            Storage.storage().reference().child("\(email!)/profilePhoto.jpg").getData(maxSize: .max) { photoData, err in
                    guard let image = UIImage(data: photoData!) else {return}
                    self.profilePhoto = image
                    completionHandler(self.profilePhoto)
                }
        }
    }
}
