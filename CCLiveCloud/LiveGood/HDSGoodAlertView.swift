//
//  HDSGoodAlertView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/7/18.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSLiveStoreModule
import SDWebImage

@objc protocol HDSGoodAlertViewDelegate {
    func goodAlertViewCloseAction()
    func goodAlertViewBuyTapAction()
}

class HDSGoodAlertView: UIView {

    private lazy var contentView: UIView = createContentView()
    private lazy var imageView: UIImageView = createImageView()
    private lazy var liveStatusBgView: UIView = createLiveStatusBgView()
    private lazy var liveStatusView: UIView = createLiveStatusView()
    private lazy var liveStatusLb: UILabel = createLiveStatusLb()
    private lazy var closeBtn: UIButton = createCloseBtn()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var oldMoney: UILabel = createOldMoneyLb()
    private lazy var buyBgView: UIView = createBuyView()
    private lazy var moneyLb: UILabel = createMoneyLb()
    private lazy var buyImgView: UIImageView = createBuyImgView()
    private var model: HDSPushItemModel?
    var delegate: HDSGoodAlertViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        addSubview(self.contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(self.imageView)
        imageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(115)
        }
        
        imageView.addSubview(self.liveStatusBgView)
        liveStatusBgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(57)
            make.height.equalTo(20)
        }
        
        liveStatusBgView.addSubview(self.liveStatusView)
        liveStatusView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(5)
        }
        
        liveStatusBgView.addSubview(self.liveStatusLb)
        liveStatusLb.snp.makeConstraints { make in
            make.left.equalTo(liveStatusView.snp.right).offset(5.5)
            make.centerY.equalToSuperview()
        }
        
        addSubview(self.closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(5)
            make.height.width.equalTo(24)
        }
        
        contentView.addSubview(self.titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(self.oldMoney)
        oldMoney.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalTo(titleLb.snp.bottom).offset(6)
        }
        
        contentView.addSubview(self.buyBgView)
        buyBgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(24)
        }
        
        buyBgView.addSubview(self.buyImgView)
        buyImgView.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(37)
        }
        
        buyBgView.addSubview(self.moneyLb)
        moneyLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.right.equalTo(buyImgView.snp.left).offset(-4.5)
        }
        
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }
}

extension HDSGoodAlertView {
    @objc func setupModel(model: HDSPushItemModel?) {
        self.model = model
        
        titleLb.text = model?.title
        
        let oldM: Double = (model?.originPrice ?? 0) / 100;
        let oldMon = String(format: "￥%.2f", oldM)
        let oldMoneyAttrString = NSMutableAttributedString(string: oldMon)
        let oldAttr: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), .strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)]
        oldMoneyAttrString.addAttributes(oldAttr, range: NSRange(location: 0, length: oldMoneyAttrString.length))
        
        oldMoney.attributedText = oldMoneyAttrString
        
        let currentM: Double = (model?.currentPrice ?? 0) / 100;
        let currentMon = String(format: "￥%.2f", currentM)
        let currentMoneyAttrString = NSMutableAttributedString(string: currentMon)
        let attr: [NSAttributedString.Key : Any] = [.foregroundColor: "#FFFFFF".uicolor(), .font: UIFont.systemFont(ofSize: 14)]
        currentMoneyAttrString.addAttributes(attr, range: NSRange(location: 0, length: currentMoneyAttrString.length))
        
        moneyLb.attributedText = currentMoneyAttrString
        
        imageView.sd_setImage(with: URL(string: model?.cover ?? ""), placeholderImage: UIImage(named: "商品占位图"), options: .retryFailed, context: nil)
        
        layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: liveStatusBgView.bounds, byRoundingCorners: .bottomRight, cornerRadii: CGSize(width: 20, height: 20))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = liveStatusBgView.bounds
        shapeLayer.path = maskPath.cgPath
        liveStatusBgView.layer.mask = shapeLayer
    }
    
    @objc func setupDelegate(delegate: HDSGoodAlertViewDelegate?) {
        self.delegate = delegate;
    }
}

extension HDSGoodAlertView {
    @objc private func buyTapAction() {
        print("==buyTapAction===")
        if let delegate = delegate {
            delegate.goodAlertViewBuyTapAction()
        }
    }
    
    @objc private func closeAction() {
        print("==closeAction===")
        if let delegate = delegate {
            delegate.goodAlertViewCloseAction()
        }
    }
}

extension HDSGoodAlertView {
    private func createContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }
    
    private func createImageView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 3
        //imgView.backgroundColor = UIColor.cyan
        return imgView
    }
    
    private func createLiveStatusBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#242424".uicolor(alpha: 0.4)
        return view
    }
    
    private func createLiveStatusView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#F55757".uicolor()
        view.layer.cornerRadius = 2.5
        view.layer.masksToBounds = true
        return view
    }
    
    private func createLiveStatusLb() -> UILabel {
        let label = UILabel()
        label.text = "讲解中"
        label.font = .systemFont(ofSize: 11)
        label.textColor = "#FFFFFF".uicolor()
        return label
    }
 
    private func createCloseBtn() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.backgroundColor = "#FFFFFF".uicolor()
        button.layer.borderWidth = 1
        button.layer.borderColor = "#E8E8E8".uicolor().cgColor
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }
    
    private func createTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.textColor = "#333333".uicolor()
        titleLb.font = .boldSystemFont(ofSize: 11)
        titleLb.text = "这是商品的名称啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        return titleLb
    }
    
    private func createOldMoneyLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#999999".uicolor()
        label.font = .systemFont(ofSize: 12)
        label.text = "#888888"
        return label
    }
    
    private func createBuyView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FF6E0A".uicolor()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buyTapAction))
        view.addGestureRecognizer(tap)
        return view
    }
    
    private func createMoneyLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#FFFFFF".uicolor()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "#888888"
        return label
    }
    
    private func createBuyImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "抢购按钮")
        return imgView
    }
    
}
