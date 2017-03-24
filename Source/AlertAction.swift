//
//  AlertAction.swift
//  AlertController
//
//  Created by Kevin on 24/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public final class AlertAction {

    public final var title: String?
    public final var style: UIAlertActionStyle
    public final var handler: ((AlertAction) -> Void)?
    public final var tintColor: UIColor?

    public init(
        title: String?,
        style: UIAlertActionStyle = .default,
        tintColor: UIColor? = nil,
        handler: ((AlertAction) -> Void)? = nil
        ) {

        self.title = title
        self.style = style
        self.tintColor = tintColor
        self.handler = handler

    }
}
