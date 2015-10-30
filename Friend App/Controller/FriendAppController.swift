//
//  FriendAppController.swift
//  Friend App
//
//  Created by Paul Galasso on 8/26/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Login
class LoginViewController : UIViewController, WebserviceClassDelegate, FBSDKLoginButtonDelegate, FBSDKAppInviteDialogDelegate {
    
    // MARK: Properties
    @IBOutlet weak var buttonLoginFacebook: UIButton!
    @IBOutlet weak var buttonLoginEmail: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    var questionColletion: QuestionCollectionModel?
    var friends: NSMutableArray!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.friends = NSMutableArray()
        
        let fbLogin = FBSDKLoginButton(frame: CGRectMake(30, (self.view.frame.size.height/2) + (self.view.frame.size.height/4) - 20 , self.view.frame.size.width-60, 40))
        fbLogin.delegate = self
        fbLogin.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(fbLogin)
        
        
        self.buttonLoginEmail.hidden = true
        self.buttonLoginFacebook.hidden = true
        self.buttonSignup.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            let parametersDictionary = NSMutableDictionary()
            parametersDictionary.setObject("id", forKey: "fields")
            parametersDictionary.setObject("first_name, last_name, picture, email", forKey: "fields")
            let request = FBSDKGraphRequest(graphPath: "me", parameters: parametersDictionary as AnyObject as! [NSObject : AnyObject], HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                
                let dictionaryResult = result as! NSDictionary
                let dictionaryPicture = dictionaryResult["picture"] as! NSDictionary
                let dictionaryData = dictionaryPicture["data"] as! NSDictionary
                
                AppModel.sharedInstance.user.firstName = dictionaryResult["first_name"] as! String
                AppModel.sharedInstance.user.email = dictionaryResult["email"] as! String
                AppModel.sharedInstance.user.emailType = "facebook"
                AppModel.sharedInstance.user.lastName = dictionaryResult["last_name"] as! String
                AppModel.sharedInstance.user.imageLink = dictionaryData["url"] as! String
                AppModel.sharedInstance.user.facebookID = dictionaryResult["id"] as! String
                
                let dictionaryName = NSMutableDictionary()
                let dictionaryUsername = NSMutableDictionary()
                let dictionaryImage = NSMutableDictionary()
                
                dictionaryUsername.setObject(dictionaryResult["email"] as! String, forKey: "email")
                dictionaryName.setObject(dictionaryResult["first_name"] as! String, forKey: "first")
                dictionaryName.setObject(dictionaryResult["last_name"] as! String, forKey: "last")
                dictionaryUsername.setObject(dictionaryResult["id"] as! String, forKey: "uid")
                dictionaryUsername.setObject("facebook", forKey: "type")
                dictionaryImage.setObject(dictionaryData["url"] as! String, forKey: "original")
                dictionaryImage.setObject(dictionaryData["url"] as! String, forKey: "thumb")
                
                
                let webservice = WebserviceClass()
                webservice.link = kWebLink + kUsers
                let dictionaryParam = NSMutableDictionary()
                webservice.identifier = "login"
                webservice.delegate = self
                
                dictionaryParam.setObject(dictionaryName, forKey: "name")
                dictionaryParam.setObject(dictionaryUsername, forKey: "username")
                dictionaryParam.setObject(dictionaryImage, forKey: "image")
                webservice.sendPostWithParameter(dictionaryParam)
                
            })
        }
        
        
    }
    
    // MARK: Button Actions
    @IBAction func loginFacebookClicked(sender: UIButton) {
        
    
    }
    
    @IBAction func signupClicked(sender: UIButton) {
        self.performSegueWithIdentifier("goToSignup", sender: nil)
    }
    
    @IBAction func loginEmailClicked(sender: UIButton) {
    
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("SetupVC") as? SetupViewController
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: {
            
        })

        /*
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: "https://fb.me/750184568442914")!
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
*/

    }


    // MARK: Method
    func getQuestions() {
        
        let dictionaryParam = NSMutableDictionary()
        
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kQuestions
        webservice.identifier = "getPrepared"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
    
    func getFriends() {
        
        let dictionaryParam = NSMutableDictionary()
        dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "uid")
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kFriends
        webservice.identifier = "getFriends"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
    
    // MARK: For Testing
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
    }

    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        
        
        if webservice.statusCode > 203 {
            // Alert (Something went wrong on the Rest API)
            return
        }
        if webservice.identifier == "login" {
            
            let dictionaryParam = NSMutableDictionary()
        
            AppModel.sharedInstance.user.identifier = content["_id"] as! String
            dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "id")
    
            let webservice = WebserviceClass()
            webservice.link = kWebLink + kUsers
            webservice.identifier = "getData"
            webservice.delegate = self
            webservice.getMethod(dictionaryParam)
            
        }else if webservice.identifier == "getData" {
            
            let questionDictionary = content["questions"] as! NSDictionary
            let preparedArray = questionDictionary["prepared"] as! NSArray
            let customArray = questionDictionary["custom"] as! NSArray
            let friendList = content["list_of_friends"] as! NSArray
            
            AppModel.sharedInstance.friends.removeAllObjects()
            AppModel.sharedInstance.preparedQuestion.removeAllObjects()
            AppModel.sharedInstance.customQuestion.removeAllObjects()
            
            for objectContent in friendList {
                let dictionaryFriend = objectContent as! NSDictionary
                let friendModel = UserModel()
                friendModel.facebookID = dictionaryFriend["fbid"] as! String
                AppModel.sharedInstance.friends.addObject(friendModel)
                
            }
            
            for objectContent in preparedArray {
                let dictionaryPrepared = objectContent as! NSDictionary
                let questionModelRepresentation = QuestionModel()
                questionModelRepresentation.identifier = dictionaryPrepared["qid"] as! String
                questionModelRepresentation.answer = dictionaryPrepared["answer"] as! String
                print("FANSWER !!! \(questionModelRepresentation.answer)")
                questionModelRepresentation.type = "prepared"
                AppModel.sharedInstance.preparedQuestion.addObject(questionModelRepresentation)
                
            }
            
            for objectContent in customArray {
                let dictionaryCstom = objectContent as! NSDictionary
                let questionModelRepresentation = QuestionModel()
                questionModelRepresentation.identifier = dictionaryCstom["qid"] as! String
                questionModelRepresentation.answer = dictionaryCstom["answer"] as! String
                questionModelRepresentation.question = dictionaryCstom["question"] as! String
                questionModelRepresentation.options.addObjectsFromArray(dictionaryCstom["options"] as! NSArray as [AnyObject])
                questionModelRepresentation.type = "custom"
                AppModel.sharedInstance.customQuestion.addObject(questionModelRepresentation)
                
            }
            
        
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                
                let parametersDictionary = NSMutableDictionary()
                parametersDictionary.setObject("id", forKey: "fields")
                parametersDictionary.setObject("first_name, last_name, picture, email", forKey: "fields")
                
                let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: parametersDictionary as AnyObject as! [NSObject : AnyObject], HTTPMethod: "GET")
                request.startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    let dictionaryParameter = NSMutableDictionary()
                    let arrayUsers = NSMutableArray()
                    
                    let resultDictionary = result as! NSDictionary
                    let arrayFriens = resultDictionary["data"] as! NSArray
                    for content in arrayFriens {
                        
                        let dictionaryContent = content as! NSDictionary
                        let dictionaryUsers = NSMutableDictionary()
                        dictionaryUsers.setObject(dictionaryContent["id"] as! String, forKey: "fbid")
                        dictionaryUsers.setObject("true", forKey: "is_notify")
                        arrayUsers.addObject(dictionaryUsers)
                        
                    }
                    
                    if arrayFriens.count == AppModel.sharedInstance.friends.count || arrayFriens.count == 0{
                        
                        
                        self.getQuestions()
                        return
                    }
            
                    dictionaryParameter.setObject(arrayUsers, forKey: "friends")
                    let webservice = WebserviceClass()
                    webservice.link = "\(kWebLink)\(kUsers)\(AppModel.sharedInstance.user.identifier)"
                    webservice.identifier = "postData"
                    webservice.delegate = self
                    webservice.sendPostWithParameter(dictionaryParameter)
                    
        
                })
                
                return
            }
            
        
        }else if webservice.identifier == "getPrepared" {
            let preparedArray = content["data"] as! NSArray
            
            if AppModel.sharedInstance.questions.count == 0 {
                
                for objectContet in preparedArray {
                    let dictionaryContent = objectContet as! NSDictionary
                    let question = QuestionModel()
                    question.question = dictionaryContent["question"] as! String
                    question.identifier = dictionaryContent["_id"] as! String
                    question.options.addObjectsFromArray(dictionaryContent["options"] as! NSArray as [AnyObject])
                    AppModel.sharedInstance.questions.addObject(question)
                }
                
            }
            
            
            if AppModel.sharedInstance.preparedQuestion.count > 0 {
                
//                let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("SetupVC") as? SetupViewController
//                self.navigationController?.pushViewController(mapViewControllerObejct!, animated: true)
                
                for model in AppModel.sharedInstance.questions {
                    
                    let questionModel = model as! QuestionModel
                    let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
                    let arrayFilter = AppModel.sharedInstance.preparedQuestion.filteredArrayUsingPredicate(predicate) as NSArray
                    if arrayFilter.count != 0 {
                        let updateModel = arrayFilter[0] as! QuestionModel
                        let index = AppModel.sharedInstance.preparedQuestion.indexOfObject(updateModel)
                        updateModel.question = questionModel.question
                        updateModel.options.addObjectsFromArray(questionModel.options as [AnyObject])
                        print("Fucking Answer = \(updateModel.answer)")
                        
                        AppModel.sharedInstance.preparedQuestion.replaceObjectAtIndex(index, withObject: updateModel)
                    }
                    
                }
                
                
            }
            self.getFriends()

        }else if webservice.identifier == "postData" {
            
            let arrayemporaryUsers = NSMutableArray()
            
            let arrayOfFriends = content["list_of_friends"] as! NSArray
            
            for dictionaryObject in arrayOfFriends {
                
                let dictionaryOfFriends = dictionaryObject as! NSDictionary
                arrayemporaryUsers.addObject(dictionaryOfFriends["fbid"] as! String)
                
            }

            let dictionaryParameter = NSMutableDictionary()
            let webservice = WebserviceClass()
            webservice.link = "\(kWebLink)\(kUsers)\(AppModel.sharedInstance.user.identifier)"
            webservice.identifier = "patchData"
            webservice.delegate = self
            dictionaryParameter.setObject(arrayemporaryUsers, forKey: "friends")
            dictionaryParameter.setObject(AppModel.sharedInstance.user.identifier , forKey: "uid")
            webservice.sendPatchWithParameter(dictionaryParameter)
            
        }else if webservice.identifier == "patchData" {
            
            self.getQuestions()
            
        }else if webservice.identifier == "getFriends" {
            
            let arrayContent = content["friends"] as! NSArray
            
            AppModel.sharedInstance.friends.removeAllObjects()
            for objectContent in arrayContent {
                
                let dictionaryContent = objectContent as! NSDictionary
                
                let dictionaryUsername = dictionaryContent["username"] as! NSDictionary
                
                let dictionaryImage = dictionaryContent["image"] as! NSDictionary
                
                let dictionaryName = dictionaryContent["name"] as! NSDictionary
                
                let friendModel = UserModel()
                friendModel.imageLink = dictionaryImage["original"] as! String
                friendModel.firstName = dictionaryName["first"] as! String
                friendModel.lastName = dictionaryName["last"] as! String
                friendModel.identifier = dictionaryContent["_id"] as! String
                friendModel.facebookID = dictionaryUsername["uid"] as! String
                friendModel.email = dictionaryUsername["email"] as! String
                friendModel.emailType = "facebook"
                AppModel.sharedInstance.friends.addObject(friendModel)
                
            }
            
            if AppModel.sharedInstance.preparedQuestion.count == 0 {
                
                self.performSegueWithIdentifier("goToInitialSetup", sender: self)
                return
            }
            
            self.performSegueWithIdentifier("goToHomeTab", sender: self)
        }
    }
    
    // FBSDKLoginButton Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToInitialSetup" {
            
            
        }else if segue.identifier! == "goToHomeTab" {
            
            
        }
        
    }
}


