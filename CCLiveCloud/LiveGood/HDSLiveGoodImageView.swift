//
//  HDSLiveGoodImageView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/7/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSLiveStoreModule
import SDWebImage

class HDSLiveGoodImageView: UIView {

    private lazy var imgView: UIImageView = createImgView()
    private lazy var topTitleLb: UILabel = createTopTitleLb()
    private lazy var bottomView: UIView = createBottomView()
    private lazy var giftImgView: UIImageView = createGiftImgView()
    private lazy var tipsLb: UILabel = createTipsLb()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        addSubview(self.imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imgView.addSubview(self.topTitleLb)
        topTitleLb.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        imgView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(25)
        }
        
        bottomView.addSubview(giftImgView)
        giftImgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(13)
            make.height.equalTo(12)
        }
        
        bottomView.addSubview(tipsLb)
        tipsLb.snp.makeConstraints { make in
            make.left.equalTo(giftImgView.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
    }
}

extension HDSLiveGoodImageView {
    func setupModel(model: HDSSingleItemModel?) {
        let score = model?.score ?? 0
        topTitleLb.text = "\(score)   "
        topTitleLb.isHidden = score == 0
        layoutIfNeeded()
        
        let maskPath = UIBezierPath(roundedRect: topTitleLb.bounds, byRoundingCorners: .bottomRight, cornerRadii: CGSize(width: 20, height: 20))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = topTitleLb.bounds
        shapeLayer.path = maskPath.cgPath
        topTitleLb.layer.mask = shapeLayer
        
        
        let push = model?.push
        if push ?? false {
            giftImgView.startAnimating()
        } else {
            giftImgView.stopAnimating()
        }
        bottomView.isHidden = push == false
        
        imgView.sd_setImage(with: URL(string: model?.cover ?? ""), placeholderImage: UIImage(named: "商品占位图"), options: .retryFailed, context: nil)
    }
}

extension HDSLiveGoodImageView {
    private func createImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 6
        imgView.layer.masksToBounds = true
        return imgView
    }
    
    private func createTopTitleLb() -> UILabel {
        let label = UILabel()
        label.backgroundColor = "#242424".uicolor(alpha: 0.4)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = "#FFFFFF".uicolor()
        return label
    }
    
    private func createBottomView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FF842F".uicolor(alpha: 0.8)
        return view
    }
    
    private func createGiftImgView() -> UIImageView {
        let imgView = UIImageView()
        //imgView.backgroundColor = UIColor.red
        var imageArr:[UIImage] = []
        for i in 0..<11 {
            let oneName = "jiangji_\(i)"
            guard let oneImage = UIImage(named: oneName) else { return imgView }
            imageArr.append(oneImage)
        }
        imgView.animationImages = imageArr
        imgView.startAnimating()
        return imgView
    }
    
    private func createTipsLb() -> UILabel {
        let tipLabel = UILabel()
        tipLabel.text = "讲解中"
        tipLabel.textColor = "#FFFFFF".uicolor()
        tipLabel.font = .systemFont(ofSize: 13)
        return tipLabel
    }
}
