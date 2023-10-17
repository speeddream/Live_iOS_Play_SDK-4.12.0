//
//  HDSCardView.swift
//  AnimationTD
//
//  Created by David Zhao on 2022/3/25.
//

import UIKit
import SDWebImage

class HDSCardView: UIView {
    var disappearClosure: (()->())?
    
    private let disappearAnimationDuration: TimeInterval = 0.35

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(origin: CGPoint, verticalOffSet: CGFloat, viewModel: HDSCardViewModel, withAnimation: Bool = true, lifeDuration: TimeInterval = 2) {
        let aHeight:CGFloat = 60
        let aWidth: CGFloat = 300
        self.init(frame: CGRect(origin: origin, size: CGSize(width: aWidth, height: aHeight)))
        isUserInteractionEnabled = false
        
        if withAnimation == true {
            DispatchQueue.main.async {[weak self] in
                self?.moveDownDisappear(offSet: verticalOffSet, duration: 1.5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + lifeDuration) {[weak self] in
            guard let disappearClosure = self?.disappearClosure else {
                return
            }
            disappearClosure()
        }
        
                
        let roundStart = CALayer()
        roundStart.frame = CGRect(origin: .zero, size: CGSize(width: aHeight, height: aHeight))
        roundStart.backgroundColor = UIColor.orange.cgColor
        roundStart.cornerRadius = aHeight / 2
        layer.addSublayer(roundStart)
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.2, y: 0)
        gradient.endPoint = CGPoint(x: 0.9, y: 0)
        gradient.frame = CGRect(x: aHeight / 2, y: 0, width: aWidth - aHeight / 2, height: aHeight)
        gradient.colors = [UIColor.orange.withAlphaComponent(1).cgColor,
                           UIColor.orange.withAlphaComponent(0).cgColor]
        
        layer.addSublayer(gradient)
        
        let headIcon = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: aHeight * 0.9, height: aHeight * 0.9)))
        headIcon.backgroundColor = .systemOrange
        headIcon.center = CGPoint(x: aHeight / 2, y: aHeight / 2)
        headIcon.layer.cornerRadius = (aHeight - 5) / 2
        headIcon.clipsToBounds = true
        headIcon.setHeader(viewModel.headIconUrlStr)
        addSubview(headIcon)
     
        let nameLabel = UILabel(frame: CGRect(origin: CGPoint(x: aHeight, y: 5), size: CGSize(width: 100, height: 20)))
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.text = viewModel.donateName
        nameLabel.textColor = .white
        addSubview(nameLabel)
        
        let giftLabel = UILabel(frame: CGRect(x: aHeight, y: nameLabel.frame.origin.y + nameLabel.frame.height, width: 100, height: 30))
        giftLabel.textColor = .white
        giftLabel.textAlignment = .center
        giftLabel.font = UIFont.systemFont(ofSize: 18)
        giftLabel.text = "赠送了 \(viewModel.giftName)"
        addSubview(giftLabel)
        
        let giftIcon = SDAnimatedImageView(frame: CGRect(x: nameLabel.frame.origin.x + nameLabel.frame.width + 5, y: 0, width: aHeight, height: aHeight))
        giftIcon.layer.cornerRadius = aHeight / 2
        giftIcon.backgroundColor = .systemOrange
        giftIcon.clipsToBounds = true
        let urlStr = viewModel.giftIconUrlStr.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
        if let url = URL(string: urlStr ?? viewModel.giftIconUrlStr) {
            giftIcon.sd_setImage(with: url)
        }
        addSubview(giftIcon)
        
        let countLabel = UILabel(frame: CGRect(x: giftIcon.center.x + giftIcon.frame.width / 2 + 5, y: 0, width: aHeight * 2, height: aHeight))
        countLabel.backgroundColor = .clear
        countLabel.textColor = .systemOrange
        
        let attStr = NSMutableAttributedString(string: "✖︎", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 227/255, green: 75/255, blue: 37/255, alpha: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        attStr.append(NSAttributedString(string: " \(viewModel.giftCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 227/255, green: 75/255, blue: 37/255, alpha: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 38)]))
        
        countLabel.attributedText = attStr
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func moveDownDisappear(offSet: CGFloat, duration: TimeInterval) {
        let slidinAnimation = CABasicAnimation(keyPath: "position.x")
        slidinAnimation.fromValue = frame.origin.x + frame.width / 2
        slidinAnimation.toValue = frame.origin.x + frame.width * 1.5 + 10
        slidinAnimation.duration = disappearAnimationDuration
        slidinAnimation.fillMode = .forwards
        slidinAnimation.isRemovedOnCompletion = false
        slidinAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let downAnimation = CABasicAnimation(keyPath: "position.y")
        downAnimation.fromValue = frame.origin.y + frame.height / 2
        downAnimation.toValue = frame.origin.y + frame.height / 2 + offSet
        downAnimation.duration = duration
        downAnimation.beginTime = disappearAnimationDuration
        downAnimation.fillMode = .forwards
        downAnimation.isRemovedOnCompletion = false
        downAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let disAnimation = CABasicAnimation(keyPath: "opacity")
        disAnimation.fromValue = 1.0
        disAnimation.toValue = 0
        disAnimation.beginTime = duration + disappearAnimationDuration
        disAnimation.duration = disappearAnimationDuration
        
        let group = CAAnimationGroup()
        group.animations = [slidinAnimation, downAnimation, disAnimation]
        group.duration = duration + disappearAnimationDuration * 2
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        layer.add(group, forKey: "moveDown-disappear")
    }
    
    private func animateDown(offSet: CGFloat, duration: TimeInterval) {
        let downAnimation = CABasicAnimation(keyPath: "position.y")
        downAnimation.fromValue = frame.origin.y + frame.height / 2
        downAnimation.toValue = frame.origin.y + frame.height / 2 + offSet
        downAnimation.duration = duration
        downAnimation.fillMode = .forwards
        downAnimation.isRemovedOnCompletion = false
        layer.add(downAnimation, forKey: "position.y")
    }
    
    public func disappear(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "opacity")
    }
}
