//
//  TabSelectionControllers.swift
//  Friend App
//
//  Created by Paul Galasso on 10/14/15.
//  Copyright © 2015 Mark Angeles. All rights reserved.
//

import Foundation

// MARK: - Invite Controller
class InviteViewController : UIViewController, WebserviceClassDelegate, FriendInviteViewDelegate, PendingInviteViewDelegate{
    
    // MARK: Properties
    
    @IBOutlet weak var scrollFriendList: UIScrollView!
    
    var currentUser: UserModel?
    var arrayUsers: NSMutableArray?
    var arrayPending: NSMutableArray?
    var arrayAvailable: NSMutableArray?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 80, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("< Logout", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.scrollFriendList.pagingEnabled = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getUsers()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    
    // MARK: Method
    // Get Users
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
        dictionaryParam.setObject("invitable", forKey: "type")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    // Webservice for login
    func getPendingInvites() {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/GetConnections.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "getPending"
        webservice.delegate = self
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user")
        dictionaryParam.setObject("pending", forKey: "type")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    func addConnections(friend: String) {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/AddConnections.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "addConnections"
        webservice.delegate = self
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "user")
        dictionaryParam.setObject(friend, forKey: "friend")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    func updateConnections(friend: String) {
        
        let webservice = WebserviceClass()
        webservice.link = "http://friendapp.com/UpdateConnections.php"
        let dictionaryParam = NSMutableDictionary()
        webservice.identifier = "addConnections"
        webservice.delegate = self
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "friend")
        dictionaryParam.setObject(friend, forKey: "user")
        webservice.sendPostWithStringParameter(dictionaryParam)
        
    }
    
    func setupViews() {
        
        for views in self.scrollFriendList.subviews {
            views.removeFromSuperview()
        }
        
        
        var yLocation = 0 as CGFloat
        for (var count = 0; count < self.arrayPending!.count; count++) {
            
            let dictionary = self.arrayPending![count] as! NSDictionary
            let user = UserModel()
            user.email = dictionary["email"] as! String
            user.firstName = dictionary["first_name"] as! String
            user.lastName = dictionary["last_name"] as! String
            user.identifier = dictionary["user_code"] as! String
            user.emailType = dictionary["email"] as! String
            
            let friend = PendingInviteView(frame: CGRectMake(0, yLocation, self.view.frame.size.width-20, 70))
            friend.user = user
            friend.delegate = self
            friend.setupView()
            friend.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
            friend.layer.borderColor = UIColor.whiteColor().CGColor
            friend.layer.borderWidth = 2
            friend.layer.cornerRadius = 10
            
            self.scrollFriendList.addSubview(friend)
            
            yLocation = yLocation + 73
        }
        
        for (var count = 0; count < self.arrayAvailable!.count; count++) {
            
            let dictionary = self.arrayAvailable![count] as! NSDictionary
            let user = UserModel()
            user.email = dictionary["email"] as! String
            user.firstName = dictionary["first_name"] as! String
            user.lastName = dictionary["last_name"] as! String
            user.identifier = dictionary["user_code"] as! String
            user.emailType = dictionary["email"] as! String
            
            let friend = FriendInviteView(frame: CGRectMake(0, yLocation, self.view.frame.size.width-20, 70))
            friend.user = user
            friend.delegate = self
            friend.setupView()
            friend.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
            friend.layer.borderColor = UIColor.whiteColor().CGColor
            friend.layer.borderWidth = 2
            friend.layer.cornerRadius = 10
            
            self.scrollFriendList.addSubview(friend)
            
            yLocation = yLocation + 73
        }
        
        self.scrollFriendList.contentSize = CGSizeMake(0, yLocation-3)
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    // MARK: Delegate
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary) {
        
        if webservice.identifier == "getUser" {
            self.arrayUsers = nil
            self.arrayUsers = NSMutableArray()
            
            let arrayContents = content["return"] as! NSArray
            
            self.arrayUsers?.addObjectsFromArray(arrayContents as [AnyObject])
            
            let predicate = NSPredicate(format: "!(self.email == '\(self.currentUser!.email)')")
            self.arrayUsers?.filterUsingPredicate(predicate)
            
            self.getConnections()
            
        }else if webservice.identifier == "getConnections" {
            self.arrayAvailable = nil
            self.arrayAvailable = NSMutableArray()
            
            if content["count"] as! NSNumber == 0 {
                self.arrayAvailable?.addObjectsFromArray(self.arrayUsers! as [AnyObject])
                self.getPendingInvites()
                return
            }
            var stringPredicate = ""
            let arrayContents = content["return"] as! NSArray
            
            for (var count = 0; count < arrayContents.count; count++) {
                
                let dictionaryContent = arrayContents[count] as! NSDictionary
                let emailFriend = dictionaryContent["friend"] as! String
                let userFriend = dictionaryContent["user"] as! String
                
                if emailFriend == self.currentUser!.identifier {
                    stringPredicate = stringPredicate.stringByAppendingFormat("!(self.user_code == '\(userFriend)')")
                }else {
                    stringPredicate = stringPredicate.stringByAppendingFormat("!(self.user_code == '\(emailFriend)')")
                }
                
                
                if count != arrayContents.count - 1 {
                    stringPredicate = stringPredicate.stringByAppendingFormat(" && ")
                }
                
            }
            
            let predicate = NSPredicate(format: stringPredicate)
            
            let arrayTempory = NSMutableArray()
            arrayTempory.addObjectsFromArray(self.arrayUsers!.filteredArrayUsingPredicate(predicate))
            self.arrayAvailable?.addObjectsFromArray(arrayTempory as [AnyObject])
            
            
            self.getPendingInvites()
            
            
        }else if webservice.identifier == "addConnections" {
            
            
            if content["status"] as! String == "Success" {
                
                self.getConnections()
                
            }
            
        }else if webservice.identifier == "getPending" {
            
            self.arrayPending = nil
            self.arrayPending = NSMutableArray()
            if content["count"] as! NSNumber != 0 {
                
                var stringPredicate = ""
                let arrayContents = content["return"] as! NSArray
                
                for (var count = 0; count < arrayContents.count; count++) {
                    
                    let dictionaryContent = arrayContents[count] as! NSDictionary
                    let emailFriend = dictionaryContent["user"] as! String
                    stringPredicate = stringPredicate.stringByAppendingFormat("self.user_code == '\(emailFriend)'")
                    
                    if count != arrayContents.count - 1 {
                        stringPredicate = stringPredicate.stringByAppendingFormat(" || ")
                    }
                    
                }
                
                let predicate = NSPredicate(format: stringPredicate)
                
                let arrayTempory = NSMutableArray()
                arrayTempory.addObjectsFromArray(self.arrayUsers!.filteredArrayUsingPredicate(predicate))
                self.arrayPending?.addObjectsFromArray(arrayTempory as [AnyObject])
                
            }
            self.setupViews()
        }else if webservice.identifier == "addConnections" {
            
            self.getConnections()
            
        }
    }
    
    // Invite Friend
    func inviteFriend(friend: UserModel) {
        
        self.addConnections(friend.identifier)
        
    }
    
    // Pending Invite
    func pendingFriendDecline(friend: UserModel) {
        
        
    }
    func pendingFriendAccept(friend: UserModel) {
        
        self.updateConnections(friend.identifier)
        
    }
}


// MARK: - Question View Controller
class QuestionViewController : UIViewController, WebserviceClassDelegate {
    
