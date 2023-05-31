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
    @IBOutlet weak var predTimeLabel: UILabel!
    
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
    
    var num = 0
    var time = 0.0
    
    var bigtime = 0.0
    
    @objc func superResolve() {
        let bigStart = Date()
        guard let leftImage = leftImageView.image else { return }
        let imw = Int(leftImage.size.width)
        let imh = Int(leftImage.size.height)
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
        
        let shapedarray = MLShapedArray(scalars: yArr, shape: [1, imw, imh, 1])
        let multiarray = MLMultiArray(shapedarray)
        
        let start = Date()
        guard let pred = try? model.prediction(input: ESPCNInput(input_1: MLShapedArray(multiarray))) else { return }
        let predtime = Date().timeIntervalSince(start)
        predTimeLabel.text = String(format: "%.5f", predtime) + "s"
        time += predtime
        num += 1
        print("Avg inference time: ", time / Double(num))
        var predImY = pred.IdentityShapedArray[0].scalars
        
        predImY = predImY.map {$0 * 255.0}
        predImY = predImY.map({ element in if element > 255.0 { return 255.0 } else { return element } })
        var uint8Y = predImY.map {UInt8($0)}
                
        guard let rgbImage = OpenCVWrapper.uiimage_(from_y: &uint8Y, and_cr: &crArr, and_bc: &bcArr, width: Int32(imw), height: Int32(imh)) else { return }
        
        rightImageView.image = rgbImage
        
        let fulltime = Date().timeIntervalSince(bigStart)
        bigtime += fulltime
        print("Avg full time: ", bigtime / Double(num))

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

