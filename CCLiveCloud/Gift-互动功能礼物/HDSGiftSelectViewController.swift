//
//  HDSGiftSelectViewController.swift
//  HDSGiftUI
//
//  Created by David Zhao on 2022/3/17.
//

import UIKit
import SDWebImage

@objc protocol HDSGiftSelectViewControllerDelegate: NSObjectProtocol {
    func hdsGiftSelectViewControllerDidDonate(gift: HDSGiftListSingleModel, count: Int)
    func hdsGiftSelectViewControllerDidCancel()
}

class HDSGiftSelectViewController: UIViewController {
    
    @objc public weak var delegate: HDSGiftSelectViewControllerDelegate?
    
    private let horizontalSideGap: CGFloat = 10
    private let verticalSideGap: CGFloat = 50
    private let betweenGap: CGFloat = 5
    private var cardWidth: CGFloat = 0
    private var cardHeight: CGFloat = 0
    private var gifts: [HDSGiftListSingleModel] = []
    
    private var safeBottom: CGFloat = 0
    private var currentSelectedGiftIndex = 0
    private var donateCount = 1 {
        didSet {
            countTextField.text = "\(donateCount)"
            fakeCountTextField.setTitle("\(donateCount)", for: .normal)
        }
    }
    
    private var cardButons: [UIButton] = []
    private var oneLineCount: Int {
        if UIDevice.current.model.lowercased().contains("ipad") {
            return 6
        } else {
            return 3
        }
    }
    
    private lazy var countTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.orange.cgColor
        textField.text = "\(donateCount)"
        textField.delegate = self
        textField.isHidden = true
        textField.returnKeyType = .done

        return textField
    }()
    
    private lazy var increaseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(countChangeTapped(sender:)), for: .touchUpInside)
        button.tag = 1
        button.layer.cornerRadius = 5
        button.isHidden = true
        return button
    }()
    
    private lazy var reduceButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(countChangeTapped(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.isHidden = true
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(closeTapped(sender:)), for: .touchUpInside)
        return button
    }()

    private lazy var mScroll: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isPagingEnabled = true
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var donateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.setTitle("确认打赏", for: .normal)
        button.addTarget(self, action: #selector(donateTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fakeCountTextField: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.0
        button.setTitleColor(.black, for: .normal)
        button.setTitle("1", for: .normal)
        button.addTarget(self, action: #selector(fakeCountTextFieldTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemOrange
        return label
    }()
    
    @objc
    convenience init(giftArray:[HDSGiftListSingleModel]) {
        self.init()
        gifts = giftArray
    }
    
    deinit {
        print("🔴 HDSGiftSelectViewController killed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🟢 HDSGiftSelectViewController viewDidLoad")
        // Do any additional setup after loading the view.
        configureData()
        configureView()
        configureConstraint()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureScrollConstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // get scrollView content size
        guard mScroll.frame != .zero, mScroll.contentSize == .zero else { return }
        cardWidth = (view.frame.width - horizontalSideGap * 2 - betweenGap * 2) / CGFloat(oneLineCount)
        cardHeight = cardWidth

        let rowCount = ceil(Double(gifts.count) / Double(oneLineCount))
        var allCardHeight = (cardHeight + betweenGap) * rowCount
        if allCardHeight < mScroll.frame.height {
            allCardHeight = mScroll.frame.height
        }
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: allCardHeight)
        mScroll.isPagingEnabled = false
        print(mScroll.frame)
        print(mScroll.contentSize)
        
        configureGiftCard()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func configureData() {
        if UIScreen.main.bounds.size.width > 736 || UIScreen.main.bounds.size.height > 736 {
            safeBottom = 34
        }
    }
    
    private func configureView() {
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.addSubview(countTextField)
        view.addSubview(increaseButton)
        view.addSubview(reduceButton)
        view.addSubview(closeButton)
        view.addSubview(mScroll)
        view.addSubview(countLabel)
        countLabel.text = "数量(个) :"
        view.addSubview(fakeCountTextField)
        view.addSubview(totalLabel)
        totalLabel.text = "合计 : 免费"
        view.addSubview(donateButton)
    }
    
    private func configureConstraint() {
        
        countTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        countTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        countTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        countTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        reduceButton.leftAnchor.constraint(equalTo: countTextField.rightAnchor, constant: 8).isActive = true
        reduceButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        reduceButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        reduceButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        increaseButton.leftAnchor.constraint(equalTo: reduceButton.rightAnchor, constant: 3).isActive = true
        increaseButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        increaseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        increaseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        countLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: horizontalSideGap).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10 - safeBottom).isActive = true
        countLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        fakeCountTextField.leftAnchor.constraint(equalTo: countLabel.rightAnchor).isActive = true
        fakeCountTextField.widthAnchor.constraint(equalToConstant: 55).isActive = true
        fakeCountTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        fakeCountTextField.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor).isActive = true
 
        totalLabel.rightAnchor.constraint(equalTo: donateButton.leftAnchor, constant: -5).isActive = true
        totalLabel.bottomAnchor.constraint(equalTo: countLabel.bottomAnchor).isActive = true
        totalLabel.widthAnchor.constraint(equalToConstant: 85).isActive = true
        totalLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        donateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15 - safeBottom).isActive = true
        donateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        donateButton.widthAnchor.constraint(equalToConstant: 95).isActive = true
        donateButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        donateButton.layer.cornerRadius = 17
    }
    
    private func configureScrollConstraint() {
        mScroll.topAnchor.constraint(equalTo: view.topAnchor, constant: verticalSideGap).isActive = true
        mScroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mScroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54 - safeBottom).isActive = true
   }

    private func configureGiftCard() {
        for (index, model) in gifts.enumerated() {
            print("row ", index)
            // add all gift card button
            let rowCount = ceil(Double(index / oneLineCount))
            let columbCount = Float(index).truncatingRemainder(dividingBy: Float(oneLineCount))
            let oneCard = UIButton(frame: CGRect(x: horizontalSideGap + CGFloat(columbCount) * betweenGap + CGFloat(columbCount) * cardWidth, y: rowCount * betweenGap + rowCount * cardHeight, width: cardWidth, height: cardHeight))
            oneCard.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
            oneCard.addTarget(self, action: #selector(giftCardTapped(sender:)), for: .touchUpInside)
            oneCard.layer.cornerRadius = 10
            oneCard.tag = index
            mScroll.addSubview(oneCard)
            cardButons.append(oneCard)
            
            // add image
            let urlStr = model.giftThumbnail.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
//            var iv = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: oneCard.frame.width / 2.2, height: oneCard.frame.height / 2.2)))
//            if urlStr?.hasSuffix(".gif") == true {
             let iv = SDAnimatedImageView(frame: CGRect(origin: .zero, size: CGSize(width: oneCard.frame.width / 2.2, height: oneCard.frame.height / 2.2)))
//            }
            iv.center = CGPoint(x: oneCard.center.x, y: oneCard.center.y - oneCard.frame.height / 8)
            iv.backgroundColor = .clear
            if let url = URL(string: urlStr ?? model.giftThumbnail) {
                iv.sd_setImage(with: url)
            }
            mScroll.addSubview(iv)
            
            // add gift title
            let titleLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: oneCard.frame.width * 0.8, height: 20)))
            titleLabel.center = CGPoint(x: iv.center.x, y: iv.center.y + iv.frame.height / 2 + titleLabel.frame.height / 2)
            titleLabel.textAlignment = .center
            titleLabel.text = model.giftName;
            titleLabel.textColor = .black
            mScroll.addSubview(titleLabel)
            
            // add gift price
            let priceLabel = UILabel(frame: titleLabel.frame)
            priceLabel.center = CGPoint(x: titleLabel.center.x, y: titleLabel.center.y + titleLabel.frame.height / 2 + priceLabel.frame.height / 2)
            priceLabel.textAlignment = .center
            priceLabel.text = "免费"
            priceLabel.font = UIFont.systemFont(ofSize: 13)
            priceLabel.textColor = .lightGray
            mScroll.addSubview(priceLabel)
        }
    }
    
    private func hightLightCard() {
        let oneCard = cardButons[currentSelectedGiftIndex]
        oneCard.backgroundColor = UIColor(red: 255/255, green: 132/255, blue: 47/255, alpha: 0.08)
        oneCard.layer.borderColor = UIColor.orange.cgColor
        oneCard.layer.borderWidth = 1.0
    }
    
    private func clearSelectedCardHighLight() {
        let oneCard = cardButons[currentSelectedGiftIndex]
        oneCard.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        oneCard.layer.borderWidth = 0
        oneCard.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func endEdit() {
        countTextField.resignFirstResponder()
        countTextField.isHidden = true
        reduceButton.isHidden = true
        increaseButton.isHidden = true
    }
}


