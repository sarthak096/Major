//
//  NewViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//


import UIKit
import AVFoundation
import Firebase
import CoreData

class ScanNGoViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    //Outlets and Variables
    @IBOutlet weak var flashLight: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var zoomPinch: UIPinchGestureRecognizer!
    var newView: HomeVC?
    var scannedCode: String?
    public var barcodeScanned: ((String) -> ())?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var captureDevice: AVCaptureDevice?
    let vc = ListTableViewController()
    let ref = Database.database().reference()
  
    
    //Handles PinchZoom
    @IBAction func zoomPinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let device = captureDevice else{return}
        
        if sender.state == .changed{
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let pinchvelocity: CGFloat = 4.0
            do{
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                defer{device.unlockForConfiguration()}
                
                let zoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchvelocity)
                device.videoZoomFactor = max(1.0,min(zoomFactor, maxZoom))
            }
            catch{
                print(error)
            }
        }
    }
    
    //Load ViewController
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        let input: AnyObject!
        
        newView = self.storyboard!.instantiateViewController(withIdentifier: "Home") as? HomeVC
        if let captureDevice = captureDevice{
            do{
                input = try AVCaptureDeviceInput(device:captureDevice)
            }
            catch let error1 as NSError{
                error = error1
                input = nil
            }
            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else{return}
            captureSession.addInput(input as! AVCaptureInput)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //Defining the type of data to be scanned
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.upce,
                                                         AVMetadataObject.ObjectType.aztec,
                                                         AVMetadataObject.ObjectType.code128,
                                                         AVMetadataObject.ObjectType.code39,
                                                         AVMetadataObject.ObjectType.code39Mod43,
                                                         AVMetadataObject.ObjectType.code93,
                                                         AVMetadataObject.ObjectType.ean13,
                                                         AVMetadataObject.ObjectType.ean8,
                                                         AVMetadataObject.ObjectType.qr,
                                                         AVMetadataObject.ObjectType.pdf417]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
            videoPreviewLayer?.frame = videoView.layer.bounds
            videoView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
        }
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.blue.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        qrCodeFrameView?.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront:qrCodeFrameView!)
        //Make Round FlashLightBTn
        flashLight.layer.cornerRadius = 0.3 * flashLight.bounds.size.width
        flashLight.clipsToBounds = true
        
        view.addSubview(flashLight!)
        view.bringSubview(toFront: flashLight!)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Handles FlashLightBtn Action
    @IBAction func flashToggle(_ sender: UIButton) {
        if (captureDevice!.hasTorch) {
            do {
                try captureDevice?.lockForConfiguration()
                if (captureDevice?.torchMode == AVCaptureDevice.TorchMode.on) {
                    captureDevice?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try captureDevice?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                captureDevice?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = self.videoView.layer.bounds
        let orientation = UIApplication.shared.statusBarOrientation
        switch (orientation){
        case UIInterfaceOrientation.landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        case UIInterfaceOrientation.landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        case UIInterfaceOrientation.portrait:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        case UIInterfaceOrientation.portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        default: print("Unknown orientation state")
        }
    }
    
    public override func viewDidLayoutSubviews() {
        //
    }
    
    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects:[AVMetadataObject], from connection: AVCaptureConnection){
        
        if metadataObjects.count == 0 || metadataObjects == nil{
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject;
        qrCodeFrameView!.frame = barCodeObject.bounds;
        var flag:Bool = false
        if metadataObj.stringValue != nil{
            print(metadataObj.stringValue!)
            let newref = Database.database().reference()
            newref.child("Database").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(metadataObj.stringValue!){
                    let alert = UIAlertController(title: "Add Item", message: "Select the quantity and add item to cart.", preferredStyle: .alert)
                    //Add textfield to alert dialog
                    alert.addTextField { (textField: UITextField) in
                        textField.keyboardAppearance = .dark
                        textField.keyboardType = .default
                        textField.autocorrectionType = .default
                        textField.placeholder = "Quantity in numbers"
                        textField.clearButtonMode = .whileEditing
                        
                    }
                    let firstTextField = alert.textFields![0] as UITextField
                    let clearAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) -> Void in
                        self.newView?.appDone = { (barcode: String) in
                            _ = self.navigationController?.popViewController(animated: true)
                            print("Received following barcode: \(barcode)")
                        }
                        if let newView = self.newView{
                            self.navigationController?.pushViewController(newView, animated: true)
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Add", style: .default) { (alert: UIAlertAction!) -> Void in
                        let alertok = UIAlertController(title: "Invalid quantity.", message: "Please scan again and enter a valid quantity", preferredStyle: .alert)
                        if self.isNumberValidInput(Input: firstTextField.text!) == false{
                            let okAction =  UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                                self.newView?.appDone = { (barcode: String) in
                                    _ = self.navigationController?.popViewController(animated: true)
                                    print("Received following barcode: \(barcode)")
                                }
                                
                                if let newView = self.newView{
                                    self.navigationController?.pushViewController(newView, animated: true)
                                }
                            })
                            alertok.addAction(okAction)
                            self.present(alertok, animated: true, completion:nil)
                        }
                        else {
                            
                            let nameToSave = metadataObj.stringValue!
                            let quantityToSave = Int(firstTextField.text!)
                            self.save(itemname: nameToSave,itemquantity: quantityToSave!)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                            //Instantiate HomeViewController
                            self.newView?.appDone = { (barcode: String) in
                                _ = self.navigationController?.popViewController(animated: true)
                                print("Received following barcode: \(barcode)")
                            }
                            
                            if let newView = self.newView{
                                self.navigationController?.pushViewController(newView, animated: true)
                            }
                        }
                        
                    }
                    
                    alert.addAction(clearAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion:nil)
                    self.captureSession?.stopRunning()
                }
                else{
                    let alertnotfound = UIAlertController(title: "No item found", message: "There is no such item. Please scan again or contact help desk.", preferredStyle: .alert)
                    let okAction =  UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                        self.newView?.appDone = { (barcode: String) in
                            _ = self.navigationController?.popViewController(animated: true)
                            print("Received following barcode: \(barcode)")
                        }
                        
                        if let newView = self.newView{
                            self.navigationController?.pushViewController(newView, animated: true)
                        }
                    })
                    alertnotfound.addAction(okAction)
                    self.captureSession?.stopRunning()
                    self.present(alertnotfound, animated: true, completion:nil)
                }
            })
        }
    }
   
    //Function to save item and quantity to CoreData
    func save(itemname: String,itemquantity: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Cartdata",
                                                in: managedContext)!
        
        let cartname = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        cartname.setValue(itemname, forKeyPath: "itemname")
        cartname.setValue(itemquantity, forKeyPath: "itemquantity")
        
        do {
            try managedContext.save()
            vc.pcart.append(cartname)
            print(vc.pcart)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //Check the validity of the input quantity
    func isNumberValidInput(Input:String) -> Bool {
        let myCharSet=CharacterSet(charactersIn:"0123456789")
        let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
        let isValid: Bool = (Input == output)
        return isValid
    }
    
}


