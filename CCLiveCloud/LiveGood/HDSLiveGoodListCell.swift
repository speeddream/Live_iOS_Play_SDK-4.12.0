//
//  HDSLiveGoodListCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/7/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSLiveStoreModule

protocol HDSLiveGoodListCellDelegate {
    func liveGoodListCellBuyAction(itemId: String)
    func liveGoodListCellBuyActionCallBackLink(link: String)
}

class HDSLiveGoodListCell: UITableViewCell {

    private lazy var bgView = createBgView()
    private lazy var shadowView = createShadowView()
    private lazy var imgView: HDSLiveGoodImageView = createImgView()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var subTitleLb: UILabel = createSubTitleLb()
    private lazy var curentMoneyLbBase: UILabel = createCurentMoneyLbBase()
    private lazy var curentMoneyLb: UILabel = createCurentMoneyLb()
    private lazy var oldMoneyLb: UILabel = createOldMoneyLb()
    private lazy var buyBtn: UIButton = createBuyBtn()
    
    private lazy var type1: UILabel = createTypeLabel()
    private lazy var type2: UILabel = createTypeLabel()
    private lazy var type3: UILabel = createTypeLabel()
    
    private var model: HDSSingleItemModel?
    var delegate: HDSLiveGoodListCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.addSubview(self.shadowView)
        shadowView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        contentView.addSubview(self.bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        bgView.addSubview(self.imgView)
        imgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(104)
        }
        
        bgView.addSubview(self.titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11)
            make.left.equalTo(imgView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(14)
        }
        
        bgView.addSubview(self.subTitleLb)
        subTitleLb.snp.makeConstraints { make in
            make.top.equalTo(titleLb.snp.bottom).offset(6)
            make.left.equalTo(imgView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-8)
        }
        
        bgView.addSubview(self.type1)
        type1.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(5)
            make.top.equalTo(subTitleLb.snp.bottom).offset(7)
            make.height.equalTo(17)
        }
        
        bgView.addSubview(self.type2)
        type2.snp.makeConstraints { make in
            make.left.equalTo(type1.snp.right).offset(5)
            make.top.equalTo(type1.snp.top)
            make.height.equalTo(17)
        }
        
        bgView.addSubview(self.type3)
        type3.snp.makeConstraints { make in
            make.left.equalTo(type2.snp.right).offset(5)
            make.top.equalTo(type1.snp.top)
            make.height.equalTo(17)
        }
        
        bgView.addSubview(self.curentMoneyLbBase)
        curentMoneyLbBase.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(5)
            make.bottom.equalTo(imgView.snp.bottom).offset(-1)
        }
        
        bgView.addSubview(self.curentMoneyLb)
        curentMoneyLb.snp.makeConstraints { make in
//            make.left.equalTo(imgView.snp.right).offset(5)
//            make.bottom.equalToSuperview().offset(-11.5)
            make.left.equalTo(curentMoneyLbBase.snp.right)
            make.bottom.equalTo(imgView.snp.bottom).offset(1)
        }
        
        bgView.addSubview(self.oldMoneyLb)
        oldMoneyLb.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(5)
            make.bottom.equalTo(curentMoneyLb.snp.top).offset(3)
        }
        
        bgView.addSubview(self.buyBtn)
        buyBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
//        layoutIfNeeded()
//        shadowView.layer.shadowColor = "#000000".uicolor(alpha: 0.2).cgColor
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        shadowView.layer.shadowOpacity = 1
//        shadowView.layer.shadowRadius = 8
    }
    
}

extension HDSLiveGoodListCell {
    func setupModel(model: HDSSingleItemModel?) {
        self.model = model
        
        titleLb.text = model?.title
        subTitleLb.text = model?.desc
        
        let oldM: Double = (model?.originPrice ?? 0) / 100;
        let oldMoney = String(format: "￥%.2f", oldM)
        let oldMoneyAttrString = NSMutableAttributedString(string: oldMoney)
        let oldAttr: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), .strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), .font: UIFont.systemFont(ofSize: 12)]
        oldMoneyAttrString.addAttributes(oldAttr, range: NSRange(location: 0, length: oldMoneyAttrString.length))

        oldMoneyLb.attributedText = oldMoneyAttrString
