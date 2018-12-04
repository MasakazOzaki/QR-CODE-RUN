//
//  QRScaner.swift
//  QR-CODE-RUN
//
//  Created by 張翔 on 2018/12/04.
//  Copyright © 2018 ueao. All rights reserved.
//

import Foundation
import AVFoundation
import RxCocoa
import RxSwift

class QRScaner: NSObject {
    let session = AVCaptureSession()
    
    private let foundQRRelay = PublishRelay<String>()
    var foundQR: Observable<String> {
        return foundQRRelay.asObservable()
    }
    
    override init() {
    }
    
    func setupQRScan() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        let devices = discoverySession.devices
        if let backCamera = devices.first {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                    let metadataOutput = AVCaptureMetadataOutput()
                    if session.canAddOutput(metadataOutput) {
                        session.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    func startQRScan() {
        session.startRunning()
    }
    
    func stopQRScan() {
        session.stopRunning()
    }
}

extension QRScaner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            guard metadata.type == .qr,
                let text = metadata.stringValue
                else {
                    continue
            }
            foundQRRelay.accept(text)
        }
    }
}
