//
//  iPv6ViewController.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/8/7.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices

var MSGLabelLocked: Bool = false

class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var captureSession = AVCaptureSession()
    @IBOutlet weak var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    
    @IBOutlet weak var msgLabel: UILabel!
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    @IBOutlet weak var QRCaremaController: UIImageView!
    
    
    @IBOutlet weak var ChangePort: UIButton!
    @IBAction func ChangePort(_ sender: Any) {
        changeTargetPort(withTip: "You are going to change port.", selfIN: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("[System] Failed to get the camera device.")
            msgLabel.text = "Failed to reach the camera on this device."
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as? AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = QRCaremaController.frame
        
        // Check the device orientation to make layout work with it.
        if UIDevice.current.orientation == .landscapeLeft {
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
        }else if UIDevice.current.orientation == .landscapeRight{
            videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
        }else{
            print("[Error] Error in setting video layer orientation")
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
        }
            
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
    }


    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            msgLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds

            if metadataObj.stringValue != nil {
                launchRocket(decodedURL: metadataObj.stringValue!)
                msgLabel.text = metadataObj.stringValue
            }
        }
    }
    
    func launchRocket(decodedURL: String) {

        if validateIpAddress(ipToValidate: decodedURL, checkiPv6: true) {
            // iPv6 Address
            TargetIPAddr_1 = -1
            TargetIPAddr_2 = -1
            TargetIPAddr_3 = -1
            TargetIPAddr_4 = -1
            isiPv6 = true
            iPv6Addr = decodedURL
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "drawViewController") as! drawViewController
                self.present(nextViewController, animated:true, completion:nil)
            return
        }
        
        if validateIpAddress(ipToValidate: decodedURL, checkiPv6: false) {
            // iPv4 Address
            isiPv6 = false
            let delimiter = "."
            let newstr = decodedURL
            let token = newstr.components(separatedBy: delimiter)
            TargetIPAddr_1 = Int(token[0])!
            TargetIPAddr_2 = Int(token[1])!
            TargetIPAddr_3 = Int(token[2])!
            TargetIPAddr_4 = Int(token[3])!
            URLStr = decodedURL
            isUpdatedFromQRCode = true
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "iPViewController") as! iPViewController
                self.present(nextViewController, animated:true, completion:nil)
            return
        }
        
            // Error iP Address.
        msgLabel.text = "Not a validate iP address."
        MSGLabelLocked = true
        return
    }

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        switch UIDevice.current.orientation{
        case .portrait: break
        case .portraitUpsideDown: break
        case .landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
        default:
            print("[Error] What a magic.")
        }
    }
 
}
