//
//  HDSLiveGoodTopView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/7/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

protocol HDSLiveGoodTopViewDelegate {
    func closeAction()
    func refreshAction()
}

class HDSLiveGoodTopView: UIView {

    private lazy var topLineView: UIView = createTopLineView()
    private lazy var bottomLineView: UIView = createBottomLineView()
    lazy var titleLb: UILabel = createTitleLb()
    private lazy var refreshBtn: UIButton = createRefreshBtn()
    private lazy var closeBtn: UIButton = createCloseBtn()
    var delegate: HDSLiveGoodTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        
        addSubview(self.topLineView)
        self.topLineView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        addSubview(self.bottomLineView)
        self.bottomLineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        addSubview(self.titleLb)
        self.titleLb.snp.makeConstraints { make in
            make.left.equalTo(self).offset(12)
            make.centerY.equalToSuperview()
        }
        
        addSubview(self.closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        
        addSubview(self.refreshBtn)
        self.refreshBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
            make.right.equalTo(closeBtn.snp.left).offset(-10)
        }
    }

}

extension HDSLiveGoodTopView {
    @objc private func refreshBtnAction() {
        if let delegate = delegate {
            delegate.refreshAction()
        }
    }
    
    @objc func closeBtnAction() {
        if let delegate = delegate {
            delegate.closeAction()
        }
    }
}

extension HDSLiveGoodTopView {
    private func createTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.textColor = "#333333".uicolor()
        titleLb.font = UIFont.systemFont(ofSize: 14)
        titleLb.text = "共有10件商品"
        return titleLb
    }
    
    private func createRefreshBtn() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "goodListRefresh"), for: .normal)
        button.addTarget(self, action: #selector(refreshBtnAction), for: .touchUpInside)
        return button
    }
    
    private func createCloseBtn() -> UIButton {
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "goodListClose"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return closeBtn
    }
    
    private func createTopLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#E8E9EB".uicolor()
        return view
    }
    
    private func createBottomLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#E8E9EB".uicolor()
        return view
    }
}

