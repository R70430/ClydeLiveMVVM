//
//  HomesStreamerCollectionVCell.swift
//  ClydeLiveMVVM
//
//  Created by Class on 2022/4/15.
//
import Lottie
import UIKit

class HomesStreamerCollectionVCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: CERoundLabel!
    @IBOutlet weak var streamerImageView: CECircleImageView!
    
    @IBOutlet weak var numButton: CERoundButton!
    
    
    @IBOutlet weak var firstTagLabel: UILabel!
    
    @IBOutlet weak var nameLabel: CERoundLabel!
    
    @IBOutlet weak var countryLabel: CERoundLabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var musicAnimationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("有進來")
        musicAnimationView.contentMode = .scaleAspectFit
        musicAnimationView.loopMode = .loop
        musicAnimationView.animationSpeed = 1
        musicAnimationView.play()
    }
}
