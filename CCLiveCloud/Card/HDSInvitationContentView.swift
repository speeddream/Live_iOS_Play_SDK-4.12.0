//
//  HDSInvitationContentView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

typealias HDSInvitationContentViewLongGes = ()->()

class HDSInvitationContentView: UIView {
    private lazy var bgView: UIImageView = createImgView()
    private lazy var contentBgView: UIView = createView()
    private lazy var titleLb: UILabel = createLb()
    private lazy var timeLb: UILabel = createLb()
    private lazy var lineView: UIView = createView()
    private lazy var contentLineView: UIView = createView()
    private lazy var descriptionLb: UILabel = createLb()
    private lazy var code: UIImageView = createImgView()
    private lazy var codeDescription: UILabel = createLb()
    private lazy var avatarImg: UIImageView = createImgView()
    private lazy var labelLb: UILabel = createLb()
    private lazy var nameLb: UILabel = createLb()
    private lazy var watermark: UILabel = createLb()
    private var isDownImg = false
    private var longGesCallback: HDSInvitationContentViewLongGes?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func resetUI() {
        bgView.removeFromSuperview()
        contentBgView.removeFromSuperview()
        titleLb.removeFromSuperview()
        timeLb.removeFromSuperview()
        lineView.removeFromSuperview()
        contentLineView.removeFromSuperview()
        descriptionLb.removeFromSuperview()
        code.removeFromSuperview()
        codeDescription.removeFromSuperview()
        avatarImg.removeFromSuperview()
        nameLb.removeFromSuperview()
        labelLb.removeFromSuperview()
        watermark.removeFromSuperview()
    }
    
    func updateUI(_ model: HDSInvitationCardModel, _ configModel: HDSInvitationCardConfigModel?, _ config: HDSInteractionManagerConfig?) {
        resetUI()
        let height = UIScreen.main.bounds.size.height - 104 - 146
        let width = height / 667 * 375
        let coefficient: Float = Float(width / 375)
        let layoutContentModel = model.layoutContentModel
        
        addSubview(bgView)
        bgView.isUserInteractionEnabled = true
        let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longGesAction))
        bgView.addGestureRecognizer(longGes)
        bgView.sd_setImage(with: URL(string:model.backUrl))
        bgView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview()
//            make.width.equalTo(225)
//            make.width.equalTo(400)
            make.edges.equalToSuperview()
        }
        
        addSubview(contentBgView)
        if layoutContentModel.bg.radius > 0 {
            contentBgView.layer.cornerRadius = CGFloat(layoutContentModel.bg.radius)
            contentBgView.layer.masksToBounds = true
        }
        contentBgView.backgroundColor = layoutContentModel.bg.color.uicolor()
        contentBgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.bg.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.bg.y * coefficient)
            make.width.equalTo(layoutContentModel.bg.width * coefficient)
            make.height.equalTo(layoutContentModel.bg.height * coefficient)
        }
        
        addSubview(lineView)
        let lineHeight = layoutContentModel.line.height > 1 ? layoutContentModel.line.height * coefficient : layoutContentModel.line.height
        lineView.backgroundColor = layoutContentModel.line.color.uicolor()
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.line.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.line.y * coefficient)
            make.width.equalTo(layoutContentModel.line.width * coefficient)
            make.height.equalTo(lineHeight)
        }
        
        addSubview(titleLb)
        if configModel?.showTitle == 2 {
            titleLb.text = configModel?.title
        } else {
            titleLb.text = config?.roomName
        }
        titleLb.isHidden = configModel?.showTitle == 0
        titleLb.numberOfLines = layoutContentModel.content.title.maxLen
        let titleFontSize = layoutContentModel.content.title.fontSize
        if layoutContentModel.content.title.fontWeight > 400 {
            titleLb.font = UIFont.boldSystemFont(ofSize: CGFloat(titleFontSize))
        } else {
            titleLb.font = UIFont.systemFont(ofSize: CGFloat(titleFontSize))
        }
        titleLb.textColor = layoutContentModel.content.title.color.uicolor()
        setLabelAlign(titleLb, layoutContentModel.content.title.textAlign)
        if titleLb.text?.count ?? 0 > 0 {
            titleLb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(layoutContentModel.content.title.x * coefficient)
                make.top.equalToSuperview().offset(layoutContentModel.content.title.y * coefficient)
                make.width.equalTo(layoutContentModel.content.title.width * coefficient)
                make.height.greaterThanOrEqualTo(30)
            }
        } else {
            titleLb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(layoutContentModel.content.title.x * coefficient)
                make.top.equalToSuperview().offset(layoutContentModel.content.title.y * coefficient)
                make.width.equalTo(layoutContentModel.content.title.width * coefficient)
            }
        }
        
        addSubview(timeLb)
        if let liveTime = config?.liveStartTime {
            if liveTime.count > 0 {
                timeLb.text = "直播时间:" + liveTime
            }
        }
        timeLb.textColor = layoutContentModel.content.time.color.uicolor()
        if layoutContentModel.content.time.fontWeight > 400 {
            timeLb.font = UIFont.boldSystemFont(ofSize: CGFloat(layoutContentModel.content.time.fontSize))
        } else {
            timeLb.font = UIFont.systemFont(ofSize: CGFloat(layoutContentModel.content.time.fontSize))
        }
        setLabelAlign(timeLb, layoutContentModel.content.time.textAlign)
        timeLb.isHidden = configModel?.showTime == 0
        timeLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLb.snp.bottom).offset(layoutContentModel.content.time.top * coefficient)
            make.width.equalTo(layoutContentModel.content.time.width * coefficient)
        }
        
