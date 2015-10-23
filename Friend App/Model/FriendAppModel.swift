//
//  FriendAppModel.swift
//  Friend App
//
//  Created by Paul Galasso on 9/11/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import Foundation


class AppModel {
    
    static let sharedInstance = AppModel()
    
    let user: UserModel! = UserModel()
    let friends: NSMutableArray! = NSMutableArray()
    let preparedQuestion: NSMutableArray! = NSMutableArray()
    let customQuestion: NSMutableArray! = NSMutableArray()
    let questions: NSMutableArray! = NSMutableArray()
    let challengeSent: NSMutableArray! = NSMutableArray()
    let challengeReceived: NSMutableArray! = NSMutableArray()
    
    private init() {
        
    } //This prevents others from using the default '()' initializer for this class.
}

// MARK: - User Model
class UserModel: NSObject {
    
    var identifier: String! = ""
    var facebookID: NSString! = ""
    var firstName: String! = ""
    var lastName: String! = ""
    var email: String! = ""
    var emailType: String! = ""
    var imageLink: String! = ""
    var totalAnswered: String! = ""
    var totalCorrect: String! = ""
    
}

// MARK: - Question Model
class QuestionModel: NSObject {
    
    var identifier: String! = ""
    var question: String! = ""
    var answer: String! = ""
    var type: String! = ""
    var options: NSMutableArray! = NSMutableArray()
    
}

// MARK: - Question Collection Model
class QuestionCollectionModel {
    
    var identifier: String! = ""
    var collection: NSMutableArray! = NSMutableArray()
    
}
// MARK: - Question Preview Model
class QuestionPreviewModel: NSObject {
    
    var result: String! = ""
    var question: String! = ""
    var answer: String! = ""
    var powerups: NSMutableArray! = NSMutableArray()
    
}

// MARK: Challenge Result Model
class ChallengeResultModel: NSObject {
    
    var identifier: String! = ""
    var result: NSMutableArray! = NSMutableArray()
}

// MARK: Challenge Model
class ChallengeModel: NSObject {
    
    var identifier: String! = ""
    var questionSet: QuestionCollectionModel! = QuestionCollectionModel()
    var friend: UserModel! = UserModel()
}
