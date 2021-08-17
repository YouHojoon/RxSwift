//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by 유호준 on 2021/08/17.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation

//ViewModel
struct Menu{
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu{
    static var id: Int = 0
    static func fromMenuItems(item: MenuItem) -> Menu {
        let nextId = id
        id += 1
        return Menu(id: nextId, name: item.name, price: item.price, count: 0)
    }
}
