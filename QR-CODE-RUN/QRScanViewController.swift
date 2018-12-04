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

class QRScanViewController: UIViewController {
    
    let qrScaner = QRScaner()

    override func viewDidLoad() {
        super.viewDidLoad()

        qrScaner.setupQRScan()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: qrScaner.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        qrScaner.foundQR
            .subscribe(onNext: { (text) in
                
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScaner.startQRScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrScaner.stopQRScan()
    }
    



}
