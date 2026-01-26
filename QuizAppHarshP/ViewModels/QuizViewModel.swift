//
//  QuizViewModel.swift
//
//  Created by My Mac Mini on 11/02/24.
//

import Foundation

// Custom Error Enum for better error handling
enum QuizError: Error {
    case invalidURL
    case invalidData
    case network(Error)
}

final class QuizViewModel {
    
    // MARK: - Properties
    private let sourceURLString = "https://quiz-68112-default-rtdb.firebaseio.com/quiz.json"
    
    // MARK: - Networking (Async/Await)
    
    /// Fetches questions from the server asynchronously.
    /// - Returns: An array of `Question` objects.
    /// - Throws: `QuizError` if something goes wrong.
    func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: sourceURLString) else {
            throw QuizError.invalidURL
        }
        
        do {
            // Modern Async API Call - No more completion handlers!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(QuizResponse.self, from: data)
            
            // Safely return questions or an empty array
            return response.data?.questions ?? []
            
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            throw QuizError.network(error)
        }
    }
}
