//
//  CamaraManager.swift
//  RoyaIA
//
//  Created by Santiago Cordova on 10/09/25.
//

import AVFoundation
import UIKit

class CamaraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func setupSession() {
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {return}
        
        if session.canAddInput(input) {session.addInput(input)}
        if session.canAddOutput(output) { session.addOutput(output) }
        
        DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        if let data = photo.fileDataRepresentation(),
           let uiImage = UIImage(data: data) {
            DispatchQueue.main.async {
                self.capturedImage = uiImage
            }
        }
            
    }
    
    
}