// MARK: - Home / Main
class HomeViewController : UIViewController, UIScrollViewDelegate , HomeMenuViewDelegate{
    
    // MARK: Properties
    var scrollActivity: UIScrollView!
    var notifView: NotificationView?
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.notifView = nil
    
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
//        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        var width = self.view.frame.size.width - 60 as CGFloat
        width = width / 3
        
        let menu = HomeMenuView(frame: CGRectMake(10, 100, self.view.frame.size.width-20, width+30))
        menu.delegate = self
        menu.setupView()
        self.view.addSubview(menu)
        
        let labelActivity = UILabel(frame: CGRectMake(0, CGRectGetMaxY(menu.frame) + 30, self.view.frame.size.width, 20))
//        labelActivity.textColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        labelActivity.textColor = UIColor.blackColor()
        labelActivity.textAlignment = NSTextAlignment.Center
        labelActivity.text = "Activity"
        self.view.addSubview(labelActivity)
        
        self.scrollActivity = UIScrollView(frame: CGRectMake(10, CGRectGetMaxY(labelActivity.frame)+10, self.view.frame.size.width-20, 360))
        self.scrollActivity.backgroundColor = UIColor.clearColor()
        self.scrollActivity.pagingEnabled = true
        self.view.addSubview(self.scrollActivity)
        
        
        var pointY = 0 as CGFloat
        
        for (var count = 0; count < 12; count++) {
            
            let challenge = ChallengeStatusView(frame: CGRectMake(0, pointY, self.view.frame.size.width-20, 80))
            challenge.setupView()
            self.scrollActivity.addSubview(challenge)
            
            pointY = pointY + 90
            
        }
        
        self.scrollActivity.contentSize = CGSizeMake(self.view.frame.size.width-20, pointY)
        

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
    
    // MARK: Delegate
    func menuChallenge() {
        
        self.performSegueWithIdentifier("goToChallengeSetup", sender: self)
    }
    
    func menuInvite() {
        
        self.performSegueWithIdentifier("goToInvite", sender: self)
        
    }
    
    func menuLadderBoard() {
        
//        self.performSegueWithIdentifier("goToLadderBoard", sender: self)
        self.performSegueWithIdentifier("goToGame", sender: self)
        
    }
    
    func menuQuestions() {
        
        self.performSegueWithIdentifier("goToQuestions", sender: self)
        
    }
    
    func menuNotification() {
        
        let arrayNames = ["Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso", "Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso"] as NSArray
        
        self.notifView = nil
        self.notifView = NotificationView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.notifView?.arrayNotification.addObjectsFromArray(arrayNames as [AnyObject])
        self.notifView?.setupView()
        self.view.addSubview(self.notifView!)
        
    }
}

// MARK: - Question Selection
protocol QuestionSelectionViewControllerDelegate {
    
    func questionSelected(selected : NSMutableArray)
}
class QuestionSelectionViewController : UIViewController, UIScrollViewDelegate , WebserviceClassDelegate, QuestionViewDelegate{
    
    // MARK: Properties
    @IBOutlet weak var labelTotalQuestions: UILabel!
    @IBOutlet weak var buttonPrepared: UIButton!
    @IBOutlet weak var buttonCustom: UIButton!
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var buttonConfirm: UIButton!
    var scrollQuestions: UIScrollView!
    var scrollCustom: UIScrollView!
    
    var delegate: QuestionSelectionViewControllerDelegate?
    
    var questionColletion: QuestionCollectionModel?
    
    var arrayCustom: NSMutableArray?
    var arrayPrepared: NSMutableArray?
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        

        self.arrayCustom = NSMutableArray()
        self.arrayPrepared = NSMutableArray()
        
        self.viewHolder.layer.cornerRadius = 5
        self.buttonPrepared.layer.cornerRadius = 2
        self.buttonCustom.layer.cornerRadius = 2
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.scrollCustom = UIScrollView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, self.view.frame.size.height-240))
//        self.scrollCustom.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.scrollCustom.layer.cornerRadius = 5
        self.viewHolder.addSubview(self.scrollCustom)
        
        self.scrollQuestions = UIScrollView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, self.view.frame.size.height-240))
