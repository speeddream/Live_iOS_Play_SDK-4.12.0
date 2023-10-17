//
//  HDSVoteHeadView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/30.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSVoteHeadView: UIView {
    
    private lazy var bgView: UIView = createBgView()
    private lazy var bannerImgView: UIImageView = createBannerImgView()
    private lazy var leftImgView: UIImageView = createLeftImgView()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var rightImgView: UIImageView = createRightImgView()
    private var shapeLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        
        addSubview(bannerImgView)
        bannerImgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(100)
        }
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.top.equalTo(bannerImgView.snp.bottom).offset(15)
        }
        
        bgView.addSubview(leftImgView)
        leftImgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(5)
            make.width.equalTo(29.5)
            make.height.equalTo(52)
        }
        
        bgView.addSubview(rightImgView)
        rightImgView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(40)
            make.height.equalTo(53)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalTo(rightImgView.snp.left)
            make.left.equalTo(leftImgView.snp.right).offset(9)
            make.height.greaterThanOrEqualTo(44)
        }
    }
    
    func updateFrameUI() {
        
        layoutIfNeeded()
        
        addShapeLayer()
    }
    
    func setModel(_ model: HDSVoteModel) {
        titleLb.text = model.title
        updateFrameUI()
        if model.themeColor != 1 {
            leftImgView.image = UIImage(named: "编组 6_1")
            rightImgView.image = UIImage(named: "右")
            titleLb.textColor = "#FFFFFF".uicolor()
            shapeLayer?.strokeColor = "#FDFF00".uicolor().cgColor
        }
        
        if model.showBanner == 1 {
            bannerImgView.isHidden = false
            bannerImgView.sd_setImage(with: URL(string: model.bannerUrl))
            bannerImgView.snp.makeConstraints { make in
                make.height.equalTo(120)
            }
        } else {
            bannerImgView.isHidden = true
            bannerImgView.snp.makeConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
}

extension HDSVoteHeadView {
    
    private func createBgView() -> UIView {
        let view = UIView()
        view.layer.borderColor = "#FF9502".uicolor().cgColor
        view.backgroundColor = UIColor.clear

        view.layer.masksToBounds = true
        
        return view
    }
    
    private func addShapeLayer() {
        shapeLayer = CAShapeLayer()
        shapeLayer?.strokeColor = "#FF9502".uicolor().cgColor
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.lineWidth = 4
        shapeLayer?.lineDashPattern = [NSNumber(value: 5),NSNumber(value: 5)]
        
        let path = UIBezierPath(roundedRect: bgView.bounds, cornerRadius: 3.5)
        shapeLayer?.path = path.cgPath
        shapeLayer?.frame = bgView.bounds
        guard let shapeLayer = shapeLayer else { return }
        bgView.layer.addSublayer(shapeLayer)
    }
    
    private func createLeftImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "编组 6")
        return imgView
    }
    
    private func createTitleLb() -> UILabel {
        let titleLb = UILabel()
//        titleLb.text = "这里是投票标题这里是投票标题"
        titleLb.font = UIFont.boldSystemFont(ofSize: 18)
        titleLb.numberOfLines = 0
        titleLb.textColor = "#000000".uicolor()
        return titleLb
    }
    
    private func createRightImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "形状")
        return imgView
    }
    
    private func createBannerImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .clear
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 3.5
        return imgView
    }
    
}
