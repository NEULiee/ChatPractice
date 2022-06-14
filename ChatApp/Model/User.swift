//
//  User.swift
//  ChatApp
//
//  Created by neuli on 2022/06/02.
//

import Foundation

struct User {
    let uid: String
    let profileImageUrl: String
    let username: String
    let fullname: String
    let email: String
    
    init(dict: [String: Any]) {
        self.uid = dict["uid"] as? String ?? ""
        self.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.fullname = dict["fullname"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
    }
}
