//
//  QuizVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import UIKit

class QuizVC: UIViewController {

    
    @IBOutlet weak var collvQues: UICollectionView!
    
    @IBOutlet weak var btnRestart : UIButton! {
        didSet {
            btnRestart.layer.cornerRadius = btnRestart.frame.height/2
        }
    }
    
    @IBOutlet weak var btnNext: UIButton! {
        didSet {
            btnNext.layer.cornerRadius = btnNext.frame.height/2
        }
    }
     
    var arrQuesitions : [Questions]?
    
    var selectedAns = false
    var isCorrectAns = false
    
    var countCorrectAns = 0
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.collvQues.delegate = self
        self.collvQues.dataSource = self
     
    }
     
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func btnRestart(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func btnNext(_ sender: Any) {
        
        if !selectedAns {
            // Show alert
            let alert = UIAlertController(title: "Must have to answer", message: "Please select one answer from four options", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        selectedAns = false
        if isCorrectAns {
            countCorrectAns += 1
        }
        
        print(index)
        if index<(self.arrQuesitions?.count ?? 0) - 1 {
            index += 1
            collvQues.scrollToItem(at: IndexPath(row: index, section: 0), at: .right, animated: true)

        } else {
            // Move the user on the result controller
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultVC else {return}
            
            
            vc.result = countCorrectAns
            vc.arrQuesitions = self.arrQuesitions
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
}

extension QuizVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrQuesitions?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCVC", for: indexPath) as? QuizCVC else {return QuizCVC()}
        cell.optionA.layer.cornerRadius = 5
        cell.optionB.layer.cornerRadius = 5
        cell.optionC.layer.cornerRadius = 5
        cell.optionD.layer.cornerRadius = 5
        cell.setValues = arrQuesitions?[indexPath.row]
        cell.selectedOption = { [weak self] isCorrect in
            self?.selectedAns = true
            self?.isCorrectAns = isCorrect
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
