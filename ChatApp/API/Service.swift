//
//  Service.swift
//  ChatApp
//
//  Created by neuli on 2022/06/02.
//

import Foundation

import Firebase

struct Service {
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        var users: [User] = []
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                let dict = document.data()
                let user = User(dict: dict)
                users.append(user)
                completion(users)
            })
        }
    }
    
    static func fetchMessages(forUser user: User, completion: @escaping([Message]) -> Void) {
        var messages = [Message]()
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGE.document(currentUID).collection(user.uid).order(by: "timestamp")
        
        // 메세지가 DB에 추가될 때마다 알 수 있다.
        query.addSnapshotListener { snapshot, error in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    completion(messages)
                }
            })
        }
    }
    
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let data = ["text": message,
                    "fromID": currentUID,
                    "toID": user.uid,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGE
            .document(currentUID)
            .collection(user.uid)
            .addDocument(data: data) { _ in
                
                COLLECTION_MESSAGE
                    .document(user.uid)
                    .collection(currentUID)
                    .addDocument(data: data, completion: completion)
        }
    }
}
