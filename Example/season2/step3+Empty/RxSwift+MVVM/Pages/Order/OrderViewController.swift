//
//  OrderViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderViewController: UIViewController {
    // MARK: - Life Cycle
    var viewModel: OrderViewModel?
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let totalPrice = 0
        //let vatPrice = Int(Float(allItemsPrice) * 0.1 / 10 + 0.5) * 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: update selected menu info
       
        self.viewModel?.orderList
            .bind(to: self.ordersList.rx.text)
        .disposed(by: disposedBag)
        self.viewModel?.totalItemPrice
            .map{$0.currencyKR()}
            .bind(to: self.itemsPrice.rx.text)
            .disposed(by: disposedBag)
        self.viewModel?.totalPriceText
            .bind(to: self.totalPrice.rx.text)
            .disposed(by: disposedBag)
        self.viewModel?.totalVAT
            .map{$0.currencyKR()}
            .bind(to: self.vatPrice.rx.text)
            .disposed(by: disposedBag)
        
        updateTextViewHeight()
    }

    // MARK: - UI Logic

    func updateTextViewHeight() {
        let text = ordersList.text ?? ""
        let width = ordersList.bounds.width
        let font = ordersList.font ?? UIFont.systemFont(ofSize: 20)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        let height = boundingBox.height

        ordersListHeight.constant = height + 40
    }

    // MARK: - Interface Builder

    @IBOutlet var ordersList: UITextView!
    @IBOutlet var ordersListHeight: NSLayoutConstraint!
    @IBOutlet var itemsPrice: UILabel!
    @IBOutlet var vatPrice: UILabel!
    @IBOutlet var totalPrice: UILabel!
}
