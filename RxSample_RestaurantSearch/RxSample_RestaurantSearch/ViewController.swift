//
//  ViewController.swift
//  RxSample_RestaurantSearch
//
//  Created by t-watanabe on 2023/02/18.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private lazy var viewModel: ViewModel = ViewModel(textFieldObservable: textField.rx.text.asObservable(),
                                                      buttonObservable: button.rx.tap.asObservable())
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        disposeBag.insert(
            button.rx.tap.bind(to: viewModel.buttonPublishSubject),
            tableView.rx.setDelegate(self),
            viewModel.shopNameList.asObservable()
                .bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, element, cell in
                    cell.textLabel?.text = element
            }
        )
    }
}
