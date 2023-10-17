//
//  HDSChooseOptionCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

class HDSChooseOptionCell: UITableViewCell {
    
    private lazy var iconImg: UIImageView = createIconImg()
    private lazy var textLb: UILabel = createTextLb()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.backgroundColor = "#FFFFFF".uicolor()
        contentView.addSubview(iconImg)
        iconImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(16.5)
            make.width.height.equalTo(17)
        }
        
        contentView.addSubview(textLb)
        textLb.snp.makeConstraints { make in
            make.left.equalTo(iconImg.snp.right).offset(10)
            make.top.equalToSuperview().offset(14.5)
            make.bottom.equalToSuperview().offset(-14.5)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?, _ optionModel: HDSQuestionnaireOption?) {
        if model?.type == "Checkbox" {
            // 多选
            if optionModel?.isSelect ?? false {
                iconImg.image = UIImage(named: "复选选中")
            } else {
                iconImg.image = UIImage(named: "复选未选")
            }
        } else {
            // 单选
            if optionModel?.isSelect ?? false {
                iconImg.image = UIImage(named: "单选选中")
            } else {
                iconImg.image = UIImage(named: "单选未选")
            }
        }
        textLb.text = optionModel?.label
    }
}

extension HDSChooseOptionCell {
    private func createIconImg() -> UIImageView {
        let iconImg = UIImageView()
        return iconImg
    }
    
    private func createTextLb() -> UILabel {
        let lb = UILabel()
        lb.textColor = "#333333".uicolor()
        lb.font = .systemFont(ofSize: 14)
        return lb
    }
}
