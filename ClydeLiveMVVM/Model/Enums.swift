//
//  Enums.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//

import Foundation

//所有Cell的ID
enum cellsID:String{
    case homeCell = "homeStreamersCell"
    case SearchCell = "searchStreamersCell"
    case ChatCell = "chatCell"
}
//所有的storyboardID
enum storyboardsVCsID:String{
    case home = "homeVC"
    case streamer = "StreamerVC"
    case search = "SearchVC"
    case login = "LoginVC"
    case register = "RegisterVC"
    case personalInfo = "PersonalInfoVC"
}
//放在assets的圖片名稱
enum assetsImageName:String {
    case brokenHeart = "brokenHeart"
    case btnEdit = "btnEdit"
    case iconEyesHidden = "iconEyesHidden"
    case iconEyesShow = "iconEyesShow"
    case iconPersonal = "iconPersonal"
    case logout = "logout"
    case paopao = "paopao"
    case picPersonal = "picPersonal"
    case send = "send"
    case tabHome = "tabHome"
    case tabPersonal = "tabPersonal"
    case tabSearch = "tabSearch"
    case titlebarBack = "titlebarBack"
    case titlebarSearch = "titlebarSearch"
    case topPic = "topPic"
    case remCheck = "remCheck"
    case remCheckSelected = "remCheckSelected"
}
//userDfaults用的Ley值
enum userDefaultKeys:String {
    case rememberData = "rememberData"
}

//聊天室種類
enum chatCodableEvent:String{
    case default_message = "default_message"
    case sys_updateRoomStatus = "sys_updateRoomStatus"
    case admin_all_broadcast = "admin_all_broadcast"
    case sys_room_endStream = "sys_room_endStream"
}
