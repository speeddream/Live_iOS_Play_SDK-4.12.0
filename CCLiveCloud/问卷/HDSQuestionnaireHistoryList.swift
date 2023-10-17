//
//  HDSQuestionnaireHistoryList.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

class HDSQuestionnaireHistoryList: UIView {
    private lazy var topView: UIView = createTopView()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var closeBtn: UIButton = createCloseBtn()
    private lazy var tableView: UITableView = createTableView()
    private var gotoCallBack: GotoBtnCallBack?
    private var modelArr: [HDSQuestionnairePushQuery]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        backgroundColor = "#000000".uicolor(alpha: 0.1)
        addSubview(topView)
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(150)
            make.height.equalTo(40)
        }
        
        topView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        topView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
    }
    
    @objc private func closeBtnAction() {
        removeFromSuperview()
    }
    
    @objc func setModelArr(_ modelArr: [HDSQuestionnairePushQuery] , _ callBack: @escaping GotoBtnCallBack) {
        self.modelArr = modelArr
        gotoCallBack = callBack
        tableView.reloadData()
    }
    
}

extension HDSQuestionnaireHistoryList: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HDSQuestionnaireHistoryCell_ID") as? HDSQuestionnaireHistoryCell
        if cell == nil {
            cell = HDSQuestionnaireHistoryCell(style: .default, reuseIdentifier: "HDSQuestionnaireHistoryCell_ID")
            cell?.selectionStyle = .none
            cell?.gotoCallBack { [weak self] model in
                if let callBack = self?.gotoCallBack {
                    callBack(model)
                }
            }
        }
        if let model = modelArr?[indexPath.row] {
            cell?.setModel(model)
        }
        return cell ?? UITableViewCell()
    }
}

extension HDSQuestionnaireHistoryList {
    private func createTopView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        
        return view
    }
    
    private func createTitleLb() -> UILabel {
        let title = UILabel()
        title.textColor = "#333333".uicolor()
        title.font = UIFont.systemFont(ofSize: 15)
        title.textAlignment = .center
        return title
    }
    
    private func createCloseBtn() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "关闭"), for: .normal)
        btn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return btn
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0)
        tableView.backgroundColor = "#F4F4F4".uicolor()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 80
        return tableView
    }
}
