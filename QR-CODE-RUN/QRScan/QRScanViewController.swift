//
//  QRScanViewController.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/04.
//  Copyright © 2018 ueao. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore

class QRScanViewController: UIViewController {
    
    let qrScaner = QRScaner()
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var countLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        qrScaner.setupQRScan()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: qrScaner.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        observeFoundQR()
        bindCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScaner.startQRScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrScaner.stopQRScan()
    }
    
    func observeFoundQR() {
        qrScaner.foundQR
            .withLatestFrom(MemberManager.shared.memberArray) { text, memberArray  in
                return (text, memberArray)
            }.withLatestFrom(UserManager.shared.scannedQRArray) { arg0, scannedQR -> (String, [Member], [String]) in
                return (arg0.0, arg0.1, scannedQR)
            }.withLatestFrom(UserManager.shared.usersMemberData) { arg0, usersMemberData -> (String, [Member], [String], Member) in
                return (arg0.0, arg0.1, arg0.2, usersMemberData)
            }
            .subscribe(onNext: { (text, memberArray, scannedQR, usersMemberData) in
                guard scannedQR.firstIndex(of: text) == nil,
                    let member = memberArray.filter({member in return member.qrString == text}).first,
                    member.group != usersMemberData.group
                    else {
                        return
                }
                Firestore.firestore().collection("Scan").addDocument(data: ["scanFrom":usersMemberData.qrString,
                                                                            "scanTo": text])
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }).disposed(by: disposeBag)
        bindCount()
    }
    
    func bindCount() {
        Observable.combineLatest(MemberManager.shared.memberArray, UserManager.shared.scannedQRArray, UserManager.shared.usersMemberData)
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { [weak self] memberArray, scannedQRArray, usersMemberData in
                let myGroupCount = memberArray.filter({ member in return member.group == usersMemberData.group}).count
                self?.countLabel.text = String(scannedQRArray.count) + "/" + String(memberArray.count - myGroupCount)
            })
            .disposed(by: disposeBag)
    }
    



}
