//
//  EventsViewController.swift
//  SegmentDestinationExample
//
//  Created by James Ellis on 10/13/21.
//

import UIKit
import Segment
import Segment_Appcues

class EventsViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.shared.screen(title: "Events Screen")
    }

    @IBAction private func buttonOneTapped(_ sender: UIButton) {
        Analytics.shared.track(name: "event1")
    }

    @IBAction private func buttonTwoTapped(_ sender: UIButton) {
        Analytics.shared.track(name: "event2")
    }

    @IBAction private func debugTapped(_ sender: Any) {
        AppcuesDestination.shared.appcues?.debug()
    }
}
