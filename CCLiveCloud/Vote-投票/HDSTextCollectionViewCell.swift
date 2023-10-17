//
//  HDSTextCollectionViewCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/29.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSTextCollectionViewCell: UICollectionViewCell {
    
    private lazy var bgView:UIView = createBgView()
    private lazy var selecBtn:UIButton = createSelectBtn()
    private lazy var titleLb:UILabel = createTitleLb()
    private lazy var progressBgView:UIView = createProgressBgView()
    private lazy var progressView:UIView = createProgressView()
    private lazy var progressLb:UILabel = createProgressLb()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        contentView.addSubview(bgView)
        let width = UIScreen.main.bounds.size.width
        bgView.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
//            make.left.equalToSuperview().offset(13)
//            make.left.equalToSuperview().offset(-13)
            make.width.equalTo(width - 26 - 28)
            make.edges.equalToSuperview()
        }
        
        bgView.addSubview(selecBtn)
        selecBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(selecBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(20)
        }
        
        bgView.addSubview(progressBgView)
        progressBgView.snp.makeConstraints { make in
            make.top.equalTo(titleLb.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(36)
            make.width.equalTo(175)
            make.height.equalTo(6)
            make.bottom.equalToSuperview().offset(-23)
        }
        
        progressBgView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        bgView.addSubview(progressLb)
        progressLb.snp.makeConstraints { make in
            make.left.equalTo(progressBgView.snp.right).offset(19)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setModel(_ model: HDSVoteOptionsModel, _ status: Int , _ showResult: Int, _ voteType: Int, _ themeColor: Int) {
        
        titleLb.text = model.optionDesc
        let imgName = getImgName(model, status, voteType, themeColor)
        selecBtn.setImage(UIImage(named: imgName), for: .normal)
        
        let hidden = showResult == 1
        
        progressBgView.isHidden = !hidden
        progressLb.isHidden = !hidden
        progressLb.text = "\(model.count)票（\(model.probability)%)"
        let width = Float(model.probability) * 0.01 * Float(175)
        progressView.snp.updateConstraints { make in
            make.width.equalTo(min(width, 175))
        }
//        if status == 2 {
//            // 结束
//
//            if !hidden {
//                hiddenProgress()
//            } else {
//
//            }
//        } else if status == 1 {
//
//            // 进行中
//            progressBgView.isHidden = true
//            progressLb.isHidden = true
//            hiddenProgress()
//        } else {
//            // 未开始
//            progressBgView.isHidden = true
//            progressLb.isHidden = true
//            hiddenProgress()
//        }
        
        switch themeColor {
        case 1:
            progressLb.textColor = "#FF9502".uicolor()
            progressView.backgroundColor = "#FF9502".uicolor()
        case 2:
            progressLb.textColor = "#06C562".uicolor()
            progressView.backgroundColor = "#06C562".uicolor()
        case 3:
            progressLb.textColor = "#00D1AB".uicolor()
            progressView.backgroundColor = "#00D1AB".uicolor()
        case 4:
            progressLb.textColor = "#1677FE".uicolor()
            progressView.backgroundColor = "#1677FE".uicolor()
        case 5:
            progressLb.textColor = "#6747ED".uicolor()
            progressView.backgroundColor = "#6747ED".uicolor()
        case 6:
            progressLb.textColor = "#FF4241".uicolor()
            progressView.backgroundColor = "#FF4241".uicolor()
        case 7:
            progressLb.textColor = "#FF6200".uicolor()
            progressView.backgroundColor = "#FF6200".uicolor()
        default: break
            
        }
        
        layoutIfNeeded()
    }
    
    private func hiddenProgress() {
        progressBgView.snp.updateConstraints { make in
            make.top.equalTo(titleLb.snp.bottom).offset(0)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-20)
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

extension HDSTextCollectionViewCell {
    @objc func createSelectBtnAction() {
        
    }
}

extension HDSTextCollectionViewCell {
    
    func createBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.borderWidth = 1
        view.layer.borderColor = "#000000".uicolor().cgColor
        view.layer.cornerRadius = 3.5
        view.layer.masksToBounds = true
        return view
    }
    
    func createSelectBtn() -> UIButton {
        let btn = UIButton()
        return btn
    }
    
    func createTitleLb() -> UILabel {
        let title = UILabel()
        title.text = "这是测试"
        title.font = UIFont.systemFont(ofSize: 14)
        title.numberOfLines = 2
        title.textColor = "#000000".uicolor()
        
        return title
    }
    
    func createProgressBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#EEEEEE".uicolor()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }
    
    func createProgressView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FF9502".uicolor()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }
    
    func createProgressLb() -> UILabel {
        let title = UILabel()
        title.text = "1123票（25%)"
        title.font = UIFont.systemFont(ofSize: 12)
        title.numberOfLines = 2
        title.textColor = "#FF9502".uicolor()
        
        return title
    }
    
}
