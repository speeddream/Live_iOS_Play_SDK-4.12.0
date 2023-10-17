//
//  HDSQuestionnaireDropDownView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSQuestionnaireDropDownView: UIView {
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var iconImg: UIImageView = createIconImg()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        layer.cornerRadius = 2
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = "#DDDDDD".uicolor().cgColor
        
        addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-18)
        }
        
        addSubview(iconImg)
        iconImg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(7)
        }
    }
    
    func placeholder(_ placeholder: String?) {
        titleLb.textColor = "#999999".uicolor()
        titleLb.text = placeholder
    }
    
    func text(_ text: String?) {
        titleLb.textColor = "#333333".uicolor()
        titleLb.text = text
    }
}

extension HDSQuestionnaireDropDownView {
    private func createTitleLb() -> UILabel {
        let lb = UILabel()
        lb.textColor = "#999999".uicolor()
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }
    
    private func createIconImg() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "三角形")
        return imgView
    }
}
