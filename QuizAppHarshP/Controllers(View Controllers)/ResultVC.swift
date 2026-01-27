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
    var questions: [Question] = []
    var finalScore: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayScore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make buttons circular based on their height
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
        btnAnswers.layer.cornerRadius = btnAnswers.frame.height / 2
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        resultLabel.font = UIFont(name: "Quicksand-Bold", size: 50)
    }
    
    private func displayScore() {
        resultLabel.text = "\(finalScore)"
        
        // Logic: Green for pass (more than 50%), Red for fail
        if finalScore > (questions.count / 2) {
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.textColor = .systemRed
        }
    }

    // MARK: - Actions
    
    @IBAction func btnRestartTapped(_ sender: Any) {
        HapticManager.shared.heavyImpact()
        // Show Interstitial Ad -> Then Navigate to Home
        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
     
    @IBAction func btnAnswersTapped(_ sender: Any) {
        HapticManager.shared.lightImpact()
        
        GoogleAdClassManager.shared.showRewardedAd(from: self, onReward: { [weak self] in
            // Success: User watched video -> Navigate
            print("🎉 Video watched! Navigating to Answers...")
            self?.navigateToAnswersVC()
            
        }, onAdNotReady: { [weak self] in
            // This rarely happens here because we checked first,
            // but just in case, let them go.
            print("⚠️ Ad not ready. Letting user pass for free to avoid Apple Rejection.")
            self?.navigateToAnswersVC()
        })
    }
    
    // MARK: - Helper Methods
    
    private func navigateToAnswersVC() {
        guard let answersVC = storyboard?.instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC else { return }
        answersVC.questions = self.questions
        navigationController?.pushViewController(answersVC, animated: true)
    }
     
}
