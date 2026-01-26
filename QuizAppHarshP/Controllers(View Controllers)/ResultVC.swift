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
            HapticManager.shared.lightImpact()
        } else {
            resultLabel.textColor = .systemRed
            HapticManager.shared.heavyImpact()
        }
    }

    // MARK: - Actions
    
    @IBAction func btnRestartTapped(_ sender: Any) {
        // Show Interstitial Ad -> Then Navigate to Home
        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnAnswersTapped(_ sender: Any) {
        HapticManager.shared.lightImpact()
        
        // Request to show Rewarded Ad
        GoogleAdClassManager.shared.showRewardedAd(from: self, onReward: { [weak self] in
            
            // Success: User watched video -> Navigate
            print("🎉 Video watched! Navigating to Answers...")
            self?.navigateToAnswersVC()
            
        }, onAdNotReady: { [weak self] in
            
            // Failure: Ad not ready -> Show Alert (Strict Mode)
            self?.showAdNotReadyAlert()
        })
    }
    
    // MARK: - Helper Methods
    
    private func navigateToAnswersVC() {
        guard let answersVC = storyboard?.instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC else { return }
        answersVC.questions = self.questions
        navigationController?.pushViewController(answersVC, animated: true)
    }
    
    private func showAdNotReadyAlert() {
        let alert = UIAlertController(title: "Loading Ad...", message: "Please wait a moment while we load the video.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
