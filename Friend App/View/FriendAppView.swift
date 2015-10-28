//
//  FriendAppView.swift
//  Friend App
//
//  Created by Paul Galasso on 8/26/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Home Menu View
protocol HomeMenuViewDelegate {
    
    func menuChallenge()
    func menuInvite()
    func menuQuestions()
    func menuLadderBoard()
    func menuNotification()
    
}
class HomeMenuView: UIView {
    
    // MARK: Properties
    var delegate: HomeMenuViewDelegate?
    var buttonNotification: UIButton!
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.layer.shadowColor = UIColor.blackColor().CGColor
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSizeMake(5, 5)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {

        
        let imageBackground = UIImageView(frame: CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height))
        imageBackground.layer.cornerRadius = 2.0
        imageBackground.alpha = 0.4
        imageBackground.layer.borderWidth = 3
        imageBackground.layer.cornerRadius = 5
        imageBackground.layer.borderColor = UIColor.whiteColor().CGColor
        imageBackground.backgroundColor = UIColor.blackColor()
        self.addSubview(imageBackground)
        
//        self.backgroundColor = UIColor(red: 77/255, green: 165/255, blue: 255/255, alpha: 1)
        
        
        var width = self.frame.size.width - 40 as CGFloat
        width = width / 3
        
        let imageProfile = UIImageView(frame: CGRectMake(10, 10, width, width))
        imageProfile.image = UIImage(named: "3")
        imageProfile.alpha = 0.9
//        imageProfile.layer.shadowColor = UIColor.blackColor().CGColor
//        imageProfile.layer.shadowOpacity = 1
//        imageProfile.layer.shadowOffset = CGSizeMake(3, 3)
        self.addSubview(imageProfile)
        
