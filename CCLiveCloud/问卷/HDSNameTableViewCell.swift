//
//  HDSNameTableViewCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

typealias HDSNameCellCallBack = ()->()

class HDSNameTableViewCell: UITableViewCell {

    private lazy var bgView: UIView = createBgView()
    private lazy var textField: UITextField = createTextField()
    private lazy var countLb: UILabel = createCountLb()
    private var model: HDSQuestionnaireStyleModel?
    var nameCallBack: HDSNameCellCallBack?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(50)
        }
        
        bgView.addSubview(countLb)
        countLb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
        
        bgView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(countLb.snp.left).offset(-5)
        }
        
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?) {
        self.model = model
        if model?.type == "NameInput" {
            countLb.isHidden = false
        } else {
            countLb.isHidden = true
        }
//        else if model?.type == "PositionInput" {
//            textField.placeholder = "输入职务"
//        } else if model?.type == "EmailInput" {
//            textField.placeholder = "输入邮箱"
//        } else
        if model?.type == "Timepicker" || model?.type == "RegionInput" {
            textField.isUserInteractionEnabled = false
        } else {
            textField.isUserInteractionEnabled = true
        }
        textField.placeholder = model?.placeholder
        textField.text = model?.contentText
        let count = model?.contentText.count ?? 0
        countLb.text = "\(count)/50"
    }
}

extension HDSNameTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if model?.type != "NameInput" || model?.type == "RegionInput" {
            return true
        }
        let count = textField.text?.count ?? 0
        if count > 50 && string.count != 0 {
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let nameCallBack = nameCallBack {
            nameCallBack()
        }
        return true
    }
    
    @objc private func textFildChange(_ textFiled: UITextField) {
        if model?.type != "NameInput" || model?.type == "RegionInput" {
            model?.contentText = textField.text ?? ""
            return
        }
        substringTextfiled(textField)
    }
    
    private func substringTextfiled(_ textField: UITextField) {
        let count = textField.text?.count ?? 0
        if count > 50 {
            // 不能大于50
            let text = textField.text ?? ""
            textField.text = text.substring(to: 50)
        }
        model?.contentText = textField.text ?? ""
        let count1 = model?.contentText.count ?? 0
        countLb.text = "\(count1)/50"
    }
}

extension HDSNameTableViewCell {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#F5F5F5".uicolor()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.placeholder = "输入姓名"
        textField.textColor = "#999999".uicolor()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFildChange(_:)), for: .editingChanged)
        return textField
    }
    
    private func createCountLb() -> UILabel {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.text = "0/50"
        lb.textColor = "#999999".uicolor()
        lb.textAlignment = .right
        return lb
    }
}
