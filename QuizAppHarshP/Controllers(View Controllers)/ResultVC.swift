//
//  ResultVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class ResultVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var btnRestart: UIButton!
    @IBOutlet weak var btnAnswers: UIButton!
    
    // MARK: - Properties
    // Using the 'Question' model we defined earlier
    var questions: [Question] = []
    
    // Renamed 'result' to 'finalScore' for clarity
    var finalScore: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayScore()
    }
    
    // Prefer layoutSubviews for corner radius to ensure correct frame size
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
        btnAnswers.layer.cornerRadius = btnAnswers.frame.height / 2
    }
    
    // MARK: - Setup
    private func setupUI() {
        // You can add more styling here if needed
        resultLabel.font = UIFont(name: "Quicksand-Bold", size: 50)
    }
    
    private func displayScore() {
        resultLabel.text = "\(finalScore)"
        
        // Optional: Change color based on score (Green if good, Red if bad)
        if finalScore > (questions.count / 2) {
            resultLabel.textColor = .systemGreen
            HapticManager.shared.lightImpact()
        } else {
            resultLabel.textColor = .systemRed
            HapticManager.shared.heavyImpact()
        }
    }

    // MARK: - Actions
    
    // Renamed function to avoid conflict with IBOutlet name
    @IBAction func btnRestartTapped(_ sender: Any) {
        HapticManager.shared.heavyImpact()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnAnswersTapped(_ sender: Any) {
        // Safe navigation with guard let
        guard let answersVC = storyboard?.instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC else { return }
        
        // Pass data securely
        answersVC.questions = self.questions
        
        HapticManager.shared.lightImpact()
        self.navigationController?.pushViewController(answersVC, animated: true)
    }
}
