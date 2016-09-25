//
//  RecognizeImageController.swift
//  OpenALPRExample
//
//  Created by Christopher Page on 9/18/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import TOCropViewController


class RecognizeImageController: UIViewController, UIImagePickerControllerDelegate, TOCropViewControllerDelegate, UINavigationControllerDelegate {
  
  var isCallOpenALPRAPI = false
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    imagePicker.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet var loadImageButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var plateTextField: UITextField!
  @IBOutlet var regionTextField: UITextField!
  @IBOutlet var makemodelTextField: UITextField!
  @IBOutlet var colorTextField: UITextField!
  @IBOutlet var responseView: UITextView!
  
  // Image button tapped
  @IBAction func loadImageButtonAction(sender: UIButton) {
    print("loadImageButton pressed")
    
    let alert:UIAlertController = UIAlertController(title: "Where would you like to take the photo from?",
                                                    message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { UIAlertAction in
      self.openCamera()
    }
    let gallaryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { UIAlertAction in
      self.openGallery()
    }
    
    alert.addAction(cameraAction)
    alert.addAction(gallaryAction)
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // Debug toggle switched
  @IBAction func debugSwitchAction(sender: UISwitch) {
    print("debugSwitch pressed")
    
    if sender.on {
      self.isCallOpenALPRAPI = true
    } else {
      self.isCallOpenALPRAPI = false
    }
  }
  
  @IBAction func callAPI(sender: AnyObject) {
    print("callAPI pressed")
    
    self.plateTextField.text = nil
    self.regionTextField.text = nil
    self.makemodelTextField.text = nil
    self.colorTextField.text = nil
    self.responseView.text = nil
    
    if self.imageView.image == nil {
      print("image is blank")
      let alert:UIAlertController = UIAlertController(title: "Identify Error",
                                                      message: "Please add an image", preferredStyle: UIAlertControllerStyle.Alert)
      alert.modalPresentationStyle = .Popover
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: nil)
    } else {
      if self.isCallOpenALPRAPI == true {
        callOpenALPRAPI(self.imageView.image!)
      } else {
        testJSON()
      }
    }
  }
  
  // MARK: - UIImagePickerControllerDelegate Methods
  
//  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//      imageView.contentMode = .ScaleAspectFit
//      imageView.image = pickedImage
//      let cropViewController = TOCropViewController(image:imageView.image)
//    }
//    
//    dismissViewControllerAnimated(true, completion: nil)
//  }
  
//  // Dissmiss the image Picker
//  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//    dismissViewControllerAnimated(true, completion: nil)
//  }
  
  // MARK: UIImagePickerControllerDelegate Methods
  
  // open the camera
  func openCamera() {
    
    if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
      presentViewController(imagePicker, animated: true, completion: nil)
    }
    else {
      openGallery()
    }
  }
  
