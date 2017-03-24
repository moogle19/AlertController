//
//  AlertController.swift
//  AlertControllerSample
//
//  Created by Marcel Dittmann on 19.02.16.
//  Copyright © 2016 blowfishlab. All rights reserved.
//

import UIKit

public enum AlertTransitionStyle {

    case coverVertical
    case popup
}

public class AlertAction: NSObject {

    public final var title: String?
    public final var style: UIAlertActionStyle
    public final var handler: ((AlertAction) -> Void)?

    public init(
        title: String?,
        style: UIAlertActionStyle = .default,
        handler: ((AlertAction) -> Void)? = nil
    ) {

        self.title = title
        self.style = style
        self.handler = handler

        super.init()

    }
}

// Button sub-class
public class AlertButton: UIButton {

    public final var alertAction: AlertAction?
    public final var highlightColor: UIColor = UIColor(white: 1, alpha: 0.4)

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

public class AlertController: UIViewController {

    // MARK: - Public Interface
    public final var transitionStyle: AlertTransitionStyle
    public final var contentWrapper = UIView()

    // MARK: Init

    public init(
        title: String?,
        message: String? = nil,
        icon: UIImage? = nil,
        preferredStyle: UIAlertControllerStyle = .alert,
        blurStyle: UIBlurEffectStyle = .light
    ) {

        alertTitle = title
        self.message = message
        self.icon = icon
        self.preferredStyle = preferredStyle
        self.blurStyle = blurStyle

        titleLabel.text = alertTitle
        textTextView.text = message

        // Set up content View
        topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))

        // Default Transition Style
        transitionStyle = preferredStyle == .alert ? .popup : .coverVertical

        super.init(nibName: nil, bundle: nil)

        // Set up main view
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(contentWrapper)

        topBlurView.layer.cornerRadius = 15
        topBlurView.clipsToBounds = true

        bottomBlurView.layer.cornerRadius = 15
        bottomBlurView.clipsToBounds = true

        contentWrapper.addSubview(topBlurView)
        contentWrapper.addSubview(bottomBlurView)

        topBlurView.contentView.addSubview(headerAreaView)
        topBlurView.contentView.addSubview(buttonAreaView)

        // Separator
        headerAreaView.addSubview(headerAreaSeperator)
        headerAreaSeperator.backgroundColor = separatorColor

