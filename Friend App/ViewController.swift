//
//  ViewController.swift
//  Friend App
//
//  Created by Paul Galasso on 8/26/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var viewMenu: UIView!
    var viewTopBar: UIView!
    var viewHolder: UIView!
    var photoview: PhotoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewHolder = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.viewHolder.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 65/255)
        self.view.addSubview(self.viewHolder)
        
        self.viewTopBar = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        self.viewTopBar.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewTopBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewTopBar.layer.shadowOpacity = 1
        self.viewTopBar.layer.shadowOffset = CGSizeMake(5, 5)
        self.viewHolder.addSubview(self.viewTopBar)
        
        let label = UILabel(frame: CGRectMake(0, 0, self.viewTopBar.frame.size.width, 40))
        label.text = "FlexPoint"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.viewTopBar.addSubview(label)
        
        let buttonMenu = UIButton(type: UIButtonType.Custom)
        buttonMenu.frame = CGRectMake(10, 7, 30, 26)
        buttonMenu.setImage(UIImage(named: "menu-Icon"), forState: UIControlState.Normal)
        buttonMenu.addTarget(self, action: "menuClicked", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewTopBar.addSubview(buttonMenu)
        
        self.viewMenu = UIView(frame: CGRectMake(-300, 0, 300, self.view.frame.size.height))
        self.viewMenu.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
        self.viewMenu.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewMenu.layer.shadowOpacity = 0
        self.viewMenu.layer.shadowOffset = CGSizeMake(3, 3)
        self.view.addSubview(self.viewMenu)
        
        let labelMenu = UILabel(frame: CGRectMake(0, 0, 300, 40))
        labelMenu.text = "Menu"
        labelMenu.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelMenu.textAlignment = NSTextAlignment.Center
        labelMenu.font = UIFont.systemFontOfSize(20)
        labelMenu.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewMenu.addSubview(labelMenu)
        
        
        let imagePhotoFeed = UIImageView(frame: CGRectMake(20, 81, 25, 25))
        imagePhotoFeed.image = UIImage(named: "repeat-icon")
        self.viewMenu.addSubview(imagePhotoFeed)
        
        let labelPhotoFeed = UILabel(frame: CGRectMake(60, 81, 100, 25))
        labelPhotoFeed.text = "Photo Feed"
        labelPhotoFeed.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewMenu.addSubview(labelPhotoFeed)
        
        let buttonPhotoFeed = UIButton(type: UIButtonType.Custom)
        buttonPhotoFeed.frame = CGRectMake(0, 73, 300, 40)
        buttonPhotoFeed.addTarget(self, action: "menuClicked", forControlEvents: UIControlEvents.TouchUpInside)
        buttonPhotoFeed.backgroundColor = UIColor.clearColor()
        self.viewMenu.addSubview(buttonPhotoFeed)
        
        let imageUpload = UIImageView(frame: CGRectMake(20, 125, 25, 25))
        imageUpload.image = UIImage(named: "photo-upload")
        self.viewMenu.addSubview(imageUpload)
        
        let labelUploadPhoto = UILabel(frame: CGRectMake(60, 125, 200, 25))
        labelUploadPhoto.text = "Upload Photo"
        labelUploadPhoto.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewMenu.addSubview(labelUploadPhoto)
        
        let buttonUploadPhoto = UIButton(type: UIButtonType.Custom)
        buttonUploadPhoto.frame = CGRectMake(0, 117, 300, 40)
        buttonUploadPhoto.backgroundColor = UIColor.clearColor()
        buttonUploadPhoto.addTarget(self, action: "uploadClicked", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewMenu.addSubview(buttonUploadPhoto)
        
        let imageProfile = UIImageView(frame: CGRectMake(20, 169, 25, 25))
        imageProfile.image = UIImage(named: "default-profile")
        self.viewMenu.addSubview(imageProfile)
        
        let labelProfile = UILabel(frame: CGRectMake(60, 169, 200, 25))
        labelProfile.text = "Profile"
        labelProfile.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewMenu.addSubview(labelProfile)
        
        let buttonProfile = UIButton(type: UIButtonType.Custom)
        buttonProfile.frame = CGRectMake(0, 161, 300, 40)
        buttonProfile.backgroundColor = UIColor.clearColor()
        self.viewMenu.addSubview(buttonProfile)
        
        let imageMap = UIImageView(frame: CGRectMake(20, 213, 25, 25))
        imageMap.image = UIImage(named: "default-profile")
        self.viewMenu.addSubview(imageMap)
        
        let labelMap = UILabel(frame: CGRectMake(60, 213, 200, 25))
        labelMap.text = "Map View"
        labelMap.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewMenu.addSubview(labelMap)
        
        let buttonMap = UIButton(type: UIButtonType.Custom)
        buttonMap.frame = CGRectMake(0, 205, 300, 40)
        buttonMap.addTarget(self, action: "mapViewSelected", forControlEvents: UIControlEvents.TouchUpInside)
        buttonMap.backgroundColor = UIColor.clearColor()
        self.viewMenu.addSubview(buttonMap)
        
        self.photoview = PhotoView(frame: CGRectMake(15, 80, self.view.frame.size.width-30, 400))
        self.photoview.setupView()
        self.viewHolder.addSubview(photoview)
        let tap = UITapGestureRecognizer(target: self, action: "tapUser")
        tap.numberOfTapsRequired = 1
        self.photoview.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapUser() {
        self.performSegueWithIdentifier("goToUserFeed", sender: self)
    }
    func menuClicked() {
        
        if self.viewHolder.frame.origin.x == 0 {
            UIView.animateWithDuration(0.2, animations: {
                
                self.viewHolder.frame = CGRectMake(300, 0, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                self.viewMenu.frame = CGRectMake(0, 0, 300, self.viewMenu.frame.size.height)
                self.viewMenu.layer.shadowOpacity = 1
                }, completion: { (finish: Bool) in
                    
            })
            
        }else {
            UIView.animateWithDuration(0.2, animations: {
                
                self.viewHolder.frame = CGRectMake(0, 0, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                self.viewMenu.frame = CGRectMake(-300, 0, 300, self.viewMenu.frame.size.height)
                self.viewMenu.layer.shadowOpacity = 0
                }, completion: { (finish: Bool) in
                    
            })
            
        }
    }
    
    func mapViewSelected() {
        self.performSegueWithIdentifier("goToMap", sender: nil)
    }
    
    func uploadClicked() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        self.presentViewController(picker, animated: true) { () -> Void in
            
            self.viewHolder.frame = CGRectMake(0, 0, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
            self.viewMenu.frame = CGRectMake(-300, 0, 300, self.viewMenu.frame.size.height)
            self.viewMenu.layer.shadowOpacity = 0
        }
    }
    
    // MARK: Delegate
    // MARK: Image Picker Controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        print("Image Picked")
        
        self.photoview.imageProfile.image = image
        self.photoview.labelCaption.text = "Falls"
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            print("Remove Image Picker")
            
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        print("Did Cancel")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            print("Remove Image Picker")
            
        })
    }

}