        self.buttonNotification = UIButton(type: UIButtonType.Custom)
        self.buttonNotification.backgroundColor = UIColor.redColor()
        self.buttonNotification.layer.cornerRadius = 15
        self.buttonNotification.addTarget(self, action: "notificationButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonNotification.frame = CGRectMake(CGRectGetMaxX(imageProfile.frame)-15, CGRectGetMinY(imageProfile.frame)-15, 30, 30)
        self.buttonNotification.setTitle("20", forState: UIControlState.Normal)
        self.buttonNotification.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.addSubview(self.buttonNotification)
        
        let labelName = UILabel(frame: CGRectMake(10, CGRectGetMaxY(imageProfile.frame)+2, width, 17))
        labelName.textAlignment = NSTextAlignment.Center
        labelName.text = "Mark"
        labelName.font = UIFont.systemFontOfSize(14)
        labelName.adjustsFontSizeToFitWidth = true
//        labelName.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelName.textColor = UIColor.whiteColor()
//        labelName.layer.shadowColor = UIColor.blackColor().CGColor
//        labelName.layer.shadowOpacity = 0.2
//        labelName.layer.shadowOffset = CGSizeMake(1, 1)
        
        self.addSubview(labelName)
        
        let buttonChallenge = UIButton(type: UIButtonType.Custom)
        buttonChallenge.frame = CGRectMake(CGRectGetMaxX(imageProfile.frame)+10, (self.frame.size.height/2)-(75/2), width, 30)
//        buttonChallenge.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        buttonChallenge.layer.borderWidth = 1
        buttonChallenge.layer.borderColor = UIColor.lightGrayColor().CGColor
        buttonChallenge.setTitle("Challenge", forState: UIControlState.Normal)
//        buttonChallenge.setTitleColor(UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1), forState: UIControlState.Normal)
        buttonChallenge.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        buttonChallenge.layer.shadowColor = UIColor.blackColor().CGColor
//        buttonChallenge.layer.shadowOpacity = 1
//        buttonChallenge.layer.cornerRadius = 5.0
        buttonChallenge.addTarget(self, action: "challengeButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
//        buttonChallenge.layer.shadowOffset = CGSizeMake(3, 3)
        self.addSubview(buttonChallenge)
        
        let buttonInvite = UIButton(type: UIButtonType.Custom)
        buttonInvite.frame = CGRectMake(CGRectGetMaxX(buttonChallenge.frame)+10, CGRectGetMinY(buttonChallenge.frame), width, 30)
//        buttonInvite.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
//        buttonInvite.setTitleColor(UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1), forState: UIControlState.Normal)
        buttonInvite.layer.borderWidth = 1
        buttonInvite.layer.borderColor = UIColor.lightGrayColor().CGColor
        buttonInvite.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonInvite.setTitle("Invite", forState: UIControlState.Normal)
//        buttonInvite.layer.shadowColor = UIColor.blackColor().CGColor
//        buttonInvite.layer.shadowOpacity = 1
//        buttonInvite.layer.cornerRadius = 5.0
        buttonInvite.addTarget(self, action: "inviteButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
//        buttonInvite.layer.shadowOffset = CGSizeMake(3, 3)
        self.addSubview(buttonInvite)
        
        let buttonQuestion = UIButton(type: UIButtonType.Custom)
        buttonQuestion.frame = CGRectMake(CGRectGetMaxX(imageProfile.frame)+10, CGRectGetMaxY(buttonChallenge.frame)+15, width, 30)
//        buttonQuestion.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
//        buttonQuestion.setTitleColor(UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1), forState: UIControlState.Normal)
        buttonQuestion.layer.borderWidth = 1
        buttonQuestion.layer.borderColor = UIColor.lightGrayColor().CGColor
        buttonQuestion.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonQuestion.setTitle("Questions", forState: UIControlState.Normal)
        buttonQuestion.addTarget(self, action: "questionButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
//        buttonQuestion.layer.shadowColor = UIColor.blackColor().CGColor
//        buttonQuestion.layer.shadowOpacity = 1
//        buttonQuestion.layer.cornerRadius = 5.0
//        buttonQuestion.layer.shadowOffset = CGSizeMake(3, 3)
        self.addSubview(buttonQuestion)
        
        let buttonLadder = UIButton(type: UIButtonType.Custom)
        buttonLadder.frame = CGRectMake(CGRectGetMaxX(buttonChallenge.frame)+10, CGRectGetMaxY(buttonChallenge.frame)+15, width, 30)
//        buttonLadder.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
//        buttonLadder.setTitleColor(UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1), forState: UIControlState.Normal)
        buttonLadder.layer.borderWidth = 1
        buttonLadder.layer.borderColor = UIColor.lightGrayColor().CGColor
//        buttonLadder.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        buttonLadder.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonLadder.setTitle("Ladder", forState: UIControlState.Normal)
//        buttonLadder.layer.shadowColor = UIColor.blackColor().CGColor
//        buttonLadder.layer.shadowOpacity = 1
//        buttonLadder.layer.cornerRadius = 5.0
        buttonLadder.addTarget(self, action: "ladderButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
//        buttonLadder.layer.shadowOffset = CGSizeMake(3, 3)
        self.addSubview(buttonLadder)
        
        
    }
    
    // MARK: Button Actions
    func challengeButtonClicked() {
        
        self.delegate?.menuChallenge()
        
    }
    
    func inviteButtonClicked() {
        
        self.delegate?.menuInvite()
        
    }
    
    func ladderButtonClicked() {
        
        self.delegate?.menuLadderBoard()
        
    }
    
    func questionButtonClicked() {
        
        self.delegate?.menuQuestions()
        
    }
    
    func notificationButtonClicked() {
        self.delegate?.menuNotification()
    }
    
    
}

// MARK: - Challenge Status view

protocol ChallengeStatusViewDelegate {
    
    func challengeView(challenge: ChallengeStatusView)
    
}
class ChallengeStatusView : UIView {
    
    // MARK: Properties
    var delegate: ChallengeStatusViewDelegate?
    var user: UserModel?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
//        self.backgroundColor = UIColor(red: 77/255, green: 165/255, blue: 255/255, alpha: 1)
//        self.backgroundColor = UIColor(red: 245/255, green: 216/255, blue: 109/255, alpha: 1)
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2
        self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
//        let imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
//        imageBackground.backgroundColor = UIColor.blackColor()
//        imageBackground.alpha = 0.4
////        imageBackground.backgroundColor = UIColor(red: 77/255, green: 165/255, blue: 255/255, alpha: 1)
//        imageBackground.layer.borderColor = UIColor.whiteColor().CGColor
//        imageBackground.layer.borderWidth = 2
//        imageBackground.layer.cornerRadius = 5
//        imageBackground.tag = 13
//        self.addSubview(imageBackground)
        print(self.user!.imageLink)
        
//        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.user!.imageLink)!)!)
        let imageProfile = UIImageView(frame: CGRectMake(10, 10, 50, 50))
        imageProfile.image = UIImage(named: "3")
//        imageProfile.image = image
        imageProfile.alpha = 0.9
        self.addSubview(imageProfile)
        
        let labelName = UILabel(frame: CGRectMake(10, CGRectGetMaxY(imageProfile.frame), 150, 17))
        labelName.text = self.user!.firstName
        labelName.font = UIFont.systemFontOfSize(14)
        labelName.adjustsFontSizeToFitWidth = true
        labelName.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelName.textColor = UIColor.whiteColor()
        labelName.textAlignment = NSTextAlignment.Left
        self.addSubview(labelName)
        
        let labelStatus = UILabel(frame: CGRectMake(self.frame.size.width-80, 0, 80, self.frame.size.height))
        labelStatus.text = "Waiting"
        labelStatus.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelStatus.textColor = UIColor.whiteColor()
        labelStatus.textAlignment = NSTextAlignment.Center
        self.addSubview(labelStatus)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print("Tap!!!")
        self.delegate?.challengeView(self)
        
    }
    
}


// MARK: - Question View
protocol QuestionViewDelegate {
    
    func questionSelected(question : QuestionModel)
    func questionDeselected(question : QuestionModel)
    
}

class QuestionView : UIView {
    
    // MARK: Properties
    var selected : Bool!
    var question: QuestionModel?
    var delegate: QuestionViewDelegate?
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selected = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
        let buttonCheckBox = UIButton(type: UIButtonType.Custom)
        buttonCheckBox.frame = CGRectMake(5, 0, 30, 30)
        buttonCheckBox.setImage(UIImage(named: "box"), forState: UIControlState.Normal)
        buttonCheckBox.addTarget(self, action: "checkBoxClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        if self.selected == true {
            buttonCheckBox.setImage(UIImage(named: "check-box"), forState: UIControlState.Normal)
        }
        self.addSubview(buttonCheckBox)
        
        let labelQuestion = UILabel(frame: CGRectMake(45, 0, self.frame.size.width - 60, 30))
//        self.labelQuestion.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
//        self.labelQuestion.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelQuestion.textColor = UIColor.whiteColor()
        labelQuestion.layer.borderColor = UIColor.whiteColor().CGColor
        labelQuestion.layer.borderWidth = 2
        labelQuestion.layer.cornerRadius = 5
        labelQuestion.textAlignment = NSTextAlignment.Center
        labelQuestion.adjustsFontSizeToFitWidth = true
        labelQuestion.text = self.question!.question
        self.addSubview(labelQuestion)
        
    }
    
    func checkBoxClicked(sender: UIButton) {
        
        self.selected = !self.selected
        sender.setImage(UIImage(named: "box"), forState: UIControlState.Normal)
        if self.selected == true {
            sender.setImage(UIImage(named: "check-box"), forState: UIControlState.Normal)
            self.delegate?.questionSelected(question!)
            return
        }
        self.delegate?.questionDeselected(question!)
    }
    
    
}

// MARK: - Question List View
class QuestionListView : UIView {
    
    // MARK: Properties
    var selected : Bool!
    var question: QuestionModel?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 5
//        self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        let labelQuestion = UILabel(frame: CGRectMake(10, 0, self.frame.size.width - 20, 30))
        //        self.labelQuestion.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
//        self.labelQuestion.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelQuestion.textColor = UIColor.whiteColor()
        labelQuestion.textAlignment = NSTextAlignment.Center
        labelQuestion.text = self.question!.question
        labelQuestion.adjustsFontSizeToFitWidth = true
        self.addSubview(labelQuestion)
    }

    
}

// MARK: - FriendList View
protocol FriendListViewDelegate {
    
