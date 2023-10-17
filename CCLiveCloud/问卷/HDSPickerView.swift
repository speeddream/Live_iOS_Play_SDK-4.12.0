//
//  HDSPickerView.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/6.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit
import SnapKit

enum HDSPickerType {
    case date
    case address
}
typealias HDSPickerCallBack = (_ result: Bool, _ content: String)->()
class HDSPickerView: UIView {
    private lazy var topView: UIView = createTopView()
    private lazy var lineView: UIView = createLineView()
    private lazy var cancleBtn: UIView = createCancleBtn()
    private lazy var okBtn: UIView = createOkBtn()
    
    private lazy var pickerView: UIPickerView = createPickerView()
    private lazy var datePickerView: UIDatePicker = createDatePickerView()
    var pickerCallBack: HDSPickerCallBack?
    private var type: HDSPickerType?
    private var addressModel: HDSAddressModel?
    
    private var provinceList:[HDSRegionModel]? = [HDSRegionModel]()
    private var cityList:[HDSRegionModel]? = [HDSRegionModel]()
    private var areaList:[HDSRegionModel]? = [HDSRegionModel]()
    
    private var selectOneRow: Int = 0
    private var selectTwoRow: Int = 0
    private var selectThreeRow: Int = 0
    
    init(frame: CGRect, type: HDSPickerType) {
        super.init(frame: frame)
        setupSubview(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview(type: HDSPickerType) {
        self.type = type
        backgroundColor = "#000000".uicolor(alpha: 0.5)
        addSubview(topView)
        if type == .date {
            addSubview(datePickerView)
            datePickerView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(217)
            }
            
            topView.snp.makeConstraints { make in
                make.right.left.equalToSuperview()
                make.bottom.equalTo(datePickerView.snp.top)
                make.height.equalTo(42)
            }
        } else {
            addressModel = HDSAddressModel.getAddressModel()
            provinceList = addressModel?.region as? [HDSRegionModel]
            getCitydate(0)
            getAreaDate(0)
            addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(217)
            }
            
            topView.snp.makeConstraints { make in
                make.right.left.equalToSuperview()
                make.bottom.equalTo(pickerView.snp.top)
                make.height.equalTo(42)
            }
            
            pickerView.reloadAllComponents()
        }
        
        topView.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(38)
        }
        
        topView.addSubview(okBtn)
        okBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(38)
        }
        
        topView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
    }
    
//    func addPickerCallBack(_ callBack: @escaping HDSPickerCallBack) {
//        pickerCallBack = callBack
//    }
}

extension HDSPickerView {
    private func getCitydate(_ row: Int) {
        let region = addressModel?.region[row] as? HDSRegionModel
        cityList = region?.children as? [HDSRegionModel]
    }
    
    private func getAreaDate(_ row: Int) {
        let region = cityList?[row]
        areaList = region?.children as? [HDSRegionModel]
    }
}

extension HDSPickerView {
    @objc func cancleAction() {
        if let pickerCallBack = pickerCallBack {
            pickerCallBack(false, "")
        }
    }
    
    @objc func okAction() {
        var content = ""
        if type == .date {
            
            let date = datePickerView.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            content = dateFormatter.string(from: date)
            
        } else {
            
            let ontRegion = provinceList?[selectOneRow]
            let twoRegion = cityList?[selectTwoRow]
            let threeRegion = areaList?[selectThreeRow]
            
            let provinceName = ontRegion?.name ?? ""
            let cityName = twoRegion?.name ?? ""
            let areaName = threeRegion?.name ?? ""
            content = provinceName + " / " + cityName + " / " + areaName
        }
        if let pickerCallBack = pickerCallBack {
            pickerCallBack(true, content)
        }
    }
}

extension HDSPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return provinceList?.count ?? 0
        } else if component == 1 {
            return cityList?.count ?? 0
        } else {
            return areaList?.count ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return provinceList?[row].name
        } else if component == 1 {
            return cityList?[row].name
        } else {
            return areaList?[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        static var oneRow = 0
//        static var tweRow = 0;
//        static var threeRow = 0;
        if component == 0 {
            selectOneRow = row
            
            getCitydate(row)
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            
            getAreaDate(0)
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        }
        
        if component == 1 {
            selectTwoRow = row
            
            getAreaDate(0)
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        }
        
        if component == 2 {
            selectThreeRow = row
        }
        
    }
}

extension HDSPickerView {
    private func createTopView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#FFFFFF".uicolor()
        return view
    }
    
    private func createLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = "#DDDDDD".uicolor()
        return view
    }
    
    private func createCancleBtn() -> UIButton {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor("#333333".uicolor(), for: .normal)
        btn.addTarget(self, action: #selector(cancleAction), for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        return btn
    }
    
    private func createOkBtn() -> UIButton {
        let btn = UIButton()
        btn.setTitle("完成", for: .normal)
        btn.setTitleColor("#FF9502".uicolor(), for: .normal)
        btn.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        return btn
    }
    
    private func createPickerView() -> UIPickerView {
        let picker = UIPickerView()
        picker.backgroundColor = "#FFFFFF".uicolor()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }
    
    private func createDatePickerView() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.backgroundColor = "#FFFFFF".uicolor()
        return picker
    }
}
