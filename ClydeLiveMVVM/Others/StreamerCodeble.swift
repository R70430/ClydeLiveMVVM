//
//  StreamerCodeble.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/19.
//

import Foundation

// MARK: - ChatCodable
struct ChatCodable: Codable {
    var event, room_id: String?
    var sender_role: Int?
    var body: Body?
    var time: String?
}

// MARK: - Body
struct Body: Codable {
    var chat_id, account, nickname, recipient: String?
    var type, text, accept_time: String?
    var info: Info?
    var entry_notice: EntryNotice?
    var room_count, real_count: Int?
    var user_infos: UserInfos?
    var guardian_count, guardian_sum, contribute_sum: Int?
    var content: Content?
}

// MARK: - Content
struct Content: Codable {
    var cn, en, tw: String?
}

// MARK: - EntryNotice
struct EntryNotice: Codable {
    var username, head_photo, action: String?
    var entry_banner: EntryBanner?
}

// MARK: - EntryBanner
struct EntryBanner: Codable {
    var present_type, img_url, main_badge: String?
    var other_badges: [String]?
}

// MARK: - Info
struct Info: Codable {
    var last_login, is_ban, level, is_guardian: Int?
    var badges: String?
}

// MARK: - UserInfos
struct UserInfos: Codable {
    var guardianlist, onlinelist: [String]?
}