//        addSubview(contentLineView)
//        contentLineView.backgroundColor = layoutContentModel.content.line.color.uicolor()
//        let contentLineHeight = layoutContentModel.content.line.height > 1 ? layoutContentModel.content.line.height * coefficient : layoutContentModel.content.line.height
//        contentLineView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(layoutContentModel.content.line.x * coefficient)
//            make.top.equalTo(timeLb.snp.bottom).offset(layoutContentModel.content.line.top * coefficient)
//            make.width.equalTo(layoutContentModel.content.line.width * coefficient)
//            make.height.equalTo(contentLineHeight)
//        }
        
        addSubview(descriptionLb)
        var desc = ""
        if configModel?.showDesc == 2 {
            desc = configModel?.hds_description ?? ""
        } else {
            desc = config?.roomDesc ?? ""
        }
        let att = try? NSAttributedString(data: desc.data(using: .unicode) ?? Data(), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        descriptionLb.attributedText = att
//        descriptionLb.text = config?.roomDesc
        descriptionLb.textColor = layoutContentModel.content.hds_description.color.uicolor()
        descriptionLb.isHidden = configModel?.showDesc == 0
        if layoutContentModel.content.hds_description.fontWeight > 400 {
            descriptionLb.font = UIFont.boldSystemFont(ofSize: CGFloat(layoutContentModel.content.hds_description.fontSize))
        } else {
            descriptionLb.font = UIFont.systemFont(ofSize: CGFloat(layoutContentModel.content.hds_description.fontSize))
        }
        setLabelAlign(descriptionLb, layoutContentModel.content.hds_description.textAlign)
        descriptionLb.numberOfLines = layoutContentModel.content.hds_description.maxLen
        descriptionLb.lineBreakMode = .byTruncatingTail
        descriptionLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.content.hds_description.x * coefficient)
            make.top.equalTo(timeLb.snp.bottom).offset(layoutContentModel.content.hds_description.top * coefficient)
            make.width.equalTo(layoutContentModel.content.hds_description.width * coefficient)
            make.bottom.lessThanOrEqualTo(self.contentBgView.snp.bottom).offset(-20)
        }
        
        addSubview(avatarImg)
        avatarImg.isHidden = configModel?.showHead == 0
