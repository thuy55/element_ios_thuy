/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 */

#import "MXKViewController.h"
#import "GeneratedInterface-Swift.h" // Cần thiết cho NotificationSettingsCoordinatorBridgePresenterDelegate

NS_ASSUME_NONNULL_BEGIN

/**
 View Controller mới để hiển thị CHỈ các cài đặt thông báo.
 */
@interface NotificationSettingsPageViewController : MXKViewController <UITableViewDataSource, UITableViewDelegate, NotificationSettingsCoordinatorBridgePresenterDelegate>

// Khai báo là 'strong' để chúng ta tự tạo bằng code
@property (strong, nonatomic) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
