//
//  HDSMoreInteractionView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/18.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

@objc enum HDSMoreInteractionType: NSInteger {
    case none = 0
    case vote = 2
    case red = 3
    case gift = 4
    case card = 5
    case questionnaire = 7
}

typealias HDSMoreInteractionBlock = (_ type: HDSMoreInteractionType)->()

class HDSMoreInteractionView: UIView {
    private var modelArr: [HDSMoreInteractionModel]? = [HDSMoreInteractionModel]()
    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var closeBtn = UIButton()
    private var callBack: HDSMoreInteractionBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        self.backgroundColor = "#000000".uicolor(alpha: 0.5)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(108)
        }
        
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.backgroundColor = UIColor.clear
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(collectionView.snp.top)
        }
    }
    
    @objc func closeBtnAction() {
        self.removeFromSuperview()
    }
    
    @objc func showMoreInteractionView(_ config: HDSInteractionManagerConfig) {
        if config.giftConfig != 0 {
            let model = HDSMoreInteractionModel(type: .gift, img: "礼物", title: "礼物")
            modelArr?.append(model)
        }
        if config.voteConfig != 0 {
            let model = HDSMoreInteractionModel(type: .vote, img: "投票记录", title: "投票记录")
            modelArr?.append(model)
        }
        if config.redConfig != 0 {
            let model = HDSMoreInteractionModel(type: .red, img: "红包记录", title: "红包记录")
            modelArr?.append(model)
        }
        if config.cardConfig != 0 {
            let model = HDSMoreInteractionModel(type: .card, img: "邀请_export", title: "邀请卡")
            modelArr?.append(model)
        }
        if config.questionnaireConfig != 0 {
            let model = HDSMoreInteractionModel(type: .questionnaire, img: "问卷列表备份", title: "问卷")
            modelArr?.append(model)
        }
        
        collectionView.reloadData()
    }
    
    @objc func interactionClickCallBack(_ block: @escaping HDSMoreInteractionBlock) {
        callBack = block
    }
}

extension HDSMoreInteractionView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArr?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDSMoreInteractionCell_ID", for: indexPath) as? HDSMoreInteractionCell
        let model = modelArr?[indexPath.item]
        if let model = model {
            cell?.setModel(model)
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = modelArr?[indexPath.item]
        if let callBack = callBack, let model = model {
            callBack(model.type ?? .none)
            removeFromSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = modelArr?.count ?? 0
        let width = self.bounds.size.width / CGFloat(count)
        return CGSize(width: width, height: 108)
    }
}

extension HDSMoreInteractionView {
    private func createCollectionView() -> UICollectionView {
        let collectionFlow = UICollectionViewFlowLayout()
        collectionFlow.itemSize = CGSize(width: 108, height: 108)
        collectionFlow.minimumLineSpacing = 0
        collectionFlow.minimumInteritemSpacing = 0
        collectionFlow.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlow)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HDSMoreInteractionCell.self, forCellWithReuseIdentifier: "HDSMoreInteractionCell_ID")
        collectionView.backgroundColor = .white
        
        return collectionView
    }
}

class HDSMoreInteractionCell: UICollectionViewCell {
    private lazy var imgView = UIImageView()
    private lazy var titleLb = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(17.5);
            make.width.height.equalTo(50)
        }
        
        addSubview(titleLb)
        titleLb.textAlignment = .center
        titleLb.textColor = "#333333".uicolor()
        titleLb.font = UIFont.systemFont(ofSize: 13)
        titleLb.contentMode = .scaleAspectFit
        titleLb.snp.makeConstraints { make in
            make.centerX.equalTo(imgView)
            make.top.equalTo(imgView.snp.bottom).offset(12)
        }
        
    }
    
    func setModel(_ model: HDSMoreInteractionModel?) {
        imgView.image = UIImage(named: model?.img ?? "")
        titleLb.text = model?.title ?? ""
    }
}

struct HDSMoreInteractionModel {
    var type: HDSMoreInteractionType?
    var img: String?
    var title: String?
}
