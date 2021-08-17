//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!
    
    let change =  PublishSubject<Int>()
    var onChange: ((Int) -> Void)?
    var disposeBag = DisposeBag()
    
    @IBAction func onIncreaseCount() {
        self.change.onNext(1)
        
    }

    @IBAction func onDecreaseCount() {
        self.change.onNext(-1)
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
}