// MARK: - OBJC Selector
extension HDSGiftSelectViewController {
    @objc
    private func fakeCountTextFieldTapped(sender: UIButton) {
        countTextField.isHidden = false
        reduceButton.isHidden = false
        increaseButton.isHidden = false
        countTextField.becomeFirstResponder()
    }
    
    @objc
    private func countChangeTapped(sender: UIButton) {
        switch sender.tag {
        case 1:
            if let text = countTextField.text, let count = Int(text) {
                donateCount = count + 1
            } else {
                donateCount = 1
            }
        default:
            if let text = countTextField.text, let count = Int(text) {
                donateCount = count - 1
            } else {
                donateCount = 1
            }
            if donateCount == 0 {
                donateCount = 1
            }
        }
    }
    
    @objc
    private func closeTapped(sender: UIButton) {
        print("gift select view close tapped")
        view.removeFromSuperview()
        self.removeFromParent()
        delegate?.hdsGiftSelectViewControllerDidCancel()
    }
    
    @objc
    private func giftCardTapped(sender: UIButton) {
        print("selected gift card ", sender.tag)
        endEdit()
        clearSelectedCardHighLight()
        currentSelectedGiftIndex = sender.tag
        hightLightCard()
    }
    
    @objc
    private func donateTapped(sender: UIButton) {
        view.removeFromSuperview()
        self.removeFromParent()
        guard gifts.count > 0 else { return }
        delegate?.hdsGiftSelectViewControllerDidDonate(gift: gifts[currentSelectedGiftIndex], count: donateCount)
    }
}

// MARK: - Scroll View Delegate
extension HDSGiftSelectViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mScroll {
            endEdit()
        }
    }
}

// MARK: - TextField Delegate
extension HDSGiftSelectViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = "\(donateCount)"
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let newNumber = Int(text) else {
            countTextField.text = "\(donateCount)"
            return
        }
        donateCount = newNumber
        countTextField.text = "\(donateCount)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEdit()
        return true
    }
}