//        self.scrollQuestions.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.scrollQuestions.layer.cornerRadius = 5
        self.viewHolder.addSubview(self.scrollQuestions)
        
        self.viewHolder.layer.cornerRadius = 5
        self.buttonPrepared.layer.cornerRadius = 2
        self.buttonCustom.layer.cornerRadius = 2
        
        self.viewHolder.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.scrollCustom.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.scrollQuestions.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        
        self.buttonPrepared.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.buttonCustom.backgroundColor = UIColor.blackColor()
        
        self.buttonConfirm.layer.cornerRadius = 5
        self.buttonConfirm.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonConfirm.layer.borderWidth = 2
        self.buttonConfirm.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.buttonConfirm.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.scrollQuestions.pagingEnabled = true
        self.scrollCustom.pagingEnabled = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.getPrepared()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: Method
    // Setup view
    func setupView() {
        
        for views in self.scrollQuestions.subviews {
            views.removeFromSuperview()
        }
        for views in self.scrollCustom.subviews {
            views.removeFromSuperview()
        }
        
        self.arrayPrepared!.addObjectsFromArray(AppModel.sharedInstance.preparedQuestion as [AnyObject])
        self.arrayCustom!.addObjectsFromArray(AppModel.sharedInstance.customQuestion as [AnyObject])
        
        var yLocation = 0 as CGFloat
        for (var count = 0; count < self.arrayPrepared!.count; count++) {
            
            let questionModel = self.arrayPrepared![count] as! QuestionModel
            
            let question = QuestionView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
            let arraySelectedFilter = self.questionColletion!.collection.filteredArrayUsingPredicate(predicate) as NSArray
            if arraySelectedFilter.count != 0 {
                question.selected = true
            }
            question.setupView()
            question.delegate = self
            self.scrollQuestions.addSubview(question)
            
            yLocation = yLocation + 40
            
        }
        self.scrollQuestions.contentSize = CGSizeMake(0, yLocation-10)
        yLocation = 0
        for (var count = 0; count < self.arrayCustom!.count; count++) {
            
            let questionModel = self.arrayCustom![count] as! QuestionModel
            
            let question = QuestionView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
            let arraySelectedFilter = self.questionColletion!.collection.filteredArrayUsingPredicate(predicate) as NSArray
            if arraySelectedFilter.count != 0 {
                question.selected = true
            }
            question.setupView()
            question.delegate = self
            self.scrollCustom.addSubview(question)
        
            yLocation = yLocation + 40
        }
        self.scrollCustom.contentSize = CGSizeMake(0, yLocation-10)
    }
    
    // Get Prepared
    func getPrepared() {
    
        let dictionaryParam = NSMutableDictionary()
    
        dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "id")
        
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kUsers
        webservice.identifier = "getData"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
   
    
    // MARK: Delegate
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.statusCode > 203 {
            // Alert (Something went wrong on the Rest API)
            return
        }
        
        
        
        if webservice.identifier == "getData" {
        
            let questionDictionary = content["questions"] as! NSDictionary
            let preparedArray = questionDictionary["prepared"] as! NSArray
            let customArray = questionDictionary["custom"] as! NSArray
            
            if preparedArray.count != 0 {
                
                AppModel.sharedInstance.preparedQuestion.removeAllObjects()
                AppModel.sharedInstance.customQuestion.removeAllObjects()
                
                for objectContent in preparedArray {
                    let dictionaryPrepared = objectContent as! NSDictionary
                    let questionModelRepresentation = QuestionModel()
                    questionModelRepresentation.identifier = dictionaryPrepared["qid"] as! String
                    questionModelRepresentation.answer = dictionaryPrepared["answer"] as! String
                    questionModelRepresentation.type = "prepared"
                    AppModel.sharedInstance.preparedQuestion.addObject(questionModelRepresentation)
                    
                }
                
                for objectContent in customArray {
                    let dictionaryCstom = objectContent as! NSDictionary
                    let questionModelRepresentation = QuestionModel()
                    questionModelRepresentation.identifier = dictionaryCstom["qid"] as! String
                    questionModelRepresentation.answer = dictionaryCstom["answer"] as! String
                    questionModelRepresentation.question = dictionaryCstom["question"] as! String
                    questionModelRepresentation.options.addObjectsFromArray(dictionaryCstom["options"] as! NSArray as [AnyObject])
                    questionModelRepresentation.type = "custom"
                    AppModel.sharedInstance.customQuestion.addObject(questionModelRepresentation)
                    
                }
                
            }
            
            let dictionaryParam = NSMutableDictionary()
            
            let webservice = WebserviceClass()
            webservice.link = kWebLink + kQuestions
            webservice.identifier = "getPrepared"
            webservice.delegate = self
            webservice.getMethod(dictionaryParam)
            
            
        }else if webservice.identifier == "getPrepared" {
            
            let preparedArray = content["data"] as! NSArray
     
    
            for objectContet in preparedArray {
                
                let dictionaryContent = objectContet as! NSDictionary
                let question = QuestionModel()
                question.question = dictionaryContent["question"] as! String
                question.options.addObjectsFromArray(dictionaryContent["options"] as! NSArray as [AnyObject])
                question.identifier = dictionaryContent["_id"] as! String
                
                let identifier = dictionaryContent["_id"] as! String
                let predicate = NSPredicate(format: "self.identifier == '\(identifier)'")
                let arrayFilter = AppModel.sharedInstance.preparedQuestion.filteredArrayUsingPredicate(predicate) as NSArray
                if arrayFilter.count != 0 {
                    let updateModel = arrayFilter[0] as! QuestionModel
                    let index = AppModel.sharedInstance.preparedQuestion.indexOfObject(updateModel)
                    let oldModel = AppModel.sharedInstance.preparedQuestion[index] as! QuestionModel
                    oldModel.question = question.question
                    oldModel.options.addObjectsFromArray(question.options as [AnyObject])
                    AppModel.sharedInstance.preparedQuestion.replaceObjectAtIndex(index, withObject: oldModel)
                }
                
                
                
                
            }
            
            self.setupView()
            
        }
    }
    
    // QuestionView Delegate
    func questionSelected(question: QuestionModel) {
        
        self.questionColletion!.collection.addObject(question)
      
    }
    
    func questionDeselected(question: QuestionModel) {
        
        let pedicate = NSPredicate(format: "self.identifier == '\(question.identifier)'")
        let arrayTemp = self.questionColletion!.collection.filteredArrayUsingPredicate(pedicate) as NSArray
        
        if arrayTemp.count != 0 {
            let userContent = arrayTemp[0] as! QuestionModel
            let index = self.questionColletion!.collection.indexOfObject(userContent)
            self.questionColletion!.collection.removeObjectAtIndex(index)
        }
        
    }
    
    
    
    
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func customButtonClicked(sender: UIButton) {
        
        self.buttonCustom.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.buttonPrepared.backgroundColor = UIColor.blackColor()
        
        self.view.bringSubviewToFront(sender)
        self.view.bringSubviewToFront(self.viewHolder)
        self.viewHolder.bringSubviewToFront(self.scrollCustom)
        
    }
    
    @IBAction func preparedButtonClicked(sender: UIButton) {
        
        self.buttonPrepared.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        self.buttonCustom.backgroundColor = UIColor.blackColor()
        
        self.view.bringSubviewToFront(sender)
        self.view.bringSubviewToFront(self.viewHolder)
        self.viewHolder.bringSubviewToFront(self.scrollQuestions)
        
    }
    @IBAction func confirmButtonClicked(sender: UIButton) {
        let arrayData = NSMutableArray()
        arrayData.addObjectsFromArray(self.questionColletion!.collection as [AnyObject])
        self.delegate?.questionSelected(arrayData)
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
}
// MARK: - Friend Selection 
protocol FriendSelectionViewControllerDelegate {
    
    func friendSelected(friends: NSMutableArray)
    
}

class FriendSelectionViewController : UIViewController, WebserviceClassDelegate , FriendListViewDelegate{
    
    // MARK: Properties
    @IBOutlet weak var viewHolder: UIView!
    var scrollFriends: UIScrollView!
    var delegate: FriendSelectionViewControllerDelegate?

    var arraySelectedFriends: NSMutableArray?
    var arrayFriends: NSMutableArray?
    
    
    
    @IBOutlet weak var buttonConfirm: UIButton!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.viewHolder.layer.cornerRadius = 5
        self.arrayFriends = NSMutableArray()
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.scrollFriends = UIScrollView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, self.view.frame.size.height-210))
//        self.scrollFriends.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.viewHolder.addSubview(self.scrollFriends)
        
        self.viewHolder.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
        
        self.buttonConfirm.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonConfirm.layer.borderWidth = 2
        self.buttonConfirm.layer.cornerRadius = 5
        self.buttonConfirm.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.buttonConfirm.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self.scrollFriends.pagingEnabled = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getFriends()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: Method 
    func setupViews() {
        
        for views in self.scrollFriends.subviews {
            views.removeFromSuperview()
        }
        
        var yLocation = 0 as CGFloat
        
        self.arrayFriends!.addObjectsFromArray(AppModel.sharedInstance.friends as [AnyObject])
        
        for (var count = 0; count < self.arrayFriends!.count; count++) {
            
            let user = self.arrayFriends![count] as! UserModel
            let friend = FriendListView(frame: CGRectMake(0, yLocation, self.scrollFriends.frame.size.width, 30))
            
            friend.user = user
            let predicate = NSPredicate(format: "self.identifier == '\(user.identifier)'")
            let arraySelectedFilter = self.arraySelectedFriends!.filteredArrayUsingPredicate(predicate) as NSArray
            if arraySelectedFilter.count != 0 {
                friend.selected = true
            }
    
            friend.setupView()
            friend.delegate = self
            self.scrollFriends.addSubview(friend)
            
            yLocation = yLocation + 40
        }
        self.scrollFriends.contentSize = CGSizeMake(0, yLocation-10)
        
    }
    
    func getFriends() {
        
        let dictionaryParam = NSMutableDictionary()
        dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "uid")
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kFriends
        webservice.identifier = "getFriends"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
    

    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func confirmButtonClicked(sender: UIButton) {
  
        let arrayToSend = NSMutableArray()
        arrayToSend.addObjectsFromArray(self.arraySelectedFriends! as [AnyObject])
        self.delegate?.friendSelected(arrayToSend)
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    // MARK: Delegate
    // MARK: Webservice
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.identifier == "getFriends" {
            
            let arrayContent = content["friends"] as! NSArray
            
            AppModel.sharedInstance.friends.removeAllObjects()
            for objectContent in arrayContent {
                
                let dictionaryContent = objectContent as! NSDictionary
                
                let dictionaryUsername = dictionaryContent["username"] as! NSDictionary
                
                let dictionaryImage = dictionaryContent["image"] as! NSDictionary
                
                let dictionaryName = dictionaryContent["name"] as! NSDictionary
                
                let friendModel = UserModel()
                friendModel.imageLink = dictionaryImage["original"] as! String
                friendModel.firstName = dictionaryName["first"] as! String
                friendModel.lastName = dictionaryName["last"] as! String
                friendModel.identifier = dictionaryContent["_id"] as! String
                friendModel.facebookID = dictionaryUsername["uid"] as! String
                friendModel.email = dictionaryUsername["email"] as! String
                friendModel.emailType = "facebook"
                AppModel.sharedInstance.friends.addObject(friendModel)
            
            }
            
            self.setupViews()
            
        }
        
    }
    
    // MARK: Delegate
    
    func friendListSelected(user: UserModel) {
        
        self.arraySelectedFriends?.addObject(user)
    }
    func friendListDeselected(user: UserModel) {
        
        let pedicate = NSPredicate(format: "self.identifier == '\(user.identifier)'")
        let arrayTemp = self.arraySelectedFriends!.filteredArrayUsingPredicate(pedicate) as NSArray
        
        if arrayTemp.count != 0 {
            let userContent = arrayTemp[0] as! UserModel
            let index = self.arraySelectedFriends!.indexOfObject(userContent)
            self.arraySelectedFriends!.removeObjectAtIndex(index)
        }
        
    }
}





