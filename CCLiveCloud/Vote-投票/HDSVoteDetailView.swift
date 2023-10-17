//
//  HDSVoteDetailView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/29.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

typealias HDSVoteDeatilSubmitBlock = (_ model: HDSVoteModel)->()

class HDSVoteDetailView: UIView, HDSVoteDetailViewBaseUI {
    private lazy var scrollView: UIScrollView = createScrollView()
    private lazy var bgView: UIView = crateBgView()
    private lazy var closeBtn: UIButton = getCloseButton()
    private lazy var titleLb: UILabel = getTitleLb()
    private lazy var closeTopBtn: UIButton = crateColseTopBtn()
    private lazy var collectionView: UICollectionView = crateCollectionView()
    
    private lazy var headView: HDSVoteHeadView = crateHeadView()
    private lazy var topImgView: UIImageView = crateTopImgView()
    private lazy var centerImgView: UIImageView = crateCenterImgViewView()
    
    private lazy var bottomView: UIView = createBottomView()
    private lazy var submitBtn: UIButton = createSubmitBtn()
    
    private var curModel: HDSVoteModel?
    private var status = 0
    private var isChangeScroll = true
    private var callBlock: HDSVoteDeatilSubmitBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
        addtagergetAndDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setModel(_ model: HDSVoteModel) {
        curModel = model
        collectionView.reloadData()
        if curModel?.voteForm == 1 {
            let layout = getVoteTextImgLayout()
            collectionView.setCollectionViewLayout(layout, animated: false)
        } else {
            let layout = getVoteTextLayout()
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
        
        collectionView.reloadData()
        headView.setModel(model)
        
        self.updateCollectionViewHeight(model)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            
//            let cells = self.collectionView.visibleCells
//            if cells.count < model.voteOptions.count {
//                // 铺满
//                self.isChangeScroll = false
//
//            } else {
//                self.isChangeScroll = true
//            }
            
            if self.collectionView.bounds.size.height < self.collectionView.contentSize.height + 26 {
                self.isChangeScroll = false
            } else {
                self.isChangeScroll = true
            }
        }
        
        setpThemeColor()
    }
    
    private func setpThemeColor() {
        if curModel?.themeColor == 1 {
            centerImgView.image = UIImage(named: "编组 18")
            submitBtn.backgroundColor = "#FF9502".uicolor()
            topImgView.image = UIImage(named: "编组 2")
        } else {
            centerImgView.image = UIImage(named: "编组 18_1")
            submitBtn.backgroundColor = "#FFFFFF".uicolor()
            topImgView.image = UIImage(named: "编组 2_1")
            titleLb.textColor = "#FFFFFF".uicolor()
            closeBtn.setImage(UIImage(named: "关闭2"), for: .normal)
        }
        bgView.backgroundColor = getThemeColorString().uicolor()
        switch curModel?.themeColor {
        case 1:
            submitBtn.setTitleColor("#FFFFFF".uicolor(), for: .normal)
        case 2:
            submitBtn.setTitleColor("#06C562".uicolor(), for: .normal)
        case 3:
            submitBtn.setTitleColor("#00D1AB".uicolor(), for: .normal)
        case 4:
            submitBtn.setTitleColor("#1677FE".uicolor(), for: .normal)
        case 5:
            submitBtn.setTitleColor("#6747ED".uicolor(), for: .normal)
        case 6:
            submitBtn.setTitleColor("#FF4241".uicolor(), for: .normal)
        case 7:
            submitBtn.setTitleColor("#FF6200".uicolor(), for: .normal)
        default: break
            
        }
    }
    
    private func getThemeColorString() -> String {
        switch curModel?.themeColor {
        case 1:
            return "#FFFFFF"
        case 2:
            return "#06C562"
        case 3:
            return "#00D1AB"
        case 4:
            return "#1677FE"
        case 5:
            return "#6747ED"
        case 6:
            return "#FF4241"
        case 7:
            return "#FF6200"
        default:
            return "#FFFFFF"
        }
    }
    
    private func updateCollectionViewHeight(_ model: HDSVoteModel) {
        let screenHeight = UIScreen.main.bounds.size.height - 52
        let optionModels = model.voteOptions as? [HDSVoteOptionsModel] ?? [HDSVoteOptionsModel]()
        status = model.status
        if status != 2 {
            for optionModel in optionModels {
                if optionModel.selected {
                    status = 2
                    break
                }
            }
        }
        if status == 2 {
            bottomView.isHidden = true
            bottomView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            
            let collectionH = screenHeight - 150 - 15//- headView.bounds.size.height
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(collectionH)
            }
        } else {
            bottomView.isHidden = false
            bottomView.snp.updateConstraints { make in
                make.height.equalTo(78)
            }
            
            let collectionH = screenHeight - 150 - 78 - 15 //- headView.bounds.size.height
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(collectionH)
            }
        }
        layoutIfNeeded()
        bgView.layer.mask = HDS_ConfigRectCorner(view: bgView, corner: [.topLeft, .topRight], radii: CGSize(width: 12, height: 12))
    }
    
    @objc func submitCallBack(_ block: @escaping HDSVoteDeatilSubmitBlock) {
        callBlock = block
    }
}

