//
//  ViewModel.swift
//  RxSample_RestaurantSearch
//
//  Created by t-watanabe on 2023/02/19.
//

import Foundation
import RxSwift
import RxRelay

class ViewModel {

    let buttonPublishSubject: PublishSubject<Void> = PublishSubject<Void>()
    let shopNameList: BehaviorRelay<[String]> = BehaviorRelay<[String]>(value: [])
    var searchText: String = ""

    private let disposeBag: DisposeBag = DisposeBag()

    init(textFieldObservable: Observable<String?>, buttonObservable: Observable<Void>) {
        disposeBag.insert(
            textFieldObservable
                .subscribe(onNext: { [weak self] inputText in
                    guard let wSelf = self,
                          let inputText = inputText else { return }
                    wSelf.searchText = inputText
                }),

            buttonPublishSubject
                .subscribe(onNext: { [weak self] in
                    guard let wSelf = self,
                          !wSelf.searchText.isEmpty else { return }
                    wSelf.fetchShopList(keyWord: wSelf.searchText)
                })
        )
    }

    func fetchShopList(keyWord: String) {
        guard let apiKey = ApiKeyManager().getValue(key: "shopListApiKey"),
              let encodedKwd = keyWord.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(Const.shopListApiUrl)?format=json&key=\(apiKey)&keyword=\(encodedKwd)") else { return }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.rx.response(request: urlRequest)
            .subscribe(
                onNext: { [weak self] response, data in
                    guard let wSelf = self,
                          let gourmet = try? JSONDecoder().decode(Gourmet.self, from: data) else { return }
                    wSelf.shopNameList.accept(gourmet.results.shop.map { $0.name })
                }
            )
            .disposed(by: disposeBag)
    }
}


struct Const {
    static let shopListApiUrl = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1"
}

class ApiKeyManager {
    private let keyFilePath = Bundle.main.path(forResource: "apiKey", ofType: "plist")

    func getValue(key: String) -> String? {
        guard let keyFilePath = keyFilePath,
              let dic = NSDictionary(contentsOfFile: keyFilePath) else { return nil }
        return dic[key] as? String
    }
}

