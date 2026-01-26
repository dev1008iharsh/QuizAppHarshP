//
//  AnswersVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//
import UIKit

class AnswersVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tblAnswers: UITableView!
    @IBOutlet weak var btnRestart: UIButton!
    
    // MARK: - Properties
    var questions: [Question] = []
    private let cellIdentifier = "MyCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // Best place to handle corner radius based on frame size
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tblAnswers.delegate = self
        tblAnswers.dataSource = self
        tblAnswers.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tblAnswers.backgroundColor = .clear
        tblAnswers.separatorStyle = .none
    }
    
    // MARK: - Actions
    @IBAction func btnRestartTapped(_ sender: Any) {
        // Show Ad first, then navigate
        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in
            // Execute navigation only after ad is dismissed
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - TableView Extensions
extension AnswersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let item = questions[indexPath.row]
        
        // Modern UI Configuration
        var content = cell.defaultContentConfiguration()
        
        // Question Style
        content.text = item.question
        content.textProperties.color = .black
        content.textProperties.font = UIFont(name: "Quicksand-Medium", size: 17) ?? .systemFont(ofSize: 17)
        
        // Answer Style
        content.secondaryText = "Correct Answer: \(item.correctAnswer ?? "N/A")"
        content.secondaryTextProperties.color = .systemBlue
        content.secondaryTextProperties.font = UIFont(name: "Quicksand-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        
        cell.contentConfiguration = content
        return cell
    }
    
    // Animation for cell appearance
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut) {
            cell.alpha = 1
        }
    }
}