    func friendListSelected(user : UserModel)
    func friendListDeselected(user : UserModel)
    
}
class FriendListView : UIView {
    
    // MARK: Properties
    var selected : Bool!
    var buttonCheckBox: UIButton!
    var user: UserModel?
    var delegate: FriendListViewDelegate?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
        self.buttonCheckBox = UIButton(type: UIButtonType.Custom)
        self.buttonCheckBox.frame = CGRectMake(5, 0, 30, 30)
        self.buttonCheckBox.setImage(UIImage(named: "box"), forState: UIControlState.Normal)
        self.buttonCheckBox.addTarget(self, action: "checkBoxClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        if self.selected == true {
            self.buttonCheckBox.setImage(UIImage(named: "check-box"), forState: UIControlState.Normal)
        }
        self.addSubview(self.buttonCheckBox)
        
        let labelName = UILabel(frame: CGRectMake(45, 0, self.frame.size.width - 60, 30))
        //        self.labelQuestion.backgroundColor = UIColor(red: 63/255, green: 94/255, blue: 134/255, alpha: 1)
//        self.labelName.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelName.layer.borderWidth = 2
        labelName.layer.borderColor = UIColor.whiteColor().CGColor
        labelName.layer.cornerRadius = 5
        labelName.text = self.user!.firstName + " " + self.user!.lastName
        labelName.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        labelName.textAlignment = NSTextAlignment.Center
        labelName.adjustsFontSizeToFitWidth = true
        labelName.textColor = UIColor.whiteColor()
        self.addSubview(labelName)
        
    }
    
    
    func checkBoxClicked(sender: UIButton) {
        
        self.selected = !self.selected
        self.buttonCheckBox.setImage(UIImage(named: "box"), forState: UIControlState.Normal)
        if self.selected == true {
            self.buttonCheckBox.setImage(UIImage(named: "check-box"), forState: UIControlState.Normal)
            self.delegate?.friendListSelected(self.user!)
            return
        }
        self.delegate?.friendListDeselected(self.user!)
    }
    
    
}

