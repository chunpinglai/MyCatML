//
//  ViewController.swift
//  MyCatML
//
//  Created by ChunpingLai on 2019/7/1.
//  Copyright © 2019 ChunpingLai. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    lazy var imgModel : ImageClassifier = ImageClassifier()
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isMyCat: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
}

extension ViewController {
    @IBAction func photoBtnPressed(_ sender: Any) {
        openGallery()
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func recognition(newImage: UIImage) {
        imageView.image = newImage
        guard let pixelBuffer = newImage.pixelBufferFromImage() else { return }
        guard let prediction = try? imgModel.prediction(image: pixelBuffer) else { return }
        isMyCat.text = "I think this is... \(prediction.classLabel)."
    }
    
    func resizeImg(image:UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            isMyCat.text = ""
            let newImg = resizeImg(image: image)
            recognition(newImage: newImg)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func pixelBufferFromImage() -> CVPixelBuffer? {
        guard let ciimage = CIImage(image: self) else {
            return nil
        }
        
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage, from: ciimage.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        let width = cgimage!.width
        let height = cgimage!.height
        
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
        print(status)
        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
        
        
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
        status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        return pxbuffer!;
    }
}
