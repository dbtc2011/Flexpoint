//
//  FriendAppModel.swift
//  Friend App
//
//  Created by Paul Galasso on 9/11/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import Foundation
// MARK: - User Model
class UserModel: NSObject {
    
    var identifier: String! = ""
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
