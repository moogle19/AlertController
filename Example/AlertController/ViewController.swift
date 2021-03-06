//
//  ViewController.swift
//  AlertController
//
//  Created by Marcel Dittmann on 02/26/2016.
//  Copyright (c) 2016 Marcel Dittmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    func presentAlertControllerWithTwoButtons() {

        let alertController = AlertController(
            title: "Title",
            message: "Lorem Ipsum",
            blurStyle: .extraLight,
            tintColor: .blue
        )

        alertController.addAction(
            action: AlertAction(title: "Default", style: .default, tintColor: .yellow, handler: nil)
        )

        alertController.addAction(
            action: AlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true) { () -> Void in

        }
    }

    func presentAlertControllerWithButtonsAndTextField() {

        let alertController = AlertController(
            title: "Title",
            message: "Lorem Ipsum"
        )

        alertController.addAction(
            action: AlertAction(title: "Default", style: .default, handler: nil)
        )

        alertController.addAction(
            action: AlertAction(title: "Cancel", style: .cancel, handler: nil)
        )

        alertController.addAction(
            action: AlertAction(title: "Destructive", style: .destructive, handler: nil)
        )

        alertController.addTextFieldWithConfigurationHandler { (_) -> Void in

        }

        self.present(alertController, animated: true)

    }

    func presentAlertControllerWithIcon() {

        let alertController = AlertController(
            title: "Title",
            message: "Lorem Ipsum",
            icon: #imageLiteral(resourceName: "Icon"),
            preferredStyle: .alert,
            blurStyle: .dark
        )

        alertController.addAction(action: AlertAction(title: "Default", style: .default))

        alertController.addAction(action: AlertAction(title: "Cancel", style: .cancel))

        alertController.addAction(
            action: AlertAction(title: "Destructive", style: .destructive)
        )

        alertController.addTextFieldWithConfigurationHandler { (_) -> Void in

        }

        present(alertController, animated: true)

    }

    func presentAlertControllerWithActionSheetStyle() {

        let alertController = AlertController(
            title: "Title",
            message: "Lorem Ipsum",
            preferredStyle: .actionSheet
        )

        alertController.addAction(
            action: AlertAction(title: "Default", style: .default)
        )

        alertController.addAction(
            action: AlertAction(title: "Cancel", style: .cancel)
        )

        alertController.addAction(
            action: AlertAction(title: "Destructive", style: .destructive)
        )

        present(alertController, animated: true)

    }

    @IBAction func exampleButton1Tapped(_ sender: AnyObject) {
        presentAlertControllerWithTwoButtons()
    }

    @IBAction func exampleButton2Tapped(_ sender: AnyObject) {
        presentAlertControllerWithButtonsAndTextField()
    }

    @IBAction func exampleButton3Tapped(_ sender: AnyObject) {
        presentAlertControllerWithIcon()
    }

    @IBAction func exampleButton4Tapped(_ sender: AnyObject) {
        presentAlertControllerWithActionSheetStyle()
    }
}
