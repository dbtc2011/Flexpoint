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
    
    
    // https://fb.me/750184568442914
    // MARK: Properties
    @IBOutlet weak var buttonLoginFacebook: UIButton!
    @IBOutlet weak var buttonLoginEmail: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    var currentUser: UserModel?
    var questionColletion: QuestionCollectionModel?
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let fbLogin = FBSDKLoginButton(frame: CGRectMake(30, (self.view.frame.size.height/2) + (self.view.frame.size.height/4) - 20 , self.view.frame.size.width-60, 40))
        fbLogin.delegate = self
        fbLogin.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(fbLogin)
        
//        self.buttonLoginEmail.hidden = true
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
                
                self.currentUser = nil
                self.currentUser = UserModel()
                self.currentUser!.firstName = dictionaryResult["first_name"] as! String
                self.currentUser!.email = dictionaryResult["email"] as! String
                self.currentUser!.emailType = "facebook"
                self.currentUser!.lastName = dictionaryResult["last_name"] as! String
                self.currentUser!.imageLink = dictionaryData["url"] as! String
                
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
                webservice.link = "http://stupideasygames.com/friendapp/api/ios/users/"
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
        /*
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("SetupVC") as? SetupViewController
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: {
            
        })
*/
        
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: "https://fb.me/750184568442914")!
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)

//        self.performSegueWithIdentifier("goToInitialSetup", sender: self)
    }
    

    // MARK: Method
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
            
            self.currentUser!.identifier = content["_id"] as! String
            
            dictionaryParam.setObject(self.currentUser!.identifier, forKey: "id")
    
            let webservice = WebserviceClass()
            webservice.link = "http://stupideasygames.com/friendapp/api/ios/users/"
            webservice.identifier = "getData"
            webservice.delegate = self
            webservice.getMethod(dictionaryParam)
            
        }else if webservice.identifier == "getData" {
            
            self.questionColletion = nil
            self.questionColletion = QuestionCollectionModel()
            let questionDictionary = content["questions"] as! NSDictionary
            let preparedArray = questionDictionary["prepared_questions"] as! NSArray
            let customArray = questionDictionary["custom_questions"] as! NSArray
            
            if preparedArray.count != 0 {
                
                for objectContent in preparedArray {
                    let dictionaryPrepared = objectContent as! NSDictionary
                    let questionModelRepresentation = QuestionModel()
                    questionModelRepresentation.identifier = dictionaryPrepared["qid"] as! String
                    questionModelRepresentation.answer = dictionaryPrepared["answer"] as! String
                    questionModelRepresentation.type = "prepared"
                    self.questionColletion!.collection.addObject(questionModelRepresentation)
                    
                }
                
                for objectContent in customArray {
                    let dictionaryCstom = objectContent as! NSDictionary
                    let questionModelRepresentation = QuestionModel()
                    questionModelRepresentation.identifier = dictionaryCstom["qid"] as! String
                    questionModelRepresentation.answer = dictionaryCstom["answer"] as! String
                    questionModelRepresentation.question = dictionaryCstom["question"] as! String
                    questionModelRepresentation.options.addObjectsFromArray(dictionaryCstom["options"] as! NSArray as [AnyObject])
                    questionModelRepresentation.type = "custom"
                    self.questionColletion!.collection.addObject(questionModelRepresentation)
                    
                }
                
            }
            
            let dictionaryParam = NSMutableDictionary()
            
            let webservice = WebserviceClass()
            webservice.link = "http://stupideasygames.com/friendapp/api/ios/questions/prepared"
            webservice.identifier = "getPrepared"
            webservice.delegate = self
            webservice.getMethod(dictionaryParam)
            
            self.currentUser!.identifier = content["user_id"] as! String
            
            
            
        }else if webservice.identifier == "getPrepared" {
            
            let preparedArray = content["data"] as! NSArray
            let arrayPrepared = NSMutableArray()
            
            for objectContet in preparedArray {
                
                let dictionaryContent = objectContet as! NSDictionary
                let question = QuestionModel()
                question.question = dictionaryContent["question"] as! String
                question.identifier = dictionaryContent["_id"] as! String
                arrayPrepared.addObject(question)
                
            }
            
            if self.questionColletion!.collection.count == 0 {
//                self.performSegueWithIdentifier("goToInitialSetup", sender: arrayPrepared)
                
                let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("SetupVC") as? SetupViewController
                self.navigationController?.pushViewController(mapViewControllerObejct!, animated: true)
                
                return
            }
            for model in arrayPrepared {
                
                let questionModel = model as! QuestionModel
                let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
                let arrayFilter = self.questionColletion!.collection.filteredArrayUsingPredicate(predicate) as NSArray
                if arrayFilter.count != 0 {
                    let updateModel = arrayFilter[0] as! QuestionModel
                    let index = self.questionColletion!.collection.indexOfObject(updateModel)
                    let oldModel = self.questionColletion!.collection[index] as! QuestionModel
                    oldModel.question = updateModel.question
                    oldModel.options.addObjectsFromArray(updateModel.options as [AnyObject])
                    self.questionColletion!.collection.replaceObjectAtIndex(index, withObject: oldModel)
                }
                
            }
            self.performSegueWithIdentifier("goToHomeTab", sender: self.questionColletion!.collection)
           

        }
    }
    
    // FBSDKLoginButton Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
    }
    
    // MARK: SEgue
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToInitialSetup" {
            
            let array = sender as! NSMutableArray
            let controller = segue.destinationViewController as! InitialSetupViewController
            controller.currentUser = self.currentUser!
            controller.arrayPreparedQuestions.addObjectsFromArray(array as [AnyObject])
            
        }else if segue.identifier! == "goToHomeTab" {
            
            let controller = segue.destinationViewController as! HomeTabBarController
            controller.currentUser = self.currentUser!
            controller.questionColletion = self.questionColletion!
            
        }
        
    }
}