//        avatarImg.backgroundColor = layoutContentModel.user.avatar.color.uicolor()
        avatarImg.image = UIImage(named: "默认头像")
        avatarImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.user.avatar.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.user.avatar.y * coefficient)
            make.width.height.equalTo(layoutContentModel.user.avatar.width * coefficient)
        }
        
        addSubview(nameLb)
        nameLb.text = config?.userName
        nameLb.isHidden = configModel?.showName == 0
        nameLb.textColor = layoutContentModel.user.name.color.uicolor()
        if layoutContentModel.user.name.fontWeight > 400 {
            nameLb.font = UIFont.boldSystemFont(ofSize: CGFloat(layoutContentModel.user.name.fontSize))
        } else {
            nameLb.font = UIFont.systemFont(ofSize: CGFloat(layoutContentModel.user.name.fontSize))
        }
        setLabelAlign(nameLb, layoutContentModel.user.name.textAlign)
        nameLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.user.name.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.user.name.y * coefficient)
            make.width.equalTo(layoutContentModel.user.name.width * coefficient)
        }
        
        addSubview(labelLb)
        labelLb.text = configModel?.inviterDesc
        labelLb.textColor = layoutContentModel.user.label.color.uicolor()
        if layoutContentModel.user.label.fontWeight > 400 {
            labelLb.font = UIFont.boldSystemFont(ofSize: CGFloat(layoutContentModel.user.label.fontSize))
        } else {
            labelLb.font = UIFont.systemFont(ofSize: CGFloat(layoutContentModel.user.label.fontSize))
        }
        setLabelAlign(labelLb, layoutContentModel.user.label.textAlign)
        labelLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.user.label.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.user.label.y * coefficient)
            make.width.equalTo(layoutContentModel.user.label.width * coefficient)
        }
        
        addSubview(code)
        let img = generateQRCode(str: config?.sortUrl ?? "")
        code.image = img
        code.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(layoutContentModel.qrCode.code.x * coefficient)
            make.top.equalToSuperview().offset(layoutContentModel.qrCode.code.y * coefficient)
            make.width.height.equalTo(layoutContentModel.qrCode.code.width * coefficient)
        }
        
        addSubview(codeDescription)
        codeDescription.text = configModel?.qrCodeDesc
        codeDescription.textColor = layoutContentModel.qrCode.hds_description.color.uicolor()
        codeDescription.numberOfLines = layoutContentModel.qrCode.hds_description.maxLen
        codeDescription.sizeToFit()
        if layoutContentModel.qrCode.hds_description.fontWeight > 400 {
            codeDescription.font = UIFont.boldSystemFont(ofSize: CGFloat(layoutContentModel.qrCode.hds_description.fontSize))
        } else {
            codeDescription.font = UIFont.systemFont(ofSize: CGFloat(layoutContentModel.qrCode.hds_description.fontSize))
        }
        setLabelAlign(codeDescription, layoutContentModel.qrCode.hds_description.textAlign)
        codeDescription.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(layoutContentModel.qrCode.hds_description.x * coefficient)
            make.top.equalTo(code.snp.bottom).offset(layoutContentModel.qrCode.hds_description.top * coefficient)
            make.width.equalTo(layoutContentModel.qrCode.hds_description.width * coefficient)
            make.centerX.equalTo(code.snp.centerX)
        }
        
        addSubview(watermark)
        watermark.text = configModel?.watermark
        watermark.isHidden = configModel?.showWatermark == 0
        watermark.textColor = "#FFFFFF".uicolor()
        watermark.textAlignment = .center
        watermark.font = UIFont.systemFont(ofSize: 12)
        watermark.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(19 * coefficient))
        }
        
        layoutIfNeeded()
    }
    
    func longGes(_ callBack: HDSInvitationContentViewLongGes?) {
        longGesCallback = callBack
    }
    
    private func setLabelAlign(_ label: UILabel?, _ align: String?) {
        switch align {
        case "center":
            label?.textAlignment = .center
        case "right":
            label?.textAlignment = .right
        default:
            label?.textAlignment = .left
        }
    }
    
    @objc private func longGesAction(tap: UIGestureRecognizer) {
        if !isDownImg {
            funcScreenshot()
            if let longGesCallback = longGesCallback {            
                longGesCallback()
            }
            print("----longGesAction---")
        }
        switch tap.state {
        case .began:
            isDownImg = true
        case .changed:
            isDownImg = true
        case .ended:
            isDownImg = false
        default:
            break
        }
        
    }
    
    private func funcScreenshot() {//截取指定UIView

        UIGraphicsBeginImageContextWithOptions(self.frame.size,false,UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.layer.render(in:context)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }

        UIGraphicsEndImageContext()

        UIImageWriteToSavedPhotosAlbum(image,self,nil,nil)

    }
}

extension HDSInvitationContentView {
    private func createLb() -> UILabel {
        let label = UILabel()
        
        return label
    }
    
    private func createView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func createImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        return imgView
    }
}

extension HDSInvitationContentView {
    private func generateQRCode(str: String) -> UIImage? {
        
        let data = str.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 9, y: 9)
        
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        
        return UIImage(ciImage: output)
    }
}
