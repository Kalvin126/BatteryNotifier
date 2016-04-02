//
//  TodayViewController.swift
//  BatteryNotifier Widget
//
//  Created by Kalvin Loc on 3/24/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController {

    @IBOutlet var listViewController: NCWidgetListViewController!
    private var needsUpdate = false
    
    // MARK: - NSViewController

    override var nibName: String? {
        return "TodayViewController"
    }

    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // TODO: Does this really detect change of NSUserDefaults, withSuite, or both?
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sharedDefaultsDidChange(_:)), name:NSUserDefaultsDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sharedDefaultsDidChange(_:)), name:NSUserDefaultsDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       updateDeviceContent()
    }


    func sharedDefaultsDidChange(notification: NSNotification) {
        needsUpdate = true
    }

    func updateDeviceContent() -> Bool {
        guard needsUpdate else { return false }

        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!

        if let devicesDict = sharedDefaults.dictionaryForKey("Devices") {
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
        completionHandler( updateDeviceContent() ? .NewData : .NoData )
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        let inset = NSEdgeInsets(top: defaultMarginInset.top, left: 3, bottom: defaultMarginInset.bottom, right: defaultMarginInset.right)
        return inset
    }

}

// MARK: - NCWidgetListViewDelegate
extension TodayViewController : NCWidgetListViewDelegate {

    func widgetList(list: NCWidgetListViewController!, viewControllerForRow row: Int) -> NSViewController! {
        let listRow = ListRowViewController()
        listRow.representedObject = list.contents[row]

        return listRow
    }

}