// MARK: - Signup
class SignupViewController : UIViewController, UITextFieldDelegate, WebserviceClassDelegate {
    
    
    // MARK: Properties
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textConfirmPassword: UITextField!
    
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var buttonSignupFacebook: UIButton!
    
    var arrayUsers: NSMutableArray?
    var currentUser: UserModel?
    var arrayPreparedQuestions: NSMutableArray?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 80, 40)
        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
    
        self.textName.textColor = UIColor.whiteColor()
        self.textEmail.textColor = UIColor.whiteColor()
        self.textPassword.textColor = UIColor.whiteColor()
        self.textConfirmPassword.textColor = UIColor.whiteColor()
        
        self.textName.text = "Name"
        self.textEmail.text = "Email"
        self.textPassword.text = "Password"
        self.textConfirmPassword.text = "Confirm Password"
        
        self.textName.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.textName.layer.borderColor = UIColor.whiteColor().CGColor
        self.textName.layer.borderWidth = 2
        self.textName.layer.cornerRadius = 10
        
        self.textEmail.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.textEmail.layer.borderColor = UIColor.whiteColor().CGColor
        self.textEmail.layer.borderWidth = 2
        self.textEmail.layer.cornerRadius = 10
        
        self.textPassword.layer.borderColor = UIColor.whiteColor().CGColor
        self.textPassword.layer.borderWidth = 2
        self.textPassword.layer.cornerRadius = 10
        self.textPassword.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.textConfirmPassword.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.textConfirmPassword.layer.borderColor = UIColor.whiteColor().CGColor
        self.textConfirmPassword.layer.borderWidth = 2
        self.textConfirmPassword.layer.cornerRadius = 10
        
        

        self.buttonSignup.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonSignup.layer.shadowOpacity = 1
        self.buttonSignup.layer.cornerRadius = 5.0
        self.buttonSignup.layer.shadowOffset = CGSizeMake(5, 5)
        
        self.buttonSignupFacebook.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonSignupFacebook.layer.shadowOpacity = 1
        self.buttonSignupFacebook.layer.cornerRadius = 5.0
        self.buttonSignupFacebook.layer.shadowOffset = CGSizeMake(5, 5)
        
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
    @IBAction func signupClicked(sender: UIButton) {
        
        self.currentUser = nil
        self.currentUser = UserModel()
        self.currentUser!.emailType = "Facebook"
        self.currentUser!.email = "\(self.textEmail.text!).\(self.textPassword.text!)@yahoo.com"
        self.currentUser!.identifier = "\(self.textEmail.text!).\(self.textPassword.text!)"
        self.currentUser!.firstName = self.textEmail.text!
        self.currentUser!.lastName = self.textPassword.text!
        
        if self.textEmail.text! == "" || self.textPassword.text! == "" {
            
            return
        }
        
        self.loginWithUser()
//        self.performSegueWithIdentifier("goToHome", sender: self)
    }
    @IBAction func signupFacebookClicked(sender: UIButton) {
        self.nestor()
    }
    
    // MARK: Method
    // Webservice for login
    func loginWithUser() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetUsers.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getUser"
        webservice.delegate = self
        webservice.sendPostWithStringParameter(dictionaryParam)
    }
    func nestor() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://stupideasygames.com/friendapp/api/ios/users/"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "addNestor"
        webservice.delegate = self
        
        let dictionaryName = NSMutableDictionary()
        let dictionaryUsername = NSMutableDictionary()
        let dictionaryImage = NSMutableDictionary()

        dictionaryUsername.setObject(self.textEmail.text!, forKey: "email")
        dictionaryName.setObject(self.textName.text!, forKey: "first")
        dictionaryName.setObject(self.textPassword.text!, forKey: "last")
        dictionaryUsername.setObject(self.textConfirmPassword.text!, forKey: "uid")
        dictionaryUsername.setObject("facebook", forKey: "type")
        dictionaryImage.setObject("image.png", forKey: "original")
        dictionaryImage.setObject("image.png", forKey: "thumb")
        
        dictionaryParam.setObject(dictionaryName, forKey: "name")
        dictionaryParam.setObject(dictionaryUsername, forKey: "username")
        dictionaryParam.setObject(dictionaryImage, forKey: "image")
        
        webservice.sendPostWithParameter(dictionaryParam)
    }
    
    func addUser() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/AddUser.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.delegate = self
        webservice.identifier = "addUser"
        dictionaryParam.setObject("\(self.textEmail.text!).\(self.textPassword.text!)@yahoo.com", forKey: "email")
        dictionaryParam.setObject("\(self.textEmail.text!).\(self.textPassword.text!)", forKey: "user_code")
        dictionaryParam.setObject(self.textEmail.text!, forKey: "first_name")
        dictionaryParam.setObject(self.textPassword.text!, forKey: "last_name")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
        
    }
    
    func getQuestions() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetQuestions.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.delegate = self
        webservice.identifier = "getQuestions"
        webservice.sendPostWithStringParameter(dictionaryParam)
        
        
    }
    
    func getPreparedQuestions() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetPreparedQuestions.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.delegate = self
        webservice.identifier = "getPreparedQuestions"
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user_code")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
        
    }
    
    // Setup Users
    func setupUsers(contents: NSArray!) {
        
        self.arrayUsers = nil
        self.arrayUsers = NSMutableArray()
        
        for (var count = 0; count < contents.count; count++) {
            
            let dictionaryUser = contents[count] as! NSDictionary
            
            let user = UserModel()
            user.identifier = dictionaryUser["user_code"] as! String
            user.email = dictionaryUser["email"] as! String
            user.firstName = dictionaryUser["first_name"] as! String
            user.lastName = dictionaryUser["last_name"] as! String
            user.emailType = dictionaryUser["type"] as! String
            self.arrayUsers!.addObject(user)
            
        }
    }
    
    // MARK: Delegate
    // MARK: Text Field
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Webservice
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.identifier == "getUser" {
            
            if content["count"] as! NSNumber == 0 {
                self.addUser()
                return
            }
            
            let arrayReturn = content["return"] as! NSArray
            
            self.setupUsers(arrayReturn)
            
            let filterData = NSPredicate(format: "self.identifier == '\(self.textEmail.text!).\(self.textPassword.text!)'")
            let contentFiltered = self.arrayUsers!.filteredArrayUsingPredicate(filterData) as NSArray
            
            if contentFiltered.count == 0 {
                
                self.addUser()
                return
            }
            
            self.getPreparedQuestions()
//        
//          
            self.getQuestions()
            
        }else if webservice.identifier == "getPreparedQuestions"{
            
            if content["count"] as! NSNumber == 0 {
                self.getQuestions()
                return
            }
            self.performSegueWithIdentifier("goToHomeTab", sender: self)
            
        }else if webservice.identifier == "getQuestions"{
            
            let contents = content["return"] as! NSArray
            self.arrayPreparedQuestions = nil
            self.arrayPreparedQuestions = NSMutableArray()
            
            for (var count = 0; count < contents.count; count++) {
                
                let dictionaryQuestions = contents[count] as! NSDictionary
            
                let questionPrepared = QuestionModel()
                
                questionPrepared.identifier = dictionaryQuestions["question_code"] as! String
                questionPrepared.question = dictionaryQuestions["question"] as! String
                let arrayOtions = (dictionaryQuestions["options"] as! String).componentsSeparatedByString("-") as NSArray
                questionPrepared.options.addObjectsFromArray(arrayOtions as [AnyObject])
                
                self.arrayPreparedQuestions!.addObject(questionPrepared)
                
            }
            
            self.performSegueWithIdentifier("goToInitialSetup", sender: self)
        
        }
        
    }

    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToInitialSetup" {
            
            let controller = segue.destinationViewController as! InitialSetupViewController
            controller.currentUser = self.currentUser!
            controller.arrayPreparedQuestions = self.arrayPreparedQuestions!
            controller.arrayUsers = self.arrayUsers!
        }else if segue.identifier! == "goToHomeTab" {
            
            let controller = segue.destinationViewController as! HomeTabBarController
            controller.currentUser = self.currentUser!
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
        
        
        
//        let challenge1 = ChallengeStatusView(frame: CGRectMake(0, 0, self.view.frame.size.width-20, 80))
//        challenge1.setupView()
//        self.scrollActivity.addSubview(challenge1)
//        
//        let challenge2 = ChallengeStatusView(frame: CGRectMake(0, 90, self.view.frame.size.width-20, 80))
//        challenge2.setupView()
//        self.scrollActivity.addSubview(challenge2)
//        
//        let challenge3 = ChallengeStatusView(frame: CGRectMake(0, 180, self.view.frame.size.width-20, 80))
//        challenge3.setupView()
//        self.scrollActivity.addSubview(challenge3)
//        
//        let challenge4 = ChallengeStatusView(frame: CGRectMake(0, 270, self.view.frame.size.width-20, 80))
//        challenge4.setupView()
//        self.scrollActivity.addSubview(challenge4)
        
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
    
    var currentUser: UserModel?
    var questions: QuestionCollectionModel?
    
    var arrayCustom: NSMutableArray?
    var arrayPrepared: NSMutableArray?
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        print(self.questions!.collection)

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
        var yLocation = 0 as CGFloat
        for (var count = 0; count < self.arrayPrepared!.count; count++) {
            
            let questionModel = self.arrayPrepared![count] as! QuestionModel
            
            let question = QuestionView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
            let arraySelectedFilter = self.questions!.collection.filteredArrayUsingPredicate(predicate) as NSArray
            if arraySelectedFilter.count != 0 {
                question.selected = true
            }
            question.setupView()
            question.delegate = self
            self.scrollQuestions.addSubview(question)
            
            let gesture = UITapGestureRecognizer(target: self, action: "tapQuestion:")
            gesture.numberOfTapsRequired = 1
            question.addGestureRecognizer(gesture)
            
            yLocation = yLocation + 40
        }
        self.scrollQuestions.contentSize = CGSizeMake(0, yLocation-10)
        yLocation = 0
        for (var count = 0; count < self.arrayCustom!.count; count++) {
            
            let questionModel = self.arrayCustom![count] as! QuestionModel
            
            let question = QuestionView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
            let arraySelectedFilter = self.questions!.collection.filteredArrayUsingPredicate(predicate) as NSArray
            if arraySelectedFilter.count != 0 {
                question.selected = true
            }
            question.setupView()
            question.delegate = self
            self.scrollCustom.addSubview(question)
            
            let gesture = UITapGestureRecognizer(target: self, action: "tapQuestion:")
            gesture.numberOfTapsRequired = 1
            question.addGestureRecognizer(gesture)
            
            yLocation = yLocation + 40
        }
        self.scrollCustom.contentSize = CGSizeMake(0, yLocation-10)
    }
    
    // Get Prepared
    func getPrepared() {
    
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetPreparedQuestions.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getPrepared"
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user_code")
        webservice.delegate = self
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    // Get Prepared
    func getCustom() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetCustomQuestions.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getCustom"
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user_code")
        webservice.delegate = self
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    // MARK: Delegate
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.identifier == "getPrepared" {
            
            self.arrayPrepared = nil
            self.arrayPrepared = NSMutableArray()
        
            if content["count"] as! NSNumber != 0 {
                
                let arrayContent = content["return"] as! NSArray
                
                for object in arrayContent {
                    
                    let dictionaryContent = object as! NSDictionary
                    let preparedQuestion = QuestionModel()
                    
                    preparedQuestion.identifier = dictionaryContent["question_code"] as! String
                    preparedQuestion.question = dictionaryContent["question"] as! String
                    preparedQuestion.answer = dictionaryContent["answer"] as! String
                    preparedQuestion.type = "prepared"
                    
                    let arrayOptions = (dictionaryContent["options"] as! String).componentsSeparatedByString("-") as NSArray
                    preparedQuestion.options.addObjectsFromArray(arrayOptions as [AnyObject])
                    self.arrayPrepared?.addObject(preparedQuestion)
                    
                }
            }
            self.getCustom()
            
        }else if webservice.identifier == "getCustom" {
            
            self.arrayCustom = nil
            self.arrayCustom = NSMutableArray()
            
            if content["count"] as! NSNumber != 0 {
                
                let arrayContent = content["return"] as! NSArray
                
                for object in arrayContent {
                    
                    let dictionaryContent = object as! NSDictionary
                    let preparedQuestion = QuestionModel()
                    
                    preparedQuestion.identifier = dictionaryContent["question_code"] as! String
                    preparedQuestion.question = dictionaryContent["question"] as! String
                    preparedQuestion.answer = dictionaryContent["answer"] as! String
                    preparedQuestion.type = "custom"
                    let arrayOptions = (dictionaryContent["options"] as! String).componentsSeparatedByString("-") as NSArray
                    preparedQuestion.options.addObjectsFromArray(arrayOptions as [AnyObject])
                    self.arrayCustom?.addObject(preparedQuestion)
                    
                }
            }
            
            self.setupView()
        }
    }
    
    // QuestionView Delegate
    func questionSelected(question: QuestionModel) {
        
        self.questions!.collection.addObject(question)
        print(self.questions!.collection)
    }
    
    func questionDeselected(question: QuestionModel) {
        
        self.questions!.collection.removeObject(question)
        
        print(self.questions!.collection)
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
        arrayData.addObjectsFromArray(self.questions!.collection as [AnyObject])
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
    var currentUser: UserModel?
    var arrayFriends: NSMutableArray?
    
    
    @IBOutlet weak var buttonConfirm: UIButton!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.viewHolder.layer.cornerRadius = 5
        
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
        self.getUsers()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: Method 
    func setupViews() {
        
        for views in self.scrollFriends.subviews {
            views.removeFromSuperview()
        }
        
        print("ETO!!!!")
        print(self.arraySelectedFriends!)
        
        var yLocation = 0 as CGFloat
        
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
    
    func getUsers() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetUsers.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getUser"
        webservice.delegate = self
        webservice.sendPostWithStringParameter(dictionaryParam)
    }
    
    // Webservice for login
    func getConnections() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetConnections.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getConnections"
        webservice.delegate = self
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user")
        dictionaryParam.setObject("friends", forKey: "type")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }

    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func confirmButtonClicked(sender: UIButton) {
        print(self.arraySelectedFriends!)
        let arrayToSend = NSMutableArray()
        arrayToSend.addObjectsFromArray(self.arraySelectedFriends! as [AnyObject])
        self.delegate?.friendSelected(arrayToSend)
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    // MARK: Delegate
    // MARK: Webservice
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.identifier == "getUser" {
            
            if content["count"] as! NSNumber == 0 {
               
                return
            }
            
            let arrayReturn = content["return"] as! NSArray
            self.arrayFriends = nil
            self.arrayFriends = NSMutableArray()
            self.arrayFriends?.addObjectsFromArray(arrayReturn as [AnyObject])

            let filterData = NSPredicate(format: "!(self.user_code == '\(self.currentUser!.identifier)')")
            self.arrayFriends!.filterUsingPredicate(filterData)
            
            if self.arrayFriends!.count == 0 {
                return
            }
            
            self.getConnections()

        }else if webservice.identifier == "getConnections" {
            
            if content["count"] as! NSNumber == 0 {
                
                return
            }
            
            let arrayReturn = content["return"] as! NSArray
            var predicate = ""
            
            for (var count = 0; count < arrayReturn.count; count++) {
                
                let dictionaryContent = arrayReturn[count] as! NSDictionary
                let userCode = dictionaryContent["friend"] as! String
                
                predicate = predicate.stringByAppendingFormat("self.user_code == '\(userCode)'")
                if count != arrayReturn.count - 1 {
                    predicate = predicate.stringByAppendingFormat(" || ")
                }
                
            }
            
            print(predicate)
            let arrayFiltered = self.arrayFriends!.filteredArrayUsingPredicate(NSPredicate(format: predicate)) as NSArray
            print(arrayFiltered)
            
            self.arrayFriends?.removeAllObjects()
            
            for objectContent in arrayFiltered {
                
                let dictionaryContent = objectContent as! NSDictionary
                
                let userModel = UserModel()
                userModel.identifier = dictionaryContent["user_code"] as! String
                userModel.firstName = dictionaryContent["first_name"] as! String
                userModel.lastName = dictionaryContent["last_name"] as! String
                userModel.email = dictionaryContent["email"] as! String
                userModel.emailType = dictionaryContent["type"] as! String
                self.arrayFriends?.addObject(userModel)
            }
            
            self.setupViews()
            
        }
        
    }
    
    // MARK: Delegate
    
    func friendListSelected(user: UserModel) {
        
        self.arraySelectedFriends?.addObject(user)
        print(self.arraySelectedFriends!)
    }
    func friendListDeselected(user: UserModel) {
        
        self.arraySelectedFriends!.removeObject(user)
        
        print(self.arraySelectedFriends!)
        
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
    
    var currentUser : UserModel?
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
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "inputeTap")
//        tapGesture.numberOfTapsRequired = 1
//        self.labelInput.addGestureRecognizer(tapGesture)
        
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
    
    // Webservice Add Question
    func addCustom() {
        
        var options = ""
        
        for (var count = 0; count < self.question.options.count; count++) {
            
            let stringOption = self.question.options[count] as! String
            options = options.stringByAppendingFormat("\(stringOption)")
            
            if count != self.question.options.count - 1 {
                options = options.stringByAppendingFormat("-")
            }
            
        }
        
        print(options)
        print(self.question.options)
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/AddCustomQuestions.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "addCustom"
        webservice.delegate = self
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user_code")
        dictionaryParam.setObject(self.question!.question, forKey: "question")
        dictionaryParam.setObject(self.question!.answer, forKey: "answer")
        dictionaryParam.setObject(options, forKey: "options")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    func addQuestion() {

        let dictionaryParam = NSMutableDictionary()
        
        let dictionaryQuestion = NSMutableDictionary()
    
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "uid")
        dictionaryQuestion.setObject(self.question!.question, forKey: "question")
        dictionaryQuestion.setObject(self.question!.answer, forKey: "answer")
        dictionaryQuestion.setObject(self.question!.options, forKey: "options")
        dictionaryParam.setObject(dictionaryQuestion, forKey: "question")
        
        let webservice = WebserviceClass()
        webservice.link = "http://stupideasygames.com/friendapp/api/ios/game-data/questions/custom"
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
    
    
    var arrayUsers: NSMutableArray?
    var currentUser: UserModel?
    var arrayPreparedQuestions: NSMutableArray! = NSMutableArray()
    
    
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
        
        let question = self.arrayPreparedQuestions[self.count] as! QuestionModel
        
        
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
        
        let questionCurrent = self.arrayPreparedQuestions[self.count] as! QuestionModel
        questionCurrent.answer = self.textAnswer.text!
        
        self.arrayPreparedQuestions!.replaceObjectAtIndex(self.count, withObject: questionCurrent)
        
        if self.count != self.arrayPreparedQuestions.count - 1 {
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
        
        
        for objectModel in self.arrayPreparedQuestions! {
            let model = objectModel as! QuestionModel
            let dictionaryQuestion = NSMutableDictionary()
            dictionaryQuestion.setObject(model.identifier, forKey: "qid")
            dictionaryQuestion.setObject(model.answer, forKey: "answer")
            arrayQuestions.addObject(dictionaryQuestion)
            
        }
        
        
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "uid")
        dictionaryParam.setObject(arrayQuestions, forKey: "questions")
        
        let webservice = WebserviceClass()
        webservice.link = "http://stupideasygames.com/friendapp/api/ios/game-data/questions/prepared"
        webservice.identifier = "addNestor"
        webservice.delegate = self
        webservice.sendPatchWithParameter(dictionaryParam)
    }
    
    func animateUserInterface() {
        
        let questionCurrent = self.arrayPreparedQuestions![self.count] as! QuestionModel
        questionCurrent.answer = self.textAnswer.text!
        
        self.arrayPreparedQuestions!.replaceObjectAtIndex(self.count, withObject: questionCurrent)
        self.count++
        let questionNext = self.arrayPreparedQuestions![self.count] as! QuestionModel
        
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
            
            let controller = segue.destinationViewController as! HomeTabBarController
            controller.currentUser = self.currentUser!
        }
    }
}

