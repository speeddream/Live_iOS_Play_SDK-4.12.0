//
//  HDScardRankHeadView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/25.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDScardRankHeadView: UITableViewHeaderFooterView {
    private lazy var rankIndexLb: UILabel = createRankLb("排名")
    private lazy var nickNameLb: UILabel = createRankLb("昵称")
    private lazy var countLb: UILabel = createRankLb("邀请人数")
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.backgroundColor = .white
        contentView.addSubview(rankIndexLb)
        rankIndexLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(nickNameLb)
        nickNameLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(105)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(countLb)
        countLb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-69)
            make.centerY.equalToSuperview()
        }
        
    }

}

extension HDScardRankHeadView {
    private func createRankLb(_ text: String?) -> UILabel {
        let lable = UILabel()
        lable.text = text
        lable.textColor = "#999999".uicolor()
        lable.font = UIFont.systemFont(ofSize: 12)
        return lable
    }
}