  // open the photo library
  func openGallery() {
    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!)
  {
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      if image != nil
      {
        let cropController:TOCropViewController = TOCropViewController(image: image)
        cropController.delegate=self
        //  controller.cropView.aspectRatioLocked = true
        //  controller.aspectRatioLocked = true
        //  animated: false)
        //  controller.rotateButtonsHidden = true
        //  controller.editing = true
        self.presentViewController(cropController, animated: true, completion: nil)
      }
    })
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController)
  {
    picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
  }
  
  // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
  //        Cropper Delegate
  // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
  
  func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int)
  {
    cropViewController.dismissViewControllerAnimated(true) { () -> Void in
      self.imageView.image = image
      self.loadImageButton.setTitle("Tap to Change", forState: UIControlState.Normal)
    }
  }
  
  func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool)
  {
    cropViewController.dismissViewControllerAnimated(true) { () -> Void in  }
  }
  
  
  // MARK: - openALPR API Methods
  
  // Test the JSON parsing to UI
  func testJSON() {
    
    let jsonString = "{\"plate\": {\"data_type\": \"alpr_results\", \"epoch_time\": 1474142169121, \"img_height\": 552, \"img_width\": 901, \"results\": [{\"plate\": \"JSJ2169\", \"confidence\": 94.895706, \"region_confidence\": 99, \"region\": \"pa\", \"plate_index\": 0, \"processing_time_ms\": 23.543285, \"candidates\": [{\"matches_template\": 1, \"plate\": \"JSJ2169\", \"confidence\": 94.895706}, {\"matches_template\": 0, \"plate\": \"JSJ269\", \"confidence\": 81.927513}], \"coordinates\": [{\"y\": 265, \"x\": 493}, {\"y\": 263, \"x\": 598}, {\"y\": 330, \"x\": 601}, {\"y\": 332, \"x\": 496}], \"matches_template\": 1, \"requested_topn\": 10}], \"version\": 2, \"processing_time_ms\": 174.520691, \"regions_of_interest\": []}, \"color\": [{\"confidence\": 89.2618, \"value\": \"blue\"}, {\"confidence\": 9.13956, \"value\": \"black\"}, {\"confidence\": 1.52206, \"value\": \"gray\"}, {\"confidence\": 0.0352506, \"value\": \"red\"}, {\"confidence\": 0.0277086, \"value\": \"green\"}], \"make\": [{\"confidence\": 100, \"value\": \"honda\"}, {\"confidence\": 3.54668e-05, \"value\": \"acura\"}, {\"confidence\": 9.0278e-06, \"value\": \"hyundai\"}, {\"confidence\": 1.4616e-06, \"value\": \"mercedes-benz\"}, {\"confidence\": 2.44708e-07, \"value\": \"saturn\"}], \"img_width\": 901, \"credits_monthly_used\": 44, \"img_height\": 552, \"makemodel\": [{\"confidence\": 99.9571, \"value\": \"honda accord\"}, {\"confidence\": 0.0426198, \"value\": \"honda odyssey\"}, {\"confidence\": 0.000286903, \"value\": \"acura tsx\"}, {\"confidence\": 7.87295e-06, \"value\": \"acura rlx\"}, {\"confidence\": 7.46212e-06, \"value\": \"subaru legacy\"}], \"total_processing_time\": 1518.1549999999788, \"credits_monthly_total\": 1500, \"credit_cost\": 4}"
    if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
      let json = JSON(data: dataFromString)
      
      print(json)
      if let plate = json["plate"]["results"][0]["plate"].string {
        self.plateTextField.text = plate
      }
      if let region = json["plate"]["results"][0]["region"].string {
        self.regionTextField.text = region.uppercaseString
      }
      if let color = json["color"][0]["value"].string {
        self.colorTextField.text = color.lowercaseString
      }
      if let makemodel = json["makemodel"][0]["value"].string {
        self.makemodelTextField.text = makemodel.capitalizedString
      }
      //    let jsonString = String(Dictionary: json, encoding: NSUTF8StringEncoding)
      self.responseView.text = jsonString
    } else {
      print("error converting json")
    }
  }
  
  
  // Call the openALPR API
  func callOpenALPRAPI(image: UIImage) {
    //curl -X POST -s -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -F image=@IMG_9480-II.png 'https://api.openalpr.com/v1/recognize?secret_key=dsfa&tasks=plate%2C%20color%2C%20make%2C%20makemodel&country=us'
    
    let country = "us"
    let tasks = "plate,color,makemodel"
    let secret_key = OpenALPRConstants.secret_key
    // test image
//    let image = UIImage(named: "Honda-Accord_rear-center")
    
    let query = "secret_key=\(secret_key)&tasks=\(tasks)&country=\(country)"
    let url = NSURL(string: "https://api.openalpr.com/v1/recognize?\(query)")
    
    let image_data = UIImagePNGRepresentation(image)
    
    if(image_data == nil)
    {
      NSLog("image_data is nil")
      return
    }
    
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    let boundary = generateBoundaryString()
    NSLog(boundary)
    //define the multipart request type
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    //    let postString = "secret_key=\(secret_key)&tasks=\(tasks)country=\(country)"
    //    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    let body = NSMutableData()
    
    let fname = "test.png"
    let mimetype = "image/png"
    
    //define the data post parameter
    
    //    body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    //    body.appendData("Content-Disposition:form-data; name=\"test\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    //    body.appendData("hi\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData("Content-Disposition:form-data; name=\"image\"; filename=\"\(fname)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(image_data!)
    body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    request.HTTPBody = body
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
      do {
        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
          print("statusCode should be 200, but is \(httpStatus.statusCode)")
          print("response = \(response)")
          dispatch_async(dispatch_get_main_queue()) {
            self.responseView.text = String(response)
          }
        }
        guard let data = data else {
          throw JSONError.NoData
        }
        //        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
        //          throw JSONError.ConversionFailed
        //        }
        
        let json = JSON(data: data)
        print(json)
        //        // Update the UI on the main thread.
        dispatch_async(dispatch_get_main_queue()) {
          
          if let plate = json["plate"]["results"][0]["plate"].string {
            self.plateTextField.text = plate
          }
          if let region = json["plate"]["results"][0]["region"].string {
            self.regionTextField.text = region.uppercaseString
          }
          if let color = json["color"][0]["value"].string {
            self.colorTextField.text = color.lowercaseString
          }
          if let makemodel = json["makemodel"][0]["value"].string {
            self.makemodelTextField.text = makemodel.capitalizedString
          }
          let jsonString = String(Dictionary: json, encoding: NSUTF8StringEncoding)
          self.responseView.text = jsonString
        }
      } catch let error as JSONError {
        print(error.rawValue)
      } catch let error as NSError {
        print(error.debugDescription)
      }
    }
    task.resume()
  }
  
  
  enum JSONError: String, ErrorType {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
  }
  
  // Generate a UUID string for Boundary
  func generateBoundaryString() -> String
  {
    return "------------------------\(NSUUID().UUIDString)"
  }
  
}
