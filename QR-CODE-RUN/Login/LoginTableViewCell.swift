//
//  LoginTableViewCell.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginTableViewCell: UITableViewCell {
    
    @IBOutlet var memberImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        memberImageView.layer.cornerRadius = memberImageView.frame.size.width / 2
        memberImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(member: Member) {
        memberImageView.sd_setImage(with: member.imageRef, placeholderImage: #imageLiteral(resourceName: "icon_user"))
        nameLabel.text = member.name
    }

}
