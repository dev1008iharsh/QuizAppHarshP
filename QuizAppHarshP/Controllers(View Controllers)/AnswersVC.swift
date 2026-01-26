//
//  AnswersVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class AnswersVC: UIViewController {

    @IBOutlet weak var tblAnswers: UITableView!
    @IBOutlet weak var btnRestart: UIButton!
    
    var questions: [Question] = []
    private let cellIdentifier = "MyCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
    }
    
    private func setupTableView() {
        tblAnswers.delegate = self
        tblAnswers.dataSource = self
        tblAnswers.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tblAnswers.backgroundColor = .clear
        tblAnswers.separatorStyle = .none
    }
    
    @IBAction func btnRestartTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension AnswersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let item = questions[indexPath.row]
        
        // Modern UIContentConfiguration
        var content = cell.defaultContentConfiguration()
        
        // Main Question Text
        content.text = item.question
        content.textProperties.color = .black
        content.textProperties.font = UIFont(name: "Quicksand-Medium", size: 17) ?? .systemFont(ofSize: 17)
        
        // Answer Text
        content.secondaryText = "Correct Answer: \(item.correctAnswer ?? "N/A")"
        content.secondaryTextProperties.color = .systemBlue
        content.secondaryTextProperties.font = UIFont(name: "Quicksand-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        
        cell.contentConfiguration = content
        return cell
    }
    
    // Best place for animations is willDisplay, not cellForRow
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut) {
            cell.alpha = 1
        }
    }
}
