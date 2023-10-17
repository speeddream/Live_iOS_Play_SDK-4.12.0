//
//  HDSVoteListTableViewCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

class HDSVoteListTableViewCell: UITableViewCell {

    private lazy var bgView: UIView = getBgView()
    private lazy var voteImgView: UIImageView = getVoteImgView()
    private lazy var voteingLb: UILabel = getVoteingLb()
    private lazy var linView: UIView = createlineView()
    private lazy var titleLb: UILabel = crateTitleLb()
    private lazy var timeLb: UILabel = createTimeLb()
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(contentView).offset(7.5)
            make.bottom.equalToSuperview().offset(-7.5)
        }
        
        bgView.addSubview(voteImgView)
        voteImgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23.5)
            make.top.equalToSuperview().offset(31)
            make.width.height.equalTo(21)
        }
        
        bgView.addSubview(voteingLb)
        voteingLb.snp.makeConstraints { make in
            make.centerX.equalTo(voteImgView)
            make.top.equalTo(voteImgView.snp.bottom).offset(7)
        }
        
        bgView.addSubview(linView)
        linView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(voteImgView.snp.right).offset(23)
            make.width.equalTo(0.5)
            make.height.equalTo(102)
        }
        
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(linView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        bgView.addSubview(timeLb)
        timeLb.snp.makeConstraints { make in
            make.left.equalTo(linView.snp.right).offset(15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    func setModel(_ model: HDSVoteModel) {
        if model.status == 0 {
            voteImgView.image =  UIImage(named: "")
            voteingLb.text = "未开始"
            voteingLb.textColor = "#999999".uicolor()
        } else if model.status == 1 {
            voteImgView.image =  UIImage(named: "投票中")
            voteingLb.text = "进行中"
            voteingLb.textColor = "#FF9502".uicolor()
        } else if model.status == 2 {
            voteImgView.image =  UIImage(named: "投票结束")
            voteingLb.text = "已结束"
            voteingLb.textColor = "#999999".uicolor()
        }
        
        titleLb.text = model.title
        timeLb.text = model.createTime
        layoutIfNeeded()
        addShadow(view: bgView, shadowColor: "#000000".uicolor(alpha: 0.2), shadowOpacity: 1, shadowRadius: 4, shadowOffset: CGSize(width: 0, height: 1))
    }
    
}

extension HDSVoteListTableViewCell {
    private func getBgView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        view.layer.cornerRadius = 4
        return view
    }
    
    private func getVoteImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "投票中")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    private func getVoteingLb() -> UILabel {
        let voteLb = UILabel()
        voteLb.textAlignment = .center
        voteLb.text = "投票中"
        voteLb.font = UIFont.systemFont(ofSize: 12)
        voteLb.textColor = "#FF9502".uicolor()
        return voteLb
    }
    
    private func createlineView() -> UIView {
        let linveView = UIView()
        linveView.backgroundColor = "#D8D8D8".uicolor()
        return linveView
    }
    
    private func crateTitleLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.font = UIFont.systemFont(ofSize: 15)
        titleLb.textColor = "#000000".uicolor()
        titleLb.numberOfLines = 2
        titleLb.text = "这是测试"
        return titleLb
    }
    
    private func createTimeLb() -> UILabel {
        let titleLb = UILabel()
        titleLb.font = UIFont.systemFont(ofSize: 13)
        titleLb.textColor = "#666666".uicolor()
        titleLb.text = "2021-06-29  17:25"
        return titleLb
    }
    
    func addShadow(view: UIView, shadowColor: UIColor, shadowOpacity: CGFloat, shadowRadius: CGFloat, shadowOffset: CGSize){
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = Float(shadowOpacity)
    }
}
