//
//  AlertButton.swift
//  AlertController
//
//  Created by Kevin on 24/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public class AlertButton: UIButton {

    public final var alertAction: AlertAction?
    public final var highlightColor = UIColor.white.withAlphaComponent(0.4)

    public init(
        title: String?,
        highlightColor: UIColor,
        action: AlertAction,
        tintColor: UIColor? = nil,
        style: UIAlertActionStyle? = nil
    ) {

        super.init(frame: .zero)

        setup()

        setTitle(title, for: .normal)

        self.highlightColor = highlightColor

        alertAction = action

        setTitleColor(tintColor ?? .white, for: .normal)

        titleLabel?.font = .systemFont(ofSize: 18, weight: UIFontWeightRegular)

        guard let style = style else {
            return
        }

        if style == .destructive {
            setTitleColor(.red, for: .normal)
        } else if style == .cancel {
            titleLabel?.font = .systemFont(ofSize: 18, weight: UIFontWeightMedium)
        }

    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private final func setup() {
        backgroundColor = .clear
    }

    public override func layoutSubviews() {

        super.layoutSubviews()

    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesBegan(touches, with: event)

        backgroundColor = highlightColor

    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesEnded(touches, with: event)

        backgroundColor = .clear
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesCancelled(touches, with: event)

        backgroundColor = .clear

    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesMoved(touches, with: event)

    }
}
