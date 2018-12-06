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
    
    @IBOutlet var enemyCountLabel: UILabel!
    @IBOutlet var scannedEnemyCountLabel: UILabel!
    @IBOutlet var scannedMeCountLable: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUser()
        bindCollectionView()
        bindCount()
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
    
    func bindCount() {
        Observable.combineLatest(MemberManager.shared.memberArray, UserManager.shared.usersMemberData)
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { [weak self] memberArray, usersMemberData in
                let myGroupCount = memberArray.filter({ member in return member.group == usersMemberData.group}).count
                self?.enemyCountLabel.text = String(memberArray.count - myGroupCount)
            })
            .disposed(by: disposeBag)
        UserManager.shared.scannedQRArray
            .map { String($0.count) }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(scannedEnemyCountLabel.rx.text)
            .disposed(by: disposeBag)
        UserManager.shared.scnnedMeArray
            .map { String($0.count) }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(scannedMeCountLable.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindCollectionView() {
        Observable.combineLatest(MemberManager.shared.memberArray, UserManager.shared.usersMemberData, UserManager.shared.scannedQRArray)
            .map { (memberArray, usersMemberData , scannedQRArray) -> [(member: Member, scanable: Bool)] in
                var array: [(member: Member, scanable: Bool)] = []
                for member in memberArray {
                    var scanable = true
                    if  member.qrString == usersMemberData.qrString {
                        continue
                    } else if scannedQRArray.firstIndex(of: member.qrString) != nil {
                        scanable = false
                    } else if member.group == usersMemberData.group {
                        scanable = false
                    }
                    array.append((member: member, scanable: scanable))
                }
                return array
            }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(collectionView.rx.items(cellIdentifier: "Cell", cellType: MemberCollectionViewCell.self)) {row, element, cell in
                cell.setup(member: element.member, scanable: element.scanable)
            }
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
