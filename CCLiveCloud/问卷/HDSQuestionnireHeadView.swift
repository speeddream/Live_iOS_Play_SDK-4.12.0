//
//  HDSQuestionnireHeadView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

class HDSQuestionnireHeadView: UITableViewHeaderFooterView {

    private lazy var mustIconImg: UIImageView = createMustIconImg()
    private lazy var titleLb: UILabel = createTitleLb()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.backgroundColor = "#FFFFFF".uicolor()
        contentView.addSubview(mustIconImg)
        mustIconImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(8)
            make.top.equalTo(15)
        }
        
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-15)
            make.top.equalTo(15)
        }
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?) {
        mustIconImg.isHidden = !(model?.required ?? false)
        
        let attStr = NSMutableAttributedString(string: model?.name ?? "", attributes: [NSAttributedString.Key.foregroundColor: "#333333".uicolor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        let substring = getSubstring(model?.type ?? "")
        if substring.count > 0 {
            attStr.append(NSAttributedString(string: substring, attributes: [NSAttributedString.Key.foregroundColor: "#999999".uicolor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        }
        titleLb.attributedText = attStr
    }
    
    private func getSubstring(_ type: String?) -> String {
        if type == "Checkbox" {
            return "(多选)"
        }
        if type == "Radio" || type == "sexRadio" {
            return "(单选)"
        }
        return ""
    }
}

extension HDSQuestionnireHeadView {
    private func createMustIconImg() -> UIImageView {
        let img = UIImageView()
        img.image = UIImage(named: "")
        img.backgroundColor = .red
        return img
    }
    
    private func createTitleLb() -> UILabel {
        let lb = UILabel()
        lb.textColor = "#333333".uicolor()
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }
}
