//
//  AdManager.swift
//  QuizAppHarshP
//
//  Created by Harsh on 27/01/26.
//
 
import GoogleMobileAds
import UIKit

/// **GoogleAdClassManager**
/// A Singleton class responsible for handling all AdMob ads (Banner, Interstitial, Rewarded).
/// This centralized approach keeps ViewControllers clean and logic easy to manage.
final class GoogleAdClassManager: NSObject, FullScreenContentDelegate {
    
    // MARK: - Singleton Access
    /// Shared instance used across the entire app.
    static let shared = GoogleAdClassManager()
    
    // MARK: - Ad Unit IDs
    // ⚠️ NOTE: Always use Test IDs during development. Replace with real IDs only before App Store submission.
    private let bannerTestID = "ca-app-pub-3940256099942544/2934735716"
    private let interstitialTestID = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedTestID = "ca-app-pub-3940256099942544/1712485313"
    
    // MARK: - Properties
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    
    /// A closure (callback) to execute when an Interstitial ad is dismissed.
    /// Primarily used for navigation logic (e.g., popToRootViewController).
    private var onInterstitialDismiss: (() -> Void)?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "e02f5ffcca7e01a7e95a18dc23a1265f" ]
        // Initialize the Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        
        // Pre-load ads immediately so they are ready when the user reaches a checkpoint
        loadInterstitial()
        loadRewardedAd()
    }
    
    // MARK: - 1. Interstitial Ad Logic (Full Screen)
    
    /// Loads the Interstitial ad from Google servers.
    func loadInterstitial() {
        let request = Request()
        InterstitialAd
            .load(with: interstitialTestID, request: request) {
                [weak self] ad,
                error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Interstitial Failed to Load: \(error.localizedDescription)")
                return
            }
            print("✅ Interstitial Ad Loaded")
            self.interstitialAd = ad
            // Set delegate to handle dismissal events
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    /// Shows the Interstitial ad.
    /// - Parameters:
    ///   - vc: The ViewController that will present the ad.
    ///   - onDismiss: The code to run AFTER the ad closes (e.g., Navigation).
    func showInterstitial(from vc: UIViewController, onDismiss: @escaping () -> Void) {
        if let ad = interstitialAd {
            // 1. Save the dismissal logic to be run later
            self.onInterstitialDismiss = onDismiss
            
            // 2. Present the ad
            ad.present(from: vc)
        } else {
            print("⚠️ Interstitial Not Ready")
            // If ad is not ready, proceed with the action anyway (don't block the user)
            onDismiss()
            loadInterstitial()
        }
    }
    
    // MARK: - 2. Rewarded Ad Logic (Video for Reward)
    
    /// Loads the Rewarded ad from Google servers.
    func loadRewardedAd() {
        let request = Request()
        RewardedAd
            .load(with: rewardedTestID, request: request) {
                [weak self] ad,
                error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Rewarded Failed to Load: \(error.localizedDescription)")
                return
            }
            print("✅ Rewarded Ad Loaded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    /// Shows the Rewarded ad.
    /// - Parameters:
    ///   - vc: The ViewController presenting the ad.
    ///   - onReward: The code to run ONLY if the user completes the video.
    ///   - onAdNotReady: Optional closure to handle cases where ad isn't loaded (e.g., Show Alert).
    func showRewardedAd(from vc: UIViewController, onReward: @escaping () -> Void, onAdNotReady: (() -> Void)? = nil) {
        if let ad = rewardedAd {
            
            // 🔥 CRITICAL SAFETY STEP:
            // Since this is a Rewarded Ad, we must clear any saved Interstitial actions.
            // This prevents the app from accidentally navigating (popping to root) when this ad closes.
            self.onInterstitialDismiss = nil
            
            ad.present(from: vc) {
                print("🎁 User earned reward!")
                // Execute the reward logic (e.g., Unlock Answers)
                onReward()
            }
        } else {
            print("⚠️ Rewarded Ad Not Ready")
            loadRewardedAd()
            // Notify the VC that ad is missing (so it can show an alert or proceed)
            onAdNotReady?()
        }
    }
    
    // MARK: - FullScreenContentDelegate (Global Dismissal Logic)
    
    /// Called when ANY full-screen ad (Interstitial or Rewarded) is dismissed.
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("ℹ️ Ad Dismissed.")
        
        // Execute the saved navigation logic (if any exists).
        // If this was a Rewarded Ad, `onInterstitialDismiss` will be nil, so nothing happens (Safe).
        onInterstitialDismiss?()
        
        // Clear the closure to prevent re-execution
        onInterstitialDismiss = nil
        
        // Reload both ad types to be ready for the next time
        loadInterstitial()
        loadRewardedAd()
    }
    
    /// Called when an ad fails to present (e.g., generic internal error).
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Presentation Failed: \(error.localizedDescription)")
        
        // Fail-safe: Ensure the user is not stuck. Run the navigation logic.
        onInterstitialDismiss?()
        onInterstitialDismiss = nil
        
        loadInterstitial()
        loadRewardedAd()
    }
    
    // MARK: - 3. Banner Ad Logic
    
    /// Loads a Banner Ad into a specific GADBannerView from Storyboard.
    func loadBanner(in bannerView: BannerView, rootVC: UIViewController) {
        bannerView.adUnitID = bannerTestID
        bannerView.rootViewController = rootVC
        bannerView.adSize = AdSizeBanner
        bannerView.load(Request())
    }
    
    /// Creates and loads a Banner Ad programmatically (Best for Container Views).
    func getProgrammaticBanner(rootVC: UIViewController) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = bannerTestID
        bannerView.rootViewController = rootVC
        bannerView.load(Request())
        return bannerView
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a Rewarded Ad is currently loaded and ready to show.
    func isRewardedAdReady() -> Bool {
        return rewardedAd != nil
    }
}
