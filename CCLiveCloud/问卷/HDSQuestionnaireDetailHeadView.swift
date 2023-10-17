//
//  HDSQuestionnaireDetailHeadView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

class HDSQuestionnaireDetailHeadView: UIView {
//    private lazy var topImgView: UIImageView = createTopImg()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var detailTitleLb: UILabel = createDetailTitleLb()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
//        addSubview(topImgView)
//        topImgView.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.height.equalTo(211)
//        }
        
        addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        addSubview(detailTitleLb)
        detailTitleLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLb.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    func setModel(_ model: HDSQuestionnaireQueryDetail) {
        titleLb.text = model.formName
        let att = try? NSAttributedString(data: model.formDescribe.data(using: .unicode) ?? Data(), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        detailTitleLb.attributedText = att
    }
    
    
}

extension HDSQuestionnaireDetailHeadView {
//    private func createTopImg() -> UIImageView {
//        let imgView = UIImageView()
//        imgView.contentMode = .scaleToFill
//        imgView.layer.masksToBounds = true
//        return imgView
//    }
    
    private func createTitleLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#333333".uicolor()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }
    
    private func createDetailTitleLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#333333".uicolor()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }
}
