//
//  OrderViewModel.swift
//  RxSwift+MVVM
//
//  Created by 유호준 on 2021/08/17.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class OrderViewModel{
    
    var selectedMeus = BehaviorSubject<[Menu]>(value: [])
    
    init(_ selectedMenus: [Menu]) {
        self.selectedMeus.onNext(selectedMenus)
    }
    
    lazy var orderList = self.selectedMeus.map{
        $0.map{"\($0.name) \($0.count)개\n"}.reduce("", +)
    }
    
    lazy var totalItemPrice = self.selectedMeus.map{
        $0.map{$0.price * $0.count}.reduce(0, +)
    }
    
    lazy var totalVAT = self.totalItemPrice.map{Int(Float($0) * 0.1)}
    
    
    lazy var totalPriceText = Observable.combineLatest(totalVAT, totalItemPrice){ $0 + $1}
        .map{$0.currencyKR()}
}
