//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 유호준 on 2021/08/17.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    lazy var menuObservable = BehaviorSubject<[Menu]>(value: [])
    lazy var menuObservableRelay = BehaviorRelay<[Menu]>(value: [])//에러가 나도 끊어지지 않음!
    let activateObservable = BehaviorSubject<Bool>(value: false)
    let refresh = PublishSubject<Void>()
    let makeOrder = PublishSubject<Void>()
    let oredering = PublishSubject<[Menu]>()
    let errorMsg = PublishSubject<NSError>()
    let disposeBag = DisposeBag()
    
    init() {
//        let menus: [Menu] = [
//            Menu(id: 1, name: "튀김", price: 100, count: 0),
//            Menu(id: 2, name: "튀김", price: 100, count: 0),
//            Menu(id: 3, name: "튀김", price: 100, count: 0),
//            Menu(id: 4, name: "튀김", price: 100, count: 0)
//        ]
        _ = refresh.do(onNext: {_ in self.activateObservable.onNext(false)}) //refresh에서 next가 내려와 indicator hidden 속성 false로 만듬
            .flatMap{ _ -> Observable<Data> in //viewWillApper, refreshControll의 이벤트 발생으로 시작
           return APIService.fechAllMenusRx()
        }.map{data -> [MenuItem] in
            struct Response: Decodable {
            let menus: [MenuItem]
        }
            let response = try! JSONDecoder().decode(Response.self, from: data)
        return response.menus
        }.map{menuitems in
            menuitems.map{Menu.fromMenuItems(item: $0)}
        }.do(onNext: {_ in self.activateObservable.onNext(true)}) //fetching이 끝나면 indicator hidden으로
        .bind(to: self.menuObservable)
        .disposed(by: disposeBag)
        
        
        makeOrder.withLatestFrom(menuObservable).map{
            $0.filter{$0.count > 0}
        }.do{items in
            if items.count == 0{
                let err = NSError(domain: "No Orders", code: -1, userInfo: nil)
                self.errorMsg.onNext(err)
            }
        }.subscribe(onNext: {self.oredering.onNext($0)})
        .disposed(by: disposeBag)
    }
    

    
    lazy var itemCount = self.menuObservable.map{
        $0.map{$0.count}.reduce(0, +)
    }
    
    //var totalPrice: Observable<Int> = BehaviorSubject<Int>(value: 10000)
    /*
        밖에서 값을 변경해야되는데 어떡하지?
        Observable -> Subject로
     */
//    var totalPrice: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 10000)
    
    
    lazy var totalPrice = self.menuObservable.map{
        $0.map{$0.price * $0.count}.reduce(0, +)
    }
    
    func clearAllItemSelections(){
        _ = self.menuObservable.map{menus in
            return menus.map{m in
                Menu(id: m.id, name: m.name, price: m.price, count: 0)
            }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.onNext($0)
        })
    }
    
    func changeCount(item: Menu, increase: Int){
      
       _ = self.menuObservable.observeOn(MainScheduler.asyncInstance).map{menus in
            let index = menus.lastIndex{return $0.id==item.id}

            if let i = index{
                var newMenus = menus
                newMenus[i].count = max(menus[i].count+increase, 0)
                return newMenus
            }
            else{
                return menus
            }
        }.take(1).subscribe(onNext: {self.menuObservable.onNext($0)})
    }
    
    
}