    // MARK: Properties
    @IBOutlet weak var buttonPrepared: UIButton!
    @IBOutlet weak var buttonCustom: UIButton!
    @IBOutlet weak var viewHolder: UIView!
    
    var arrayCustom: NSMutableArray?
    var arrayPrepared: NSMutableArray?
    
    var scrollQuestions: UIScrollView!
    var scrollCustom: UIScrollView!
    
    @IBOutlet weak var buttonAdd: UIButton!
    
    var currentUser: UserModel?
    var questionColletion: QuestionCollectionModel?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 80, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("< Logout", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.scrollCustom = UIScrollView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, self.view.frame.size.height-200))
        //        self.scrollCustom.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.scrollCustom.layer.cornerRadius = 5
        self.viewHolder.addSubview(self.scrollCustom)
        
        self.scrollQuestions = UIScrollView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, self.view.frame.size.height-200))
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
        
        self.buttonAdd.layer.borderWidth = 2
        self.buttonAdd.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonAdd.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.buttonAdd.layer.cornerRadius = 5
        
        self.scrollQuestions.pagingEnabled = true
        self.scrollCustom.pagingEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        
//        self.getPrepared()
        let dictionaryParam = NSMutableDictionary()
        
        
        dictionaryParam.setObject(self.currentUser!.identifier, forKey: "id")
        
        let webservice = WebserviceClass()
        webservice.link = "http://stupideasygames.com/friendapp/api/ios/users/"
        webservice.identifier = "getData"
        webservice.delegate = self
        webservice.getMethod(dictionaryParam)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Method
    func tapQuestion(sender : UITapGestureRecognizer) {
        
        let question = sender.view as! QuestionListView
        self.performSegueWithIdentifier("goToQuestionViewer", sender: question.question!)
        
    }
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func addButtonClicked(sender: UIButton) {
        
        self.performSegueWithIdentifier("goToAdd", sender: self)
        
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
    
    // MARK: Method
    // Setup view
    func setupView() {
        
        for views in self.scrollQuestions.subviews {
            views.removeFromSuperview()
        }
        for views in self.scrollCustom.subviews {
            views.removeFromSuperview()
        }
        self.arrayPrepared = nil
        self.arrayCustom = nil
        
        self.arrayPrepared = NSMutableArray()
        self.arrayCustom = NSMutableArray()
        
        let predicateCustom = NSPredicate(format: "self.type == 'custom'")
        let predicatePrepared = NSPredicate(format: "self.type == 'prepared'")
        
        self.arrayCustom!.addObjectsFromArray(self.questionColletion!.collection.filteredArrayUsingPredicate(predicateCustom) as NSArray as [AnyObject])
        self.arrayPrepared!.addObjectsFromArray(self.questionColletion!.collection.filteredArrayUsingPredicate(predicatePrepared) as NSArray as [AnyObject])
    
        var yLocation = 0 as CGFloat
        for (var count = 0; count < self.arrayPrepared!.count; count++) {
            
            let questionModel = self.arrayPrepared![count] as! QuestionModel
            print("question == \(questionModel.question)")
            
            let question = QuestionListView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            question.setupView()
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
            
            let question = QuestionListView(frame: CGRectMake(5, yLocation, self.scrollQuestions.frame.size.width-10, 30))
            question.question = questionModel
            question.setupView()
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
        
        
        self.arrayPrepared = nil
        self.arrayPrepared = NSMutableArray()
        
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
        
        
        self.arrayCustom = nil
        self.arrayCustom = NSMutableArray()
        
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
        
        if webservice.statusCode > 203 {
            // Alert (Something went wrong on the Rest API)
            return
        }
            
            
            
        if webservice.identifier == "getData" {
            
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
                question.options.addObjectsFromArray(dictionaryContent["options"] as! NSArray as [AnyObject])
                question.identifier = dictionaryContent["_id"] as! String
                arrayPrepared.addObject(question)
                
            }
            
            for model in arrayPrepared {
                
                let questionModel = model as! QuestionModel
                let predicate = NSPredicate(format: "self.identifier == '\(questionModel.identifier)'")
                let arrayFilter = self.questionColletion!.collection.filteredArrayUsingPredicate(predicate) as NSArray
                if arrayFilter.count != 0 {
                    let updateModel = arrayFilter[0] as! QuestionModel
                    let index = self.questionColletion!.collection.indexOfObject(updateModel)
                    let oldModel = self.questionColletion!.collection[index] as! QuestionModel
                    oldModel.question = questionModel.question
                    oldModel.options.addObjectsFromArray(questionModel.options as [AnyObject])
                    self.questionColletion!.collection.replaceObjectAtIndex(index, withObject: oldModel)
                }
                
            }
            
            self.setupView()
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToQuestionViewer" {
            let controller = segue.destinationViewController as! QuestionViewerController
            controller.question = sender as? QuestionModel
        }else if segue.identifier == "goToAdd" {
            let controller = segue.destinationViewController as! AddCustomViewController
            controller.currentUser = self.currentUser!
        }
        
    }
    
    
}