class TinderLogin : UIViewController {
    
    var imageIcon : UIImageView!
    var buttonLogin : UIButton!
    var labelIcon: UILabel!
    
    override func viewDidLoad() {
        
        self.imageIcon = UIImageView(frame: CGRectMake((self.view.frame.size.width/2)-(180/2), (self.view.frame.size.height/2)-(180/2), 180, 180))
        self.imageIcon.image = UIImage(named: "flexpoint")
        self.view.addSubview(self.imageIcon)
        
        self.labelIcon = UILabel(frame: CGRectMake(0, (self.view.frame.size.height/2)-20, self.view.frame.size.width, 40))
        self.labelIcon.text = "FlexPoint"
        self.labelIcon.textAlignment = NSTextAlignment.Center
        self.labelIcon.font = UIFont.boldSystemFontOfSize(24)
        self.labelIcon.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.view.addSubview(self.labelIcon)
        
        self.buttonLogin = UIButton(type: UIButtonType.Custom)
        self.buttonLogin.layer.cornerRadius = 5
        self.buttonLogin.frame = CGRectMake((self.view.frame.size.width/2)-(300/2), (self.view.frame.size.height/2)+100, 300, 40)
        self.buttonLogin.setTitle("Signup with Facebook", forState: UIControlState.Normal)
        self.buttonLogin.setTitleColor(UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1), forState: UIControlState.Normal)
        self.buttonLogin.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
        self.buttonLogin.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonLogin.layer.shadowOpacity = 1
        self.buttonLogin.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonLogin.layer.cornerRadius = 5.0
        self.buttonLogin.layer.shadowOffset = CGSizeMake(5, 5)
        self.view.addSubview(self.buttonLogin)
        
        self.labelIcon.alpha = 0.0
        self.buttonLogin.alpha = 0.0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(2.0, animations: {
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(1.0, animations: {
                    
                    self.imageIcon.frame = CGRectMake(self.imageIcon.frame.origin.x, self.imageIcon.frame.origin.y - 120, self.imageIcon.frame.size.width, self.imageIcon.frame.size.height)
                    self.view.addSubview(self.imageIcon)
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(1.0, animations: {
                            
                            self.labelIcon.alpha = 1.0
                            self.buttonLogin.alpha = 1.0
                           
                            }, completion: { (finish: Bool) in
                                
                        })
                })
        })
    }
    
    func login() {
        self.performSegueWithIdentifier("login", sender: self)
    }
}

class PhotoView : UIView {
    