// MARK: - Tab Bar Controller
class HomeTabBarController : UITabBarController {
    
    var currentUser: UserModel?
    var questionColletion: QuestionCollectionModel?
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.blueColor()
        
        
        for controller in self.viewControllers! {
            
            controller.setValue(self.currentUser!, forKey: "currentUser")
//            if controller.isKindOfClass(QuestionViewController) {
//                controller.setValue(self.questionColletion!, forKey: "questionColletion")
//            }
            
        }
        
        print("View did load")
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
class ChallengeViewController : UIViewController {
    
    // MARK: Prorperties
    @IBOutlet weak var imgQuestion: UIImageView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var questions: QuestionCollectionModel?
    var counter: Int!
    
    

    // MARK: View Life Cycle
    override func viewDidLoad() {
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
        
        let question = self.questions?.collection[self.counter] as! QuestionModel
        self.labelQuestion.text = question.question
        self.button1.setTitle(question.answer, forState: UIControlState.Normal)
        self.button2.setTitle(question.options[0] as? String, forState: UIControlState.Normal)
        self.button3.setTitle(question.options[1] as? String, forState: UIControlState.Normal)
        self.button4.setTitle(question.options[2] as? String, forState: UIControlState.Normal)
    }
    
    // MARK: Method
    func answer(selected: Int) {
        self.counter = self.counter + 1
        
        if self.counter == 5 {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }else {
            UIView.animateWithDuration(0.2, animations: {
                
                self.viewHolder.frame = CGRectMake(-self.viewHolder.frame.size.width, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                
                }, completion: { (finish: Bool) in
                    let question = self.questions?.collection[self.counter] as! QuestionModel
                    self.labelQuestion.text = question.question
                    self.button1.setTitle(question.answer, forState: UIControlState.Normal)
                    self.button2.setTitle(question.options[0] as? String, forState: UIControlState.Normal)
                    self.button3.setTitle(question.options[1] as? String, forState: UIControlState.Normal)
                    self.button4.setTitle(question.options[2] as? String, forState: UIControlState.Normal)
                    self.viewHolder.frame = CGRectMake(self.viewHolder.frame.size.width, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                    UIView.animateWithDuration(0.2, animations: {
                        self.viewHolder.frame = CGRectMake(0, self.viewHolder.frame.origin.y, self.viewHolder.frame.size.width, self.viewHolder.frame.size.height)
                        }, completion: { (finish: Bool) in
                            
                    })
            })
        }
        
        
        
    }
    
    // MARK: Button Actions
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
                                                        
                                                        self.answer(1)
                                                        
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
                                                        
                                                        
                                                        self.answer(2)
                                                        
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
                                                        
                                                        
                                                        self.answer(3)
                                                        
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
                                                        
                                                        
                                                        self.answer(4)
                                                        
                                                })
                                        })
                                        
                                })
                        })
                })
                
        })
    }
    
}