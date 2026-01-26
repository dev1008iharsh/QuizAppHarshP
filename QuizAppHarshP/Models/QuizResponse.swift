//
//  QuizResponse
//  Created by My Mac Mini on 11/02/24.
//

import Foundation

// MARK: - API Response Model
struct QuizResponse: Codable {
    // Optional because API might return nil
    let data: QuestionData?
}

struct QuestionData: Codable {
    let questions: [Question]?
}

// MARK: - Question Model
struct Question: Codable {
    let question: String?
    let option1: String?
    let option2: String?
    let option3: String?
    let option4: String?
    let correctAnswer: String?
    
    // CodingKeys to map JSON keys to CamelCase properties
    enum CodingKeys: String, CodingKey {
        case question
        case option1 = "option_1"
        case option2 = "option_2"
        case option3 = "option_3"
        case option4 = "option_4"
        case correctAnswer = "correct_answer"
    }
}
