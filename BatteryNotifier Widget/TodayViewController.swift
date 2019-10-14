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

    @IBOutlet var listViewController: NCWidgetListViewController!
    private var needsUpdate = false
    
    // MARK: - NSViewController

    override var nibName: String? {
        return "TodayViewController"
    }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        updateDeviceContent()
    }

    @objc
    func sharedDefaultsDidChange(notification: NSNotification) {
        needsUpdate = true
    }

    @discardableResult
    func updateDeviceContent() -> Bool {
        guard needsUpdate else { return false }

        let sharedDefaults = UserDefaults.sharedSuite!

        if let devicesDict = sharedDefaults.dictionary(forKey: "Devices") {
            listViewController.contents = Array(devicesDict.values)

            return true
        } else {
            return false
        }
    }
}

// MARK: - NCWidgetProviding
extension TodayViewController : NCWidgetProviding {

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler( updateDeviceContent() ? .newData : .noData )
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        let inset = NSEdgeInsets(top: defaultMarginInset.top, left: 3, bottom: defaultMarginInset.bottom, right: defaultMarginInset.right)
        return inset
    }

}

// MARK: - NCWidgetListViewDelegate
extension TodayViewController : NCWidgetListViewDelegate {

    func widgetList(_ list: NCWidgetListViewController, viewControllerForRow row: Int) -> NSViewController {
        let listRow = ListRowViewController()
        listRow.representedObject = list.contents[row]

        return listRow
    }

}