// MARK: - Friend Invite View
protocol FriendInviteViewDelegate {
    
    func inviteFriend(friend: UserModel)
}

class FriendInviteView : UIView {
    
    // MARK: Properties
    var buttonInvite: UIButton!
    var user: UserModel?
    var delegate: FriendInviteViewDelegate?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
        
        self.buttonInvite = UIButton(type: UIButtonType.Custom)
        self.buttonInvite.frame = CGRectMake(self.frame.size.width - 70, 20, 60, 30)
        self.buttonInvite.layer.borderWidth = 2
        self.buttonInvite.layer.cornerRadius = 5
        self.buttonInvite.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonInvite.setTitle("Invite", forState: UIControlState.Normal)
        self.buttonInvite.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.buttonInvite.addTarget(self, action: "checkBoxClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.buttonInvite)
        
        let imageProfile = UIImageView(frame: CGRectMake(5, 5, 60, 60))
//        imageProfile.backgroundColor = UIColor.blackColor()
        imageProfile.image = UIImage(named: "3")
        self.addSubview(imageProfile)
        
        let labelName = UILabel(frame: CGRectMake(70, 5, self.frame.size.width - 145, 20))
        labelName.backgroundColor = UIColor.clearColor()
        labelName.textAlignment = NSTextAlignment.Left
        labelName.adjustsFontSizeToFitWidth = true
        labelName.textColor = UIColor.whiteColor()
        labelName.text = "\(self.user!.firstName) \(self.user!.lastName)"
        self.addSubview(labelName)
        
        let labelEmail = UILabel(frame: CGRectMake(70, CGRectGetMaxY(labelName.frame), labelName.frame.size.width, 20))
        labelEmail.text = self.user!.email
        labelEmail.backgroundColor = UIColor.clearColor()
        labelEmail.adjustsFontSizeToFitWidth = true
        labelEmail.textColor = UIColor.whiteColor()
        self.addSubview(labelEmail)
        
        let labelGender = UILabel(frame: CGRectMake(70, CGRectGetMaxY(labelEmail.frame), labelName.frame.size.width, 20))
        labelGender.text = "Male"
        labelGender.backgroundColor = UIColor.clearColor()
        labelGender.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelGender.textColor = UIColor.whiteColor()
        self.addSubview(labelGender)
        
    }
    
    
    func checkBoxClicked(sender: UIButton) {
        
        self.delegate?.inviteFriend(self.user!)
        
    }
    
}