// MARK: - Challenge Setup
class ChallengeSetupViewController : UIViewController, QuestionSelectionViewControllerDelegate, FriendSelectionViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var checkBoxQuestion: UIImageView!
    @IBOutlet weak var checkBoxFriends: UIImageView!
    @IBOutlet weak var buttonQuestion: UIButton!
    @IBOutlet weak var buttonFriends: UIButton!
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var imageViewHolder: UIImageView!
    
    var currentUser: UserModel?
    var questions: QuestionCollectionModel?
    var friendsCollection: NSMutableArray?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.friendsCollection = NSMutableArray()
        self.questions = QuestionCollectionModel()
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("< ", forState: UIControlState.Normal)
        self.view.addSubview(buttonBack)
        
        self.buttonSend.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonSend.layer.borderWidth = 2
        self.buttonSend.layer.cornerRadius = 5
        self.buttonSend.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        
        self.buttonFriends.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonFriends.layer.borderWidth = 2
        self.buttonFriends.layer.cornerRadius = 5
        self.buttonFriends.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.buttonQuestion.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonQuestion.layer.borderWidth = 2
        self.buttonQuestion.layer.cornerRadius = 5
        self.buttonQuestion.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        
        self.imageViewHolder.layer.cornerRadius = 10
        self.imageViewHolder.layer.borderWidth = 2
        self.imageViewHolder.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageViewHolder.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        //        var width = self.view.frame.width - 40 as CGFloat
        
        //        let labelName = UILabel(frame: CGRectMake(20, 80, 100, 30))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: Method
    
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    @IBAction func questionButtonClicked(sender: UIButton) {
        
//        self.performSegueWithIdentifier("goToQuestionSelection", sender: self)
        sender.selected = !sender.selected
        if sender.selected {
            self.checkBoxQuestion.image = UIImage(named: "check-box")
        }else {
            self.checkBoxQuestion.image = UIImage(named: "box")
        }
        
        
    }
    @IBAction func friendButtonClicked(sender: UIButton) {
        
//        self.performSegueWithIdentifier("goToFriend", sender: self)
        sender.selected = !sender.selected
        if sender.selected {
            self.checkBoxFriends.image = UIImage(named: "check-box")
        }else {
            self.checkBoxFriends.image = UIImage(named: "box")
        }
        
    }
    
    @IBAction func sendButtonClicked(sender: UIButton) {
        
    }
    
    // MARK: Delegate
    func questionSelected(selected: NSMutableArray) {
        
        self.questions!.collection.removeAllObjects()
        self.questions!.collection.addObjectsFromArray(selected as [AnyObject])
        
    }
    
    func friendSelected(friends: NSMutableArray) {
        
        self.friendsCollection!.removeAllObjects()
        self.friendsCollection!.addObjectsFromArray(friends as [AnyObject])
        
    }
    
    // Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToQuestionSelection"{
            let controller = segue.destinationViewController as! QuestionSelectionViewController
            controller.delegate = self
            controller.currentUser = self.currentUser!
            controller.questions = self.questions!
            
            
        }else if segue.identifier! == "goToFriend"{
            
            let controller = segue.destinationViewController as! FriendSelectionViewController
            controller.delegate = self
            controller.currentUser = self.currentUser!
            controller.arraySelectedFriends = self.friendsCollection!
            
        }
    }
    
}

