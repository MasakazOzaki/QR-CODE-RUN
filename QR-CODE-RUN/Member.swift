//
//  Member.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import Foundation
import FirebaseStorage

class Member {
    var name: String
    var qrString: String
    var group: String
    var imageRef: StorageReference
    
    private let storage = Storage.storage()
    
    init(name: String, qrString: String, group: String, imageString: String) {
        self.name = name
        self.qrString = qrString
        self.group = group
        self.imageRef = storage.reference(withPath: imageString)
    }
    
    func update(name: String, group: String, imageString: String) {
        self.name = name
        self.group = group
        self.imageRef = storage.reference(withPath: imageString)
    }
}

extension Member: Equatable {
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.qrString == rhs.qrString
    }
}