extension HDSVoteDetailView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curModel?.voteOptions.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = curModel?.voteOptions[indexPath.item] as? HDSVoteOptionsModel
        if curModel?.voteForm == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDSTextAndImageCollectionViewCell_ID", for: indexPath) as? HDSTextAndImageCollectionViewCell
            if let model = model {
                cell?.setModel(model, status, curModel?.showResult ?? 0, curModel?.voteType ?? 1, curModel?.themeColor ?? 1)
            }
            return cell ?? UICollectionViewCell()
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDSTextCollectionViewCell_ID", for: indexPath) as? HDSTextCollectionViewCell
            if let model = model {
                cell?.setModel(model, status, curModel?.showResult ?? 0, curModel?.voteType ?? 1, curModel?.themeColor ?? 1)
            }
            return cell ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if status == 2 {
            return
        }
        if status == 0 {
            HDSToastTool.shard().showTip(with: "投票未开始")
            return
        }
        let model = curModel?.voteOptions[indexPath.item] as? HDSVoteOptionsModel
        if curModel?.voteType == 1 {
            // 单选
            if let options = curModel?.voteOptions as? [HDSVoteOptionsModel] {
                for model in options {
                    model.selected = false
                }
            }
            model?.selected = true
            collectionView.reloadData()
        } else {
            // 多选
            if curModel?.voteLimit == 0 {
                // 不限制
                
                model?.selected = !(model?.selected ?? false)
            } else {
                // 限制个数
                if model?.selected ?? false {
                    // 已选中再点击不需要往下执行 只需要取消选中
                    model?.selected = false
                    collectionView.reloadData()
                    return
                }
                var countSelect = 0
                if let options = curModel?.voteOptions as? [HDSVoteOptionsModel] {
                    for model in options {
                        if model.selected {
                            countSelect += 1
                        }
                    }
                }
                let voteLimit = curModel?.voteLimit ?? 0
                if countSelect >= voteLimit {
                    HDSToastTool.shard().showTip(with: "最多选择\(voteLimit)项")
                    return
                }
                model?.selected = !(model?.selected ?? false)
            }
            collectionView.reloadData()
        }
    }
}

extension HDSVoteDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isChangeScroll {
            return
        }
        let offsetY = scrollView.contentOffset.y
        if scrollView.tag == 10001 {
            if offsetY >= headView.bounds.size.height {
                scrollView.isScrollEnabled = false
                scrollView.contentOffset = CGPoint(x: 0, y: headView.bounds.size.height)
                collectionView.isScrollEnabled = true
            }
        } else {
            if offsetY <= -14 {
                self.scrollView.isScrollEnabled = true
                
                collectionView.isScrollEnabled = false
            }
        }
    }
}

extension HDSVoteDetailView {
    func addtagergetAndDelegate() {
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        closeTopBtn.addTarget(self, action: #selector(crateColseTopBtnAction), for: .touchUpInside)
        scrollView.delegate = self
        submitBtn.addTarget(self, action: #selector(createSubmitBtnAction), for: .touchUpInside)
    }
    @objc func closeAction() {
        hiddenView()
    }
    
    @objc func crateColseTopBtnAction() {
        hiddenView()
    }
    
    private func hiddenView() {
        removeFromSuperview()
        isHidden = true
    }
    
    @objc func createSubmitBtnAction() {
        if status == 0 {
            HDSToastTool.shard().showTip(with: "投票未开始")
            return
        }
        var isSelect = false
        if let options = curModel?.voteOptions as? [HDSVoteOptionsModel] {
            for model in options {
                if model.selected {
                    isSelect = true
                    break
                }
            }
        }
        if !isSelect {
            // 还没选择
            HDSToastTool.shard().showTip(with: "请先选择")
            return
        }
        // 提交
        guard let callBack = callBlock, let model = curModel else { return }
        callBack(model)
    }
}

extension HDSVoteDetailView {
    
    private func setupSubview() {

        self.backgroundColor = "#000000".uicolor(alpha: 0.5)
        
        addSubview(closeTopBtn)
        closeTopBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(closeTopBtn.snp.bottom)
        }
        
        bgView.addSubview(topImgView)
        topImgView.snp.makeConstraints { make in
            make.height.equalTo(139.5)
            make.top.left.right.equalToSuperview()
        }
        
        bgView.addSubview(centerImgView)
        centerImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(30)
            make.height.equalTo(287)
        }
        
        bgView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(20)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(17)
        }
        
        bgView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(78)
        }
        
        bottomView.addSubview(submitBtn)
        submitBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }
        
        bgView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
            make.top.equalTo(closeBtn.snp.bottom).offset(17)
        }
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let collectionH = height - 150 - 53 - 78;
        
        scrollView.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalTo(width)
            make.top.equalToSuperview()
        }
                
        scrollView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(headView.snp.bottom).offset(15)
            make.height.equalTo(collectionH)
            make.bottom.equalToSuperview()
        }
        
        layoutIfNeeded()
//        headView.updateFrameUI()
    }
    
    private func crateCollectionView() ->UICollectionView {
        
        let flowLayout = getVoteTextLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.register(HDSTextCollectionViewCell.self, forCellWithReuseIdentifier: "HDSTextCollectionViewCell_ID")
        collectionView.register(HDSTextAndImageCollectionViewCell.self, forCellWithReuseIdentifier: "HDSTextAndImageCollectionViewCell_ID")
        collectionView.contentInset = UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)
        collectionView.layer.cornerRadius = 5
        collectionView.layer.masksToBounds = true
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = "#111213".uicolor().cgColor
        collectionView.backgroundColor = "#FFFFFF".uicolor(alpha: 0.8)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }
    
    private func getVoteTextImgLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 155, height: 217)
        flowLayout.minimumLineSpacing = 13
        flowLayout.minimumInteritemSpacing = 13
        flowLayout.scrollDirection = .vertical
        
        return flowLayout
    }
    
    private func getVoteTextLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 13
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        
        let width = UIScreen.main.bounds.size.width
        flowLayout.estimatedItemSize = CGSize(width: width - 26 - 28, height: 73)
        
        return flowLayout
    }
}
