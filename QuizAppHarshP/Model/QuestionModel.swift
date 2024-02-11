//
//  DataModel
//  Created by My Mac Mini on 11/02/24.
//

import Foundation

struct DataModel: Codable {
    var data:QuestionModel?
}

struct QuestionModel: Codable {
    var questions: [Questions]?
}

struct Questions: Codable {
    var correctAnswer: String?
    var option1: String?
    var option2: String?
    var option3: String?
    var option4: String?
    var question: String?

    enum CodingKeys: String, CodingKey {
        case correctAnswer = "correct_answer"
        case option1 = "option_1"
        case option2 = "option_2"
        case option3 = "option_3"
        case option4 = "option_4"
        case question
    }
}
