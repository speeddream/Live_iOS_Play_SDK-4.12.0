//
//  HDSCustomBaseAnimationImageView.swift
//  InteractionUIKit
//
//  Created by David Zhao on 2022/3/29.
//

import UIKit
import SDWebImage

class HDSCustomBaseAnimationImageView: SDAnimatedImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
