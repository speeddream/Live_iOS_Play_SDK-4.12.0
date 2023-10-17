//
//  HDSQuestionnaireImgInputCell.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule

typealias HDSImgCellCallBack = (_ model: HDSQuestionnaireStyleModel?)->()

class HDSQuestionnaireImgInputCell: UITableViewCell {
    private lazy var imgBtn: UIButton = createImgBtn()
    private lazy var imgView: UIImageView = createImgView()
    private lazy var deleteBtn: UIButton = createDeleteBtn()
    weak var vc: UIViewController?
    private var model: HDSQuestionnaireStyleModel?
    var callBack: HDSImgCellCallBack?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.backgroundColor = "#FFFFFF".uicolor()
        
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        imgView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        contentView.addSubview(imgBtn)
        imgBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
        }
    }
    
    func setModel(_ model: HDSQuestionnaireStyleModel?) {
        self.model = model
        imgView.image = model?.img
        let data = model?.img.jpegData(compressionQuality: 1)
        if data == nil {
            imgBtn.isHidden = false
        } else {
            imgBtn.isHidden = true
        }
    }
    
    @objc private func deleteAction() {
        model?.img = UIImage()
        imgBtn.isHidden = false
        model?.contentText = ""
    }
    
    @objc private func addimgAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        vc?.present(picker, animated: true, completion: nil)
    }
}

extension HDSQuestionnaireImgInputCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        imgView.image = info[.originalImage] as? UIImage
        if let img = info[.originalImage] as? UIImage {
            model?.img = img
        }
        imgBtn.isHidden = true
        if let callBack = callBack {
            callBack(self.model)
        }
    }
}

extension HDSQuestionnaireImgInputCell {
    private func createImgBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = "#F5F5F5".uicolor()
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(addimgAction), for: .touchUpInside)
        btn.setImage(UIImage(named: "上传图片icon"), for: .normal)
        return btn
    }
    
    private func createImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 2
        imgView.layer.masksToBounds = true
        imgView.isUserInteractionEnabled = true
        return imgView
    }
    
    private func createDeleteBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = "#000000".uicolor()
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        btn.setImage(UIImage(named: "关闭2"), for: .normal)
        return btn
    }
}
