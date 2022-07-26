//
//  FireUser.swift
//  Meetings
//
//  Created by Yu on 2022/07/23.
//

import Firebase

class FireUser {
    
    static func toUser(document: DocumentSnapshot) -> User {
        let id = document.documentID
        let displayName = document.get("displayName") as? String ?? ""
        let userTag = document.get("userTag") as? String ?? ""
        let introduction = document.get("introduction") as? String ?? ""
        let iconUrl = document.get("iconUrl") as? String
        let likedCommentIds = document.get("likedCommentIds") as? [String] ?? []
        
        let user = User(id: id, displayName: displayName, userTag: userTag, introduction: introduction, iconUrl: iconUrl, likedCommentIds: likedCommentIds)
        return user
    }
    
    static func readUser(userId: String, completion: ((User?) -> Void)?) {
        // キャッシュから読み取り
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument(source: .cache) { (document, error) in
                // 失敗
                if let error = error {
                    print("HELLO! Fail! Error reading User from cashe. \(error)")
                    completion?(nil)
                    return
                }
                
                // ドキュメントが無い
                if !document!.exists {
                    print("HELLO! Fail! User not found in cashe.")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read 1 User from cashe.")
                let user = toUser(document: document!)
                completion?(user)
            }
        
        // サーバーから読み取り
        db.collection("users")
            .document(userId)
            .getDocument(source: .server) { (document, error) in
                // 失敗
                if let error = error {
                    print("HELLO! Fail! Error reading User from server. \(error)")
                    completion?(nil)
                    return
                }
                
                // ドキュメントが無い
                if !document!.exists {
                    print("HELLO! Fail! User not found in server.")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read 1 User from server.")
                let user = toUser(document: document!)
                completion?(user)
            }
    }
    
    static func readUsers(keyword: String, completion: (([User]?) -> Void)?) {
        // keywordが空なら終了
        if keyword.isEmpty {
            completion?(nil)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .order(by: "displayName")
            .start(at: [keyword])
            .end(at: [keyword + "\u{f8ff}"])
            .limit(to: 100)
            .getDocuments { (querySnapshot, err) in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error Reeding Users. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read \(querySnapshot!.count) Users.")
                
                // commentsに値を代入
                var users: [User] = []
                querySnapshot!.documents.forEach { document in
                    let user = FireUser.toUser(document: document)
                    users.append(user)
                }
                
                // Return
                completion?(users)
            }
    }
    
    static func readLikedUserIds(commentId: String, completion: (([String]?) -> Void)?) {
        // キャッシュから読み取り
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("likedCommentIds", arrayContains: commentId)
            .getDocuments(source: .cache) { (querySnapshot, err) in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error getting Users from cashe. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read \(querySnapshot!.count) Users from cashe.")
                
                // Users
                var users: [User] = []
                for document in querySnapshot!.documents {
                    let user = toUser(document: document)
                    users.append(user)
                }
                
                // User IDs
                var userIds: [String] = []
                users.forEach { user in
                    let userId = user.id
                    userIds.append(userId)
                }
                
                // Return
                completion?(userIds)
            }
        
        // サーバーから読み取り
        db.collection("users")
            .whereField("likedCommentIds", arrayContains: commentId)
            .getDocuments(source: .server) { (querySnapshot, err) in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error getting Users from server. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read \(querySnapshot!.count) Users from server.")
                
                // Users
                var users: [User] = []
                for document in querySnapshot!.documents {
                    let user = toUser(document: document)
                    users.append(user)
                }
                
                // User IDs
                var userIds: [String] = []
                users.forEach { user in
                    let userId = user.id
                    userIds.append(userId)
                }
                
                // Return
                completion?(userIds)
            }
    }
    
    static func readIsUserTagDuplicates(userTag: String, completion: ((Bool?) -> Void)?) {
        // UIDを確認
        if FireAuth.uid() == nil {
            completion?(nil)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("userTag", isEqualTo: userTag)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error getting Users. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Read \(querySnapshot!.count) Users from server.")
                
                // Users
                var users: [User] = []
                for document in querySnapshot!.documents {
                    let user = toUser(document: document)
                    users.append(user)
                }
                
                // Users without me
                var otherUsers: [User] = []
                users.forEach { user in
                    if user.id != FireAuth.uid()! {
                        otherUsers.append(user)
                    }
                }
                
                // 特定のuserTagを持つUserが他に一つでもあればTrueをReturn
                if otherUsers.count == 0 {
                    completion?(false)
                } else {
                    completion?(true)
                }
            }
    }
    
    static func createUser(userId: String, displayName: String, userTag: String, introduction: String, iconUrl: String?, completion: ((String?) -> Void)?) {
        // ドキュメント追加
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .setData([
                "displayName": displayName,
                "userTag": userTag,
                "introduction": introduction,
                "iconUrl": iconUrl as Any,
                "likedCommentIds": []
            ]) { error in
                // 失敗
                if let error = error {
                    print("HELLO! Fail! Error adding new Thread. \(error)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Added 1 Thread.")
                completion?(userId)
            }
    }
    
    static func likeComment(commentId: String, completion: ((String?) -> Void)?) {
        // UIDを確認
        if FireAuth.uid() == nil {
            completion?(nil)
            return
        }
        
        // Userドキュメントをアップデート
        let db = Firestore.firestore()
        db.collection("users")
            .document(FireAuth.uid()!)
            .updateData([
                "likedCommentIds": FieldValue.arrayUnion([commentId])
            ]) { err in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error updating 1 User. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Updated 1 User.")
                
                // TODO: Notificationドキュメントの追加はCloud Functionsで行う
                // Notificationドキュメントを追加
                FireNotification.createLikeNotification(likedCommentId: commentId) { notificationId in
                    // 失敗
                    if notificationId == nil {
                        completion?(nil)
                        return
                    }
                    
                    // 成功
                    completion?(FireAuth.uid()!)
                }
            }
    }
    
    static func unlikeComment(commentId: String, completion: ((String?) -> Void)?) {
        // UIDを確認
        if FireAuth.uid() == nil {
            completion?(nil)
            return
        }
        
        // Userドキュメントをアップデート
        let db = Firestore.firestore()
        db.collection("users")
            .document(FireAuth.uid()!)
            .updateData([
                "likedCommentIds": FieldValue.arrayRemove([commentId])
            ]) { err in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error updating 1 User. \(err)")
                    completion?(nil)
                    return
                }
                
                // 成功
                print("HELLO! Success! Updated 1 User.")
                
                // TODO: Notificationドキュメントの削除はCloud Functionsで行う
                // Notificationドキュメントを削除
                FireNotification.deleteNotification(likedCommentId: commentId) { notificationId in
                    // 失敗
                    if notificationId == nil {
                        completion?(nil)
                        return
                    }
                    
                    // 成功
                    completion?(FireAuth.uid()!)
                }
            }
    }
    
    static func updateUser(displayName: String, userTag: String, introduction: String, iconUrl: String?, completion: ((String?) -> Void)?) {
        // UIDを確認
        if FireAuth.uid() == nil {
            completion?(nil)
            return
        }
        
        // Userドキュメントをアップデート
        let db = Firestore.firestore()
        db.collection("users")
            .document(FireAuth.uid()!)
            .updateData([
                "displayName": displayName,
                "userTag": userTag,
                "introduction": introduction,
                "iconUrl": iconUrl as Any
            ]) { err in
                // 失敗
                if let err = err {
                    print("HELLO! Fail! Error updating User. \(err)")
                    completion?(nil)
                    return
                }
                // 成功
                print("HELLO! Success! Updated 1 User.")
                completion?(FireAuth.uid()!)
            }
    }
    
}
