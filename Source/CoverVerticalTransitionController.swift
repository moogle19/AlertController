//
//  CoverVerticalTransitionController.swift
//  AlertControllerSample
//
//  Created by Marcel Dittmann on 25.02.16.
//  Copyright © 2016 blowfishlab. All rights reserved.
//

import UIKit

class CoverVerticalTransitionController: UIViewController, AlertTransitionController {

    fileprivate var mode: AlertTransitionControllerMode

    required init(mode: AlertTransitionControllerMode) {

        self.mode = mode
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func animateShow(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView

        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) as? AlertController else {
            return
        }

        toViewController.view.frame = fromViewController.view.frame
        toViewController.contentWrapper.alpha = 0
        toViewController.contentWrapper.transform = toViewController
            .contentWrapper
            .transform
            .translatedBy(x: 0, y: toViewController.view.frame.height)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseIn,
            animations: { () -> Void in

                toViewController.contentWrapper.alpha = 1
                toViewController.contentWrapper.transform = toViewController
                    .contentWrapper
                    .transform
                    .translatedBy(x: 0, y: -toViewController.view.frame.height)

                toViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                containerView.addSubview(toViewController.view)

            }, completion: { (completed) -> Void in

                transitionContext.completeTransition(completed)

            }
        )

    }

    fileprivate func animateHide(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromViewController = transitionContext.viewController(forKey: .from) as? AlertController else {
            return
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        toViewController.view.frame = fromViewController.view.frame

        fromViewController.view.backgroundColor = UIColor.white.withAlphaComponent(0.0)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseIn,
            animations: { () -> Void in

                fromViewController.view.alpha = 0
                fromViewController.view.transform = fromViewController
                    .view
                    .transform
                    .translatedBy(x: 0, y: fromViewController.view.frame.height)

            }, completion: { (completed) -> Void in

                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(completed)

            }
        )

    }
}

extension CoverVerticalTransitionController: UIViewControllerAnimatedTransitioning {

    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        return 1

    }

    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if mode == .show {

            animateShow(using: transitionContext)

        } else {

            animateHide(using: transitionContext)
        }

    }

}
