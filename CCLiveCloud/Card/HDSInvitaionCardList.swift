//
//  HDSInvitaionCardList.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSInvitaionCardList: UIView {
    private lazy var bottomView: UIView = createBottomView()
    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var shadowImgView: UIImageView = createShadowImgView()
    private lazy var cancleBtn: UIButton = createCancleBtn()
    private lazy var tipsLb: UILabel = createLb()
    private var oldCardView: HDSInvitationContentView?
    private var modelArr: [HDSInvitationCardModel]?
    private var configModel: HDSInvitationCardConfigModel?
    private var config: HDSInteractionManagerConfig?
    private var selectIndex: Int = 0
    private var currentModel: HDSInvitationCardModel?
    private var longGesCallBack: HDSInvitationContentViewLongGes?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        self.backgroundColor = "#000000".uicolor(alpha: 0.1)
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
            make.height.equalTo(150)
        }
        
        bottomView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview()
            make.height.equalTo(70)
        }
        
        bottomView.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(36)
        }
        
        addSubview(tipsLb)
        tipsLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(61.5)
            make.width.equalTo(186)
            make.height.equalTo(32)
        }
        
        bottomView.addSubview(shadowImgView)
        shadowImgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(20)
            make.height.equalTo(50)
        }
        
    }
    
    @objc func setModel(_ modelArr: [HDSInvitationCardModel]?, _ configModel: HDSInvitationCardConfigModel?, _ config: HDSInteractionManagerConfig?) {
        self.modelArr = modelArr
        self.configModel = configModel
        self.config = config
        selectIndex = 0
        collectionView.reloadData()
        if let model = modelArr?.first {
            showCardView(model, configModel, config)
        }
    }
    
    @objc func longGesAction(_ longGesCallBack: @escaping HDSInvitationContentViewLongGes) {
        self.longGesCallBack = longGesCallBack
    }
    
    private func showCardView(_ model: HDSInvitationCardModel, _ configModel: HDSInvitationCardConfigModel?, _ config: HDSInteractionManagerConfig?) {
        if currentModel?.id == model.id {
            return
        }
        oldCardView?.removeFromSuperview()
        currentModel = model
        let cardView = HDSInvitationContentView()
        cardView.longGes { [weak self] in
            if let callback = self?.longGesCallBack {
                callback()
            }
        }
        oldCardView = cardView
        cardView.updateUI(model, configModel, config)
        addSubview(cardView)
        let height = UIScreen.main.bounds.size.height - 104 - 146
        let width = height / 667 * 375
        cardView.snp.makeConstraints { make in
            make.top.equalTo(tipsLb.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
    }
    
    @objc func cancleAction() {
        removeFromSuperview()
    }
}

extension HDSInvitaionCardList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDSInvitaionCardListCell_ID", for: indexPath) as? HDSInvitaionCardListCell
        
        cell?.setModel(modelArr?[indexPath.item], indexPath.item == selectIndex)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.item
        collectionView.reloadData()
        if let model = modelArr?[indexPath.item] {
//            cardView.updateUI(model, configModel, config)
            showCardView(model, configModel, config)
        }
    }
}

extension HDSInvitaionCardList {
    private func createBottomView() -> UIView{
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = "#FFFFFF".uicolor()
        collectionView.register(HDSInvitaionCardListCell.self, forCellWithReuseIdentifier: "HDSInvitaionCardListCell_ID")
        
        return collectionView
    }
    
    private func createShadowImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "渐变遮罩")
        return imgView
    }
    
    private func createCancleBtn() -> UIButton {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor("#333333".uicolor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(cancleAction), for: .touchUpInside)
        btn.backgroundColor = "#EEEEEE".uicolor()
        return btn
    }
    
    private func createCardView() -> HDSInvitationContentView {
        let cardView = HDSInvitationContentView()
        return cardView
    }
    
    private func createLb() -> UILabel {
        let tipsLb = UILabel()
        tipsLb.layer.cornerRadius = 16
        tipsLb.layer.masksToBounds = true
        tipsLb.font = UIFont.systemFont(ofSize: 14)
        tipsLb.textColor = "#FFFFFF".uicolor()
        tipsLb.textAlignment = .center
        tipsLb.backgroundColor = "#000000".uicolor(alpha: 0.6)
        tipsLb.text = "长按下方图片保存至相册"
        return tipsLb
    }
}


class HDSInvitaionCardListCell: UICollectionViewCell {
    
    private lazy var imgView = createImgView()
    private lazy var selectImgView = createSelectImgView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imgView.addSubview(selectImgView)
        selectImgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func setModel(_ model:HDSInvitationCardModel?, _ isSelect: Bool) {
        imgView.sd_setImage(with: URL(string: model?.thumbnail ?? ""))
        selectImgView.isHidden = !isSelect
    }
    
    private func createImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        return imgView
    }
    
    private func createSelectImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "card选中")
        return imgView
    }
    
}
