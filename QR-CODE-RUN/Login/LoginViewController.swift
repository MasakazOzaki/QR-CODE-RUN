//
//  LoginViewController.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/03.
//  Copyright © 2018 ueao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bindTableView()
        setDidSelectTableViewCell()
    }
    
    func bindTableView() {
        MemberManager.shared.memberArray.asDriver(onErrorDriveWith: Driver.empty())
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: LoginTableViewCell.self)) {row, element, cell in
                cell.setup(member: element)
            }
            .disposed(by: disposeBag)
    }
    
    func setDidSelectTableViewCell() {
        tableView.rx
            .itemSelected
            .withLatestFrom(MemberManager.shared.memberArray) {indexPath, memberArray in
                return (memberArray[indexPath.row], indexPath)
            }
            .subscribe(onNext: {[weak self] (member, indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                UserManager.shared
                    .login(member: member)
                    .subscribe(
                        onNext: {user in
                            print(user.uid)
                    },
                        onError: {error in
                            print(error.localizedDescription)
                    },
                        onCompleted: {
                            self?.dismiss(animated: true, completion: nil)
                    }).disposed(by: (self?.disposeBag)!)
            })
            .disposed(by: disposeBag)
    }
    
    
    
}