// MARK: - Game View Controller
class GameViewController : UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var buttonOption1: UIButton!
    @IBOutlet weak var buttonOption2: UIButton!
    @IBOutlet weak var buttonOption3: UIButton!
    @IBOutlet weak var buttonOption4: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var buttonShow: UIButton!
    @IBOutlet weak var buttonBomb: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.buttonOption1.layer.borderWidth = 2
        self.buttonOption1.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.buttonOption2.layer.borderWidth = 2
        self.buttonOption2.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.buttonOption3.layer.borderWidth = 2
        self.buttonOption3.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.buttonOption4.layer.borderWidth = 2
        self.buttonOption4.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.labelQuestion.text = "Question 1"
        self.labelQuestion.layer.borderWidth = 2
        self.labelQuestion.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: Method
    func animateButtons(sender: UIButton) {
        
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                            
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        
                                                        UIView.animateWithDuration(0.2, animations: {
                                                            
                                                            self.buttonOption1.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
                                                            
                                                            self.buttonOption2.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
                                                            
                                                            self.buttonOption3.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
                                                            
                                                            self.buttonOption4.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
                                                            
                                                            }, completion: { (finish: Bool) in
                                                                
                                                                self.buttonOption1.frame = CGRectMake(self.view.frame.size.width, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
                                                                
                                                                self.buttonOption2.frame = CGRectMake(self.view.frame.size.width, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
                                                                
                                                                self.buttonOption3.frame = CGRectMake(self.view.frame.size.width, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
                                                                
                                                                self.buttonOption4.frame = CGRectMake(self.view.frame.size.width, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
                                                                
                                                                UIView.animateWithDuration(0.2, animations: {
                                                                    
                                                                    self.buttonOption1.frame = CGRectMake(40, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
                                                                    
                                                                    self.buttonOption2.frame = CGRectMake(40, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
                                                                    
                                                                    self.buttonOption3.frame = CGRectMake(40, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
                                                                    
                                                                    self.buttonOption4.frame = CGRectMake(40, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
                                                                    
                                                                    }, completion: { (finish: Bool) in
                                                                        
                                                                })
                                                                
                                                        })
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
    
    // MARK: Button Actions
    @IBAction func option1Clicked(sender: UIButton) {
        
        self.animateButtons(sender)
        
    }
    
    @IBAction func option2Clicked(sender: UIButton) {
        
        self.animateButtons(sender)
        
    }
    
    @IBAction func option3Clicked(sender: UIButton) {
        
        self.animateButtons(sender)
        
    }
    
    @IBAction func option4Clicked(sender: UIButton) {
        
        self.animateButtons(sender)
        
    }
    
    func buttonActionClicked () {
        
    }
    
    @IBAction func showClicked(sender: UIButton) {
        
        UIView.animateWithDuration(2.0, animations: {
            
            self.buttonOption2.alpha = 0
            self.buttonOption3.alpha = 0
            self.buttonOption4.alpha = 0
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.1, delay: 1.0, options: [], animations: {
                    self.buttonOption2.alpha = 1
                    self.buttonOption3.alpha = 1
                    self.buttonOption4.alpha = 1
                    }, completion: { (sender: Bool) in
                       
                        
                })
        })
    }
    
    @IBAction func bombClicked(sender: UIButton) {
        UIView.animateWithDuration(2.0, animations: {
            
            self.buttonOption2.alpha = 0
            self.buttonOption3.alpha = 0
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.1, delay: 1.0, options: [], animations: {
                    self.buttonOption2.alpha = 1
                    self.buttonOption3.alpha = 1
                    }, completion: { (sender: Bool) in
                        
                        
                })
        })
    }
    @IBAction func nextClicked(sender: UIButton) {
        
       
        UIView.animateWithDuration(0.2, animations: {
            
            self.buttonOption1.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
            
            self.buttonOption2.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
            
            self.buttonOption3.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
            
            self.buttonOption4.frame = CGRectMake(-self.view.frame.size.width, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
            
            }, completion: { (finish: Bool) in
                
                self.buttonOption1.frame = CGRectMake(self.view.frame.size.width, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
                
                self.buttonOption2.frame = CGRectMake(self.view.frame.size.width, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
                
                self.buttonOption3.frame = CGRectMake(self.view.frame.size.width, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
                
                self.buttonOption4.frame = CGRectMake(self.view.frame.size.width, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
                
                UIView.animateWithDuration(0.2, animations: {
                    
                    self.buttonOption1.frame = CGRectMake(40, self.buttonOption1.frame.origin.y, self.buttonOption1.frame.size.width, self.buttonOption1.frame.size.height)
                    
                    self.buttonOption2.frame = CGRectMake(40, self.buttonOption2.frame.origin.y, self.buttonOption2.frame.size.width, self.buttonOption2.frame.size.height)
                    
                    self.buttonOption3.frame = CGRectMake(40, self.buttonOption3.frame.origin.y, self.buttonOption3.frame.size.width, self.buttonOption3.frame.size.height)
                    
                    self.buttonOption4.frame = CGRectMake(40, self.buttonOption4.frame.origin.y, self.buttonOption4.frame.size.width, self.buttonOption4.frame.size.height)
                    
                    }, completion: { (finish: Bool) in
                        
                })
                
        })
    
    
    }
    
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
}


// MARK: - Add Custom Question
class AddCustomViewController : UIViewController, UITextFieldDelegate, UITextViewDelegate , WebserviceClassDelegate{
    
    // MARK: Properties    
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var labelIdentifier: UILabel!
    @IBOutlet weak var textInput: UITextView!

    
    
    @IBOutlet weak var labelInput: UILabel!
    
    var currentIndex: Int!
    
    var question: QuestionModel!
    var inputs: NSArray!
   
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.inputs = ["Question", "Answer", "Option 1", "Option 2", "Option 3"]
        
        self.question = QuestionModel()
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.currentIndex = 0
        self.labelIdentifier.text = self.inputs[self.currentIndex] as? String
        
        self.textInput.layer.cornerRadius = 10
        self.textInput.layer.borderColor = UIColor.whiteColor().CGColor
        self.textInput.layer.borderWidth = 2
        self.textInput.text = ""
        self.textInput.textColor = UIColor.whiteColor()
        self.textInput.contentOffset = CGPointMake(100, 100)
        self.textInput.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.labelInput.textAlignment = NSTextAlignment.Center
        self.labelInput.textColor = UIColor.whiteColor()
        self.labelInput.adjustsFontSizeToFitWidth = true
        self.labelInput.numberOfLines = 10
        self.labelInput.text = self.labelIdentifier.text!
        
        self.buttonSave.layer.borderWidth = 2
        self.buttonSave.layer.cornerRadius = 5
        self.buttonSave.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonSave.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
    
        let resignGesture = UITapGestureRecognizer(target: self, action: "resignText")
        resignGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(resignGesture)
        
       
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Method
    
    func inputeTap() {
        
        self.labelInput.hidden = true
        if self.labelInput.text! == self.labelIdentifier.text! {
            self.textInput.text = ""
        }
        
        self.textInput.becomeFirstResponder()
        
    }
    
    func resignText() {
        
        if self.textInput.text == "" && self.labelInput.text != self.labelIdentifier.text! {
            return
        }
        self.labelInput.text = self.textInput.text
        
        if self.textInput.text == "" {
            self.labelInput.text = self.labelIdentifier.text!
        }
        self.labelInput.hidden = false
        self.textInput.resignFirstResponder()
        self.textInput.textColor = UIColor.clearColor()
        
    }
    
    func animateUserInterface() {
        
        let originalFrameLabel = self.labelInput.frame
        let originalFrameText = self.textInput.frame
        UIView.animateWithDuration(0.2, animations: {
            
            self.labelInput.frame = CGRectMake(-self.labelInput.frame.width - 5, self.labelInput.frame.origin.y, self.labelInput.frame.width, self.labelInput.frame.height)
            self.textInput.frame = CGRectMake(-self.textInput.frame.width, self.textInput.frame.origin.y, self.textInput.frame.width, self.textInput.frame.height)
            
            }, completion: { (finish: Bool) in
                
                self.labelInput.frame = CGRectMake(self.view.frame.width + 5, self.labelInput.frame.origin.y, self.labelInput.frame.width, self.labelInput.frame.height)
                self.textInput.frame = CGRectMake(self.view.frame.width, self.textInput.frame.origin.y, self.textInput.frame.width, self.textInput.frame.height)
                
                self.textInput.text = ""
                self.labelIdentifier.text = self.inputs[self.currentIndex] as? String
                self.labelInput.text = self.inputs[self.currentIndex] as? String
                
                UIView.animateWithDuration(0.2, animations: {
                    self.labelInput.frame = originalFrameLabel
                    self.textInput.frame = originalFrameText
                    }, completion: { (finish: Bool) in
                        
                })
        })
        
    }
    
    
    func addQuestion() {

        let dictionaryParam = NSMutableDictionary()
        
        let dictionaryQuestion = NSMutableDictionary()
    
        dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "uid")
        dictionaryQuestion.setObject(self.question!.question, forKey: "question")
        dictionaryQuestion.setObject(self.question!.answer, forKey: "answer")
        dictionaryQuestion.setObject(self.question!.options, forKey: "options")
        dictionaryParam.setObject(dictionaryQuestion, forKey: "question")
        
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kAddCustom
        webservice.identifier = "addNestor"
        webservice.delegate = self
        webservice.sendPatchWithParameter(dictionaryParam)
        
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
        
    
    }
    
    @IBAction func saveButtonClicked(sender: UIButton) {
        
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
        if self.labelInput.text! == self.labelIdentifier.text! && self.textInput.text == "" {
            // No input
            return
        }
        
        if self.currentIndex == 0 {
            
            question.question = self.textInput.text
            
        }else if self.currentIndex == 1 {
            
            question.answer = self.textInput.text
            
        }else {
            
            question.options.addObject(self.textInput.text)
            
        }
        
        if self.currentIndex == self.inputs.count - 1 {
            // Custom Qestion Ready
            self.addQuestion()
            return
        }
        
        self.currentIndex = self.currentIndex + 1
        
        self.animateUserInterface()
    
        
    }
    // MARK: Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        self.textInput.textColor = UIColor.whiteColor()
        self.labelInput.hidden = true
        if self.labelInput.text! == self.labelIdentifier.text! {
            self.textInput.text = ""
        }else {
            self.textInput.text = self.labelInput.text!
        }
        self.labelInput.hidden = true
        
        return true
    }
    
    // Webservice
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
     
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
}


// MARK: - Setup 
class SetupViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Properties
    var tableData : NSMutableArray!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.tableData = NSMutableArray()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.clearColor()
        
        let dictionaryPersonal = NSMutableDictionary()
        let dictionaryGroup = NSMutableDictionary()
        let dictionaryHome = NSMutableDictionary()
        
        dictionaryPersonal.setObject("profile-selected", forKey: "image")
        dictionaryPersonal.setObject("Personal", forKey: "title")
        dictionaryPersonal.setObject("Personal questions about you.", forKey: "content")
        
        dictionaryGroup.setObject("set-up-challenge-selected", forKey: "image")
        dictionaryGroup.setObject("Group", forKey: "title")
        dictionaryGroup.setObject("Questions from your sorority/fraternity", forKey: "content")
        
        dictionaryHome.setObject("logo", forKey: "image")
        dictionaryHome.setObject("Start", forKey: "title")
        dictionaryHome.setObject("Start friend app after answering the personal questions.", forKey: "content")
        
        self.tableData.addObject(dictionaryPersonal)
        self.tableData.addObject(dictionaryGroup)
        self.tableData.addObject(dictionaryHome)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 110.0
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tableData.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let identifier = "Cell"
        var cell: SetupTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? SetupTableViewCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "SetupTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SetupTableViewCell
        }
        
        let dictionaryContent = self.tableData[indexPath.row] as! NSDictionary
        
        cell.imageCell?.image = UIImage(named: dictionaryContent["image"] as! String)
        cell.labelTitle!.text = dictionaryContent["title"] as? String
        cell.labelContent!.text = dictionaryContent["content"] as? String
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    
    
    
}

// MARK: - Initial Setup 
class InitialSetupViewController : UIViewController, UITextFieldDelegate, WebserviceClassDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var viewHolder: UIImageView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var textAnswer: UITextField!
    var setupDone: Bool = false

    var count : Int = 0
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        
        self.viewHolder.layer.borderWidth = 3.0
        self.viewHolder.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.buttonSave.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonSave.layer.borderWidth = 2.0
        self.buttonSave.layer.cornerRadius = 5
        self.buttonSave.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.viewHolder.alpha = 0;
        
    
        self.labelQuestion.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.labelQuestion.layer.borderWidth = 2
        self.labelQuestion.layer.borderColor = UIColor.whiteColor().CGColor
//        self.labelQuestion.layer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        let question = AppModel.sharedInstance.questions[self.count] as! QuestionModel
        
        
        self.textAnswer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.textAnswer.layer.borderColor = UIColor.whiteColor().CGColor
        self.textAnswer.layer.cornerRadius = 5
        self.textAnswer.layer.borderWidth = 2
        
        self.labelQuestion.text = question.question
        self.textAnswer.text = "Answer"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.setupDone == true {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.setupDone = true
    }
    
    // MARK: Button Actions
    @IBAction func saveButtonClicked(sender: UIButton) {
        
        if self.textAnswer.text! == "" || self.textAnswer.text! == "Answer" {
            return
        }
        

        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        self.addQuestion()
                                                        
//                                                        self.performSegueWithIdentifier("goToHomeTab", sender: self)
                                    
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
        
    }
    
    // MARK: Method
    func addQuestion() {
        
        let questionCurrent = AppModel.sharedInstance.questions[self.count] as! QuestionModel
        questionCurrent.answer = self.textAnswer.text!
        
        AppModel.sharedInstance.preparedQuestion.addObject(questionCurrent)
        
        if self.count != AppModel.sharedInstance.questions.count - 1 {
            self.animateUserInterface()
            return
        }
        self.setupQuestions()
        
//        self.performSegueWithIdentifier("goToHomeTab", sender: self)
    
    }
    
    // Webservice
    func setupQuestions() {
        
        let dictionaryParam = NSMutableDictionary()
        let arrayQuestions = NSMutableArray()
        
        
        for objectModel in AppModel.sharedInstance.preparedQuestion {
            let model = objectModel as! QuestionModel
            let dictionaryQuestion = NSMutableDictionary()
            dictionaryQuestion.setObject(model.identifier, forKey: "qid")
            dictionaryQuestion.setObject(model.answer, forKey: "answer")
            arrayQuestions.addObject(dictionaryQuestion)
            
        }
        
        
        dictionaryParam.setObject(AppModel.sharedInstance.user.identifier, forKey: "uid")
        dictionaryParam.setObject(arrayQuestions, forKey: "questions")
        
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kPrepared
        webservice.identifier = "addNestor"
        webservice.delegate = self
        webservice.sendPatchWithParameter(dictionaryParam)
    }
    
    func animateUserInterface() {
//        
//        let questionCurrent = AppModel.sharedInstance.questions[self.count] as! QuestionModel
//        questionCurrent.answer = self.textAnswer.text!
        
        self.count++
        let questionNext = AppModel.sharedInstance.questions[self.count] as! QuestionModel
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.labelQuestion.frame = CGRectMake(-self.labelQuestion.frame.size.width, self.labelQuestion.frame.origin.y, self.labelQuestion.frame.size.width, self.labelQuestion.frame.size.height)
            
            }, completion: { (finish: Bool) in
                
                self.labelQuestion.frame = CGRectMake(self.view.frame.size.width, self.labelQuestion.frame.origin.y, self.labelQuestion.frame.size.width, self.labelQuestion.frame.size.height)
                UIView.animateWithDuration(0.3, animations: {
                    self.labelQuestion.frame = CGRectMake(30, self.labelQuestion.frame.origin.y, self.labelQuestion.frame.size.width, self.labelQuestion.frame.size.height)
                    self.textAnswer.frame = CGRectMake(-self.textAnswer.frame.size.width, self.textAnswer.frame.origin.y, self.textAnswer.frame.size.width, self.textAnswer.frame.size.height)
                    }, completion: { (finish: Bool) in
                        self.labelQuestion.text = questionNext.question
                        self.textAnswer.text = "Answer"
                        self.textAnswer.frame = CGRectMake(self.view.frame.size.width, self.textAnswer.frame.origin.y, self.textAnswer.frame.size.width, self.textAnswer.frame.size.height)
                        UIView.animateWithDuration(0.2, animations: {
                            self.textAnswer.frame = CGRectMake(40, self.textAnswer.frame.origin.y, self.textAnswer.frame.size.width, self.textAnswer.frame.size.height)
                            }, completion: { (finish: Bool) in
                                
                        })
                })
        })

    }
    
    // MARK: Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: Webservice
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
      self.performSegueWithIdentifier("goToHomeTab", sender: self)
        
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToHomeTab" {
            
        }
    }
}

// MARK: - Tab Bar Controller
class HomeTabBarController : UITabBarController {
    
    var questionColletion: QuestionCollectionModel?
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.blueColor()

        
    }
    
    
    
}


// MARK: - Question Viewer

class QuestionViewerController : UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var imgLabelFrame: UIImageView!
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var textAnswer: UITextField!
    
    @IBOutlet weak var textOption1: UITextField!
    @IBOutlet weak var textOption2: UITextField!
    @IBOutlet weak var textOption3: UITextField!
    
    var question: QuestionModel?
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.imgLabelFrame.layer.cornerRadius = 10.0
        self.imgLabelFrame.layer.borderColor = UIColor.whiteColor().CGColor
        self.imgLabelFrame.layer.borderWidth = 2.0
        self.imgLabelFrame.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.labelQuestion.adjustsFontSizeToFitWidth = true
        
        self.textAnswer.layer.cornerRadius = 5.0
        self.textAnswer.layer.borderColor = UIColor.whiteColor().CGColor
        self.textAnswer.layer.borderWidth = 2.0
        self.textAnswer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.textOption1.layer.cornerRadius = 5.0
        self.textOption1.layer.borderColor = UIColor.whiteColor().CGColor
        self.textOption1.layer.borderWidth = 2.0
        self.textOption1.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.textOption2.layer.cornerRadius = 5.0
        self.textOption2.layer.borderColor = UIColor.whiteColor().CGColor
        self.textOption2.layer.borderWidth = 2.0
        self.textOption2.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.textOption3.layer.cornerRadius = 5.0
        self.textOption3.layer.borderColor = UIColor.whiteColor().CGColor
        self.textOption3.layer.borderWidth = 2.0
        self.textOption3.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.labelQuestion.text = self.question!.question
        self.textOption3.text = self.question!.options[2] as? String
        self.textOption2.text = self.question!.options[1] as? String
        self.textOption1.text = self.question!.options[0] as? String
        self.textAnswer.text = self.question!.answer
        
        self.textAnswer.textColor = UIColor.whiteColor()
        self.textAnswer.textAlignment = NSTextAlignment.Center
        
        self.textOption2.textColor = UIColor.whiteColor()
        self.textOption2.textAlignment = NSTextAlignment.Center
        
        self.textOption1.textColor = UIColor.whiteColor()
        self.textOption1.textAlignment = NSTextAlignment.Center
        
        self.textOption3.textColor = UIColor.whiteColor()
        self.textOption3.textAlignment = NSTextAlignment.Center
        
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
    
    // MARK: Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
        
    }
    
    
}