// MARK: - Friend Invite View
protocol PendingInviteViewDelegate {
    
    func pendingFriendDecline(friend: UserModel)
    func pendingFriendAccept(friend: UserModel)
}

class PendingInviteView : UIView {
    
    // MARK: Properties
    var user: UserModel?
    var delegate: PendingInviteViewDelegate?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Method
    func setupView() {
        
        
        let buttonInvite = UIButton(type: UIButtonType.Custom)
        buttonInvite.frame = CGRectMake(self.frame.size.width - 70, 8, 60, 25)
        buttonInvite.layer.borderWidth = 2
        buttonInvite.layer.cornerRadius = 5
        buttonInvite.layer.borderColor = UIColor.whiteColor().CGColor
        buttonInvite.setTitle("Accept", forState: UIControlState.Normal)
        buttonInvite.titleLabel!.font = UIFont.systemFontOfSize(14)
        buttonInvite.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonInvite.addTarget(self, action: "checkBoxClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonInvite)
        
        let buttonDecline = UIButton(type: UIButtonType.Custom)
        buttonDecline.frame = CGRectMake(self.frame.size.width - 70, 38, 60, 25)
        buttonDecline.layer.borderWidth = 2
        buttonDecline.layer.cornerRadius = 5
        buttonDecline.titleLabel!.font = UIFont.systemFontOfSize(14)
        buttonDecline.layer.borderColor = UIColor.whiteColor().CGColor
        buttonDecline.setTitle("Decline", forState: UIControlState.Normal)
        buttonDecline.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDecline.addTarget(self, action: "declineClicked", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonDecline)
        
        let imageProfile = UIImageView(frame: CGRectMake(5, 5, 60, 60))
        //        imageProfile.backgroundColor = UIColor.blackColor()
        imageProfile.image = UIImage(named: "3")
        self.addSubview(imageProfile)
        
        let labelName = UILabel(frame: CGRectMake(70, 5, self.frame.size.width - 145, 20))
        labelName.backgroundColor = UIColor.clearColor()
        labelName.textAlignment = NSTextAlignment.Left
        labelName.adjustsFontSizeToFitWidth = true
        labelName.textColor = UIColor.whiteColor()
        labelName.text = "\(self.user!.firstName) \(self.user!.lastName)"
        self.addSubview(labelName)
        
        let labelEmail = UILabel(frame: CGRectMake(70, CGRectGetMaxY(labelName.frame), labelName.frame.size.width, 20))
        labelEmail.text = self.user!.email
        labelEmail.backgroundColor = UIColor.clearColor()
        labelEmail.adjustsFontSizeToFitWidth = true
        labelEmail.textColor = UIColor.whiteColor()
        self.addSubview(labelEmail)
        
        let labelGender = UILabel(frame: CGRectMake(70, CGRectGetMaxY(labelEmail.frame), labelName.frame.size.width, 20))
        labelGender.text = "Male"
        labelGender.backgroundColor = UIColor.clearColor()
        labelGender.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        labelGender.textColor = UIColor.whiteColor()
        self.addSubview(labelGender)
        
    }
    
    
    func checkBoxClicked(sender: UIButton) {
        
        self.delegate?.pendingFriendAccept(self.user!)
        
    }
    
    func declineClicked() {
        
        self.delegate?.pendingFriendDecline(self.user!)
    }
    
}

// MARK: - Ladder Board View
class LadderBoardView : UIView {
    
    // Properties 
    
    
    