//
//
//        let currentMoneyAttrString = NSMutableAttributedString(string: "￥")
//        let attr: [NSAttributedString.Key : Any] = [.foregroundColor: "#FF842F".uicolor(), .font: UIFont.systemFont(ofSize: 12)]
//        currentMoneyAttrString.addAttributes(attr, range: NSRange(location: 0, length: currentMoneyAttrString.length))
//
//        let currentMoneyAttrString1 = NSMutableAttributedString(string: "\(model?.originPrice ?? 0)")
//        let attr1: [NSAttributedString.Key : Any] = [.foregroundColor: "#FF842F".uicolor(), .font: UIFont.systemFont(ofSize: 20)]
//        currentMoneyAttrString1.addAttributes(attr1, range: NSRange(location: 0, length: currentMoneyAttrString1.length))
//        currentMoneyAttrString.append(currentMoneyAttrString1)
//        curentMoneyLb.attributedText = currentMoneyAttrString
        
        let currentM: Double = (model?.currentPrice ?? 0) / 100;
        curentMoneyLb.text = String(format: "%.2f", currentM)
        print("🛒 -> oldMoney -> \(oldMoney) nowMoney -> \(currentM)")
        
        imgView.setupModel(model: model)
        var oneCount = model?.buttonTitle.count ?? 4
        if oneCount < 4 {
            oneCount = 4
        }
        buyBtn.snp.updateConstraints { make in
            make.width.equalTo(oneCount * 14 + 24)
        }
        
        buyBtn.setTitle(model?.buttonTitle ?? "立即购买", for: .normal)
        
        let linkType = model?.linkType
        if linkType == 1 {
            let linkArr = model?.platformLink as? [HDSSingleItemPlatformLinkModel] ?? [HDSSingleItemPlatformLinkModel]()
            for oneModel in linkArr {
                if oneModel.terminal == 1 {
                    buyBtn.isEnabled = false
                    buyBtn.setTitleColor("#AAAAAA".uicolor(), for: .normal)
                    let image = UIImage()
                    buyBtn.setBackgroundImage(image, for: .normal)
                } else if oneModel.terminal == 2 {
                    buyBtn.isEnabled = true
                    buyBtn.setTitleColor("#FFFFFF".uicolor(), for: .normal)
                    var image = UIImage(named: "按钮")
                    image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
                    buyBtn.setBackgroundImage(image, for: .normal)
                }
            }
        }
        
        let push = model?.push ?? false
        if push {
            bgView.backgroundColor = "#FF842F".uicolor(alpha: 0.08)
        } else {
            bgView.backgroundColor = "#FFFFFF".uicolor()
        }
        
        type1.isHidden = true
        type3.isHidden = true
        type2.isHidden = true
        
        if let tags = model?.tags {
            if tags.count > 0 {            
                var i = 0
                for string in tags {
                    if i == 0 {
                        type1.text = "  \(string)  "
                        type1.isHidden = false
                    }
                    
                    if i == 1 {
                        type2.text = "  \(string)  "
                        type2.isHidden = false
                    }
                    
                    if i == 2 {
                        type3.text = "  \(string)  "
                        type3.isHidden = false
                    }
                    i += 1
                }
            }
        }
        
        if model?.desc.count == 0 {
            type1.snp.updateConstraints { make in
                make.top.equalTo(subTitleLb.snp.bottom).offset(0);
            }
        } else {
            type1.snp.updateConstraints { make in
                make.top.equalTo(subTitleLb.snp.bottom).offset(7)
            }
        }
        
    }
}

extension HDSLiveGoodListCell {
    @objc private func createBuyAction() {
        if let delegate = delegate {
            
            let linkType = model?.linkType
            if linkType == 1 {
                let linkArr = model?.platformLink as? [HDSSingleItemPlatformLinkModel] ?? [HDSSingleItemPlatformLinkModel]()
                for oneModel in linkArr {
                    if oneModel.terminal == 2 {
                        delegate.liveGoodListCellBuyActionCallBackLink(link: oneModel.link)
                    }
                }
            } else {
                delegate.liveGoodListCellBuyAction(itemId: model?.id ?? "")
            }
        }
    }
}

extension HDSLiveGoodListCell {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = "#E9E9E9".uicolor().cgColor
        return view
    }
    
    private func createShadowView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        return view
    }
    
    private func createImgView() -> HDSLiveGoodImageView {
        let imgView = HDSLiveGoodImageView()
        
        return imgView
    }
    
    private func createTitleLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#333333".uicolor()
        label.font = .systemFont(ofSize: 14)
        return label
    }
    
    private func createSubTitleLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#999999".uicolor()
        label.font = .systemFont(ofSize: 12)
        return label
    }
    
    private func createTypeLabel() -> UILabel {
        let label = UILabel()
        label.textColor = "#FF842F".uicolor()
        label.font = .systemFont(ofSize: 11)
        label.backgroundColor = "#FF842F".uicolor(alpha: 0.14)
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        return label
    }
    
    private func createCurentMoneyLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#FF842F".uicolor()
        label.font = .systemFont(ofSize: 20)
        return label
    }
    
    private func createCurentMoneyLbBase() -> UILabel {
        let label = UILabel()
        label.textColor = "#FF842F".uicolor()
        label.font = .systemFont(ofSize: 12)
        label.text = "￥"
        return label
    }
    
    private func createOldMoneyLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#999999".uicolor()
        //label.font = .systemFont(ofSize: 12)
        return label
    }
    
    private func createBuyBtn() -> UIButton {
        let button = UIButton()
        button.setTitle("立即购买", for: .normal)
        button.setTitleColor("#FFFFFF".uicolor(), for: .normal)
        button.backgroundColor = "#EEEEEE".uicolor(alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        var image = UIImage(named: "按钮")
        image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(createBuyAction), for: .touchUpInside)
        return button
    }
}
