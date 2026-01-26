//
//  OnboardingVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import GoogleMobileAds
import UIKit

class OnboardingVC: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnRules: UIButton!

    @IBOutlet var bannerView: BannerView!

    // MARK: - Properties

    private let viewModel = QuizViewModel()
    private var questions: [Question] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        setupAd()
    }

    // MARK: - Ad Configuration

    private func setupAd() {
        // We delegate all the heavy lifting to our Manager class.
        // This keeps our View Controller clean and focused.
        GoogleAdClassManager.shared.loadBanner(in: bannerView, rootVC: self)
    }

    // MARK: - Setup

    private func setupUI() {
        btnPlay.layer.cornerRadius = btnPlay.frame.height / 2
        btnRules.layer.cornerRadius = btnRules.frame.height / 2
        // Disable play button until data is loaded
        btnPlay.isEnabled = false
        btnPlay.alpha = 0.5
    }

    // MARK: - API Call

    private func loadData() {
        // 'Task' is used to bridge async/await with synchronous viewDidLoad
        Task { [weak self] in
            do {
                guard let self else { return }
                // Fetch data on background thread automatically
                let fetchedQuestions = try await viewModel.fetchQuestions()

                // Update UI on Main Thread
                self.questions = fetchedQuestions
                self.btnPlay.isEnabled = true
                self.btnPlay.alpha = 1.0
                print("Questions Loaded: \(fetchedQuestions.count)")

            } catch {
                // Handle Error (Show Alert)

                print("Failed to load questions: \(error)")
            }
        }
    }

    // MARK: - Actions

    @IBAction func btnPlayTapped(_ sender: Any) {
        guard let quizVC = storyboard?.instantiateViewController(withIdentifier: "QuizVC") as? QuizVC else { return }

        quizVC.questions = questions
        HapticManager.shared.lightImpact() // Using our optimized manager
        navigationController?.pushViewController(quizVC, animated: true)
    }

    @IBAction func btnRulesTapped(_ sender: Any) {
        // Optimized Alert Helper usage
        showAlert(title: "Rules", message: "1. Answer all questions.\n2. Restarting loses progress.\n3. Total 10 Questions.")
    }

    // MARK: - Helper Functions

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
