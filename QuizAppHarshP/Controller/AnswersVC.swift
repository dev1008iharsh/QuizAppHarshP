//
//  AnswersVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class AnswersVC: UIViewController {
    
    @IBOutlet weak var tblAnswers: UITableView!
    
    var arrQuesitions : [Questions]?
    
    let cellReuseIdentifier = "MyCell"
    
    @IBOutlet weak var btnRestart : UIButton! {
        didSet {
            btnRestart.layer.cornerRadius = btnRestart.frame.height/2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAnswers.dataSource = self
        tblAnswers.delegate = self
        tblAnswers.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tblAnswers.backgroundColor = .clear
    }
    
    @IBAction func btnRestart(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension AnswersVC : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrQuesitions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        
        let ques = arrQuesitions?[indexPath.row]
        var contentConfigue = cell.defaultContentConfiguration()
        contentConfigue.text = (ques?.question ?? "")
        contentConfigue.textProperties.color = .black
        if let customFontText = UIFont(name: "Quicksand-Medium", size: 17) {
            contentConfigue.textProperties.font = customFontText
        }
        
        contentConfigue.secondaryText = "Answer : \(ques?.correctAnswer ?? "")"
        contentConfigue.secondaryTextProperties.color = .blue
        if let customFontSec = UIFont(name: "Quicksand-Bold", size: 18) {
            contentConfigue.secondaryTextProperties.font = customFontSec
        }
        cell.contentConfiguration = contentConfigue
        cell.alpha = 0
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
