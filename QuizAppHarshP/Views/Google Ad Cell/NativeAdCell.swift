 
//
//  NativeAdCell.swift
//  QuizAppHarshP
//
//  Created by Harsh on 27/01/26.
//

import UIKit
import GoogleMobileAds

/// **NativeAdCell**
/// A custom programmatic cell to display Google Native Ads in a TableView.
/// This is separated into its own file for cleaner code structure.
class NativeAdCell: UITableViewCell {
    
    // MARK: - UI Components
    // The main container view required by AdMob
    let adView = NativeAdView()
    
    // Subviews for ad content
    let headlineLabel = UILabel()
    let callToActionButton = UIButton()
    let iconImageView = UIImageView()
    let adLabel = UILabel() // Small "Ad" badge to comply with policy
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAdUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupAdUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        // Add AdView to Content View
        contentView.addSubview(adView)
        
        // Disable autoresizing mask for constraints
        adView.translatesAutoresizingMaskIntoConstraints = false
        [iconImageView, headlineLabel, callToActionButton, adLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview($0)
        }
        
        // 1. Configure Main Ad View (Card Style)
        adView.backgroundColor = .white
        adView.layer.cornerRadius = 12
        adView.layer.shadowColor = UIColor.black.cgColor
        adView.layer.shadowOpacity = 0.1
        adView.layer.shadowOffset = CGSize(width: 0, height: 2)
        adView.layer.shadowRadius = 4
        
        // 2. Configure Subviews
        
        // Icon
        iconImageView.backgroundColor = .systemGray6
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        
        // Headline
        headlineLabel.font = .boldSystemFont(ofSize: 15)
        headlineLabel.numberOfLines = 2
        headlineLabel.textColor = .black
        
        // CTA Button
        callToActionButton.backgroundColor = .systemBlue
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        callToActionButton.layer.cornerRadius = 6
        callToActionButton.isUserInteractionEnabled = false // Important: AdView handles the click
        
        // "Ad" Badge
        adLabel.text = "Ad"
        adLabel.font = .systemFont(ofSize: 10, weight: .bold)
        adLabel.textColor = .white
        adLabel.backgroundColor = .orange
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 2
        adLabel.clipsToBounds = true
        
        // MARK: - Constraints
        NSLayoutConstraint.activate([
            // Pin AdView to Cell Content (with padding)
            // This ensures it stays inside the 120 height limit
            adView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            adView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            adView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            adView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Icon: Top Left
            iconImageView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 45),
            iconImageView.heightAnchor.constraint(equalToConstant: 45),
            
            // Headline: Right of Icon
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            headlineLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            headlineLabel.bottomAnchor.constraint(lessThanOrEqualTo: callToActionButton.topAnchor, constant: -5),
            
            // CTA Button: Bottom Right
            callToActionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            callToActionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
            callToActionButton.heightAnchor.constraint(equalToConstant: 34),
            callToActionButton.widthAnchor.constraint(equalToConstant: 100),
            
            // Ad Badge: Below Icon
            adLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            adLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6),
            adLabel.widthAnchor.constraint(equalToConstant: 24),
            adLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        // MARK: - Bind Views to AdMob
        // This is critical for the ad to work properly
        adView.headlineView = headlineLabel
        adView.callToActionView = callToActionButton
        adView.iconView = iconImageView
    }
    
    // MARK: - Configuration
    func configure(with ad: NativeAd) {
        // Populate Data
        headlineLabel.text = ad.headline
        callToActionButton.setTitle(ad.callToAction, for: .normal)
        iconImageView.image = ad.icon?.image
        
        // Register the ad object
        adView.nativeAd = ad
    }
}