// MARK: - Activity Controller
class ActivityViewController : UIViewController, ChallengeStatusViewDelegate, NotificationViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var scrollActivity: UIScrollView!
    
    @IBOutlet weak var buttonNotification: UIButton!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelName: UILabel!
    
    var notifView: NotificationView?
    
    var currentUser: UserModel?
    
    // MARK: View Life cycle
    override func viewDidLoad() {
        
        var pointY = 0 as CGFloat
        
        for (var count = 0; count < 12; count++) {
            
            let challenge = ChallengeStatusView(frame: CGRectMake(0, pointY, self.view.frame.size.width-20, 80))
            challenge.setupView()
            challenge.delegate = self
            self.scrollActivity.addSubview(challenge)
            
            pointY = pointY + 90
            
        }
        
        self.scrollActivity.pagingEnabled = true
        self.scrollActivity.contentSize = CGSizeMake(self.view.frame.size.width-20, pointY)
        
        self.viewProfile.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewProfile.layer.borderWidth = 2.0
        self.viewProfile.layer.cornerRadius = 10
        self.viewProfile.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        self.buttonNotification.layer.cornerRadius = 15
        
        
        self.imgProfile.image = UIImage(named: "3")
        
        self.labelEmail.text = "flexpoint.markangeles@gmail.com"
        self.labelName.text = "Mark Angeles"
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Button Actions
    @IBAction func notifButtonClicked(sender: UIButton) {
        
        self.menuNotification()
        
    }
    
    func menuNotification() {
        
        let arrayNames = ["Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso", "Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso","Mark Angeles", "Nestor Alveyra", "Vince Espanola", "Kenneth Froyalde", "Paul Gallaso"] as NSArray
        
        let arrayNotif = NSMutableArray()
        for (var count = 0; count < arrayNames.count; count++) {
            
            let questionCollection = QuestionCollectionModel()
            questionCollection.identifier = arrayNames[count] as! String
            
            let question = QuestionModel()
            question.question = "What is my favorite drink?"
            question.answer = "Coke"
            question.options.addObjectsFromArray(["Sprite", "Royal", "Pepsi"])
            questionCollection.collection.addObject(question)
            
            let question1 = QuestionModel()
            question1.question = "What is my favorite anime?"
            question1.answer = "Slam Dunk"
            question1.options.addObjectsFromArray(["Ghost Fighter", "Dragon Ball Z", "Flame of Reca"])
            questionCollection.collection.addObject(question1)
            
            let question2 = QuestionModel()
            question2.question = "Who is my favorite anime character?"
            question2.answer = "Fujima"
            question2.options.addObjectsFromArray(["Sakuragi", "Rukawa", "Miyata"])
            questionCollection.collection.addObject(question2)
            
            let question3 = QuestionModel()
            question3.question = "What is my dog's name?"
            question3.answer = "Loktu"
            question3.options.addObjectsFromArray(["Blacky", "Max", "Scooby"])
            questionCollection.collection.addObject(question3)
            
            let question4 = QuestionModel()
            question4.question = "What is my jersey number?"
            question4.answer = "13"
            question4.options.addObjectsFromArray(["10", "1", "23"])
            questionCollection.collection.addObject(question4)
            
            arrayNotif.addObject(questionCollection)
            
            
        }
        
        self.notifView = nil
        self.notifView = NotificationView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50))
        self.notifView?.arrayNotification.addObjectsFromArray(arrayNotif as [AnyObject])
        self.notifView?.setupView()
        self.notifView?.delegate = self
        self.view.addSubview(self.notifView!)
        
    }
    
    // MARK: Delegate
    func challengeView(challenge: ChallengeStatusView) {
        
        self.performSegueWithIdentifier("goToQAPreview", sender: self)
    }
    
    func notificationSelected(selected: QuestionCollectionModel) {
        
        self.notifView?.removeFromSuperview()
        self.performSegueWithIdentifier("goToChallenge", sender: selected)
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "goToQAPreview" {
            
            let preview1 = QuestionPreviewModel()
            let preview2 = QuestionPreviewModel()
            let preview3 = QuestionPreviewModel()
            let preview4 = QuestionPreviewModel()
            let preview5 = QuestionPreviewModel()
            
            let challenge = ChallengeResultModel()
            
            preview1.question = "What is my favorite drink?"
            preview1.answer = "Coke"
            preview1.result = "Correct"
            challenge.result.addObject(preview1)
            
            preview2.question = "What is my favorite anime?"
            preview2.answer = "Slam Dunk"
            preview2.result = "Correct"
            challenge.result.addObject(preview2)
            
            preview3.question = "Who is my favorite anime character?"
            preview3.answer = "Sakuragi"
            preview3.result = "Wrong"
            challenge.result.addObject(preview3)
            
            preview4.question = "What is my dog's name?"
            preview4.answer = "Blacky"
            preview4.result = "Wrong"
            challenge.result.addObject(preview4)
            
            preview5.question = "What is my jersey number?"
            preview5.answer = "13"
            preview5.result = "Correct"
            challenge.result.addObject(preview5)
            
            
            let controller = segue.destinationViewController as! QuestionAnswerPreviewViewController
            controller.challengePreviewModel = challenge
            
        }else if segue.identifier == "goToChallenge" {
            
            let controller = segue.destinationViewController as! ChallengeViewController
            controller.questions = sender as? QuestionCollectionModel
        }
    }
}

