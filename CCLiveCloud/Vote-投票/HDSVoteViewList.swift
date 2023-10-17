//
//  HDSVoteView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

typealias HDSCellListSelectBlock = (_ model: HDSVoteModel)->()

class HDSVoteViewList: UIView {
    private lazy var bgView: UIView = crateBgView()
    private lazy var closeTopBtn: UIButton = crateColseTopBtn()
    private lazy var backBtn: UIButton = getBackButton()
    private lazy var closeBtn: UIButton = getCloseButton()
    private lazy var titleLb: UILabel = getTitleLb()
    private lazy var tableView: UITableView = getTableView()
    private var listModel: [HDSVoteModel]?
    private var callBlock: HDSCellListSelectBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        self.backgroundColor = "#000000".uicolor(alpha: 0.5)
        
        addSubview(closeTopBtn)
        closeTopBtn.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(closeTopBtn.snp.bottom)
        }
        
        bgView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(15)
            make.width.height.equalTo(20)
        }
        
        bgView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(20)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
        }
        
        bgView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(titleLb.snp.bottom).offset(7.5)
        }
        
    }
    
    @objc func updateModelArr(_ modelList: Array<HDSVoteModel>) {
        listModel = modelList
        tableView.reloadData()
        layoutIfNeeded()
        bgView.layer.mask = HDS_ConfigRectCorner(view: bgView, corner: [.topLeft, .topRight], radii: CGSize(width: 12, height: 12))
    }
    
    @objc func didSelectAction(_ block:@escaping HDSCellListSelectBlock) {
        callBlock = block
    }
    
}

extension HDSVoteViewList: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HDSVoteListTableViewCell_ID") as? HDSVoteListTableViewCell
        if cell == nil {
            cell = HDSVoteListTableViewCell(style: .default, reuseIdentifier: "HDSVoteListTableViewCell_ID")
            cell?.selectionStyle = .none
        }
        let model = listModel?[indexPath.row]
        if let model = model {
            cell?.setModel(model)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let block = callBlock else { return }
        let model = listModel?[indexPath.row]
        if let model = model {
            block(model)
        }
    }
}

/// 点击事件
extension HDSVoteViewList {
    @objc private func backAction() {
        removeUI()
    }
    
    @objc private func closeAction() {
        removeUI()
    }
    
    @objc private func crateColseTopBtnAction() {
        removeUI()
    }
    
    private func removeUI() {
        self.removeFromSuperview()
        self.isHidden = true
    }
}

/// 生成view
extension HDSVoteViewList {
    private func getBackButton() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "返回 (1)"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }
    
    private func getCloseButton() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "关闭"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }
    
    private func getTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.text = "投票";
        titleLb.font = UIFont.systemFont(ofSize: 18)
        titleLb.textColor = "#000000".uicolor()
        titleLb.textAlignment = .center
        return titleLb
    }
    
    private func getTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 117;
        return tableView
    }
    
    private func crateBgView() -> UIView {
        let bgView = UIView()
        bgView.backgroundColor = "#FFFFFF".uicolor()
        return bgView
    }
    
    private func crateColseTopBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(crateColseTopBtnAction), for: .touchUpInside)
        return btn
    }
}

