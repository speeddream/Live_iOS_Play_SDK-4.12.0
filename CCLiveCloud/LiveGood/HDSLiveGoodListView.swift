//
//  HDSLiveGoodListView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/7/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSLiveStoreModule
import MJRefresh

@objc protocol HDSLiveGoodListViewDelegate {
    func liveGoodListRefreshData()
    func liveGoodListLoadMoreData(curPage: Int)
    func liveGoodListCloseAction()
    func liveGoodListCellBuyAction(itemid: String)
    func liveGoodListCellBuyActionCallBackLink(link: String)
}

class HDSLiveGoodListView: UIView {

    private lazy var topMaskView: UIButton = createBgView()
    private lazy var contentView: UIView = createContentView()
    private lazy var tableView: UITableView = createTableView()
    private lazy var barView: HDSLiveGoodTopView = createTopView()
    private lazy var noDataView: HDSNoDataView = createNoDataView()
    private var modelArr: [HDSSingleItemModel] = []
    private var curPage: Int = 1
    private var delegate: HDSLiveGoodListViewDelegate?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupSubview()
    }
    
    @objc init(frame: CGRect, topHeight: CGFloat) {
        super.init(frame: frame)
        setupSubview(topHeight: topHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview(topHeight: CGFloat) {
        addSubview(self.topMaskView)
        topMaskView.snp.makeConstraints { make in
            make.top.left.right.top.equalToSuperview()
            make.height.equalTo(topHeight)
        }
        
        addSubview(self.contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topMaskView.snp.bottom)
        }
        
        contentView.addSubview(self.barView)
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(35)
        }
        
        contentView.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.addSubview(self.noDataView)
        noDataView.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        let footer: MJRefreshAutoNormalFooter = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.stateLabel?.textColor = "#999999".uicolor()
        footer.setTitle("已经到底啦", for: .noMoreData)
        tableView.mj_footer = footer
    }
}

class HDSNoDataView: UIView {
    
    private lazy var tipLabel: UILabel = UILabel()
    private lazy var tipImgView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customView()
        customConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customView() {
        tipLabel.textColor = "#666666".uicolor()
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        tipLabel.text = "还没有添加商品到直播间哦~"
        
        tipImgView.image = UIImage(named: "no_data")
        tipImgView.contentMode = .scaleAspectFit
    }
    
    private func customConstraints() {
        addSubview(tipImgView)
        tipImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.width.equalTo(190)
            make.height.equalTo(120)
        }
        
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(tipImgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}

extension HDSLiveGoodListView {
    @objc func refreshData() {
        if let delegate = delegate {
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            if modelArr.count > 0 {            
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            }
            delegate.liveGoodListRefreshData()
        }
    }
    
    @objc func loadMoreData() {
        if let delegate = delegate {
            delegate.liveGoodListLoadMoreData(curPage: curPage)
        }
    }
    
    @objc func endRefreshing() {
        self.tableView.mj_header?.endRefreshing()
        self.tableView.mj_footer?.endRefreshing()
    }
    
    @objc func maskViewTap() {
        closeAction()
    }
}

extension HDSLiveGoodListView {
    @objc func showViewWith(model: HDSItemListModel?) {
        curPage = model?.pagination.pageNo ?? 1
        if curPage == 1 {
            // 第一页或者刷新
            self.modelArr.removeAll()
            if (model?.records.count ?? 0) == 0 {
                noDataView.isHidden = false
                tableView.mj_footer?.isHidden = true
                tableView.mj_header?.isHidden = true
            } else {
                noDataView.isHidden = true
                tableView.mj_footer?.isHidden = false
                tableView.mj_header?.isHidden = false
            }
        }
        if let model = model {
            if model.records.count < 10 {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
//                tableView.mj_footer?.isHidden = curPage == 1
            } else {
//                tableView.mj_footer?.isHidden = false
                tableView.mj_footer?.resetNoMoreData()
            }
            self.modelArr.append(contentsOf: model.records)
        }
        
        let att1 = NSMutableAttributedString(string: "共有", attributes: [.foregroundColor: "#333333".uicolor()])
        
        let att2 = NSMutableAttributedString(string: "\(model?.pagination.totalCount ?? 0)", attributes: [.foregroundColor: "#FF842F".uicolor()])
        
        let att3 = NSMutableAttributedString(string: "件商品", attributes: [.foregroundColor: "#333333".uicolor()])
        att1.append(att2)
        att1.append(att3)
        barView.titleLb.attributedText = att1
        tableView.reloadData()
    }
    
    @objc func setupDelegate(delegate: HDSLiveGoodListViewDelegate?) {
        self.delegate = delegate;
    }
}

extension HDSLiveGoodListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HDSLiveGoodListCell_ID") as? HDSLiveGoodListCell
        if cell == nil {
            cell = HDSLiveGoodListCell(style: .default, reuseIdentifier: "HDSLiveGoodListCell_ID")
            cell?.selectionStyle = .none
            cell?.delegate = self
        }
        cell?.setupModel(model: modelArr[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
}

extension HDSLiveGoodListView: HDSLiveGoodTopViewDelegate {
    func refreshAction() {
        refreshData()
    }
    
    func closeAction() {
        if let delegate = delegate {
            delegate.liveGoodListCloseAction()
        }
    }
}

extension HDSLiveGoodListView: HDSLiveGoodListCellDelegate {
    func liveGoodListCellBuyAction(itemId: String) {
        if let delegate = delegate {
            delegate.liveGoodListCellBuyAction(itemid: itemId)
        }
    }
    
    func liveGoodListCellBuyActionCallBackLink(link: String) {
        if let delegate = delegate {
            delegate.liveGoodListCellBuyActionCallBackLink(link: link)
        }
    }
}

extension HDSLiveGoodListView {
    private func createBgView() -> UIButton {
        let bgView = UIButton()
        bgView.addTarget(self, action: #selector(maskViewTap), for: .touchUpInside)
        bgView.backgroundColor = UIColor.clear;
        return bgView
    }
    
    private func createContentView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = "#FFFFFF".uicolor()
        return contentView
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 126.5
        tableView.separatorStyle = .none
        tableView.backgroundColor = "#FFFFFF".uicolor()
        return tableView
    }
    
    private func createTopView() -> HDSLiveGoodTopView {
        let view = HDSLiveGoodTopView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.delegate = self
        return view
    }
    
    private func createNoDataView() -> HDSNoDataView {
        let view = HDSNoDataView()
        view.isHidden = true
        return view
    }
}
