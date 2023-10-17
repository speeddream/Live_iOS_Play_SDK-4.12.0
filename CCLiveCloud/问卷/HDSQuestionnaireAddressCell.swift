//
//  HDSQuestionnaireAddressCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSQuestionnaireAddressCell: UITableViewCell {
    private lazy var leftView: HDSQuestionnaireDropDownView = createView("请选择省")
    private lazy var centerView: HDSQuestionnaireDropDownView = createView("请选择城市")
    private lazy var rightView: HDSQuestionnaireDropDownView = createView("请选择区/县")
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        let width = (UIScreen.main.bounds.size.width - 40 - 20) / 3
        
        addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(width)
        }
        
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right).offset(10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(width)
        }
        
        addSubview(rightView)
        rightView.snp.makeConstraints { make in
            make.left.equalTo(centerView.snp.right).offset(10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(width)
        }
    }
}

extension HDSQuestionnaireAddressCell {
    private func createView(_ placeholder: String) -> HDSQuestionnaireDropDownView {
        let view = HDSQuestionnaireDropDownView()
        view.placeholder(placeholder)
        return view
    }
}
