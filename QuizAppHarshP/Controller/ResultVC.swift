//
//  ResultVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class ResultVC: UIViewController {
    
    var arrQuesitions : [Questions]?
    
    @IBOutlet weak var btnRestart : UIButton! {
        didSet {
            btnRestart.layer.cornerRadius = btnRestart.frame.height/2
        }
    }
    @IBOutlet weak var btnAnswers : UIButton! {
        didSet {
            btnAnswers.layer.cornerRadius = btnAnswers.frame.height/2
        }
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var result = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "\(result)"
        // Do any additional setup after loading the view.
    }

    @IBAction func btnRestart(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnAnswersTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC else {return}
        if let arrQues = self.arrQuesitions {
            vc.arrQuesitions = arrQues
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
}
