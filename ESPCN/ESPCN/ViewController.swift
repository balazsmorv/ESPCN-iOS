//
//  ViewController.swift
//  ESPCN
//
//  Created by Balázs Morvay on 2023. 05. 29..
//

import UIKit
import Metal
import ARKit
import CoreGraphics

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    let model = try! ESPCN(configuration: .init())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let pred = try! model.prediction(input: .init(input_3: .init(shape: [1, 64, 64, 1], dataType: .float16)))
        
        // print(pred.IdentityShapedArray)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        leftImageView.isUserInteractionEnabled = true
        leftImageView.addGestureRecognizer(tapGestureRecognizer)
        
        actionButton.addTarget(self, action: #selector(superResolve), for: .touchUpInside)
    }
    
    @objc func superResolve() {
        guard let leftImage = leftImageView.image else { return }
        guard let ycrbcImage = OpenCVWrapper.rgb_(to_ycrbc: leftImage) else {return }
        guard let pixelData = ycrbcImage.cgImage?.dataProvider?.data as? NSData else { return }
        let pixelBytes = pixelData.bytes
        
        var yArr = [Float32]()
        var crArr = [UInt8]()
        var bcArr = [UInt8]()
        for i in stride(from: 0, to: pixelData.length, by: 3) {
            let y = pixelBytes.advanced(by: i).load(as: UInt8.self)
            let cr = pixelBytes.advanced(by: i+1).load(as: UInt8.self)
            let bc = pixelBytes.advanced(by: i+2).load(as: UInt8.self)
            yArr.append(Float32(y) / 255.0)
            crArr.append(cr)
            bcArr.append(bc)
        }
        
        let shapedarray = MLShapedArray(scalars: yArr, shape: [1, 64, 64, 1])
        let multiarray = MLMultiArray(shapedarray)
        
        let start = Date()
        guard let pred = try? model.prediction(input: ESPCNInput(input_3: MLShapedArray(multiarray))) else { return }
        print("Model inference time: ", Date().timeIntervalSince(start))
        var predImY = pred.IdentityShapedArray[0].scalars
        
        predImY = predImY.map {$0 * 255.0}
        predImY = predImY.map({ element in if element > 255.0 { return 255.0 } else { return element } })
        var uint8Y = predImY.map {UInt8($0)}
                
        guard let rgbImage = OpenCVWrapper.uiimage_(from_y: &uint8Y, and_cr: &crArr, and_bc: &bcArr) else { return }
        
        rightImageView.image = rgbImage
        
        
    }
    

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        present(imagePickerVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

            if let image = info[.originalImage] as? UIImage {
                leftImageView.image = image
            }

    }
    
    
}

