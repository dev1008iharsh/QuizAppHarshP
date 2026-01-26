//
//  QuizCVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit


class QuizCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblQuestion: UILabel!
    
    @IBOutlet weak var option1: UILabel!
    @IBOutlet weak var option2: UILabel!
    @IBOutlet weak var option3: UILabel!
    @IBOutlet weak var option4: UILabel!
    
    // Make sure these are connected in Storyboard
    @IBOutlet weak var optionA: UIControl!
    @IBOutlet weak var optionB: UIControl!
    @IBOutlet weak var optionC: UIControl!
    @IBOutlet weak var optionD: UIControl!
    
    // MARK: - Properties
    private var currentQuestion: Question?
    
    // Closure to send data back to VC
    var onOptionSelected: ((Bool) -> Void)?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        resetBorders()
    }
    
    // MARK: - Configuration
    func configure(with question: Question) {
        self.currentQuestion = question
        lblQuestion.text = question.question
        
        option1.text = question.option1
        option2.text = question.option2
        option3.text = question.option3
        option4.text = question.option4
        
        resetBorders()
    }
    
    // MARK: - Actions (Restored to 4 Actions like before)
    
    @IBAction func onClickOptionA(_ sender: Any) {
        handleSelection(selectedOptionText: currentQuestion?.option1, selectedView: optionA)
    }
    
    @IBAction func onClickOptionB(_ sender: Any) {
        handleSelection(selectedOptionText: currentQuestion?.option2, selectedView: optionB)
    }
    
    @IBAction func onClickOptionC(_ sender: Any) {
        handleSelection(selectedOptionText: currentQuestion?.option3, selectedView: optionC)
    }
    
    @IBAction func onClickOptionD(_ sender: Any) {
        handleSelection(selectedOptionText: currentQuestion?.option4, selectedView: optionD)
    }
    
    // MARK: - Helper Logic (The "Brain" of the selection)
    
    private func handleSelection(selectedOptionText: String?, selectedView: UIControl) {
        // Validation
        guard let validQuestion = currentQuestion, let selectedText = selectedOptionText else { return }
        
        // Logic: Check if answer is correct
        let isCorrect = (selectedText == validQuestion.correctAnswer)
        
        // Visual Update
        highlightSelectedOption(selectedView)
        
        // Pass Data to Controller
        onOptionSelected?(isCorrect)
    }
    
    // MARK: - UI Helpers
    
    private func resetBorders() {
        [optionA, optionB, optionC, optionD].forEach { view in
            view?.layer.borderWidth = 0
            view?.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func highlightSelectedOption(_ view: UIControl) {
        resetBorders()
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.white.cgColor
    }
}
