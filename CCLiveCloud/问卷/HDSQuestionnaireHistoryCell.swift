//
//  HDSQuestionnaireHistoryCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

typealias GotoBtnCallBack = (_ model: HDSQuestionnairePushQuery)->()
class HDSQuestionnaireHistoryCell: UITableViewCell {

    private lazy var bgView: UIView = createBgView()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var timeLb: UILabel = createTimeLb()
    private lazy var gotoBtn: UIButton = createGotoBtn()
    private var gotoCallBack: GotoBtnCallBack?
    private var model: HDSQuestionnairePushQuery?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.backgroundColor = "#F4F4F4".uicolor()
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9.5)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(11.5)
            make.right.equalToSuperview().offset(-12)
        }
        
        bgView.addSubview(timeLb)
        timeLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(titleLb.snp.bottom).offset(15)
        }
        
        bgView.addSubview(gotoBtn)
        gotoBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLb.snp.bottom).offset(8)
            make.height.equalTo(32)
            make.width.equalTo(82)
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
    func gotoCallBack(_ callBack: @escaping GotoBtnCallBack) {
        gotoCallBack = callBack
    }
    
    func setModel(_ model: HDSQuestionnairePushQuery) {
        self.model = model
        titleLb.text = model.formName
        timeLb.text = model.formPushDate
        if model.existence == 1 {
            gotoBtn.backgroundColor = "#FF842F".uicolor(alpha: 0.8)
            gotoBtn.setTitle("已填写", for: .normal)
        } else {
            gotoBtn.setTitle("填写问卷", for: .normal)
            gotoBtn.backgroundColor = "#FF842F".uicolor()
        }
    }
    
    @objc private func gotoBtnAction() {
        if model?.existence == 1 {
            return
        }
        if let gotoCallBack = gotoCallBack {
            guard let model = model else { return }
            gotoCallBack(model)
        }
    }
}

extension HDSQuestionnaireHistoryCell {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }
    
    private func createTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.numberOfLines = 0
        titleLb.textColor = "#333333".uicolor()
        titleLb.font = UIFont.systemFont(ofSize: 14)
        return titleLb
    }
    
    private func createTimeLb() -> UILabel {
        let timeLb = UILabel()
        timeLb.textColor = "#333333".uicolor(alpha: 0.4)
        timeLb.font = UIFont.systemFont(ofSize: 12)
        return timeLb
    }
    
    private func createGotoBtn() -> UIButton {
        let btn = UIButton()
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(gotoBtnAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return btn
    }
}
