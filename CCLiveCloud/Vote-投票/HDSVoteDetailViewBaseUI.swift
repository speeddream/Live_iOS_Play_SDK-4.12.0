//
//  HDSVoteDetailViewBaseUI.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/30.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit

protocol HDSVoteDetailViewBaseUI {
    func createScrollView() -> UIScrollView
    
    func crateBgView() -> UIView
    
    func crateHeadView() -> HDSVoteHeadView
    
    func getCloseButton() -> UIButton
    
    func crateColseTopBtn() -> UIButton
        
    func createBottomView() -> UIView
    
    func createSubmitBtn() -> UIButton
    
    func getTitleLb() -> UILabel
    
    func crateTopImgView() -> UIImageView
    
    func crateCenterImgViewView() -> UIImageView

}

extension HDSVoteDetailViewBaseUI {
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.tag = 10001
        return scrollView
    }
    
    func crateBgView() -> UIView {
        let bgView = UIView()
        bgView.backgroundColor = "#FFFFFF".uicolor()
        return bgView
    }
    
    func crateHeadView() -> HDSVoteHeadView {
        let bgView = HDSVoteHeadView()
        bgView.backgroundColor = UIColor.clear
        return bgView
    }
    
    func getCloseButton() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "关闭"), for: .normal)
        return btn
    }
    
    func crateColseTopBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = UIColor.clear
        return btn
    }
    
    func createBottomView() -> UIView {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        return bgView
    }
    
    func createSubmitBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = "#FF9502".uicolor()
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        btn.layer.borderColor = "#000000".uicolor().cgColor
        btn.layer.borderWidth = 1
        btn.setTitle("提交", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return btn
    }
    
    func getTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.text = "投票"
        titleLb.textColor = "#000000".uicolor()
        titleLb.font = UIFont.systemFont(ofSize: 18)
        titleLb.textAlignment = .center
        return titleLb
    }
    
    func crateTopImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "编组 2")
        imgView.contentMode = .scaleToFill
        return imgView
    }
    
    func crateCenterImgViewView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "编组 18")
        imgView.contentMode = .scaleToFill
        return imgView
    }
}
