//
//  HDSQuestionnairePhoneNumCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

typealias HDSPhoneCellCallBack = ()->()

class HDSQuestionnairePhoneNumCell: UITableViewCell {
    
    private lazy var phoneNumBgView: UIView = createView()
    private lazy var phoneNumTextFiled: UITextField = createPhoneNumTextFiled()
    var phoneCallBack: HDSPhoneCellCallBack?
    private var model: HDSQuestionnaireStyleModel?
//    private lazy var codeBgView: UIView = createView()
//    private lazy var codeTextFiled: UITextField = createCodeTextFiled()
//    private lazy var getCodeBtn: UIButton = createGetCodeBtn()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.backgroundColor = "#FFFFFF".uicolor()
        contentView.addSubview(phoneNumBgView)
        phoneNumBgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        phoneNumBgView.addSubview(phoneNumTextFiled)
        phoneNumTextFiled.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
//        contentView.addSubview(getCodeBtn)
//        getCodeBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-20)
//            make.top.equalTo(phoneNumBgView.snp.bottom).offset(10)
//            make.height.equalTo(50)
//            make.width.equalTo(120)
//        }
//
//        contentView.addSubview(codeBgView)
//        codeBgView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(20)
//            make.top.equalTo(phoneNumBgView.snp.bottom).offset(10)
//            make.right.equalTo(getCodeBtn.snp.left).offset(-10)
//            make.height.equalTo(50)
//            make.bottom.equalToSuperview().offset(-15)
//        }
//
//        codeBgView.addSubview(codeTextFiled)
//        codeTextFiled.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(10)
//            make.centerY.equalToSuperview()
//            make.right.equalToSuperview().offset(-10)
//        }
        
        
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?) {
        self.model = model
        phoneNumTextFiled.placeholder = model?.placeholder
        phoneNumTextFiled.text = model?.contentText
//        codeTextFiled.text = model?.codeText
        
    }
    
//    @objc private func btnAction() {
//
//    }
}

extension HDSQuestionnairePhoneNumCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let callBack = phoneCallBack {
            callBack()
        }
        return true
    }
    
    @objc private func textFildChange(_ textFiled: UITextField) {
        
        substringTextfiled(phoneNumTextFiled)
    }
    
    private func substringTextfiled(_ textField: UITextField) {
        let count = textField.text?.count ?? 0
        if count > 11 {
            // 不能大于11
            let text = textField.text ?? ""
            textField.text = text.substring(to: 11)
        }
        model?.contentText = textField.text ?? ""
    }
}

extension HDSQuestionnairePhoneNumCell {
    private func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#F5F5F5".uicolor()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }
    
    private func createPhoneNumTextFiled() -> UITextField {
        let textFiled = UITextField()
        textFiled.backgroundColor = "#F5F5F5".uicolor()
        textFiled.placeholder = "输入手机号"
        textFiled.keyboardType = .numberPad
        textFiled.delegate = self
        textFiled.addTarget(self, action: #selector(textFildChange(_:)), for: .editingChanged)
        return textFiled
    }
    
//    private func createCodeTextFiled() -> UITextField {
//        let textFiled = UITextField()
//        textFiled.backgroundColor = "#F5F5F5".uicolor()
//        textFiled.placeholder = "输入验证码"
//        textFiled.keyboardType = .numberPad
//        return textFiled
//    }
//
//    private func createGetCodeBtn() -> UIButton {
//        let btn = UIButton()
//        btn.setTitle("获取验证码", for: .normal)
//        btn.backgroundColor = "#FF9502".uicolor()
//        btn.layer.cornerRadius = 2
//        btn.layer.masksToBounds = true
//        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
//        return btn
//    }
}

