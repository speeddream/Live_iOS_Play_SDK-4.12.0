//
//  HDSQuestionnaireDetailView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit
import HDSQuestionnaireModule
import AliyunOSSiOS

typealias HDSTipsCallBack = (_ tipString: String?)->()

class HDSQuestionnaireDetailView: UIView {
    private lazy var navView: UIView = createNavView()
    private lazy var backBtn: UIButton = createBackBtn()
    private lazy var closeBtn: UIButton = createCloseBtn()
    private lazy var titleLb: UILabel = createTitleLb()
    private lazy var headView: HDSQuestionnaireDetailHeadView = HDSQuestionnaireDetailHeadView()
    private lazy var tableView: UITableView = createTableView()
    private lazy var bottomView: UIView = createBottomView()
    private lazy var submitBtn: UIButton = createSubmitBtn()
    private lazy var bottomLb: UILabel = createBottomLb()
    private var model: HDSQuestionnaireQueryDetail?
    @objc weak var vc: UIViewController?
    @objc var quesFunc: HDSQuestionnaireFunc?
    private var normalUploadRequest: OSSPutObjectRequest?
    private var defaultClient: OSSClient?
    private lazy var loadingView: LoadingView = crateLoadingView()
    private var tipsCallBack: HDSTipsCallBack?
    private var navBackCallBack: HDSTipsCallBack?
    private var closeCallBack: HDSTipsCallBack?
    private var submitCallBack: HDSTipsCallBack?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
        yyhcb_addKeyboardCorverNotification()
        yyhcb_addKeyboardCorverGesture()
    }
    deinit {
        yyhcb_removeKeyboardCorverNotification()
        yyhcb_removeKeyboardCorverGesture()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        backgroundColor = "#F5F5F5".uicolor()
        addSubview(navView)
        navView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        navView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        navView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.left.equalTo(backBtn.snp.right).offset(10)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        navView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(closeBtn.snp.right).offset(10.5)
            make.centerY.equalTo(closeBtn)
        }
        addSubview(headView)
        headView.snp.makeConstraints { make in
            make.right.left.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(84)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).offset(-10)
            make.top.equalTo(navView.snp.bottom)
        }
        
        bottomView.addSubview(submitBtn)
        submitBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(40)
        }
        
        bottomView.addSubview(bottomLb)
        bottomLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(submitBtn.snp.bottom).offset(10)
        }
    }
    
    @objc func setModel(_ model: HDSQuestionnaireQueryDetail) {
        self.model = model
        headView.setModel(model)
        headView.layoutIfNeeded()
        headView.removeFromSuperview()
        tableView.tableHeaderView = headView
        headView.snp.remakeConstraints { make in
            make.right.left.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        tableView.reloadData()
    }
    
    @objc func setTipsCallBack(_ callBack: HDSTipsCallBack?) {
        tipsCallBack = callBack
    }
    
    @objc func setNavBackCallBack(_ callBack: HDSTipsCallBack?) {
        navBackCallBack = callBack
    }
    
    @objc func setCloseCallBack(_ callBack: HDSTipsCallBack?) {
        closeCallBack = callBack
    }
    
    @objc func setSubmitCallBack(_ callBack: HDSTipsCallBack?) {
        submitCallBack = callBack
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
    
}

extension HDSQuestionnaireDetailView: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model?.formStyleModel.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = model?.formStyleModel[section]
        let optionsCount = model?.options.count ?? 0
        return optionsCount > 0 ? optionsCount : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = model?.formStyleModel[indexPath.section]
        switch model?.type {
        case "NameInput","PositionInput","EmailInput","Timepicker","RegionInput":
            var cell = tableView.dequeueReusableCell(withIdentifier: "HDSNameTableViewCell_ID") as? HDSNameTableViewCell
            if cell == nil {
                cell = HDSNameTableViewCell(style: .default, reuseIdentifier: "HDSNameTableViewCell_ID")
                cell?.selectionStyle = .none
                cell?.nameCallBack = {
//                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
            }
            cell?.setModel(model)
            return cell ?? UITableViewCell()
        case "PhoneInput":
            var cell = tableView.dequeueReusableCell(withIdentifier: "HDSQuestionnairePhoneNumCell_ID") as? HDSQuestionnairePhoneNumCell
            if cell == nil {
                cell = HDSQuestionnairePhoneNumCell(style: .default, reuseIdentifier: "HDSQuestionnairePhoneNumCell_ID")
                cell?.selectionStyle = .none
                cell?.phoneCallBack = {
//                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
            }
            cell?.setModel(model)
            return cell ?? UITableViewCell()
        case "Radio","sexRadio","Checkbox":
            var cell = tableView.dequeueReusableCell(withIdentifier: "HDSChooseOptionCell_ID") as? HDSChooseOptionCell
            if cell == nil {
                cell = HDSChooseOptionCell(style: .default, reuseIdentifier: "HDSChooseOptionCell_ID")
                cell?.selectionStyle = .none
            }
            cell?.setModel(model, model?.options[indexPath.row])
            return cell ?? UITableViewCell()
        case "Textarea":
            var cell = tableView.dequeueReusableCell(withIdentifier: "HDSQuesionnaireQACell_ID") as? HDSQuesionnaireQACell
            if cell == nil {
                cell = HDSQuesionnaireQACell(style: .default, reuseIdentifier: "HDSQuesionnaireQACell_ID")
                cell?.selectionStyle = .none
                cell?.qaCallBack = {
//                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
            }
            cell?.setModel(model)
            return cell ?? UITableViewCell()
        case "ImageInput":
            var cell = tableView.dequeueReusableCell(withIdentifier: "HDSQuestionnaireImgInputCell_ID") as? HDSQuestionnaireImgInputCell
            if cell == nil {
                cell = HDSQuestionnaireImgInputCell(style: .default, reuseIdentifier: "HDSQuestionnaireImgInputCell_ID")
                cell?.selectionStyle = .none
                cell?.vc = self.vc
                cell?.callBack = {[weak self] model in
                    self?.checkoutImgAndUplod(model)
                }
            }
            cell?.setModel(model)
            return cell ?? UITableViewCell()
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HDSQuestionnireHeadView_ID") as? HDSQuestionnireHeadView
        if headView == nil {
            headView = HDSQuestionnireHeadView(reuseIdentifier: "HDSQuestionnireHeadView_ID")
        }
        let model = model?.formStyleModel[section]
        headView?.setModel(model)
        return headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditing(true)
        let model = model?.formStyleModel[indexPath.section]
        switch model?.type {
        case "Timepicker":
            let picker = HDSPickerView(frame: .zero, type: .date)
            addSubview(picker)
            picker.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            picker.pickerCallBack = { result, content in
                if result {
                    model?.contentText = content
                }
                picker.removeFromSuperview()
                tableView.reloadData()
            }
            break
        case "RegionInput":
            let picker = HDSPickerView(frame: .zero, type: .address)
            addSubview(picker)
            picker.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            picker.pickerCallBack = { result, content in
                if result {
                    model?.contentText = content
                }
                picker.removeFromSuperview()
                tableView.reloadData()
            }
            break
        case "Radio","sexRadio","Checkbox":
            if model?.type == "Checkbox" {
                // 多选
                let option = model?.options[indexPath.row]
                option?.isSelect = !(option?.isSelect ?? false)
            } else {
                guard let options = model?.options else { return }
                for option in options {
                    option.isSelect = false
                }
                let option = model?.options[indexPath.row]
                option?.isSelect = true
            }
            
            tableView.reloadData()
            break
        default:
            break
        }
    }
}

extension HDSQuestionnaireDetailView {
    private func showTips(_ tips: String?) {
        if let callback = tipsCallBack {
            callback(tips)
        }
    }
    @objc private func backBtnAction() {
        if let navBackCallBack = navBackCallBack {
            navBackCallBack("")
        }
    }
    @objc private func closeBtnAction() {
        if let closeCallBack = closeCallBack {
            closeCallBack("")
        }
    }
    @objc private func submitAction() {
        showLoadingView()
        let isRequired = checkRequired()
        if !isRequired {
            // 提示
            showTips("请填写必选项!")
            stopLoading()
            return
        }
        
        var params = [String: Any]()
        let formStyleModel = self.model?.formStyleModel ?? [HDSQuestionnaireStyleModel]()
        var formContent: Array = [Dictionary<String, Any>]()
        for styleModel in formStyleModel {
            if styleModel.options.count > 0 {
                var options = ""
                for option in styleModel.options {
                    if option.isSelect {
                        if options.count == 0 {
                            options = option.label
                        }
                    }
                }
                if options.count > 0 {
                    var dic: Dictionary = [String:Any]()
                    dic["name"] = styleModel.name
                    dic["value"] = options
                    dic["No"] = styleModel.no
                    dic["id"] = styleModel.id
                    formContent.append(dic)
                }
            } else {
                if styleModel.contentText.count > 0 {
                    var dic: Dictionary = [String:Any]()
                    dic["name"] = styleModel.name
                    dic["value"] = styleModel.contentText
                    dic["No"] = styleModel.no
                    dic["id"] = styleModel.id
                    
                    formContent.append(dic)
                }
            }
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: formContent, options: .prettyPrinted)
        guard let jsonData = jsonData else {
            // 解析失败 提示
            showTips("参数解析错误")
            stopLoading()
            return }
        let jsonString = String(data: jsonData, encoding: .utf8)
        params["formContent"] = jsonString
        params["formCode"] = self.model?.formCode
        quesFunc?.sendPushQuerResult(params, closure: {[weak self] result, string in
            self?.stopLoading()
            if !result {
                self?.showTips(string)
                return
            }
            DispatchQueue.main.async {
                self?.removeFromSuperview()
            }
            if result {
                if let submitCallBack = self?.submitCallBack {
                    submitCallBack(self?.model?.formCode)
                }
            }
        })
    }
    
    private func checkoutImgAndUplod(_ model: HDSQuestionnaireStyleModel?) {
        showLoadingView()
        quesFunc?.getUserSign(self.model?.userCode ?? "", closure: {[weak self] result, message in
            self?.stopLoading()
        }, dataCallBack: {[weak self] result, signModel in
            self?.stopLoading()
        })
    }
    
    private func uploadImg(_ model: HDSQuestionnaireSign?, _ styleModel: HDSQuestionnaireStyleModel?) {
        normalUploadRequest = OSSPutObjectRequest()
        normalUploadRequest?.bucketName = model?.bucket ?? ""
        let objectKey = "\(Date().timeIntervalSince1970)" + (model?.accessKeySecret ?? "")
        normalUploadRequest?.objectKey = objectKey
        let data = styleModel?.img.jpegData(compressionQuality: 1)
        if let data = data {
            normalUploadRequest?.uploadingData = data
        }
        normalUploadRequest?.isAuthenticationRequired = true
        
        let ossProvider = OSSStsTokenCredentialProvider(accessKeyId: model?.accessKeyId ?? "", secretKeyId: model?.accessKeySecret ?? "", securityToken: model?.securityToken ?? "")
        let cfg = OSSClientConfiguration()
        cfg.maxRetryCount = 3
        cfg.timeoutIntervalForRequest = 15
        cfg.isHttpdnsEnable = false
        cfg.crc64Verifiable = true
        
        defaultClient = OSSClient(endpoint: model?.endpoint ?? "", credentialProvider: ossProvider, clientConfiguration: cfg)
        guard let normalUploadRequest = normalUploadRequest else { return }
        let task = defaultClient?.putObject(normalUploadRequest)
        task?.continue({[weak self] task in
            self?.stopLoading()
            if task.error == nil {
                let task = self?.defaultClient?.presignPublicURL(withBucketName: model?.bucket ?? "", withObjectKey: model?.accessKeySecret ?? "")
                styleModel?.contentText = task?.result as? String ?? ""
            }
            return nil
        })
    }
    
    private func checkRequired() -> Bool {
        let formStyleModel = self.model?.formStyleModel ?? [HDSQuestionnaireStyleModel]()
        for styleModel in formStyleModel {
            if styleModel.required {
                // 必选项
                if styleModel.options.count > 0 {
                    // 选择题
                    var isSelect = false
                    for option in styleModel.options {
                        if option.isSelect {
                            isSelect = true
                        }
                    }
                    if !isSelect {
                        // 提示需要 选择必选项
                        return false
                    }
                } else {
                    /// 输入题
                    if styleModel.type == "ImageInput" {
                        let data = styleModel.img.jpegData(compressionQuality: 1)
                        if data == nil {
                            return false
                        }
                    } else if styleModel.type == "EmailInput" {
                        if styleModel.isCheck {
                            if !(styleModel.contentText.contains("@")) {
                                // 提示
                                return false
                            }
                        }
                    } else {
                        if styleModel.contentText.count == 0 {
                            // 提示
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    private func showLoadingView() {
        DispatchQueue.main.async {
            self.addSubview(self.loadingView)
            self.loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.loadingView.removeFromSuperview()
        }
    }
}

extension HDSQuestionnaireDetailView {
    private func createNavView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#333333".uicolor()
        return view
    }
    
    private func createBackBtn() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "返回白"), for: .normal)
        btn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        return btn
    }
    
    private func createCloseBtn() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "关闭2"), for: .normal)
        btn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return btn
    }
    
    private func createTitleLb() -> UILabel {
        let label = UILabel()
        label.textColor = "#FFFFFF".uicolor()
//        label.text = "测试title"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = "#FFFFFF".uicolor()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 125
        tableView.estimatedSectionFooterHeight = 0.01
        tableView.estimatedSectionHeaderHeight = 45
        return tableView
    }
    
    private func createBottomView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        return view
    }
    
    private func createSubmitBtn() -> UIButton {
        let btn = UIButton()
        btn.backgroundColor = "#FF9502".uicolor()
        btn.setTitle("提交", for: .normal)
        btn.setTitleColor("#FFFFFF".uicolor(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        return btn
    }
    
    private func createBottomLb() -> UILabel {
        let lb = UILabel()
        lb.text = "由获得场景提供技术支持"
        lb.textAlignment = .center
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = "#999999".uicolor()
        return lb
    }
    private func crateLoadingView() -> LoadingView {
        let loadingView = LoadingView(label: "正在发起请求...", centerY: true)
        
        return loadingView ?? LoadingView()
    }
}
