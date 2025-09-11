//
//  CamaraPreview.swift
//  RoyaIA
//
//  Created by Santiago Cordova on 09/09/25.
//

import SwiftUI
import AVFoundation

struct CamaraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    // Creamos un UIView custom que tiene un AVCaptureVideoPreviewLayer
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
    }
}
