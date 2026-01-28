//
//  AnswersVC.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 11/02/24.
//

import GoogleMobileAds
import UIKit

// MARK: - List Item Enum

/// Helper enum to handle mixed content (Questions + Ads)
enum ListItem {
    case question(Question)
    case ad(NativeAd)
}

class AnswersVC: UIViewController {
    // MARK: - Outlets

    @IBOutlet var tblAnswers: UITableView!
    @IBOutlet var btnRestart: UIButton!

    // MARK: - Properties

    var questions: [Question] = [] // Raw Data passed from QuizVC

    // The mixed data source for the table
    var arrListItems: [ListItem] = []

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
        // 1. Transform the 'questions' array (Raw Data) into a 'ListItem' array (Enum Wrapper)
        // 2. The .map function iterates through each question and wraps it in the .question case
        // 3. This allows the TableView to handle different types of cells (Question vs. Ad) in the same list

        // arrListItems = questions.map { ListItem.question($0) }

        // Repeat same data for 5 times to check ad loading efficiently
        let repeatedData = questions + questions + questions + questions + questions
        arrListItems = repeatedData.map { ListItem.question($0) }
    }

    func loadNativeAds() {
        // Request 5 ads to ensure we have a good variety in the list
        GoogleAdClassManager.shared.loadNativeAds(rootVC: self, count: 5) { [weak self] in
            guard let self = self else { return }
            self.insertAdsIntoList()
        }
    }

    func insertAdsIntoList() {
        // Circular Repeat (Modulo) Reate those 5 Ads which we added
        // Retrieve loaded ads from the manager
        let loadedAds = GoogleAdClassManager.shared.nativeAds

        // Safety check: Exit if no ads are available
        guard !loadedAds.isEmpty else {
            tblAnswers.reloadData()
            return
        }

        // Match the 5x logic used in prepareTableData
        let repeatedQuestions = questions + questions + questions + questions + questions
        let oldListCount = arrListItems.count
        var mixedList: [ListItem] = []

        // Circular Ad Injection Logic
        var adCounter = 0 // Track how many ad slots we have filled

        for (index, question) in repeatedQuestions.enumerated() {
            mixedList.append(.question(question))

            // Logic: Insert ad after every 4th question
            if (index + 1) % 4 == 0 {
                // 🔥 Circular Logic: Cycle through available ads using Modulo
                let circularIndex = adCounter % loadedAds.count
                let ad = loadedAds[circularIndex]

                mixedList.append(.ad(ad))
                adCounter += 1
            }
        }

        // Identify IndexPaths for new ad placements
        var indexPathsToInsert: [IndexPath] = []
        for (newIndex, item) in mixedList.enumerated() {
            if case .ad = item {
                indexPathsToInsert.append(IndexPath(row: newIndex, section: 0))
            }
        }

        // Update data source
        arrListItems = mixedList

        // Perform Batch Updates for smooth UI transition
        if oldListCount > 0 && !indexPathsToInsert.isEmpty {
            tblAnswers.performBatchUpdates({
                tblAnswers.insertRows(at: indexPathsToInsert, with: .fade)
            }, completion: nil)
        } else {
            tblAnswers.reloadData()
        }
    }

    // MARK: - Actions

    @IBAction func btnRestartTapped(_ sender: Any) {
        HapticManager.shared.heavyImpact()

        GoogleAdClassManager.shared.showInterstitial(from: self) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    /* TABLE RELOAD DATA LOGIC
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

         self.arrListItems = mixedList
         self.tblAnswers.reloadData()
     }*/
}

// MARK: - TableView Extensions

extension AnswersVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrListItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = arrListItems[indexPath.row]

        switch item {
        case let .question(question):
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

        case let .ad(nativeAd):
            // Show Native Ad Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: adCellIdentifier, for: indexPath) as? NativeAdCell else {
                return UITableViewCell()
            }
            cell.configure(with: nativeAd)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = arrListItems[indexPath.row]
        switch item {
        case .question:
            return UITableView.automaticDimension // Auto height for text
        case .ad:
            return 120 // Fixed height for Ad Cell
        }
    }
}
