//
//  QuestionViewModel.swift
//
//  Created by My Mac Mini on 11/02/24.
//

import Foundation

class QueViewModel {
    
    var queData : DataModel?
    
    private let sourcesURL = URL(string: "https://quiz-68112-default-rtdb.firebaseio.com/quiz.json")!

    func fetchQuestions(completion : @escaping () -> ()) {
        
        URLSession.shared.dataTask(with: sourcesURL) { [weak self] (data, urlResponse, error) in
            if let data = data {
                
                let jsonDecoder = JSONDecoder()
                
                let empData = try! jsonDecoder.decode(DataModel.self, from: data)
                self?.queData = empData
                print(empData)
                completion()
            }
        }.resume()
    }
}
