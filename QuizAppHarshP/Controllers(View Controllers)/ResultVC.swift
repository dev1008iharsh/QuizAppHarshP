//
//  ResultVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//
import UIKit

class ResultVC: UIViewController {
    // MARK: - Outlets

    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var btnRestart: UIButton!
    @IBOutlet var btnAnswers: UIButton!

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
        // Directly calling the prompt instead of starting ad immediately
        showRewardPrompt()
    }

    // MARK: - Ad Logic Functions

    func showRewardPrompt() {
        // 1. Create the alert with professional and positive wording
        // We use "Unlock" to make it feel like a premium benefit
        let alert = UIAlertController(
            title: "Unlock Full Results 🏆",
            message: "Watch a short video to see all correct answers with detailed explanations. If the ad is skipped, the results will remain locked.",
            preferredStyle: .alert
        )

        // 2. The Reward Action (User agrees to watch)
        let watchAction = UIAlertAction(title: "Watch & Reveal", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.launchRewardedAd()
        }

        // 3. The Cancel Action (User opts out)
        let cancelAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)

        alert.addAction(watchAction)
        alert.addAction(cancelAction)

        // Present the alert to the user
        present(alert, animated: true, completion: nil)
    }

    private func launchRewardedAd() {
        // Call the Singleton Manager to play the ad
        GoogleAdClassManager.shared.showRewardedAd(from: self, onReward: { [weak self] in
            // Success: Ad completed
            print("🎉 Reward earned! Navigating to Answers...")
            self?.navigateToAnswersVC()
        }, onAdNotReady: { [weak self] in
            // Fallback: If ad isn't ready, don't frustrate the user
            print("⚠️ Ad not ready. Providing access to avoid negative UX.")
            self?.navigateToAnswersVC()
        })
    }

    // MARK: - Helper Methods

    private func navigateToAnswersVC() {
        guard let answersVC = storyboard?.instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC else { return }
        answersVC.questions = questions
        navigationController?.pushViewController(answersVC, animated: true)
    }
}
