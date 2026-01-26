//
//  QuizVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//
import UIKit

class QuizVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collvQues: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnRestart: UIButton!
    
    // MARK: - Properties
    var questions: [Question] = [] // Data passed from OnboardingVC
    
    private var currentScore = 0
    private var currentIndex = 0
    private var hasSelectedAnswer = false
    private var isCurrentAnswerCorrect = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        collvQues.delegate = self
        collvQues.dataSource = self
        collvQues.isScrollEnabled = false // Prevent manual scrolling
        
        btnNext.layer.cornerRadius = btnNext.frame.height / 2
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
    }

    // MARK: - Actions
    @IBAction func btnNextTapped(_ sender: Any) {
         
        guard hasSelectedAnswer else {
            showAlert(title: "Wait!", message: "Please select an answer before proceeding.")
            return
        }
        
        // Update Score
        if isCurrentAnswerCorrect {
            currentScore += 1
            HapticManager.shared.lightImpact()
        } else {
            HapticManager.shared.heavyImpact()
        }
        
        // Reset flags for next question
        hasSelectedAnswer = false
        
        if currentIndex < questions.count - 1 {
                    currentIndex += 1
                    
                    // મેઈન થ્રેડ પર થોડી રાહ જોઈને સ્ક્રોલ કરો (Safe Side)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let nextIndexPath = IndexPath(item: self.currentIndex, section: 0)
                        self.collvQues.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                    }
                    
                } else {
                    navigateToResults()
                }
    }
    
    @IBAction func btnRestartTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func navigateToResults() {
        guard let resultVC = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultVC else { return }
        resultVC.finalScore = currentScore
        resultVC.questions = self.questions
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func setupCollectionView() {
            collvQues.delegate = self
            collvQues.dataSource = self
            collvQues.isScrollEnabled = false // યુઝર હાથેથી સ્ક્રોલ ન કરી શકે
            
            // Layout Fix (આના વગર સ્ક્રોલ કામ નહીં કરે)
            if let layout = collvQues.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                
                // ⚠️ સૌથી મહત્વનું: Estimated Size ને Zero કરો
                layout.estimatedItemSize = .zero
            }
            
            // Data Load થયા પછી એકવાર Reload કરવું જરૂરી છે
            collvQues.reloadData()
        }
}

// MARK: - CollectionView DataSource & Delegate
extension QuizVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         
        return questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCollectionViewCell", for: indexPath) as? QuizCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let question = questions[indexPath.row]
        cell.configure(with: question)
        
        // Handle Option Selection using Closure
        // [weak self] prevents Memory Leak (Retain Cycle)
        cell.onOptionSelected = { [weak self] isCorrect in
            self?.hasSelectedAnswer = true
            self?.isCurrentAnswerCorrect = isCorrect
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
