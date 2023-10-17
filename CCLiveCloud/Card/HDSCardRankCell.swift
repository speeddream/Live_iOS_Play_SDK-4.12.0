//
//  HDSCardRankCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/25.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSCardRankCell: UITableViewCell {
    private lazy var lineView: UIView = createLineView()
    private lazy var rankIconImg: UIImageView = createRankIcon()
    private lazy var rankIndexLb: UILabel = createRankIndex()
    private lazy var userIconImg: UIImageView = createUserIcon()
    private lazy var userNameLb: UILabel = createUserName()
    private lazy var detailTitleLb: UILabel = createDetailTitleLb()
    private lazy var mySelfIcon: UIImageView = createMySelfIcon()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(mySelfIcon)
        mySelfIcon.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        contentView.addSubview(rankIconImg)
        rankIconImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }
        
        contentView.addSubview(rankIndexLb)
        rankIndexLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }
        
        contentView.addSubview(userIconImg)
        userIconImg.snp.makeConstraints { make in
            make.left.equalTo(rankIconImg.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        contentView.addSubview(userNameLb)
        userNameLb.snp.makeConstraints { make in
            make.left.equalTo(userIconImg.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(98)
        }
        
        contentView.addSubview(detailTitleLb)
        detailTitleLb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func setModel(_ model: HDSInvitationCardRankModel?, _ index: Int) {
        
        if index <= 2 {
            rankIndexLb.isHidden = true
            rankIconImg.isHidden = false
            if index == 0 {
                rankIconImg.image = UIImage(named: "redPacket_gold")
            } else if index == 1 {
                rankIconImg.image = UIImage(named: "redPacket_silver")
            } else {
                rankIconImg.image = UIImage(named: "redPacket_bronze")
            }
        } else {
            rankIndexLb.isHidden = false
            rankIconImg.isHidden = true
            rankIndexLb.text = "\(index + 1)"
        }
        
        if model?.mySelf == true {
            mySelfIcon.isHidden = false
            rankIndexLb.textColor = "#FF9502".uicolor()
        } else {
            mySelfIcon.isHidden = true
            rankIndexLb.textColor = "#999999".uicolor()
        }
        
        userIconImg.sd_setImage(with: URL(string: model?.fromHeadUrl ?? ""), placeholderImage: UIImage(named: "默认头像"), options: .retryFailed, completed: nil)
        
        userNameLb.text = model?.fromUsername
        
        let attStr1 = NSMutableAttributedString(string: "邀请 ", attributes: [NSAttributedString.Key.foregroundColor: "#4A4A4A".uicolor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        let attStr2 = NSMutableAttributedString(string: "\(model?.count ?? 0)", attributes: [NSAttributedString.Key.foregroundColor: "#FF9502".uicolor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        let attStr3 = NSMutableAttributedString(string: " 位好友", attributes: [NSAttributedString.Key.foregroundColor: "#4A4A4A".uicolor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attStr1.append(attStr2)
        attStr1.append(attStr3)
        
        detailTitleLb.attributedText = attStr1
    }

}

extension HDSCardRankCell {
    private func createLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#E5E5E5".uicolor()
        return view
    }
    private func createRankIcon() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    private func createUserIcon() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "默认头像")
        return imgView
    }
    
    private func createUserName() -> UILabel {
        let label = UILabel()
        label.textColor = "#333333".uicolor()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    private func createDetailTitleLb() -> UILabel {
        let label = UILabel()
        return label
    }
    
    private func createRankIndex() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }
    
    private func createMySelfIcon() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "我标签")
        return imgView
    }
}
