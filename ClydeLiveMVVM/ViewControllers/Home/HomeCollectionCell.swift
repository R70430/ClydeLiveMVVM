//
//  HomesStreamerCollectionVCell.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//
import Lottie
import UIKit

class HomesStreamerCollectionVCell: UICollectionViewCell {
//MARK: - Variable
    //AnimationView
    @IBOutlet weak var musicAnimationView: AnimationView!
    //Button
    @IBOutlet weak var numButton: UIButton!
    //ImageView
    @IBOutlet weak var streamerImageView: UIImageView!
    //Label
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    
//MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        print("有進來")
        musicAnimationView.contentMode = .scaleAspectFit
        musicAnimationView.loopMode = .loop
        musicAnimationView.animationSpeed = 1
        musicAnimationView.play()
    }
}
