//
//  CommetedCOde.swift
//  QuizAppHarshP
//
//  Created by Harsh on 28/01/26.
//
//
/*
 func insertAdsIntoList() {
     // 1. Retrieve loaded ads from the manager
     let loadedAds = GoogleAdClassManager.shared.nativeAds
     
     // 2. Safety check: If no ads are available, just reload to show questions and exit
     guard !loadedAds.isEmpty else {
         tblAnswers.reloadData()
         return
     }
     
     // 3. Keep a reference of the current list before updating
     let oldListCount = arrListItems.count
     var mixedList: [ListItem] = []
     var adIndex = 0
     
     // 4. Re-calculate the mixed list (Questions + Ads)
     for (index, question) in questions.enumerated() {
         mixedList.append(.question(question))
         
         // Logic: Insert ad after every 4th question
         if (index + 1) % 4 == 0 && adIndex < loadedAds.count {
             mixedList.append(.ad(loadedAds[adIndex]))
             adIndex += 1
         }
     }
     
     // 5. Identify the exact IndexPaths where ads are being injected
     // We compare the new list against the old count to find new positions
     var indexPathsToInsert: [IndexPath] = []
     for (newIndex, item) in mixedList.enumerated() {
         if case .ad = item {
             // Add this index to our animation list
             indexPathsToInsert.append(IndexPath(row: newIndex, section: 0))
         }
     }
     
     // 6. Update the data source
     arrListItems = mixedList
     
     // 7. Perform Batch Updates for smooth middle-insertion animation
     // If the table was empty (first load), we use reloadData.
     // Otherwise, we use insertRows for the professional '.fade' effect.
     if oldListCount > 0 && !indexPathsToInsert.isEmpty {
         tblAnswers.performBatchUpdates({
             tblAnswers.insertRows(at: indexPathsToInsert, with: .fade)
         }, completion: nil)
     } else {
         tblAnswers.reloadData()
     }
 }
*/
