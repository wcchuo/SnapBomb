//
//  CameraViewController.swift
//  iOSSocket
//
//  Created by Wei Chung Chuo on 8/20/15.
//  Copyright © 2015 Wei Chung Chuo. All rights reserved.
//

import UIKit
import AVFoundation
import Social
import Accounts

class CameraViewController: UIViewController {
    
    let socket = SocketIOClient(socketURL: "http://localhost:5001")
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.connect()
        socket.on("connect") { data, ack in
            print("iOS::WE ARE USING SOCKETS!")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            })
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        socket.emit("sendMsg", "Hello");
        print("Button")
        
//        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
//            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
//            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
//                if (sampleBuffer != nil) {
//                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
//                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
//                    
//                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
//                    self.capturedImage.image = image
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    
//                    self.socket.emit("sendMsg", "Hello");
//                    
//                    self.socket.emit("sendImage", image);
//                    
        
                    //starts tweet
                    //                    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
                    //                        let twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    //                        twitterController.setInitialText("I just hiked " + "\r\n" + "\r\n" + "#MissionPeak")
                    //                        //img
                    //                        twitterController.addImage(image)
                    //                        self.presentViewController(twitterController, animated: true, completion: nil)
                    //                    } else {
                    //                        let alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
                    //                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    //                        self.presentViewController(alert, animated: true, completion: nil)
                    //                    }
                    //ends tweet
//                }
//            })
//        }
    }
    
    @IBAction func photoFromLibrary(sender: UIButton) {
        picker.allowsEditing = true //2
        picker.sourceType = .PhotoLibrary //3
        picker.modalPresentationStyle = .Popover
        presentViewController(picker, animated: true, completion: nil)//4
        //picker.popoverPresentationController?.UIView = sender
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        capturedImage.contentMode = .ScaleAspectFit //3
        capturedImage.image = chosenImage //4
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    
}



