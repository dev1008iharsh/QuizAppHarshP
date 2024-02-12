//
//  OnboardingVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class OnboardingVC: UIViewController {

    
    @IBOutlet weak var btnPlay: UIButton! {
        didSet {
            btnPlay.layer.cornerRadius = btnPlay.frame.height/2
        }
    }
    @IBOutlet weak var btnRules: UIButton! {
        didSet {
            btnRules.layer.cornerRadius = btnRules.frame.height/2
        }
    }
     
    
    var viewModel = QueViewModel()
    var arrQuesitions :  [Questions]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchQuestions { [weak self] in
            self?.arrQuesitions = self?.viewModel.queData?.data?.questions
        }
    }
    
    @IBAction func btnPlayTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "QuizVC") as? QuizVC else {return}
        if let arrQues = arrQuesitions {
            vc.arrQuesitions = arrQues
            self.navigationController?.pushViewController(vc, animated: true)
            Utility.shared.lightHapticFeedBack()
        }
        
    }
    
    @IBAction func btnRulesTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Rules", message: "You must have to answer each and every question's answer, and you will get results at the end.Restarting game will loose points.There will be total 10 Question, each with 4 options.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }


}

