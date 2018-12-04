//
//  UserManager.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import Foundation
import Firebase
import RxCocoa
import RxSwift
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    let db = Firestore.firestore()
    
    var isLoggedin: Bool {
        return user != nil
    }
    
    private var user: User? {
        return Auth.auth().currentUser
    }
    
    private var usersMemberDataRelay = BehaviorRelay<Member>(value: Member(name: "", qrString: "", group: "", imageString: ""))
    var usersMemberData: Observable<Member> {
        return usersMemberDataRelay.asObservable()
    }
    
    private var scannedQRArrayRelay = BehaviorRelay<[String]>(value: [])
    var scannedQRArray: Observable<[String]> {
        return scannedQRArrayRelay.asObservable()
    }
    
    var usersMemberDataListener: ListenerRegistration?
    var userQRStringListener: ListenerRegistration?
    var scannedQRListener: ListenerRegistration?
    
    private init() {
    }
    
    
    func login(member: Member) -> Observable<User>{
        return Observable.create({[weak self] (observer) -> Disposable in
            Auth.auth().signInAnonymously(completion: { (result, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    let uid = result?.user.uid
                    self?.db.collection("User").document(uid!).setData(["qr": member.qrString], completion: { (error) in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext((self?.user!)!)
                            observer.onCompleted()
                            self?.startListening()
                        }
                    })
                }
            })
            return Disposables.create()
        })
    }
    
    func startListening() {
        guard let user = user else {
            return
        }
        if let userQRStringListener = usersMemberDataListener {
            userQRStringListener.remove()
        }
        userQRStringListener = db.collection("User").document(user.uid).addSnapshotListener {[weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(),
                let qrString = data["qr"] as? String else {
                return
            }
            self?.listenUsersMemberData(qrString: qrString)
        }
    }
    
    func listenUsersMemberData(qrString: String) {
        if let usersMemberDataListener = usersMemberDataListener {
            usersMemberDataListener.remove()
        }
        usersMemberDataListener = db.collection("Member").document(qrString).addSnapshotListener {[weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(),
                let name = data["name"] as? String,
                let group = data["group"] as? String,
                let imageString = data["pic"] as? String
                else {
                    return
            }
            let member = Member(name: name,
                                qrString: document.documentID,
                                group: group,
                                imageString: imageString)
            self?.usersMemberDataRelay.accept(member)
        }
        
        if let scannedQRListener = scannedQRListener {
            scannedQRListener.remove()
        }
        scannedQRListener = db.collection("Scan").whereField("scanFrom", isEqualTo: qrString)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var scannedQR: [String] = []
            for document in snapshot.documents {
                scannedQR.append(document.data()["scanTo"] as! String)
            }
            self?.scannedQRArrayRelay.accept(scannedQR)
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
    
    
}
