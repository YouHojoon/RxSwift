//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
   let cellId = "MenuItemTableViewCell"
    
    let viewModel: MenuListViewModel
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = MenuListViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
//        self.itemCountLabel.text = "\(self.viewModel.itemCount)"
//        self.totalPrice.text = self.viewModel.totalPrice.currencyKR()
//        self.activityIndicator.isHidden = false
        
        
        
      
        //drive는 항상 main 스레드가 돈다, + 에러처리
//        self.viewModel.itemCount.map{"\($0)"}
//            .asDriver(onErrorJustReturn: "")
//            .drive(self.itemCountLabel.rx.text)
//            .disposed(by: disposeBag)
        
//        self.viewModel.itemCount.map{"\($0)"}
//            .subscribe(onNext: {
//                self.itemCountLabel.text = $0
//            }).disposed(by: disposeBag)
//
//        self.viewModel.totalPrice
////            .scan(0, accumulator: +)
//            .map{$0.currencyKR()}
//            .subscribe(onNext: {[weak self] in //순환 참조 막기
//                        self?.totalPrice.text="\($0)"}).disposed(by: disposeBag)
//
        self.setupBinding()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
            let selectedMenus = sender as? [Menu] ?? [Menu]()
            let orderViewModel = OrderViewModel(selectedMenus)
            orderVC.viewModel = orderViewModel
        }
    }



    // MARK: - InterfaceBuilder Links

    @IBOutlet var orderButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        self.viewModel.clearAllItemSelections()
    }

//    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
        
//
//    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.menus.count
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//        let menu = viewModel.menus[indexPath.item]
//        cell.title.text = "\(menu.name)"
//        cell.price.text = "\(menu.price)"
//        cell.count.text = "\(menu.count)"
//
//        return cell
//    }
//}
extension MenuViewController{
    func setupBinding() {

        //이것으로 인해 TableViewDataSource를 구현할 필요가 사라진다
         self.viewModel.menuObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: cellId,cellType: MenuItemTableViewCell.self)){index, item, cell in
                 //index = indexPath.row, item=menuObservable[index], cell = dequeue해서 cellType의 instance를 가져와준다
                 cell.title.text = item.name
                 cell.price.text = "\(item.price)"
                 cell.count.text = "\(item.count)"
                 
//                 cell.onChange = {[weak self] increase in
//                     self?.viewModel.changeCount(item: item, increase: increase)
//                 }
                cell.change
                    .subscribe(onNext: {self.viewModel.changeCount(item: item, increase: $0)})
                    .disposed(by: cell.disposeBag)
                
             }.disposed(by: disposeBag)
        
        //bind
        self.viewModel.itemCount.map{"\($0)"}
            .bind(to: self.itemCountLabel.rx.text)//bind는 weak self를 안해도 순환참조를 막아준다
            .disposed(by: disposeBag)
        
        self.viewModel.totalPrice
            .map{$0.currencyKR()}
            .bind(to: self.totalPrice.rx.text).disposed(by: disposeBag)
        
        bindMenu()
        bindOrder()
        
        
        
        
        
        //에러 메시지 처리
        self.viewModel.errorMsg
            .map{$0.domain}
            .subscribe(onNext: {[weak self]msg in
                        self?.showAlert("Order Fail", msg)})
            .disposed(by: disposeBag)
    }
    func bindMenu(){
        //첫 등장 + 새로고침
        self.viewModel.activateObservable.observeOn(MainScheduler.instance)
            .do{[weak self] isHidden in
                if isHidden{
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .bind(to: self.activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        let viewAppear = self.rx
            .viewWillAppear
            .take(1).map{_ -> Void in ()}
        let refresh = self.tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map{_ -> Void in ()} ?? Observable.just(())
        Observable.merge([viewAppear, refresh])
            .bind(to: self.viewModel.refresh)
            .disposed(by: disposeBag)
    }
    
    func bindOrder(){
        //order button 눌렸을 때
        self.orderButton.rx.tap
            .bind(to: self.viewModel.makeOrder
            ).disposed(by: disposeBag)
        
        //order button 눌렀을 때 화면 이동 처리
        self.viewModel.oredering
            .subscribe(onNext: {
                self.performSegue(withIdentifier: "OrderViewController", sender: $0)
            }).disposed(by: disposeBag)
    }

}


