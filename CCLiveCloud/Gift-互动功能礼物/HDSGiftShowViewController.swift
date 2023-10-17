//
//  HDSGiftShowViewController.swift
//  AnimationTD
//
//  Created by David Zhao on 2022/3/25.
//

import UIKit
import SDWebImage

struct HDSCardViewModel: Equatable {
    let id = UUID().uuidString
    let headIconUrlStr: String
    let donateName: String
    let giftName: String
    let giftIconUrlStr: String
    let giftCount: String
    
    static func ==(modelA: HDSCardViewModel, modelB: HDSCardViewModel) -> Bool {
        return modelA.id == modelB.id
    }
}

class HDSGiftShowViewController: UIViewController {
    @objc var playLimitCount: Int = 5 {
        didSet {
            if playLimitCount < 3 {
                playLimitCount = 3
            }
        }
    }
    
    @objc var bornFromLeftSide = true
    
    private var centerShowingBusy = false
    
    private var waitingGifts: [HDSCardViewModel] = []
    
    private var waitingVIPGifts: [HDSCardViewModel] = []
    
    private var showingCards: [HDSCardView] = [] {
        didSet {
            if bornFromLeftSide == true {
                if showingCards.count == 0 {
                    stopTimer()
                }
            } else {
                if showingCards.count == 0 && waitingGifts.count == 0 {
                    stopTimer()
                }
            }
        }
    }
    private var cardPlayTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureData()
        configureView()
        configureConstraint()
    }
    
    private func configureData() {

    }
    
    private func configureView() {
        view.clipsToBounds = true
    }
    
    private func configureConstraint() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func startTimer() {
            guard cardPlayTimer == nil else { return }
            var timeStep = 0.75
            if bornFromLeftSide == false {
                timeStep = 1
            }
            cardPlayTimer = Timer.scheduledTimer(withTimeInterval: timeStep, repeats: true, block: {[weak self] t in
                if let vipGifts = self?.waitingVIPGifts, vipGifts.count > 0 {
                    if self?.bornFromLeftSide == false && self?.centerShowingBusy == true {
                        return
                    }
                    guard let one = self?.waitingVIPGifts.removeFirst() else { return }
                    guard let bornLeft = self?.bornFromLeftSide else { return }
                    if bornLeft == true {
                        self?.addNewCard(viewModel: one)
                    } else {
                        self?.addNewBoard(viewModel: one)
                    }
                    return
                }
                
                guard let gifts = self?.waitingGifts, gifts.count > 0 else { return }
                if self?.bornFromLeftSide == false && self?.centerShowingBusy == true {
                    return
                }
                guard let one = self?.waitingGifts.removeFirst() else { return }
                guard let bornLeft = self?.bornFromLeftSide else { return }
                if bornLeft == true {
                    self?.addNewCard(viewModel: one)
                } else {
                    self?.addNewBoard(viewModel: one)
                }
            })
        }
    
    private func stopTimer() {
        print("stop gift play timer")
        cardPlayTimer?.invalidate()
        cardPlayTimer = nil
    }
    
    private func addNewCard(viewModel: HDSCardViewModel) {
        let card = HDSCardView(origin: CGPoint(x: -300, y: 200), verticalOffSet: -150, viewModel: viewModel)
        card.disappearClosure = {[weak self] in
            card.removeFromSuperview()
            if let index = self?.showingCards.firstIndex(of: card) {
                self?.showingCards.remove(at: index)
            }
            print("left showing", self?.showingCards.count)
            print("left waiting", self?.waitingGifts.count)
            print("subviews", self?.view.subviews.count)
        }
        view.addSubview(card)
        showingCards.append(card)
    }
    
    private func addNewBoard(viewModel: HDSCardViewModel) {
        guard centerShowingBusy == false else { return }
        centerShowingBusy = true
        let card = HDSCardView(origin: CGPoint.zero, verticalOffSet: 0, viewModel: viewModel, withAnimation: false, lifeDuration: 5)
        card.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - 80)
        card.disappearClosure = {[weak self] in
            card.removeFromSuperview()
            if let index = self?.showingCards.firstIndex(of: card) {
                self?.showingCards.remove(at: index)
            }
            print("left showing", self?.showingCards.count)
            print("left waiting", self?.waitingGifts.count)
            print("subviews", self?.view.subviews.count)
            self?.centerShowingBusy = false
        }
        view.addSubview(card)
        showingCards.append(card)
        let bigGiftImageViewWidth = card.frame.width * 1.1
        let bigGiftImageView = HDSCustomBaseAnimationImageView(frame: CGRect(origin: .zero, size: CGSize(width: bigGiftImageViewWidth, height: bigGiftImageViewWidth)))
        bigGiftImageView.backgroundColor = .clear
        bigGiftImageView.contentMode = .scaleAspectFit
        bigGiftImageView.center = CGPoint(x: view.frame.width / 2, y: card.frame.origin.y - bigGiftImageViewWidth / 2 - 10)
        let urlStr = viewModel.giftIconUrlStr.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
        if let url = URL(string: urlStr ?? viewModel.giftIconUrlStr) {
            bigGiftImageView.sd_setImage(with: url)
        }
        view.addSubview(bigGiftImageView)
    }
}

// MARK: - API
extension HDSGiftShowViewController {
    public func addNewGift(gift: HDSCardViewModel) {
        startTimer()
        if waitingGifts.count >= playLimitCount {
            print("upto limited remove first")
            waitingGifts.removeFirst()
        }
        waitingGifts.append(gift)
        print("append new gift all \(waitingGifts.count)")
    }
    
    @objc func addNewGiftOC(gift: HDSReceivedGiftModel) {
        let viewModel = HDSCardViewModel(headIconUrlStr: gift.avatar, donateName: gift.fromUser, giftName: gift.giftName, giftIconUrlStr: gift.giftImg, giftCount: "\(gift.giftNum)")
        addNewGift(gift: viewModel)
    }
    
    @objc func addMineGiftOC(gift: HDSReceivedGiftModel) {
        startTimer()
        let viewModel = HDSCardViewModel(headIconUrlStr: gift.avatar, donateName: gift.fromUser, giftName: gift.giftName, giftIconUrlStr: gift.giftImg, giftCount: "\(gift.giftNum)")
        waitingVIPGifts.append(viewModel)
    }
}
