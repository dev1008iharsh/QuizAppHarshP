//
//  AnswersVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//
 
import UIKit
import GoogleMobileAds

// MARK: - List Item Enum
/// Helper enum to handle mixed content (Questions + Ads)
enum ListItem {
    case question(Question)
    case ad(NativeAd)
}

class AnswersVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tblAnswers: UITableView!
    @IBOutlet weak var btnRestart: UIButton!
    
    // MARK: - Properties
    var questions: [Question] = [] // Raw Data passed from QuizVC
    
    // The mixed data source for the table
    var tableData: [ListItem] = []
    
    private let cellIdentifier = "MyCell"
    private let adCellIdentifier = "NativeAdCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Prepare initial data
        prepareTableData()
        
        // Load Ads
        loadNativeAds()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnRestart.layer.cornerRadius = btnRestart.frame.height / 2
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tblAnswers.delegate = self
        tblAnswers.dataSource = self
        
        // Register Standard Cell
        tblAnswers.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Register Native Ad Cell (from separate file)
        tblAnswers.register(NativeAdCell.self, forCellReuseIdentifier: adCellIdentifier)
        
        tblAnswers.backgroundColor = .clear
        tblAnswers.separatorStyle = .none
    }
    
    // MARK: - Data Logic
    func prepareTableData() {
        tableData = questions.map { ListItem.question($0) }
        tblAnswers.reloadData()
    }
    
    func loadNativeAds() {
        // Load 3 ads to mix into the list
        GoogleAdClassManager.shared.loadNativeAds(rootVC: self, count: 3) { [weak self] in
            guard let self = self else { return }
            self.insertAdsIntoList()
        }
    }
    
    func insertAdsIntoList() {
        let loadedAds = GoogleAdClassManager.shared.nativeAds
        guard !loadedAds.isEmpty else { return }
        
        var mixedList: [ListItem] = []
        var adIndex = 0
        
        for (index, question) in questions.enumerated() {
            mixedList.append(.question(question))
            
            // Insert Ad after every 4th question
            if (index + 1) % 4 == 0 && adIndex < loadedAds.count {
                let ad = loadedAds[adIndex]
                mixedList.append(.ad(ad))
                adIndex += 1
            }
        }
        
        self.tableData = mixedList
        self.tblAnswers.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func btnRestartTapped(_ sender: Any) {
        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - TableView Extensions
extension AnswersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = tableData[indexPath.row]
        
        switch item {
        case .question(let question):
            // Show Question Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            var content = cell.defaultContentConfiguration()
            
            // Question Text
            content.text = question.question
            content.textProperties.color = .black
            content.textProperties.font = UIFont(name: "Quicksand-Medium", size: 17) ?? .systemFont(ofSize: 17)
            content.textProperties.numberOfLines = 3 // Allow multi-line questions
            
            // Answer Text
            content.secondaryText = "Correct Answer: \(question.correctAnswer ?? "N/A")"
            content.secondaryTextProperties.color = .systemBlue
            content.secondaryTextProperties.font = UIFont(name: "Quicksand-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
            
            cell.contentConfiguration = content
            return cell
            
        case .ad(let nativeAd):
            // Show Native Ad Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: adCellIdentifier, for: indexPath) as? NativeAdCell else {
                return UITableViewCell()
            }
            cell.configure(with: nativeAd)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let item = tableData[indexPath.row]
            switch item {
            case .question:
                return UITableView.automaticDimension // Auto height for text
            case .ad:
                return 120 // Fixed height for Ad Cell
            }
        }
}
