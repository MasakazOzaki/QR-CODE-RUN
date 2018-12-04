//
//  MemberViewController.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import FirebaseUI

class MemberViewController: UIViewController {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UserManager.shared.isLoggedin {
            let nv = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
            present(nv, animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }
    
    func bindUser() {
        UserManager.shared.usersMemberData
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: {[weak self] (member) in
                self?.userImageView.sd_setImage(with: member.imageRef, placeholderImage: #imageLiteral(resourceName: "icon_user"))
                self?.userNameLabel.text = member.name
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func logout() {
        UserManager.shared.logout()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