    // MARK: Init
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Method
    func setupView() {
        
        let imageProfile = UIImageView(frame: CGRectMake(5, 5, 50, 50))
        imageProfile.image = UIImage(named: "3")
        self.addSubview(imageProfile)
        
        let labelName = UILabel(frame: CGRectMake(59, 5, self.frame.size.width - 180, 50))
        labelName.text = "Mark Angeles"
        labelName.adjustsFontSizeToFitWidth = true
        labelName.textColor = UIColor.whiteColor()
        self.addSubview(labelName)
        
        let labelTotal = UILabel(frame: CGRectMake(CGRectGetMaxX(labelName.frame), 5, 50, 50))
        labelTotal.text = "20"
        labelTotal.adjustsFontSizeToFitWidth = true
        labelTotal.textAlignment = NSTextAlignment.Center
        labelTotal.textColor = UIColor.whiteColor()
        self.addSubview(labelTotal)
        
        let labelCorrect = UILabel(frame: CGRectMake(CGRectGetMaxX(labelTotal.frame), 5, 50, 50))
        labelCorrect.text = "16"
        labelCorrect.textAlignment = NSTextAlignment.Center
        labelCorrect.adjustsFontSizeToFitWidth = true
        labelCorrect.textColor = UIColor.whiteColor()
        self.addSubview(labelCorrect)
        
    }
    
}

// MARK: - Notification View
protocol NotificationViewDelegate {
    
    func notificationSelected (selected : ChallengeModel)
    
}
class NotificationView : UIView {
    
    // MARK: Properties
    var arrayNotification: NSMutableArray! = NSMutableArray()
    var scrollNotification: UIScrollView!
    
    var delegate: NotificationViewDelegate?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    // MARK: Method
    func setupView() {
        
        let imageViewHolder = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageViewHolder.backgroundColor = UIColor.blackColor()
        imageViewHolder.alpha = 0.9
        self.addSubview(imageViewHolder)
        
        let labelInfo = UILabel(frame: CGRectMake(0, 45, self.frame.size.width, 20))
        labelInfo.textColor = UIColor.whiteColor()
        labelInfo.text = "Tap to accept the challenge"
        labelInfo.textAlignment = NSTextAlignment.Center
        self.addSubview(labelInfo)
        
        self.scrollNotification = UIScrollView(frame: CGRectMake(20, 70, self.frame.size.width - 40, self.frame.size.height - 100))
        self.scrollNotification.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor
        self.scrollNotification.layer.borderWidth = 1.0
        self.scrollNotification.pagingEnabled = true
        self.addSubview(self.scrollNotification)
        
        var yLocation = 0 as CGFloat
        
        for (var count = 0; count < AppModel.sharedInstance.challengeReceived.count; count++) {
            
            
            let challenge = AppModel.sharedInstance.challengeReceived[count] as! ChallengeModel
            
            let buttonBack = UIButton(type: UIButtonType.Custom)
            buttonBack.frame = CGRectMake(0, yLocation, self.scrollNotification.frame.size.width, 50)
            buttonBack.layer.borderWidth = 1.0
            buttonBack.addTarget(self, action: "selectedChallenge:", forControlEvents: UIControlEvents.TouchUpInside)
            buttonBack.setTitle("\(challenge.friend.firstName) has Challenged you!", forState: UIControlState.Normal)
            buttonBack.tag = count+1
            buttonBack.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor
            self.scrollNotification.addSubview(buttonBack)
            
            yLocation = yLocation + 50
            
        }
        
//        for (index, player) in self.arrayNotification.enumerate() {
//            
//        
//            let viewNotif = UIView(frame: CGRectMake(0, yLocation, self.scrollNotification.frame.size.width, 50))
//            viewNotif.layer.borderWidth = 1.0
//            viewNotif.tag = index + 1
//            viewNotif.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).CGColor
//            self.scrollNotification.addSubview(viewNotif)
//            
//            let labelNotif = UILabel(frame: CGRectMake(0, 0, self.scrollNotification.frame.size.width, 50))
//            labelNotif.text = "\(player as! String) has challenged you!"
//            labelNotif.textColor = UIColor.whiteColor()
//            
//            labelNotif.textAlignment = NSTextAlignment.Center
//            labelNotif.adjustsFontSizeToFitWidth = true
//            viewNotif.addSubview(labelNotif)
//            
//            yLocation = yLocation + 50
//            
//        }
        
        self.scrollNotification.contentSize = CGSizeMake(0, yLocation)
        
        
    }
    
    // MARK: Button Action
    func selectedChallenge(sender: UIButton) {
        
        let challenge = AppModel.sharedInstance.challengeReceived[sender.tag - 1] as! ChallengeModel
        self.delegate?.notificationSelected(challenge)
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print("touches view")
        self.removeFromSuperview()
    }
}



