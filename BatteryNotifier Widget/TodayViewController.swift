//
//  TodayViewController.swift
//  BatteryNotifier Widget
//
//  Created by Kalvin Loc on 3/24/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import NotificationCenter

final class TodayViewController: NSViewController {

    private var needsUpdate = false

    // MARK: Children

    @IBOutlet private var listViewController: NCWidgetListViewController!

    // MARK: Init

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // TODO: Does this really detect change of UserDefaults, withSuite, or both?
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sharedDefaultsDidChange(notification:)),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sharedDefaultsDidChange(notification:)),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }

    // MARK: - NSViewController

    override var nibName: String? { "TodayViewController" }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateDeviceContent()
    }

}

// MARK: - Actions
private extension TodayViewController {

    /// Updates list content. Returns `true` if content was updated; otherwise `false`.
    @discardableResult
    func updateDeviceContent() -> Bool {
        guard needsUpdate else { return false }

        if let devices = DeviceStore.getDevices() {
            listViewController.contents = devices // TODO Does this work with set?

            return true
        } else {
            return false
        }
    }

}

// MARK: - Events
private extension TodayViewController {

    @objc
    func sharedDefaultsDidChange(notification: NSNotification) {
        needsUpdate = true
    }

}

// MARK: - NCWidgetProviding
extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        completionHandler( updateDeviceContent() ? .newData : .noData )
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        // TODO Redo this
        let inset = NSEdgeInsets(top: defaultMarginInset.top,
                                 left: 3,
                                 bottom: defaultMarginInset.bottom,
                                 right: defaultMarginInset.right)
        return inset
    }

}

// MARK: - NCWidgetListViewDelegate
extension TodayViewController: NCWidgetListViewDelegate {

    func widgetList(_ list: NCWidgetListViewController, viewControllerForRow row: Int) -> NSViewController {
        let listRow = ListRowViewController()
        listRow.representedObject = list.contents[row]

        return listRow
    }

}