        // Title
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18, weight: UIFontWeightMedium)
        headerAreaView.addSubview(titleLabel)

        // Text
        textTextView.isEditable = false
        textTextView.textAlignment = .center
        textTextView.textContainerInset = .zero
        textTextView.textContainer.lineFragmentPadding = 0
        textTextView.font = .systemFont(ofSize: 14)
        headerAreaView.addSubview(textTextView)

        // Icon
        if let icon = icon {
            iconView.backgroundColor = .white
            iconView = UIImageView(image: icon)
            headerAreaView.addSubview(iconView)
        }

        // Colours
        textTextView.textColor = fontColor
        textTextView.backgroundColor = .clear
        titleLabel.textColor = fontColor

        // Gesture Recognizer for tapping outside the textinput
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        modalPresentationStyle = .custom
        transitioningDelegate = self

    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    // MARK: Configuring the User Actions

    public final var actions: [AlertAction] {
        return alertActions
    }

    public final func addAction(action: AlertAction) {

        alertActions.append(action)
        let button = buttonForAction(action: action)

        // save button
        if action.style == .cancel {
            cancelButton = button
        }

        buttons.append(button)

        // add button as subview
        if action.style == .cancel && preferredStyle == .actionSheet {
            bottomBlurView.contentView.addSubview(button)
        } else {
            buttonAreaView.addSubview(button)
        }

        // add Separator if needed
        if buttons.count > 1 {

            let separator = UIView()
            separator.backgroundColor = separatorColor
            buttonSeparators.append(separator)
            buttonAreaView.addSubview(separator)
        }
    }

    // MARK: Configuring Text Fields

    public final func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField) -> Void)?) {

        let textField = UITextField()
        textField.textColor = .white
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.keyboardAppearance = textFieldKeyboardAppearance

        textField.backgroundColor = textFieldBackgroundColor

        _textFields.append(textField)

        headerAreaView.addSubview(textField)

        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)

        configurationHandler?(textField)
    }

    public final var textFields: [UITextField] {
        return _textFields
    }

    // MARK: - Private

    // MARK: Private Properties

    // Positioning
    private final var isKeyboardShown = false
    private final var tmpContentViewFrameOrigin: CGPoint?
    fileprivate final var activeField: UITextField?

    private var isPresenting = false

    // MARK: Constants
    private final let topContentVSpace: CGFloat = 10.0
    private final let titleHeight: CGFloat = 40.0
    private final let buttonHeight: CGFloat = 45.0
    private final let textFieldHeight: CGFloat = 30.0

    // MARK: Content
    private final var alertTitle: String?
    private final var message: String?
    private final var icon: UIImage?

    // MARK: Actions
    private final var alertActions = [AlertAction]()

    // MARK: Style
    private final var preferredStyle: UIAlertControllerStyle
    private final var blurStyle: UIBlurEffectStyle

    // MARK: - Views
    private final var titleLabel = UILabel()
    private final var textTextView = UITextView()
    private final var iconView = UIView()
    private final var topBlurView: UIVisualEffectView
    private final var bottomBlurView: UIVisualEffectView
    private final var headerAreaView = UIView()
    private final var buttonAreaView = UIView()
    private final var headerAreaSeperator = UIView()

    private final var buttons = [AlertButton]()
    private final var cancelButton: AlertButton?
    private final var _textFields = [UITextField]()
    private final var buttonSeparators = [UIView]()

    // MARK: Computed properties
    private final var window: UIWindow {
        return UIApplication.shared.keyWindow ?? UIWindow()
    }

    private final var screenSize: CGSize {
        return window.frame.size
    }

    private final var iconSize: CGSize {
        return icon?.size ?? .zero
    }

    private final var alertBoxWidth: CGFloat {
        return self.preferredStyle == .alert ? 280 : screenSize.width - 24
    }

    private final var viewTextWidth: CGFloat {
        return alertBoxWidth - 24
    }

    private final var viewTextHeight: CGFloat {

        // computing the right size to use for the textView
        let maxHeight = screenSize.height - 100 // max overall height

        let maxViewTextHeight = maxHeight - calcConsumedHeightForHeaderArea()

        let suggestedViewTextSize = textTextView.sizeThatFits(
            CGSize(width: viewTextWidth, height: CGFloat.greatestFiniteMagnitude)
        )

        return min(suggestedViewTextSize.height, maxViewTextHeight)
    }

    private final var fontColor: UIColor {

        if blurStyle == .extraLight {
            return .black
        }

        return .white

    }

    private final var separatorColor: UIColor {

        if blurStyle == .dark {
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        }

        return UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.2)

    }

    private final var separatorHeight: CGFloat {

        return 0.5

    }

    private final var actionSheetCancelButtonSpacer: CGFloat {

        return displayAsActionSheetWithCancel ? 12 : 0

    }

    private final var textFieldBackgroundColor: UIColor {

        if blurStyle == .dark {
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        }

        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)

    }

    private final var textFieldFontColor: UIColor {

        return blurStyle == .extraLight ? .black : .white

    }

    private final var textFieldKeyboardAppearance: UIKeyboardAppearance {

        return blurStyle == .extraLight ? .light : .dark

    }

    private final var displayAsActionSheetWithCancel: Bool {

        return cancelButton != nil && preferredStyle == .actionSheet

    }

    private final var displayAsAlertWithFullButtons: Bool {

        return preferredStyle == .alert && buttons.count > 2

    }

    private final var displayAsActionSheet: Bool {

        return preferredStyle == .actionSheet

    }

    // MARK: View Lifecycle

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: Notification.Name.UIKeyboardWillShow,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil
        )

        textFields.first?.becomeFirstResponder()

    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(Notification.Name.UIKeyboardWillShow)
        NotificationCenter.default.removeObserver(Notification.Name.UIKeyboardWillHide)
    }

    // MARK: Layout Methods

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Set background frame
        view.frame.size = screenSize

        // MainFrames
        layoutMainFrames()

        // Icon
        var y = layoutIcon()

        // Title
        titleLabel.frame = CGRect(x: 12, y: y, width: alertBoxWidth - 24, height: titleHeight)
        y += titleHeight

        // Subtitle
        textTextView.frame = CGRect(x: 12, y: y, width: viewTextWidth, height: viewTextHeight)
        y += viewTextHeight + 14

        // Text fields
        for textField in textFields {
            textField.frame = CGRect(x: 12, y: y, width: alertBoxWidth - 24, height: textFieldHeight)
            textField.layer.cornerRadius = 2
            y += textFieldHeight + 15
        }

        // Buttons
        layoutButtons()
    }

    private final func layoutMainFrames() {

        let consumedHeightForHeaderArea = calcConsumedHeightForHeaderArea()
        let consumedHeightForButtonArea = calcConsumedHeightForButtonArea()
        let consumedHeightForBottomBlurView = calcConsumedHeightForBottomBlurView()

        let headerAreaHeight = consumedHeightForHeaderArea + viewTextHeight
        let topBlurViewHeight = headerAreaHeight + consumedHeightForButtonArea
        let contentWrapperHeight = topBlurViewHeight + consumedHeightForBottomBlurView + actionSheetCancelButtonSpacer

        let x = self.preferredStyle == .alert
            ? (screenSize.width - alertBoxWidth) / 2
            : 12

        let y = self.preferredStyle == .alert
            ? (screenSize.height - contentWrapperHeight) / 2
            : screenSize.height - contentWrapperHeight - 12

        contentWrapper.frame = CGRect(x: x, y: y, width: alertBoxWidth, height: contentWrapperHeight)

        topBlurView.frame = CGRect(x: 0, y: 0, width: alertBoxWidth, height: topBlurViewHeight)

        headerAreaView.frame = CGRect(x: 0, y: 0, width: alertBoxWidth, height: headerAreaHeight)

        headerAreaSeperator.frame = CGRect(
            x: 0,
            y: headerAreaHeight - separatorHeight,
            width: alertBoxWidth,
            height: separatorHeight
        )

        buttonAreaView.frame = CGRect(
            x: 0,
            y: headerAreaHeight,
            width: alertBoxWidth,
            height: consumedHeightForButtonArea
        )

        bottomBlurView.frame = CGRect(
            x: 0,
            y: headerAreaHeight + consumedHeightForButtonArea + actionSheetCancelButtonSpacer,
            width: alertBoxWidth,
            height: consumedHeightForBottomBlurView
        )

    }

    private final func layoutIcon() -> CGFloat {

        if icon == nil {
            return topContentVSpace
        }

        iconView.frame = CGRect(
            x: (alertBoxWidth - iconSize.width) / 2,
            y: topContentVSpace,
            width: iconSize.width,
            height: iconSize.height
        )

        return topContentVSpace + iconSize.height

    }

    private final func layoutButtons() {

        if preferredStyle == .alert && buttons.count == 2 {

            // Alerts should display two buttons in a row if there are only two buttons
            let buttonWidth = (alertBoxWidth - separatorHeight) / 2

            buttons[0].frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)

            buttonSeparators[0].frame = CGRect(
                x: buttonWidth,
                y: 0,
                width: separatorHeight,
                height: buttonHeight
            )

            buttons[1].frame = CGRect(
                x: buttonWidth + separatorHeight,
                y: 0,
                width: buttonWidth,
                height: buttonHeight
            )

        } else {

            // Make sure Cancel Button is always the last one
            buttons.sort { (button1, _) -> Bool in
                return button1 != self.cancelButton
            }

            var y: CGFloat = 0

            for i in 0..<buttons.count {

                // Separator
                if i > 0 {

                    let separator = buttonSeparators[i-1]
                    separator.frame = CGRect(x:0, y:y, width:alertBoxWidth, height: separatorHeight)
                    y += separatorHeight
                }

                // Button
                let button = buttons[i]
                button.frame = CGRect(x: 0, y: y, width: alertBoxWidth, height: buttonHeight)

                y += buttonHeight
            }

            if let cancelButton = cancelButton, preferredStyle == .actionSheet {
                cancelButton.frame = CGRect(x: 0, y: 0, width: alertBoxWidth, height: buttonHeight)
            }
        }
    }

    // MARK: Subview Height Calculations

    private final func calcConsumedHeightForHeaderArea() -> CGFloat {

        return topContentVSpace +
            iconSize.height +
            titleHeight +
            (textFieldHeight + 15) * CGFloat(textFields.count) +
            separatorHeight + 14

    }

    private final func calcConsumedHeightForButtonArea() -> CGFloat {

        if displayAsActionSheetWithCancel {

            // ActionSheet with Cancel Button
            return buttonHeight * CGFloat(buttons.count - 1) + separatorHeight * CGFloat(buttonSeparators.count - 1)

        }

        if displayAsActionSheet || displayAsAlertWithFullButtons {

            // ActionSheet without Cancel Button && Alert with buttons.count > 2
            return buttonHeight * CGFloat(buttons.count) + separatorHeight * CGFloat(buttonSeparators.count)

        }

        // Alert with buttons.count <= 2
        return buttonHeight

    }

    private final func calcConsumedHeightForBottomBlurView() -> CGFloat {

        return displayAsActionSheetWithCancel ? buttonHeight : 0

    }

    // MARK: Keyboard Handling

    @objc
    private final func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
            let endKeyBoardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let activeField = activeField else {

                return
        }

        let contentViewHeight = contentWrapper.frame.height

        if !isKeyboardShown {
            tmpContentViewFrameOrigin = contentWrapper.frame.origin
            isKeyboardShown = true
        }

        let newContentViewCenterY = endKeyBoardRect.origin.y / 2
        let centerFromTextFieldinContentView = activeField.center
        let textFieldOffSetFromCenter = contentViewHeight > endKeyBoardRect.origin.y
            ? contentViewHeight / 2 - centerFromTextFieldinContentView.y
            : 0

        self.contentWrapper.center = CGPoint(
            x: self.contentWrapper.center.x,
            y: newContentViewCenterY + textFieldOffSetFromCenter
        )
    }

    @objc
    private final func keyboardWillHide(notification: NSNotification) {

        // This could happen on the simulator (keyboard will be hidden)
        guard isKeyboardShown else { return }

        if let origin = tmpContentViewFrameOrigin {
            contentWrapper.frame.origin.y = origin.y
        }

        isKeyboardShown = false

    }

    // Dismiss keyboard when tapped outside textfield
    @objc
    private final func dismissKeyboard() {
        view.endEditing(true)
    }

    private final func buttonForAction(action: AlertAction) -> AlertButton {

        let globalTint = UIApplication.shared.delegate?.window??.tintColor ?? .white

        let button = AlertButton()
        button.setTitle(action.title, for: .normal)
        button.highlightColor = separatorColor
        button.alertAction = action
        button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)

        switch action.style {

        case .cancel:
            button.setTitleColor(globalTint, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: UIFontWeightMedium)
        case .default:
            button.setTitleColor(globalTint, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: UIFontWeightRegular)
        case .destructive:
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: UIFontWeightRegular)
        }

        return button

    }

    @objc
    private final func buttonTapped(button: AlertButton) {

        self.dismiss(animated: true) { () -> Void in

            if let action = button.alertAction {
                button.alertAction?.handler?(action)
            }

        }
    }
}

// MARK: - UITextFieldDelegate
extension AlertController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

}

// MARK: - UIViewControllerTransitioningDelegate
extension AlertController: UIViewControllerTransitioningDelegate {
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {

        if transitionStyle == .popup {
            return PopupTransitionController(mode: .show)
        }

        return CoverVerticalTransitionController(mode: .show)

    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {

        if transitionStyle == .popup {
            return PopupTransitionController(mode: .hide)
        }

        return CoverVerticalTransitionController(mode: .hide)

    }

}
