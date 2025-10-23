// 
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import UIKit

/// `AllChatsActionProvider` provides the menu for managing the `AllChatsLayoutSettingsManager`
@available(iOS 13.0, *)
class AllChatsActionProvider {
    
    // MARK: - Properties
    
    private let allChatsSettingsManager = AllChatsLayoutSettingsManager.shared
    
    // MARK: - RoomActionProviderProtocol
    
    var menu: UIMenu {
        return UIMenu(title: "", children: [
            self.recentsAction,
            self.filtersAction,
            UIMenu(title: "", options: .displayInline, children: [
                activityOrderAction,
                alphabeticalOrderAction
            ])
        ])
    }
    
    // MARK: - Private
    
    private var recentsAction: UIAction {
        return UIAction(title: VectorL10n.allChatsEditLayoutShowRecents,
                        image: UIImage(systemName: "clock.arrow.circlepath")?.withRenderingMode(.alwaysTemplate),
                        discoverabilityTitle: VectorL10n.allChatsEditLayoutShowRecents,
                        state: AllChatsLayoutSettingsManager.shared.allChatLayoutSettings.sections.contains(.recents) ? .on : .off) { action in
                            let settings = AllChatsLayoutSettingsManager.shared.allChatLayoutSettings
                            let newSettings = AllChatsLayoutSettings(sections: action.state == .on ? [] : .recents,
                                                                     filters: settings.filters,
                                                                     sorting: settings.sorting)
                            AllChatsLayoutSettingsManager.shared.allChatLayoutSettings = newSettings
                            Analytics.shared.trackInteraction(action.state == .on ? .allChatsRecentsDisabled : .allChatsRecentsEnabled)
                        }
    }
    
    private var filtersAction: UIAction {
        // 1. Read the CURRENT state from data to set the initial UI state
        let currentFilters = AllChatsLayoutSettingsManager.shared.allChatLayoutSettings.filters
        // Note: AllChatsLayoutFilterType seems to be an OptionSet, check if isEmpty works as expected
        // If filters is an OptionSet, check if it contains any values or is empty
        let initialState: UIAction.State = currentFilters.isEmpty ? .off : .on

        return UIAction(title: VectorL10n.allChatsEditLayoutShowFilters,
                        image: UIImage(systemName: "bubble.right")?.withRenderingMode(.alwaysTemplate),
                        state: initialState) { action in // 2. Set initial state based on data

                            // 3. Inside the handler, decide the NEW state based on the current DATA state
                            let currentSettings = AllChatsLayoutSettingsManager.shared.allChatLayoutSettings
                            // If current filters are empty, the user wants to ENABLE them
                            let shouldEnableFilters = currentSettings.filters.isEmpty

                            // Calculate the NEW filters state
                            // --- Use the CORRECT type name here ---
                            let newFilters: AllChatsLayoutFilterType = shouldEnableFilters ? [.unreads, .favourites, .people] : []
                            // --- End correction ---

                            let newSettings = AllChatsLayoutSettings(sections: currentSettings.sections,
                                                                     filters: newFilters, // Use the new filters
                                                                     sorting: currentSettings.sorting)

                            // 4. Update the data
                            AllChatsLayoutSettingsManager.shared.allChatLayoutSettings = newSettings

                            // Send analytics based on the action (enabled or disabled)
                            Analytics.shared.trackInteraction(shouldEnableFilters ? .allChatsFiltersEnabled : .allChatsFiltersDisabled)

                            // The system will automatically toggle the UI state (checkmark) after the tap.
                        }
    }
    
    private var activityOrderAction: UIAction {
        return UIAction(title: VectorL10n.allChatsEditLayoutActivityOrder,
                        state: AllChatsLayoutSettingsManager.shared.allChatLayoutSettings.sorting == .activity ? .on : .off) { action in
                            let settings = AllChatsLayoutSettingsManager.shared.allChatLayoutSettings
                            let newSettings = AllChatsLayoutSettings(sections: settings.sections,
                                                                     filters: settings.filters,
                                                                     sorting: .activity)
                            AllChatsLayoutSettingsManager.shared.allChatLayoutSettings = newSettings
                        }
    }
    
    private var alphabeticalOrderAction: UIAction {
        return UIAction(title: VectorL10n.allChatsEditLayoutAlphabeticalOrder,
                        state: AllChatsLayoutSettingsManager.shared.allChatLayoutSettings.sorting == .alphabetical ? .on : .off) { action in
                            let settings = AllChatsLayoutSettingsManager.shared.allChatLayoutSettings
                            let newSettings = AllChatsLayoutSettings(sections: settings.sections,
                                                                     filters: settings.filters,
                                                                     sorting: .alphabetical)
                            AllChatsLayoutSettingsManager.shared.allChatLayoutSettings = newSettings
                        }
    }
}