    var imageName: String!
    var name: String!
    var caption: String!
    var labelCaption: UILabel!
    var imageProfile: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.imageName = "3"
        self.name = "Mark Angeles"
        self.caption = "Baby"
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
//        self.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
//        self.layer.shadowColor = UIColor.blackColor().CGColor
//        self.layer.shadowOpacity = 1
//        self.layer.cornerRadius = 5.0
//        self.layer.shadowOffset = CGSizeMake(5, 5)
        
        self.imageProfile = UIImageView(frame: CGRectMake(10, 10, self.frame.size.width-20, 350))
        self.imageProfile.image = UIImage(named: self.imageName)
        self.addSubview(self.imageProfile)
        
        let imageView = UIImageView(frame: CGRectMake(10, 330, self.frame.size.width-20, 30))
        imageView.backgroundColor = UIColor.blackColor()
        imageView.alpha = 0.3
        self.addSubview(imageView)
        
        let labelName = UILabel(frame: imageView.frame)
        labelName.textAlignment = NSTextAlignment.Center
        labelName.textColor = UIColor.whiteColor()
        labelName.text = self.name
        self.addSubview(labelName)
        
        self.labelCaption = UILabel(frame: CGRectMake(7, 372, 100, 20))
        self.labelCaption.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.labelCaption.text = self.caption
        self.addSubview(self.labelCaption)
        
        var xPoint = 170 as CGFloat
        for (var count = 0; count < 5; count++) {
            let imageRate = UIImageView(frame: CGRectMake(xPoint, 370, 30, 30))
            imageRate.image = UIImage(named: "Star_Selected")
            self.addSubview(imageRate)
            xPoint = xPoint + 35
        }
        
        
        
    }

}

class MapViewController : UIViewController , CLLocationManagerDelegate{
    
    // MARK: Properties
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.mapView = MKMapView(frame: CGRectMake(10, 80, self.view.frame.size.width-20, self.view.frame.size.height-100))
        self.view.addSubview(self.mapView)
        
        self.locationManager = CLLocationManager()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error.localizedDescription)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
}

class UserPhotoFeedViewController : UIViewController {
    
    // MARK: Properties
    
    
    @IBOutlet weak var scrollPhotoFeed: UIScrollView!
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        let imageProfile = UIImageView(frame: CGRectMake(20, 10, self.view.frame.size.width-40, 300))
        imageProfile.image = UIImage(named: "3")
        self.scrollPhotoFeed.addSubview(imageProfile)
        
        let imageTop = UIImageView(frame: CGRectMake(20, 10, self.view.frame.size.width-40, 20))
        imageTop.backgroundColor = UIColor.blackColor()
        imageTop.alpha = 0.3
        self.scrollPhotoFeed.addSubview(imageTop)
        
        let labelTop = UILabel(frame: CGRectMake(20, 10, self.view.frame.size.width-70, 20))
        labelTop.text = "42"
        labelTop.textAlignment = NSTextAlignment.Right
        labelTop.font = UIFont.systemFontOfSize(14)
        labelTop.textColor = UIColor.whiteColor()
        self.scrollPhotoFeed.addSubview(labelTop)
        
        let imagePhoto = UIImageView(frame: CGRectMake(CGRectGetMaxX(labelTop.frame)+5, 11, 20, 18))
        imagePhoto.image = UIImage(named: "photo")
        self.scrollPhotoFeed.addSubview(imagePhoto)
        
        let imageBottom = UIImageView(frame: CGRectMake(20, 290, self.view.frame.size.width-40, 20))
        imageBottom.backgroundColor = UIColor.blackColor()
        imageBottom.alpha = 0.3
        self.scrollPhotoFeed.addSubview(imageBottom)
        
        let labelBottom = UILabel(frame: CGRectMake(20, 290, self.view.frame.size.width-40, 20))
        labelBottom.text = "Mark Angeles"
        labelBottom.textAlignment = NSTextAlignment.Center
        labelBottom.font = UIFont.systemFontOfSize(14)
        labelBottom.textColor = UIColor.whiteColor()
        self.scrollPhotoFeed.addSubview(labelBottom)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let width = (self.view.frame.size.width - 100) / 3 as CGFloat
        var xPosition = 30 as CGFloat
        var yPosition = 320 as CGFloat
        
        for (var count = 1; count < 43; count++) {
            
            let viewPicture = UIView(frame: CGRectMake(xPosition, yPosition, width, width))
            viewPicture.backgroundColor = UIColor.whiteColor()
            self.scrollPhotoFeed.addSubview(viewPicture)
            
            let imagePicture = UIImageView(frame: CGRectMake(2, 2, width-4, width-4))
            imagePicture.image = UIImage(named: "\(count)")
            viewPicture.addSubview(imagePicture)
            
            xPosition = xPosition + 20 + width
            if count % 3 == 0 {
                xPosition = 30.0
                yPosition = yPosition + 20 + width
            }
            
        }
        
        self.scrollPhotoFeed.contentSize = CGSizeMake(0, yPosition)
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
}
