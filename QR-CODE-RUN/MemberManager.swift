//
//  MemberManager.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase
import FirebaseFirestore

class MemberManager {
    static let shared = MemberManager()
    
    private let memberArrayRelay = BehaviorRelay<[Member]>(value: [])
    var memberArray: Observable<[Member]> {
        return memberArrayRelay.asObservable()
    }
    
    let db = Firestore.firestore()
    
    private init() {
        startListenMember()
    }
    
    func startListenMember() {
        db.collection("Member").addSnapshotListener {[weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var tempMemberArray = self?.memberArrayRelay.value ?? []
            snapshot.documentChanges.forEach {diff in
                let data = diff.document.data()
                guard let name = data["name"] as? String,
                    let group = data["group"] as? String,
                    let imageString = data["pic"] as? String
                    else {
                        return
                }
                if (diff.type == .added) {
                    let member = Member(name: name,
                                        qrString: diff.document.documentID,
                                        group: group,
                                        imageString: imageString)
                    tempMemberArray.append(member)
                }
                if (diff.type == .modified) {
                    tempMemberArray.filter{$0.qrString == diff.document.documentID}.first?
                        .update(name: name, group: group, imageString: imageString)
                }
                if (diff.type == .removed) {
                    if let index = tempMemberArray
                        .firstIndex(of: tempMemberArray.filter{$0.qrString == diff.document.documentID}.first!) {
                        tempMemberArray.remove(at: index)
                    }
                }
            }
            self?.memberArrayRelay.accept(tempMemberArray)
        }
    }
    
}
