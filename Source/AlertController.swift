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
    
    var title: String?
    var style: UIAlertActionStyle
    var handler: ((AlertAction) -> Void)?
    
    public init(title: String?, style: UIAlertActionStyle, handler: ((AlertAction) -> Void)?) {
        
        self.title = title;
        self.style = style;
        self.handler = handler;
        super.init()
        
    }
}

// Button sub-class
public class AlertButton: UIButton {
    
    var alertAction: AlertAction!
    var highlightColor: UIColor! = UIColor(white: 1, alpha: 0.4)
    
    public init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame:CGRect) {
        super.init(frame:frame)
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event);
        
        self.backgroundColor = highlightColor
        
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        self.backgroundColor = .clear
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = .clear
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with: event)

    }
}

public class AlertController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Public Interface
    public var transitionStyle: AlertTransitionStyle
    public var contentWrapper = UIView()
    
    // MARK: Init
    
    public init(title: String?, message: String?, icon: UIImage?, preferredStyle: UIAlertControllerStyle, blurStyle: UIBlurEffectStyle = .light) {
        
        self.alertTitle = title;
        self.message = message;
        self.icon = icon;
        self.preferredStyle = preferredStyle;
        self.blurStyle = blurStyle;
        
        self.titleLabel.text = alertTitle;
        self.textTextView.text = message;
        
        // Set up content View
        self.topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        self.bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle));
        
        // Default Transition Style
        self.transitionStyle = self.preferredStyle == .alert ? AlertTransitionStyle.popup : AlertTransitionStyle.coverVertical
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom;
        self.transitioningDelegate = self;
        
        // Set up main view
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(contentWrapper)
        
        topBlurView.layer.cornerRadius = 15;
        topBlurView.clipsToBounds = true;
        
        bottomBlurView.layer.cornerRadius = 15;
        bottomBlurView.clipsToBounds = true;
        
        self.contentWrapper.addSubview(topBlurView)
        self.contentWrapper.addSubview(bottomBlurView)
        
        topBlurView.contentView.addSubview(headerAreaView)
        topBlurView.contentView.addSubview(buttonAreaView)
        
        // Separator
        self.headerAreaView.addSubview(headerAreaSeperator)
        self.headerAreaSeperator.backgroundColor = self.separatorColor
        
        // Title
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        self.headerAreaView.addSubview(self.titleLabel)
        
        // Text
        textTextView.isEditable = false
        textTextView.textAlignment = .center
        textTextView.textContainerInset = .zero
        textTextView.textContainer.lineFragmentPadding = 0;
        textTextView.font = .systemFont(ofSize: 14)
        self.headerAreaView.addSubview(self.textTextView)
        
        // Icon
        if self.icon != nil {
            self.iconView.backgroundColor = .white
            self.iconView = UIImageView(image: self.icon)
            self.headerAreaView.addSubview(self.iconView)
        }
        
        // Colours
        textTextView.textColor = self.fontColor;
        textTextView.backgroundColor = .clear
        titleLabel.textColor = self.fontColor;
        
        //Gesture Recognizer for tapping outside the textinput
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Configuring the User Actions
    
    public var actions: [AlertAction] {
        return _actions
    }
    
    public func addAction(action: AlertAction) {
        
        self._actions.append(action)
        let button = buttonForAction(action: action)
        
        // save button
        if action.style == .cancel {
            _cancelButton = button;
        }

        self._buttons.append(button)
        
        // add button as subview
        if action.style == .cancel && self.preferredStyle == .actionSheet {
            bottomBlurView.contentView.addSubview(button)
        } else {
            buttonAreaView.addSubview(button)
        }
        
        // add Separator if needed
        if self._buttons.count > 1 {
            
            let separator = UIView();
            separator.backgroundColor = self.separatorColor;
            self.buttonSeparators.append(separator)
            self.buttonAreaView.addSubview(separator)
        }
    }
    
    // MARK: Configuring Text Fields
    
    public func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField) -> Void)?) {
        
        let textField = UITextField()
        textField.textColor = .white
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.keyboardAppearance = self.textFieldKeyboardAppearance
        
        textField.backgroundColor = self.textFieldBackgroundColor;
        
        self._textFields.append(textField)
        
        self.headerAreaView.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        configurationHandler?(textField)
    }
    
    public var textFields: [UITextField] {
        return _textFields
    }
    
    // MARK: - Private
    
    // MARK: Private Properties
    
    // Positioning
    private var keyboardHasBeenShown:Bool = false
    private var tmpContentViewFrameOrigin: CGPoint?
    private var activeField: UITextField?
    
    private var isPresenting: Bool = false;
    
    // MARK: Constants
    private let topContentVSpace: CGFloat = 10;
    private let titleHeight: CGFloat = 40.0
    private let buttonHeight: CGFloat = 45.0
    private let textFieldHeight: CGFloat = 30
    
    // MARK: Content
    private var alertTitle: String?;
    private var message: String?;
    private var icon: UIImage?;
    
    // MARK: Actions
    private var _actions = [AlertAction]();
    
    // MARK: Style
    private var preferredStyle: UIAlertControllerStyle;
    private var blurStyle: UIBlurEffectStyle
    
    // MARK: - Views
    private var titleLabel = UILabel()
    private var textTextView = UITextView()
    private var iconView = UIView()
    private var topBlurView: UIVisualEffectView
    private var bottomBlurView: UIVisualEffectView
    private var headerAreaView = UIView();
    private var buttonAreaView = UIView();
    private var headerAreaSeperator = UIView();
    
    private var _buttons = [AlertButton]()
    private var _cancelButton: AlertButton?
    private var _textFields = [UITextField]()
    private var buttonSeparators = [UIView]();

    // MARK: Computed properties
    private var window: UIWindow {
        return UIApplication.shared.keyWindow ?? UIWindow()
    }
    
    private var screenSize: CGSize {
        return window.frame.size
    }
    
    private var iconSize: CGSize {
        return icon?.size ?? .zero
    }
    
    private var alertBoxWidth: CGFloat {
        return self.preferredStyle == .alert ? 280 : screenSize.width - 24
    }
    
    private var viewTextWidth: CGFloat {
        return alertBoxWidth - 24
    }
    
    private var viewTextHeight: CGFloat {
        
        // computing the right size to use for the textView
        let maxHeight = screenSize.height - 100 // max overall height
        
        let maxViewTextHeight = maxHeight - calcConsumedHeightForHeaderArea()

        let suggestedViewTextSize = textTextView.sizeThatFits(CGSize(width: viewTextWidth, height: CGFloat.greatestFiniteMagnitude))
        return min(suggestedViewTextSize.height, maxViewTextHeight)
    }
    
    private var fontColor: UIColor {
        
        return blurStyle == .extraLight ? .black : .white
        
    }
    
    private var separatorColor: UIColor {
        
        return blurStyle == .dark ? UIColor(red: 1, green: 1 , blue: 1, alpha: 0.05) : UIColor(red: 0 / 255.0, green: 0 / 255.0 , blue: 0 / 255.0, alpha: 0.2);
        
    }
    
    private var separatorHeight: CGFloat {
        
        return 0.5
    }
    
    private var actionSheetCancelButtonSpacer: CGFloat {
        
        return shouldDisplayAsActionSheetWithCancelButton ? 12 : 0
    }
    
    private var textFieldBackgroundColor: UIColor {
        
        return self.blurStyle == .dark ? UIColor(red:1, green:1, blue:1, alpha:0.1): UIColor(red:0, green:0, blue:0, alpha:0.1)
    }
    
    private var textFieldFontColor: UIColor {
        
        return self.blurStyle == .extraLight ? .black : .white
    }
    
    private var textFieldKeyboardAppearance: UIKeyboardAppearance {
        
        return self.blurStyle == .extraLight ? .light : .dark
    }
    
    private var shouldDisplayAsActionSheetWithCancelButton: Bool {
        return preferredStyle == .actionSheet && self._cancelButton != nil
    }
    
    private var shouldDisplayAsAlertWithFullWidthButtons: Bool {
        return preferredStyle == .alert && self._buttons.count > 2
    }
    
    private var shouldDisplayAsActionSheet: Bool {
        return preferredStyle == .actionSheet
    }
    
    // MARK: View Lifecycle
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        if self.textFields.count > 0 {
            
            self.textFields[0].becomeFirstResponder()
        }
        
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
        self.view.frame.size = screenSize
        
        // MainFrames
        self.layoutMainFrames()
        
        // Icon
        var y = self.layoutIcon()
        
        // Title
        self.titleLabel.frame = CGRect(x: 12, y: y, width: alertBoxWidth - 24, height: titleHeight)
        y += titleHeight
        
        // Subtitle
        textTextView.frame = CGRect(x: 12, y: y, width: viewTextWidth, height: viewTextHeight)
        y += viewTextHeight + 14
        
        // Text fields
        for txt in textFields {
            txt.frame = CGRect(x: 12, y: y, width: alertBoxWidth - 24, height: textFieldHeight)
            txt.layer.cornerRadius = 2
            y += textFieldHeight + 15
        }
        
        // Buttons
        self.layoutButtons()
    }
    
    private func layoutMainFrames() {
        
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
        self.headerAreaSeperator.frame = CGRect(x: 0, y: headerAreaHeight - separatorHeight, width: alertBoxWidth, height: self.separatorHeight)
        
        buttonAreaView.frame = CGRect(x: 0, y: headerAreaHeight, width: alertBoxWidth, height: consumedHeightForButtonArea)
        bottomBlurView.frame = CGRect(x: 0, y: headerAreaHeight + consumedHeightForButtonArea + actionSheetCancelButtonSpacer, width: alertBoxWidth, height: consumedHeightForBottomBlurView)
    }
    
    private func layoutIcon() -> CGFloat {
        
        var y = topContentVSpace;
        if icon != nil {
            self.iconView.frame = CGRect(x:(alertBoxWidth - iconSize.width) / 2, y:y, width: iconSize.width, height: iconSize.height);
            y += iconSize.height;
        }
        
        return y
    }
    
    private func layoutButtons() {
        
        if self.preferredStyle == .alert && self._buttons.count == 2 {
            
            // Alerts should display two buttons in a row if there are only two buttons
            let buttonWidth = (alertBoxWidth - separatorHeight) / 2;
            _buttons[0].frame = CGRect(x:0, y:0, width:buttonWidth, height:buttonHeight)
            buttonSeparators[0].frame = CGRect(x:buttonWidth, y:0, width:separatorHeight, height:buttonHeight)
            _buttons[1].frame = CGRect(x: buttonWidth + separatorHeight, y:0, width:buttonWidth, height:buttonHeight)
            
        } else {
            
            // Make sure Cancel Button is always the last one
            self._buttons.sort { (button1, button2) -> Bool in
                return button1 != self._cancelButton
            }
            
            var y: CGFloat = 0
            
            for i in 0..<_buttons.count {
                
                // Separator
                if i > 0 {
                    
                    let separator = self.buttonSeparators[i-1];
                    separator.frame = CGRect(x:0, y:y, width:alertBoxWidth, height: self.separatorHeight)
                    y += self.separatorHeight
                }
                
                // Button
                let btn = self._buttons[i]
                btn.frame = CGRect(x:0, y:y, width:alertBoxWidth, height:buttonHeight)
                
                y += buttonHeight
            }
            
            if self.preferredStyle == .actionSheet && self._cancelButton != nil {
                self._cancelButton!.frame = CGRect(x:0, y:0, width:alertBoxWidth, height: buttonHeight)
            }
        }
    }
    
    // MARK: Subview Height Calculations
    
    private func calcConsumedHeightForHeaderArea() -> CGFloat {
        
        var consumedHeightForHeaderArea: CGFloat = 0
        consumedHeightForHeaderArea += topContentVSpace
        consumedHeightForHeaderArea += icon != nil ? iconSize.height : 0
        consumedHeightForHeaderArea += titleHeight;
        consumedHeightForHeaderArea += (textFieldHeight + 15) * CGFloat(textFields.count)
        consumedHeightForHeaderArea += 14 // spacer before text field
        consumedHeightForHeaderArea += self.separatorHeight; // Separator between HeaderArea and Button Area
        
        return consumedHeightForHeaderArea
    }
    
    private func calcConsumedHeightForButtonArea() -> CGFloat {
        
        if shouldDisplayAsActionSheetWithCancelButton {
            
            // ActionSheet with Cancel Button
            return buttonHeight * CGFloat(_buttons.count - 1) + self.separatorHeight * CGFloat(self.buttonSeparators.count - 1)
            
        } else if shouldDisplayAsActionSheet || shouldDisplayAsAlertWithFullWidthButtons {
            
            // ActionSheet without Cancel Button && Alert with buttons.count > 2
            return buttonHeight * CGFloat(_buttons.count) + self.separatorHeight * CGFloat(self.buttonSeparators.count)
            
        } else {
            
            // Alert with buttons.count <= 2
            return buttonHeight
        }
        
    }
    
    private func calcConsumedHeightForBottomBlurView() -> CGFloat {
        
        return shouldDisplayAsActionSheetWithCancelButton ? buttonHeight : 0
        
    }
    
    // MARK: Keyboard Handling
    
    func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let endKeyBoardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let activeField = self.activeField else {
                
                return
        }
        
        let contentViewHeight = self.contentWrapper.frame.height
        
        if !self.keyboardHasBeenShown {
            self.tmpContentViewFrameOrigin = self.contentWrapper.frame.origin
            self.keyboardHasBeenShown = true
        }
        
        let newContentViewCenterY = endKeyBoardRect.origin.y / 2
        let centerFromTextFieldinContentView = activeField.center
        let textFieldOffSetFromCenter = contentViewHeight > endKeyBoardRect.origin.y
            ? contentViewHeight / 2 - centerFromTextFieldinContentView.y
            : 0
        
        self.contentWrapper.center = CGPoint(x: self.contentWrapper.center.x, y: newContentViewCenterY + textFieldOffSetFromCenter)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(self.keyboardHasBeenShown){//This could happen on the simulator (keyboard will be hidden)
            if(self.tmpContentViewFrameOrigin != nil){
                self.contentWrapper.frame.origin.y = self.tmpContentViewFrameOrigin!.y
            }
            
            self.keyboardHasBeenShown = false
        }
    }
    
    //Dismiss keyboard when tapped outside textfield
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: TextField Events
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
    
    private func buttonForAction(action: AlertAction) -> AlertButton {
        
        let globalTint = UIApplication.shared.delegate?.window??.tintColor ?? .white
        
        let button = AlertButton();
        button.setTitle(action.title, for: .normal)
        button.highlightColor = self.separatorColor;
        button.alertAction = action;
        button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        
        switch action.style {
            
        case .cancel:
            button.setTitleColor(globalTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        case .default:
            button.setTitleColor(globalTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        case .destructive:
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        }
        
        return button
    }
    
    public func buttonTapped(button: AlertButton) {
        
        self.dismiss(animated: true) { () -> Void in
            
            button.alertAction.handler?(button.alertAction)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AlertController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.transitionStyle == .popup ? PopupTransitionController(mode: .hide) : CoverVerticalTransitionController(mode: .hide)
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.transitionStyle == .popup ? PopupTransitionController(mode: .show) : CoverVerticalTransitionController(mode: .show)
        
    }
}