// MARK: - Question and Answer Preview
class QuestionAnswerPreviewViewController : UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var viewSummary: UIView!
    @IBOutlet weak var labelSummary: UILabel!
    @IBOutlet weak var viewQuestion: UIView!
    @IBOutlet weak var labelQuesiton: UILabel!
    @IBOutlet weak var labelAnswer: UILabel!
    @IBOutlet weak var imgResult: UIImageView!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var labelCount: UILabel!
    
    var challengePreviewModel: ChallengeResultModel?
    
    var counter: Int!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.counter = 1
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.viewQuestion.layer.borderWidth = 2
        self.viewQuestion.layer.cornerRadius = 10
        self.viewQuestion.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewQuestion.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
    
        self.viewSummary.layer.borderWidth = 2
        self.viewSummary.layer.cornerRadius = 10
        self.viewSummary.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewSummary.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.buttonNext.layer.borderWidth = 2
        self.buttonNext.layer.cornerRadius = 10
        self.buttonNext.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.buttonPrevious.layer.borderWidth = 2
        self.buttonPrevious.layer.cornerRadius = 10
        self.buttonPrevious.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonPrevious.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.labelSummary.text = "He got 3 correct answer out of 5 questions"
        self.labelSummary.adjustsFontSizeToFitWidth = true
        
        let chalenge = self.challengePreviewModel!.result[self.counter - 1] as! QuestionPreviewModel
        self.labelQuesiton.text = chalenge.question
        self.labelAnswer.text = chalenge.answer
        self.labelCount.text = "\(self.counter)"
        if chalenge.result == "Correct" {
            self.imgResult.image = UIImage(named: "check-button-clr")
        }else {
            
            self.imgResult.image = UIImage(named: "x-button-clr")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func nextButtonClicked(sender: UIButton) {
        self.buttonPrevious.enabled = false
        self.buttonNext.enabled = false
        
        self.buttonPrevious.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.buttonNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        
        if self.counter == 5 {
            self.counter = 1
        }else {
            self.counter = self.counter + 1
        }
    
        
        let chalenge = self.challengePreviewModel!.result[self.counter - 1] as! QuestionPreviewModel
        
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
       
        UIView.animateWithDuration(0.2, animations: {
            
//            self.viewSummary.frame = CGRectMake(-self.viewSummary.frame.size.width, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
            self.viewQuestion.frame = CGRectMake(-self.viewQuestion.frame.size.width-10, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
            
            }, completion: { (finish: Bool) in
//                self.viewSummary.frame = CGRectMake(self.view.frame.size.width, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
                self.viewQuestion.frame = CGRectMake(self.view.frame.size.width + 10, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
                self.labelQuesiton.text = chalenge.question
                self.labelAnswer.text = chalenge.answer
                self.labelCount.text = "\(self.counter)"
                if chalenge.result == "Correct" {
                    self.imgResult.image = UIImage(named: "check-button-clr")
                }else {
                    
                    self.imgResult.image = UIImage(named: "x-button-clr")
                }
                
                UIView.animateWithDuration(0.2, animations: {
//                    self.viewSummary.frame = CGRectMake(40, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
                    self.viewQuestion.frame = CGRectMake(30, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
                    
                    }, completion: { (finish: Bool) in
                        
                        self.buttonPrevious.enabled = true
                        self.buttonNext.enabled = true
                        
                        self.buttonPrevious.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
                        self.buttonNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
                })
        })
        
        
    }
    
    @IBAction func previousButtonClicked(sender: UIButton) {
        self.buttonPrevious.enabled = false
        self.buttonNext.enabled = false
        self.buttonPrevious.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.buttonNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        if self.counter == 1 {
            self.counter = 5
        }else {
            self.counter = self.counter - 1
        }
        
        let chalenge = self.challengePreviewModel!.result[self.counter - 1] as! QuestionPreviewModel
        
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
        
        UIView.animateWithDuration(0.2, animations: {
//            self.viewSummary.frame = CGRectMake(self.view.frame.size.width, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
            self.viewQuestion.frame = CGRectMake(self.view.frame.size.width + 10, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
            
            }, completion: { (finish: Bool) in
                
//                self.viewSummary.frame = CGRectMake(-self.viewSummary.frame.size.width, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
                self.viewQuestion.frame = CGRectMake(-self.viewQuestion.frame.size.width-10, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
                
                self.labelQuesiton.text = chalenge.question
                self.labelAnswer.text = chalenge.answer
                self.labelCount.text = "\(self.counter)"
                if chalenge.result == "Correct" {
                    self.imgResult.image = UIImage(named: "check-button-clr")
                }else {
                    
                    self.imgResult.image = UIImage(named: "x-button-clr")
                }
                
                UIView.animateWithDuration(0.2, animations: {
                    
//                    self.viewSummary.frame = CGRectMake(40, self.viewSummary.frame.origin.y, self.viewSummary.frame.size.width, self.viewSummary.frame.size.height)
                    self.viewQuestion.frame = CGRectMake(30, self.viewQuestion.frame.origin.y, self.viewQuestion.frame.size.width, self.viewQuestion.frame.size.height)
                    
                    }, completion: { (finish: Bool) in
                        
                        self.buttonPrevious.enabled = true
                        self.buttonNext.enabled = true
                        
                        self.buttonPrevious.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
                        self.buttonNext.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
                })
        })
    }
    
}

// MARK: - Profile,
class ProfileViewController : UIViewController{
    
    // MARK: Properties
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var scrollInvites: UIScrollView!
    
    var arrayNotification: NSMutableArray! = NSMutableArray()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        var width = self.view.frame.size.width - 60 as CGFloat
        width = width / 3
        
        self.viewHolder.layer.borderWidth = 2.0
        self.viewHolder.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewHolder.layer.cornerRadius = 10.0
        self.viewHolder.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.scrollInvites.layer.borderWidth = 2.0
        self.scrollInvites.layer.borderColor = UIColor.whiteColor().CGColor
 
        
        let arrayNotification = ["Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso", "Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso"] as NSArray
        
        self.arrayNotification.addObjectsFromArray(arrayNotification as [AnyObject])
        
        var yLocation = 0 as CGFloat
        for (var count = 0; count < self.arrayNotification.count; count++) {
        
            let buttonBack = UIButton(type: UIButtonType.Custom)
            buttonBack.frame = CGRectMake(0, yLocation, self.view.frame.size.width-40, 40)
            buttonBack.setTitle(self.arrayNotification[count] as? String, forState: UIControlState.Normal)
            buttonBack.layer.borderWidth = 1.0
            buttonBack.layer.borderColor = UIColor.whiteColor().CGColor
            self.scrollInvites.addSubview(buttonBack)
            
            yLocation = yLocation + 39
        
        }
        
        self.scrollInvites.contentSize = CGSizeMake(0, yLocation)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    // MARK: Delegate
}

// MARK: - Challenge
class ChallengeViewController : UIViewController, WebserviceClassDelegate {
    
    // MARK: Prorperties
    @IBOutlet weak var imgQuestion: UIImageView!
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var viewPowerups: UIView!
    @IBOutlet weak var buttonBomb: UIButton!
    @IBOutlet weak var buttonShow: UIButton!
    @IBOutlet weak var buttonChange: UIButton!
    @IBOutlet weak var buttonPower: UIButton!
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var challenge: ChallengeModel?
    var questions: QuestionCollectionModel?
    var counter: Int!
    var reservedQuestion: NSMutableArray!
    var powerupsUsed: NSMutableDictionary!
    

    // MARK: View Life Cycle
    override func viewDidLoad() {
        self.reservedQuestion = NSMutableArray()
        self.powerupsUsed = NSMutableDictionary()
        let bobms = NSMutableArray()
        let show = NSMutableArray()
        let change = NSMutableArray()
        self.powerupsUsed.setObject(bobms, forKey: "bombs")
        self.powerupsUsed.setObject(show, forKey: "show")
        self.powerupsUsed.setObject(change, forKey: "changed")
        
        self.counter = 0
        
        self.imgQuestion.layer.borderColor = UIColor.whiteColor().CGColor
        self.imgQuestion.layer.borderWidth = 2.0
        self.imgQuestion.layer.cornerRadius = 10
        self.imgQuestion.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.button1.layer.borderColor = UIColor.whiteColor().CGColor
        self.button1.layer.borderWidth = 2.0
        self.button1.layer.cornerRadius = 5
        self.button1.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.button2.layer.borderColor = UIColor.whiteColor().CGColor
        self.button2.layer.borderWidth = 2.0
        self.button2.layer.cornerRadius = 5
        self.button2.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.button3.layer.borderColor = UIColor.whiteColor().CGColor
        self.button3.layer.borderWidth = 2.0
        self.button3.layer.cornerRadius = 5
        self.button3.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.button4.layer.borderColor = UIColor.whiteColor().CGColor
        self.button4.layer.borderWidth = 2.0
        self.button4.layer.cornerRadius = 5
        self.button4.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getFriends()
    
    }
    
    // MARK: Method
    func getFriends() {
        
        let dictionaryParam = NSMutableDictionary()
        var parameter = "?setId=[quiz]&senderId=[user]"
        parameter = parameter.stringByReplacingOccurrencesOfString("[quiz]", withString: challenge!.identifier)
        parameter = parameter.stringByReplacingOccurrencesOfString("[user]", withString: challenge!.friend.identifier)
        dictionaryParam.setObject(parameter, forKey: "uid")
        let webservice = WebserviceClass()
        webservice.link = kWebLink + kQSet
        webservice.identifier = "getQuestions"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
    
    func setContents() {
        
        let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
        let temporaryArray = NSMutableArray()
        temporaryArray.addObjectsFromArray(question.options as [AnyObject])
        if !temporaryArray.containsObject(question.answer) {
            temporaryArray.removeLastObject()
            temporaryArray.addObject(question.answer)
        }
        if question.type == "custom" {
            temporaryArray.addObject(question.answer)
        }
        
        self.labelQuestion.text = question.question
        print("Correct Answer = \(question.answer)")
        
        var random = Int(arc4random_uniform(UInt32(temporaryArray.count)))
        self.button1.setTitle(temporaryArray[random] as? String, forState: UIControlState.Normal)
        temporaryArray.removeObjectAtIndex(random)
        
        random = Int(arc4random_uniform(UInt32(temporaryArray.count)))
        self.button2.setTitle(temporaryArray[random] as? String, forState: UIControlState.Normal)
        temporaryArray.removeObjectAtIndex(random)
        
        random = Int(arc4random_uniform(UInt32(temporaryArray.count)))
        self.button3.setTitle(temporaryArray[random] as? String, forState: UIControlState.Normal)
        temporaryArray.removeObjectAtIndex(random)
        
        random = Int(arc4random_uniform(UInt32(temporaryArray.count)))
        self.button4.setTitle(temporaryArray[random] as? String, forState: UIControlState.Normal)
        temporaryArray.removeObjectAtIndex(random)
        
        self.button1.tag = 1001
        self.button4.tag = 1001
        self.button2.tag = 1001
        self.button3.tag = 1001
        
        self.button1.alpha = 1
        self.button4.alpha = 1
        self.button2.alpha = 1
        self.button3.alpha = 1
        
        if self.button1.titleLabel!.text == question.answer {
            self.button1.tag = 1003
            self.button2.tag = 1002
        }
        
        if self.button2.titleLabel!.text == question.answer {
            self.button2.tag = 1003
            self.button1.tag = 1002
        }
        
        if self.button3.titleLabel!.text == question.answer {
            self.button3.tag = 1003
            self.button4.tag = 1002
        }
        
        if self.button4.titleLabel!.text == question.answer {
            self.button4.tag = 1003
            self.button3.tag = 1002
        }
        
        self.buttonBomb.enabled = true
        self.buttonShow.enabled = true
        self.buttonChange.enabled = true
    
        
    }
    
    func sendAnswer() {
        
    
        print("PARAMETER = \(self.powerupsUsed)")
        
        let dictionaryParameter = NSMutableDictionary()
        dictionaryParameter.setObject(self.challenge!.stats, forKey: "stats_id")
        dictionaryParameter.setObject(self.challenge!.identifier, forKey: "set_id")
        dictionaryParameter.setObject(AppModel.sharedInstance.user.identifier, forKey: "rid")
        dictionaryParameter.setObject(self.challenge!.friend.identifier, forKey: "sender_id")
        dictionaryParameter.setObject("1", forKey: "status")
        
        let results  = NSMutableArray()
        for  objectChallenge in  self.challenge!.questionSet.collection{
            let challengeRep = objectChallenge as! QuestionModel
            let dictionaryQuestion = NSMutableDictionary()
            
            dictionaryQuestion.setObject(challengeRep.identifier, forKey: "qid")
            dictionaryQuestion.setObject(challengeRep.selectedAnswer, forKey: "answer")
            dictionaryQuestion.setObject(challengeRep.result, forKey: "correct")
            results.addObject(dictionaryQuestion)
            
        }
        dictionaryParameter.setObject(results, forKey: "results")
        
        
        dictionaryParameter.setObject(self.powerupsUsed, forKey: "powerups")
        
        let webservice = WebserviceClass()
        webservice.link = "\(kWebLink)\(kSendAnswer)\(self.challenge!.stats)"
        webservice.identifier = "patchData"
        webservice.delegate = self
        webservice.sendPatchWithParameter(dictionaryParameter)
        
    }
    
    func answer(selected: String) {
        
        let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
        question.selectedAnswer = selected
        question.result = "false"
        if question.answer == selected {
            question.result = "true"
        }
        self.counter = self.counter + 1
        
        if self.counter == 5 {
            self.sendAnswer()
        }else {
            UIView.animateWithDuration(0.2, animations: {
                
                self.viewHolder.frame = CGRectMake(-self.viewHolder.frame.size.width, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                
                }, completion: { (finish: Bool) in
                    /*&
                    let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
                    self.labelQuestion.text = question.question
                    self.button1.setTitle(question.answer, forState: UIControlState.Normal)
                    self.button2.setTitle(question.options[0] as? String, forState: UIControlState.Normal)
                    self.button3.setTitle(question.options[1] as? String, forState: UIControlState.Normal)
                    self.button4.setTitle(question.options[2] as? String, forState: UIControlState.Normal)
                    self.viewHolder.frame = CGRectMake(self.viewHolder.frame.size.width, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                    
*/
                    self.setContents()
                    UIView.animateWithDuration(0.2, animations: {
                        self.viewHolder.frame = CGRectMake(0, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                        }, completion: { (finish: Bool) in
                            
                    })
            })
        }
        
        
        
    }
    
    // MARK: Button Actions
    
    @IBAction func powerClicked(sender: UIButton) {
        
        sender.enabled = false
        
        UIView.animateWithDuration(0.2, animations: {
            
            var frame = self.viewPowerups.frame
            
            if frame.origin.x == self.view.frame.size.width {
                frame.origin.x = frame.origin.x - 60
            }else {
                frame.origin.x = frame.origin.x + 60
            }
            
            self.viewPowerups.frame = frame
            }, completion: { (finish: Bool) in
                
                sender.enabled = true
                
        })
        
    }
    
    @IBAction func bombClicked(sender: UIButton) {
        
        sender.enabled = false
        
        
        let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
        
        let array = self.powerupsUsed["bombs"] as! NSMutableArray
        let dictionary = NSMutableDictionary()
        dictionary.setObject(question.identifier, forKey: "qid")
        array.addObject(dictionary)
        self.powerupsUsed.setObject(array, forKey: "bombs")
        
        
        UIView.animateWithDuration(0.5, animations: {
            
            if self.button1.tag == 1001 {
                self.button1.alpha = 0
            }
            if self.button2.tag == 1001 {
                self.button2.alpha = 0
            }
            if self.button3.tag == 1001 {
                self.button3.alpha = 0
            }
            if self.button4.tag == 1001 {
                self.button4.alpha = 0
            }
            
            }, completion: { (finish : Bool) in
                
        })
        
        
      
        
        
        
    }
    
    @IBAction func showClicked(sender: UIButton) {
        sender.enabled = false
        
        let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
        
        let array = self.powerupsUsed["show"] as! NSMutableArray
        let dictionary = NSMutableDictionary()
        dictionary.setObject(question.identifier, forKey: "qid")
        array.addObject(dictionary)
        self.powerupsUsed.setObject(array, forKey: "show")
        
        UIView.animateWithDuration(0.5, animations: {
            
            if self.button1.tag != 1003 {
                self.button1.alpha = 0
            }
            if self.button2.tag != 1003 {
                self.button2.alpha = 0
            }
            if self.button3.tag != 1003 {
                self.button3.alpha = 0
            }
            if self.button4.tag != 1003 {
                self.button4.alpha = 0
            }
            
            }, completion: { (finish : Bool) in
                
        })
    }
    
    @IBAction func changeClicked(sender: UIButton) {
        
        if self.reservedQuestion.count == 0 {
            return
        }
        
        let question = self.challenge!.questionSet.collection[self.counter] as! QuestionModel
        let newQuestion = self.reservedQuestion.lastObject as! QuestionModel
        self.challenge!.questionSet.collection.replaceObjectAtIndex(self.counter, withObject: newQuestion)
        
        let array = self.powerupsUsed["changed"] as! NSMutableArray
        let dictionary = NSMutableDictionary()
        dictionary.setObject(question.identifier, forKey: "from")
        dictionary.setObject(newQuestion.identifier, forKey: "to")
        array.addObject(dictionary)
        self.powerupsUsed.setObject(array, forKey: "changed")
        self.reservedQuestion.removeLastObject()
        self.setContents()
        
    }
    
    @IBAction func button1Clicked(sender: UIButton) {
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        UIView.animateWithDuration(0.1, animations: {
            
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
        
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        self.answer(sender.titleLabel!.text!)
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
    @IBAction func button2Clicked(sender: UIButton) {
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                    
                                                        self.answer(sender.titleLabel!.text!)
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
    @IBAction func button3Clicked(sender: UIButton) {
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                        
                                                        self.answer(sender.titleLabel!.text!)
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
    @IBAction func button4Clicked(sender: UIButton) {
        var degrees = 5 as Double
        var radians = (degrees / 180.0) * M_PI as Double
        UIView.animateWithDuration(0.1, animations: {
            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            
            
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.2, animations: {
                    degrees = -15
                    radians = (degrees / 180.0)
                    
                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                    
                    }, completion: { (finish: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            
                            sender.transform = CGAffineTransformIdentity
                            
                            }, completion: { (finish: Bool) in
                                
                                degrees = 5
                                UIView.animateWithDuration(0.1, animations: {
                                    sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                    
                                    }, completion: { (finish: Bool) in
                                        UIView.animateWithDuration(0.2, animations: {
                                            degrees = -15
                                            radians = (degrees / 180.0)
                                            
                                            sender.transform = CGAffineTransformMakeRotation(CGFloat(radians))
                                            
                                            }, completion: { (finish: Bool) in
                                                UIView.animateWithDuration(0.1, animations: {
                                                    
                                                    sender.transform = CGAffineTransformIdentity
                                                    
                                                    
                                                    }, completion: { (finish: Bool) in
                                                        
                                                        
                                                        
                                                        self.answer(sender.titleLabel!.text!)
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
    //MARK: Delegate
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.statusCode > 203 {
            // Alert (Something went wrong on the Rest API)
            return
        }
        
        if webservice.identifier == "getQuestions" {
            let returnQuestions = content["questions"] as! NSArray
            let returnExtra = content["extra"] as! NSDictionary
            self.reservedQuestion.removeAllObjects()
            
            let predicatePrepared = NSPredicate(format: "self.type == 'prepared'")
            let predicateCustom = NSPredicate(format: "self.type == 'custom'")
            
            let questionPrepared = returnQuestions.filteredArrayUsingPredicate(predicatePrepared) as NSArray
            let questionCustom = returnQuestions.filteredArrayUsingPredicate(predicateCustom) as NSArray
            let extraPrepared = returnExtra["prepared"] as! NSArray
            let extraCustom = returnExtra["custom"] as! NSArray
            
            for objectPrepared in questionPrepared {
                let dictionaryPrepared = objectPrepared as! NSDictionary
                let key = dictionaryPrepared["qid"] as! String
                let predicate = NSPredicate(format: "self.identifier == '\(key)'")
                let arrayFilter = AppModel.sharedInstance.preparedQuestion.filteredArrayUsingPredicate(predicate) as NSArray
                if arrayFilter.count != 0 {
                    let model = arrayFilter[0] as! QuestionModel
                    let newQuestion = QuestionModel()
                    newQuestion.identifier = model.identifier
                    newQuestion.type = model.type
                    newQuestion.answer = dictionaryPrepared["answer"] as! String
                    newQuestion.question = model.question
                    print(model.options)
                    newQuestion.options.addObjectsFromArray(model.options as [AnyObject])
                    self.challenge!.questionSet.collection.addObject(newQuestion)
                    
                }
            }
            
            for objectCustom in questionCustom {
                let dictionaryCustom = objectCustom as! NSDictionary
                let newQuestion = QuestionModel()
                newQuestion.identifier = dictionaryCustom["qid"] as! String
                newQuestion.type = "custom"
                newQuestion.answer = dictionaryCustom["answer"] as! String
                newQuestion.question = dictionaryCustom["question"] as! String
                newQuestion.options.addObjectsFromArray(dictionaryCustom["options"] as! NSArray as [AnyObject])
                self.challenge!.questionSet.collection.addObject(newQuestion)
            }
            
            for objectPrepared in extraPrepared {
                let dictionaryPrepared = objectPrepared as! NSDictionary
                let key = dictionaryPrepared["qid"] as! String
                let predicate = NSPredicate(format: "self.identifier == '\(key)'")
                let arrayFilter = AppModel.sharedInstance.preparedQuestion.filteredArrayUsingPredicate(predicate) as NSArray
                if arrayFilter.count != 0 {
                    let model = arrayFilter[0] as! QuestionModel
                    let newQuestion = QuestionModel()
                    newQuestion.identifier = model.identifier
                    newQuestion.type = model.type
                    newQuestion.answer = dictionaryPrepared["answer"] as! String
                    newQuestion.question = model.question
                    print(model.options)
                    newQuestion.options.addObjectsFromArray(model.options as [AnyObject])
                    self.reservedQuestion.addObject(newQuestion)
                    
                }
            }
            
            for objectCustom in extraCustom {
                let dictionaryCustom = objectCustom as! NSDictionary
                let newQuestion = QuestionModel()
                newQuestion.identifier = dictionaryCustom["qid"] as! String
                newQuestion.type = "custom"
                newQuestion.answer = dictionaryCustom["answer"] as! String
                newQuestion.question = dictionaryCustom["question"] as! String
                newQuestion.options.addObjectsFromArray(dictionaryCustom["options"] as! NSArray as [AnyObject])
                self.reservedQuestion.addObject(newQuestion)
            }
            
            
            self.setContents()
        }else {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }
        
        
        
        
    }
    
    
}