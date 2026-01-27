//
//  AdManager.swift
//  QuizAppHarshP
//
//  Created by Harsh on 27/01/26.
//
import GoogleMobileAds
import UIKit

/// **GoogleAdClassManager**
/// A Singleton class responsible for handling all AdMob ads (Banner, Interstitial, Rewarded, Native, App Open).
/// This centralized approach keeps ViewControllers clean and logic easy to manage.
final class GoogleAdClassManager: NSObject, FullScreenContentDelegate, NativeAdLoaderDelegate {
    // MARK: - Singleton Access

    /// Shared instance used across the entire app.
    static let shared = GoogleAdClassManager()

    // MARK: - Ad Unit IDs

    // ⚠️ NOTE: Always use Test IDs during development. Replace with real IDs only before App Store submission.
    private let bannerTestID = "ca-app-pub-3940256099942544/2934735716"
    private let interstitialTestID = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedTestID = "ca-app-pub-3940256099942544/1712485313"
    private let nativeTestID = "ca-app-pub-3940256099942544/3986624511"
    private let appOpenTestID = "ca-app-pub-3940256099942544/5575463023"

    // MARK: - Properties

    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var appOpenAd: AppOpenAd? // 🔥 New

    // Properties for Native Ads
    private var adLoader: AdLoader?
    // Stores loaded native ads to be used in TableView
    var nativeAds: [NativeAd] = []
    // Callback to notify TableView when native ads are ready
    private var onNativeAdsLoaded: (() -> Void)?

    // Properties for App Open Ad Logic
    private var loadTime: Date?
    private var isShowingAd = false

    /// A closure (callback) to execute when an Interstitial ad is dismissed.
    /// Primarily used for navigation logic (e.g., popToRootViewController).
    private var onInterstitialDismiss: (() -> Void)?

    // MARK: - Initialization

    override private init() {
        super.init()
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["e02f5ffcca7e01a7e95a18dc23a1265f"]
        // Initialize the Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)

        // Pre-load ads immediately so they are ready when the user reaches a checkpoint
        loadInterstitial()
        loadRewardedAd()
        loadAppOpenAd()
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
            onInterstitialDismiss = onDismiss

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
            onInterstitialDismiss = nil

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

    // MARK: - 3. Native Ad Logic (For TableView Cells)

    /// Loads multiple native ads to be displayed within a TableView.
    /// - Parameters:
    ///   - rootVC: The ViewController responsible for the ads (needed for AdLoader).
    ///   - count: Number of ads to load (e.g., 3 if you want to show 3 ads in the list).
    ///   - completion: Callback triggered when ads are successfully loaded (so you can reloadTableView).
    func loadNativeAds(rootVC: UIViewController, count: Int, completion: @escaping () -> Void) {
        // Save the completion handler
        onNativeAdsLoaded = completion

        // Options to load multiple ads at once
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = count

        // Initialize the AdLoader
        adLoader = AdLoader(adUnitID: nativeTestID,
                            rootViewController: rootVC,
                            adTypes: [.native],
                            options: [multipleAdsOptions])

        adLoader?.delegate = self

        // Request the ads
        let request = Request()
        adLoader?.load(request)
    }

    // MARK: - NativeAdLoaderDelegate Methods

    // Called when a native ad is received
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("✅ Native Ad Received")
        // Add the ad to our array
        nativeAds.append(nativeAd)
    }

    // Called when the ad loader finishes loading all ads (Success or Failure)
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        print("ℹ️ Finished loading native ads. Total count: \(nativeAds.count)")
        // Notify the VC to reload the table
        onNativeAdsLoaded?()
    }

    // Called when loading fails
    func adLoader(
        _ adLoader: AdLoader,
        didFailToReceiveAdWithError error: Error
    ) {
        print("❌ Native Ad Failed: \(error.localizedDescription)")
        // Even if it fails, we notify so the table can show content without ads
        onNativeAdsLoaded?()
    }

    // MARK: - 4. App Open Ad Logic (Launch Ad) 🆕

    /// Loads the App Open Ad
    func loadAppOpenAd() {
        // Do not load if already exists or currently showing
        if isAppOpenAdAvailable() || isShowingAd { return }

        let request = Request()
        AppOpenAd.load(with: appOpenTestID, request: request) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ App Open Ad Failed: \(error.localizedDescription)")
                return
            }

            print("✅ App Open Ad Loaded")
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date() // Save the time it was loaded
        }
    }

    /// Check if ad exists and was loaded less than 4 hours ago (Google Rule)
    private func isAppOpenAdAvailable() -> Bool {
        guard let ad = appOpenAd, let loadTime = loadTime else { return false }

        // Check if 4 hours (14,400 seconds) have passed
        let timeInterval = Date().timeIntervalSince(loadTime)
        return timeInterval < 14400
    }

    /// Shows the App Open ad if available
    func showAppOpenAdIfAvailable(scene: UIWindowScene) {
        // 1. Check conditions
        if isShowingAd {
            print("⚠️ An ad is already showing.")
            return
        }

        if !isAppOpenAdAvailable() {
            // Ad expired or not ready
            loadAppOpenAd()
            return
        }

        // 2. Find the top-most View Controller to present on
        guard let window = scene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return
        }

        // 3. Present the Ad
        if let ad = appOpenAd {
            isShowingAd = true
            ad.present(from: rootVC)
        }
    }

    // MARK: - FullScreenContentDelegate (Global Dismissal Logic)

    /// Called when ANY full-screen ad (Interstitial, Rewarded or App Open) is dismissed.
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // 🔥 Special Check for App Open Ad
        if ad is AppOpenAd {
            print("ℹ️ App Open Ad Dismissed")
            appOpenAd = nil
            isShowingAd = false
            loadAppOpenAd() // Pre-load the next one
            return // Exit early to avoid triggering other logic
        }

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

        // If App Open Ad failed
        if ad is AppOpenAd {
            appOpenAd = nil
            isShowingAd = false
            loadAppOpenAd()
            return
        }

        // Fail-safe: Ensure the user is not stuck. Run the navigation logic.
        onInterstitialDismiss?()
        onInterstitialDismiss = nil

        loadInterstitial()
        loadRewardedAd()
    }

    // MARK: - 5. Banner Ad Logic

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
