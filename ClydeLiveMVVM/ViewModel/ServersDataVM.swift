//
//  HomeVM.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//

import Foundation

class ServersDataViewModel {
    
    //解析伺服器的StreamersJSON字串
    func serversStreamersJSONDecode(jsonString:String,completionHandler:([StreamersCellData]?) -> Void){
        
        //要回傳的Array資料
        var returnArray: [StreamersCellData]?
        
        //String轉Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            completionHandler(returnArray)
            return
        }
        
        //開始解析JSON字串成自訂的Codable
        do {
            let jsonCodable = try JSONDecoder().decode(streamerJsonCodable.self, from: jsonData)
            returnArray = [StreamersCellData]()
            //塞入 returnArray
            for i in 0...jsonCodable.result.stream_list.count - 1 {
                let decodedData = StreamersCellData(
                    head_photo: jsonCodable.result.stream_list[i].head_photo,
                    nickname: jsonCodable.result.stream_list[i].nickname,
                    online_num: jsonCodable.result.stream_list[i].online_num,
                    stream_title: jsonCodable.result.stream_list[i].stream_title,
                    tags: jsonCodable.result.stream_list[i].tags
                )
                returnArray?.append(decodedData)
            }
            //callBack
            completionHandler(returnArray)
        } catch {
            print("...發生錯誤：\(error.localizedDescription)")
            completionHandler(returnArray)
        }
    }
    
    //解析伺服器的LightyearJSON字串
    func serversLightyearJSONDecode(jsonString:String,completionHandler:([StreamersCellData]?) -> Void){
        
        //要回傳的Array資料
        var returnArray: [StreamersCellData]?
        
        //String轉Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            completionHandler(returnArray)
            return
        }
        
        //開始解析JSON字串成自訂的Codable
        do {
            let jsonCodable = try JSONDecoder().decode(streamerJsonCodable.self, from: jsonData)
            returnArray = [StreamersCellData]()
            //塞入 returnArray
            for i in 0...jsonCodable.result.lightyear_list.count - 1 {
                let decodedData = StreamersCellData(
                    head_photo: jsonCodable.result.lightyear_list[i].head_photo,
                    nickname: jsonCodable.result.lightyear_list[i].nickname,
                    online_num: jsonCodable.result.lightyear_list[i].online_num,
                    stream_title: jsonCodable.result.lightyear_list[i].stream_title,
                    tags: jsonCodable.result.lightyear_list[i].tags
                )
                returnArray?.append(decodedData)
            }
            //callBack
            completionHandler(returnArray)
        } catch {
            print("...發生錯誤：\(error.localizedDescription)")
            completionHandler(returnArray)
        }
    }
}
// MARK: - StreamersCellData
//要放在 Cell 中的 Streamers 資料
struct StreamersCellData {
    var head_photo:String
    var nickname:String
    var online_num:Int
    var stream_title:String
    var tags:String
}

// MARK: - streamerJsonCodable
struct streamerJsonCodable: Codable {
    let error_code, error_text: String
    let result: Result
}

// MARK: - Result
struct Result: Codable {
    let lightyear_list, stream_list: [List]
}

// MARK: - List
struct List: Codable {
    let stream_id, streamer_id: Int
    let stream_title: String
    let status, open_at, closed_at, deleted_at: Int
    let start_time: Int
    let nickname: String
    let head_photo: String
    let tags: String
    let online_num: Int
    let game: Game
    let charge, group_id: Int
    let background_image: String
    let open_attention, open_guardians: Bool
}
enum Game: String, Codable {
    case e5Paoe51 = "E5-PAOE5-1"
    case ltPao1Mlt1 = "LT-PAO1MLT-1"
    case pkPaopk1 = "PK-PAOPK-1"
    case q3Paoq31 = "Q3-PAOQ3-1"
    case scPao1Msc1 = "SC-PAO1MSC-1"
    case sicboPaofsc1 = "SICBO-PAOFSC-1"
}
