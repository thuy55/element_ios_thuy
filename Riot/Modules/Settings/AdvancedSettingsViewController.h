// 
// Copyright 2025 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 */

#import "MXKViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 View Controller mới để hiển thị CHỈ các cài đặt Nâng cao.
 */
@interface AdvancedSettingsViewController : MXKViewController <UITableViewDataSource, UITableViewDelegate>

// Khai báo là 'strong' để chúng ta tự tạo bằng code
@property (strong, nonatomic) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
