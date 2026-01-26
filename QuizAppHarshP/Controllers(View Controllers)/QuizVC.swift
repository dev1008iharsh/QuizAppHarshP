import UIKit

class QuizVC: UIViewController {
    // MARK: - Outlets

    @IBOutlet var bannerContainerView: UIView!
    @IBOutlet var collvQues: UICollectionView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var btnRestart: UIButton!

    // MARK: - Properties

    var questions: [Question] = []

    private var currentScore = 0
    private var currentIndex = 0
    private var hasSelectedAnswer = false
    private var isCurrentAnswerCorrect = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupBannerInContainer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Ad Setup

    private func setupBannerInContainer() {
        let bannerView = GoogleAdClassManager.shared.getProgrammaticBanner(rootVC: self)
        bannerContainerView.addSubview(bannerView)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: bannerContainerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bannerContainerView.bottomAnchor),
            bannerView.leadingAnchor.constraint(equalTo: bannerContainerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: bannerContainerView.trailingAnchor),
        ])
    }

    // MARK: - UI Setup

    private func setupUI() {
        btnNext.layer.cornerRadius = btnNext.frame.height / 2
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
    }

    private func setupCollectionView() {
        collvQues.delegate = self
        collvQues.dataSource = self
        collvQues.isScrollEnabled = false

        if let layout = collvQues.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }
        collvQues.reloadData()
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

        // Reset flags
        hasSelectedAnswer = false

        if currentIndex < questions.count - 1 {
            currentIndex += 1

            // Scroll to next
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let nextIndexPath = IndexPath(item: self.currentIndex, section: 0)
                self.collvQues.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        } else {
            navigateToResults()
        }
    }

    // 🔥 FIXED RESTART ACTION
    @IBAction func btnRestartTapped(_ sender: Any) {
        
        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in

            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Navigation & Helpers

    private func navigateToResults() {
        guard let resultVC = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultVC else { return }
        resultVC.finalScore = currentScore
        resultVC.questions = questions
        navigationController?.pushViewController(resultVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CollectionView Extensions

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
