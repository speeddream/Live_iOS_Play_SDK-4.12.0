//
//  HDSTextAndImageCollectionViewCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/29.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class HDSTextAndImageCollectionViewCell: UICollectionViewCell {
    
    private lazy var bgView: UIView = createBgView()
    private lazy var imgView: UIImageView = createImgView()
    
    private lazy var voteDoneView: UIView = createVoteDoneView()
    private lazy var voteDoneLb: UILabel = createVoteDoneLb()
    
    private lazy var voteCountView: UIView = createVoteCountView()
    private lazy var voteCountLb: UILabel = createVoteCountCountLb()
    private lazy var voteCountProportionLb: UILabel = createVoteCountProportionLb()
    
    private lazy var selectBtn: UIButton = createSelectBtn()
    
    private lazy var titleLb: UILabel = createTitleLb()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(135)
        }
        
        bgView.addSubview(voteDoneView)
        voteDoneView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(18)
            make.width.equalTo(62)
            make.height.equalTo(24)
        }
        
        voteDoneView.addSubview(voteDoneLb)
        voteDoneLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        
        imgView.addSubview(voteCountView)
        voteCountView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(28)
        }
        
        voteCountView.addSubview(voteCountLb)
        voteCountLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
        }
        
        voteCountView.addSubview(voteCountProportionLb)
        voteCountProportionLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
        }
        
        bgView.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(imgView.snp.bottom).offset(7)
            make.width.height.equalTo(14)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(selectBtn.snp.right).offset(8)
            make.top.equalTo(imgView.snp.bottom).offset(7)
            make.right.equalToSuperview().offset(-6)
        }
    }
    
    func setModel(_ model: HDSVoteOptionsModel, _ status: Int , _ showResult: Int, _ voteType: Int, _ themeColor: Int) {
        imgView.sd_setImage(with: URL(string: model.optionUrl))
        
        titleLb.text = model.optionDesc
        
        let imgName = getImgName(model, status, voteType, themeColor)
        selectBtn.setImage(UIImage(named: imgName), for: .normal)
        
        voteCountView.isHidden = !(showResult == 1)
        voteCountLb.text = "票数：\(model.count)"
        voteCountProportionLb.text = "\(model.probability)%"
        
        if status == 2 {
            // 结束
            let hidden = showResult == 1 && model.selected
            voteDoneView.isHidden = !hidden
            
        } else if status == 1 {
            // 进行中
            voteDoneView.isHidden = true
        } else {
            // 未开始
            voteDoneView.isHidden = true
        }
        
        switch themeColor {
        case 1:
            voteDoneView.backgroundColor = "#FF9502".uicolor()
        case 2:
            voteDoneView.backgroundColor = "#06C562".uicolor()
        case 3:
            voteDoneView.backgroundColor = "#00D1AB".uicolor()
        case 4:
            voteDoneView.backgroundColor = "#1677FE".uicolor()
        case 5:
            voteDoneView.backgroundColor = "#6747ED".uicolor()
        case 6:
            voteDoneView.backgroundColor = "#FF4241".uicolor()
        case 7:
            voteDoneView.backgroundColor = "#FF6200".uicolor()
        default: break
            
        }
    }
    
    private func getImgName(_ model: HDSVoteOptionsModel, _ status: Int , _ voteType: Int, _ themeColor: Int) -> String {
        let baseNorName = "单选-未选"
        let baseSelectName = "单选-选中"
        
        let baseDoubleNorName = "多选-未选"
        let baseDoubleSelectName = "多选-选中"
        var imgName = ""
        if voteType == 1 {
            // 单选
            if model.selected {
                imgName = baseSelectName + "\(themeColor)"
            } else {
                if status == 2 || status == 0 {
                    imgName = "单选-禁用"
                } else {
                    imgName = baseNorName + "\(themeColor)"
                }
            }
        } else {
            // 多选
            
            if model.selected {
                imgName = baseDoubleSelectName + "\(themeColor)"
            } else {
                if status == 2 || status == 0 {
                    imgName = "多选-禁用"
                } else {
                    imgName = baseDoubleNorName + "\(themeColor)"
                }
            }
        }
        return imgName
    }
}

//extension HDSTextAndImageCollectionViewCell {
//    @objc func createSelectBtnAction() {
//        print("==HDSTextAndImageCollectionViewCell createSelectBtnAction==")
//    }
//}

extension HDSTextAndImageCollectionViewCell {
    private func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = "#000000".uicolor().cgColor
        view.layer.masksToBounds = true
        return view
    }
    
    private func createImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = "#FFFFFF".uicolor()
        imgView.layer.cornerRadius = 4
        imgView.layer.masksToBounds = true
        return imgView
    }
    
    private func createVoteDoneView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FF9502".uicolor()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = "#000000".uicolor().cgColor
        view.layer.masksToBounds = true
        return view
    }
    
    private func createVoteDoneLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.text = "已投票"
        titleLb.font = UIFont.boldSystemFont(ofSize: 12)
        titleLb.textColor = "#FFFFFF".uicolor()
        titleLb.textAlignment = .center
        return titleLb
    }
    
    private func createVoteCountView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#000000".uicolor(alpha: 0.5)
        return view
    }
    
    private func createVoteCountCountLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.font = UIFont.systemFont(ofSize: 12)
        titleLb.textColor = "#FFFFFF".uicolor()
        return titleLb
    }
    
    private func createVoteCountProportionLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.font = UIFont.systemFont(ofSize: 12)
        titleLb.textColor = "#FFFFFF".uicolor()
        return titleLb
    }
    
    private func createSelectBtn() -> UIButton {
        let btn = UIButton()
//        btn.addTarget(self, action: #selector(createSelectBtnAction), for: .touchUpInside)
        return btn
    }
    
    private func createTitleLb() -> UILabel {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 14)
        title.numberOfLines = 3
        title.textColor = "#000000".uicolor()
        title.sizeToFit()
        return title
    }
    
}
