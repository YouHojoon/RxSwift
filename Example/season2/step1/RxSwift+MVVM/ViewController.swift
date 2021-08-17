//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    func downloadJson(_ url: String, _ completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let url = URL(string: MEMBER_LIST_URL)!
            let data = try! Data(contentsOf: url)
            let json = String(data: data, encoding: .utf8)
            
            DispatchQueue.main.async {
                completion(json)
            }
        }
    }
    
    func downloadJsonAsync(_ url: String) -> Observable<String?> {
        return Observable<String?>.create{observer -> Disposable in
            let url = URL(string: MEMBER_LIST_URL)!
//            let data = try! Data(contentsOf: url)
//            let json = String(data: data, encoding: .utf8)
//
//            observer.onNext(json)
//            observer.onCompleted()
            
            let task = URLSession.shared.dataTask(with: url){data, _, err in
                guard err == nil else {
                    observer.onError(err!)
                    return
                }
            if let dat = data, let json = String(data: dat, encoding: .utf8){
                observer.onNext(json)
            }
            }
            task.resume()
            
            return Disposables.create{task.cancel()} // 중간에 캔슬했을 시
        }.observeOn(MainScheduler.instance) // 메인 스레드에서 실행
    }
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        
//        downloadJson(MEMBER_LIST_URL){json in
//            self.editView.text = json
//            self.setVisibleWithAnimation(self.activityIndicator, false)
//        }
        
        downloadJsonAsync(MEMBER_LIST_URL).subscribe{ event in
            switch event{
            case let .next(json):
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            case .completed:
                break
            case .error:
                break
            }
            
        }.disposed(by: bag)
    }
}