// MARK: - Ladder board
class LadderBoardViewController : UIViewController {
    
    // MARK: Properties
    var currentUser: UserModel?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        let viewHolder = UIView(frame: CGRectMake(10, 80, self.view.frame.size.width-20, self.view.frame.size.height-140))
        viewHolder.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        viewHolder.layer.borderWidth = 2
        viewHolder.layer.borderColor = UIColor.whiteColor().CGColor
        viewHolder.layer.cornerRadius = 10
        self.view.addSubview(viewHolder)
        
        let buttonBack = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 0, 60, 40)
        buttonBack.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.setTitle("<        ", forState: UIControlState.Normal)
        //        self.view.addSubview(buttonBack)
        
        let labelName = UILabel(frame: CGRectMake(70, 90, 100, 40))
        labelName.text = "Name"
        labelName.textColor = UIColor.whiteColor()
        self.view.addSubview(labelName)
        
        let labelTotal = UILabel(frame: CGRectMake(self.view.frame.size.width - 120, 90, 50, 40))
        labelTotal.textColor = UIColor.whiteColor()
        labelTotal.text = "Total"
        labelTotal.adjustsFontSizeToFitWidth = true
        self.view.addSubview(labelTotal)
        
        let labelCorrect = UILabel(frame: CGRectMake(CGRectGetMaxX(labelTotal.frame), 90,50, 40))
        labelCorrect.text = "Correct"
        labelCorrect.textColor = UIColor.whiteColor()
        labelCorrect.adjustsFontSizeToFitWidth = true
        self.view.addSubview(labelCorrect)
        
        let imageView = UIImageView(frame: CGRectMake(0, 50, viewHolder.frame.size.width, 2))
        imageView.backgroundColor = UIColor.whiteColor()
        viewHolder.addSubview(imageView)
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 55, viewHolder.frame.width, viewHolder.frame.size.height-60))
        scrollView.pagingEnabled = true
        viewHolder.addSubview(scrollView)
        
        var yPoint = 0.0 as CGFloat
        
        for (var count = 0; count < 13; count++) {
            
            let ladder = LadderBoardView(frame: CGRectMake(10, yPoint, self.view.frame.size.width-20, 60))
            //            ladder.layer.borderColor = UIColor.whiteColor().CGColor
            //            ladder.layer.borderWidth = 1
            ladder.setupView()
            scrollView.addSubview(ladder)
            
            yPoint = yPoint + 63
            
        }
        scrollView.contentSize = CGSizeMake(0, yPoint)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    
    
    // MARK: Method
    
    
    
    // MARK: Button Actions
    func backButtonClicked (sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
    }
}
