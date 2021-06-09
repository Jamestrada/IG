//
//  CameraViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let cameraView = UIView()
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = .red
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Take Photo"
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        setUpNavBar()
        checkCameraPermission()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true // Hide tab bar when selecting the camera tab
        if let session = captureSession, !session.isRunning { // resume camera
            session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning() // pause camera from running in the background
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.frame = view.bounds
        previewLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        
        let buttonSize: CGFloat = view.width / 5
        shutterButton.frame = CGRect(x: (view.width - buttonSize) / 2, y: view.safeAreaInsets.top + view.width + 100, width: buttonSize, height: buttonSize)
        shutterButton.layer.cornerRadius = buttonSize / 2
    }
    
    @objc func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            // Request access
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .authorized:
            setUpCamera()
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let captureSession = AVCaptureSession()
        
        // Add device
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) { // makes sure that there won't be conflicts with other inputs
                    captureSession.addInput(input)
                }
            } catch {
                print(error)
            }
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            // Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        }
    }
    
    @objc func didTapClose() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        // make navbar transparent
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage() // hide navbar divider
//        navigationController?.navigationBar.backgroundColor = .clear
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        captureSession?.stopRunning()
        
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else {
            return
        }
        
        let vc = PostEditViewController(image: resizedImage)
        if #available(iOS 14.0, *) {
            vc.navigationItem.backButtonDisplayMode = .minimal
        } else {
            vc.navigationItem.backButtonTitle = ""
        }
        navigationController?.pushViewController(vc, animated: false)
    }
}
