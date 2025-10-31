// 
// Copyright 2020-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// InviteFriendsPresenter enables to share current user contact to someone else
@objcMembers
final class InviteFriendsPresenter: NSObject {
    
    // MARK: - Constants
    
    // MARK: - Properties
    
    // MARK: Private
    
    private weak var presentingViewController: UIViewController?
    private weak var sourceView: UIView?
    
    // MARK: - Public
    
    func present(for userId: String,
                 from viewController: UIViewController,
                 sourceView: UIView?,
                 animated: Bool) {
        
        self.presentingViewController = viewController
        self.sourceView = sourceView
        
        self.shareInvite(from: userId)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        self.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Private
    
    private func shareInvite(from userId: String) {
        
        let shareText = self.buildShareText(with: userId)
        
        // Set up activity view controller
        let activityItems: [Any] = [ shareText ]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        self.present(activityViewController, animated: true)
    }
    
//    private func buildShareText(with userId: String) -> String {
//        let userMatrixToLink: String = MXTools.permalinkToUser(withUserId: userId)
//        return VectorL10n.inviteFriendsShareText(AppInfo.current.displayName, userMatrixToLink)
//    }
    
    private func buildShareText(with userId: String) -> String {
        // 1. Get the app name
        let appName = AppInfo.current.displayName

        // 2. Define your App Store link
        let appStoreLink = "https://testflight.apple.com/join/NADxgCGj" // Make sure this ID is correct

        // 3. Create the final text with the desired format (two lines)
        let resultText = """
        Này, trò chuyện với tôi ở \(appName): \(appStoreLink)
        Tài khoản của tôi là: \(userId)
        """

        // 4. Return the newly created text
        return resultText
    }
    
    private func present(_ viewController: UIViewController, animated: Bool) {
        
        // Configure source view when view controller is presented with a popover
        if let sourceView = self.sourceView, let popoverPresentationController = viewController.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
        }
        
        self.presentingViewController?.present(viewController, animated: animated, completion: nil)
        
        AnalyticsScreenTracker.trackScreen(.inviteFriends)
    }
}
