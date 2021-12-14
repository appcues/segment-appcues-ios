//
//  GroupViewController.swift
//  SegmentDestinationExample
//
//  Created by James Ellis on 12/14/21.
//

import UIKit
import Segment

class GroupViewController: UIViewController {
    @IBOutlet private var groupIDTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.shared.screen(title: "Update Group")
    }

    @IBAction private func saveGroupTapped(_ sender: Any) {
        view.endEditing(true)
        guard let groupId = groupIDTextField.text else { return }
        Analytics.shared.group(groupId: groupId, traits: [
            "test_user": true
        ])
    }
}
