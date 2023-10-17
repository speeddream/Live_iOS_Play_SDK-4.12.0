//
//  HDSCardRankView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/25.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

typealias HDSCardRankViewBottomBlock = () -> ()
class HDSCardRankView: UIView {
    private lazy var bgView: UIView = createBgView()
    private lazy var topRankImgView: UIImageView = createTopRankImgView()
    private lazy var tableView: UITableView = createTableView()
    private lazy var topCloseBtn: UIButton = createTopCloseBtn()
    private lazy var bottomBtn: UIButton = createBottomBtn()
    private var modelArr: [HDSInvitationCardRankModel]?
    private var callBack: HDSCardRankViewBottomBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        self.backgroundColor = "#000000".uicolor(alpha: 0.1)
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(509)
        }
        
        bgView.addSubview(topRankImgView)
        topRankImgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(105)
        }
        
        bgView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-86)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(topRankImgView.snp.bottom)
        }
        
        addSubview(topCloseBtn)
        topCloseBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bgView.snp.top)
        }
        
        addSubview(bottomBtn)
        bottomBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func setModel(_ modelArr: [HDSInvitationCardRankModel]?) {
        self.modelArr = modelArr
        tableView.reloadData()
    }
    
    @objc func closeBtnAction() {
        removeFromSuperview()
    }
    
    @objc func bottomBtnAction() {
        if let callBack = callBack {
            callBack()
        }
    }
    
    @objc func addBottomBlock(_ block: @escaping HDSCardRankViewBottomBlock) {
        self.callBack = block
    }
}

extension HDSCardRankView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modelArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HDSCardRankCell_ID") as? HDSCardRankCell
        if cell == nil {
            cell = HDSCardRankCell(style: .default, reuseIdentifier: "HDSCardRankCell_ID")
            cell?.selectionStyle = .none
        }
        if let model = self.modelArr?[indexPath.row] {
            cell?.setModel(model, indexPath.row)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HDScardRankHeadView_ID")
        if headView == nil {
            headView = HDScardRankHeadView(reuseIdentifier: "HDScardRankHeadView_ID")
        }
        return headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension HDSCardRankView {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FA5F29".uicolor()
        return view
    }
    
    private func createTopRankImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "H5-头部装饰")
        return imgView
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.backgroundColor = "#FFFFFF".uicolor()
        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }
    
    private func createTopCloseBtn() -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return btn
    }
    
    private func createBottomBtn() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "邀请icon"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "按钮背景"), for: .normal)
        btn.setTitle("邀请好友看直播，争取上榜机会", for: .normal)
        btn.setTitleColor("#B42E00".uicolor(), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(bottomBtnAction), for: .touchUpInside)
        btn.layer.cornerRadius = 28.5
        btn.layer.masksToBounds = true
        return btn
    }
}
