//
//  GoogleBannerAdManager.swift
//  QuizAppHarshP
//
//  Created by My Mac Mini on 13/02/24.
//
 
import UIKit
import GoogleMobileAds

class GoogleBannerAdManager: NSObject, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    var adUnitID: String = "YOUR_AD_UNIT_ID_HERE"
    weak var presentingView: UIView?
    
    init(presentingView: UIView) {
        super.init()
        self.presentingView = presentingView
        let adSize = GADAdSizeFromCGSize(CGSize(width: presentingView.bounds.width, height: presentingView.bounds.height))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootViewController
            }
        } else {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                bannerView.rootViewController = rootViewController
            }
        }
        bannerView.delegate = self
    }
    
    func loadAd() {
        bannerView.load(GADRequest())
    }
    
    func addBannerToView() {
        presentingView?.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bottomAnchor.constraint(equalTo: presentingView!.bottomAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: presentingView!.centerXAnchor).isActive = true
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Handle banner ad loaded
        print(#function)
        addBannerToView()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        // Handle banner ad failed to load
        print(#function)
    }
    
   
    
}
