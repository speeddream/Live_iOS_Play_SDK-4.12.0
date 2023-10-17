//
//  HDSQuesionnaireQACell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

typealias HDSQACellCallBack = ()->()

class HDSQuesionnaireQACell: UITableViewCell {

    private lazy var bgView: UIView = createBgView()
    private lazy var textView: UITextView = createTextView()
    private lazy var placeholdLb: UILabel = createPlaceholdLb()
    private lazy var countLb: UILabel = createCountLb()
    private var model: HDSQuestionnaireStyleModel?
    var qaCallBack: HDSQACellCallBack?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.backgroundColor = "#FFFFFF".uicolor()
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(100)
        }
        
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(6.5)
            make.bottom.equalToSuperview().offset(-20)
//            make.height.equalTo(70)
        }
        
        bgView.addSubview(placeholdLb)
        placeholdLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(6.5)
        }
        
        bgView.addSubview(countLb)
        countLb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?) {
        self.model = model
        placeholdLb.text = model?.placeholder
        placeholdLb.isHidden = (model?.contentText.count ?? 0) > 0
        textView.text = model?.contentText
        let inputCount = model?.contentText.count ?? 0
//        let count = 200 - inputCount
        countLb.text = "\(inputCount)/200"
    }
}

extension HDSQuesionnaireQACell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 200 && text.count != 0 {
            // 提示
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let callBack = qaCallBack {
            callBack()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text?.count ?? 0
        if count > 200 {
            // 不能大于200
            let text = textView.text ?? ""
            textView.text = text.substring(to: 200)
        }
        model?.contentText = textView.text ?? ""
        let count1 = model?.contentText.count ?? 0
        countLb.text = "\(count1)/200"
        
        placeholdLb.isHidden = (model?.contentText.count ?? 0) > 0
    }
}

extension HDSQuesionnaireQACell {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#F5F5F5".uicolor()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }
    
    private func createTextView() -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = "#333333".uicolor()
        textView.backgroundColor = "#F5F5F5".uicolor()
        textView.delegate = self
        return textView
    }
    
    private func createPlaceholdLb() -> UILabel {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.text = "请输入..."
        lb.textColor = "#999999".uicolor()
        return lb
    }
    
    private func createCountLb() -> UILabel {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.text = "0/200"
        lb.textColor = "#999999".uicolor()
        lb.textAlignment = .right
        return lb
    }
}
