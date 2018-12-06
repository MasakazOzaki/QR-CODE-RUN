//
//  MemberCollectionViewCell.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/06.
//  Copyright © 2018 ueao. All rights reserved.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet var memberImageView: UIImageView!
    @IBOutlet var memberNameLabel: UILabel!
    
    func setup(member: Member, scanable: Bool) {
        memberImageView.sd_setImage(with: member.imageRef, placeholderImage: #imageLiteral(resourceName: "icon_user"))
        memberNameLabel.text = member.name
        memberImageView.layer.cornerRadius = memberImageView.frame.size.width / 2
        memberImageView.clipsToBounds = true
        
        if scanable {
            memberNameLabel.alpha = 1
            memberImageView.alpha = 1
        } else {
            memberNameLabel.alpha = 0.5
            memberImageView.alpha = 0.15
        }
    }
}
