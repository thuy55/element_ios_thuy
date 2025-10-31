/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 */

#import "MXKViewController.h"
#import "GeneratedInterface-Swift.h" // Cần thiết cho NotificationSettingsCoordinatorBridgePresenterDelegate
#import "MXSession.h" // Cần thiết để truy cập session

NS_ASSUME_NONNULL_BEGIN

@class NotificationSettingsCoordinatorBridgePresenter; // Khai báo trước

/**
 View Controller mới để hiển thị CHỈ các cài đặt thông báo chi tiết.
 */
@interface NotificationSettingsPageViewController : MXKViewController <UITableViewDataSource, UITableViewDelegate, NotificationSettingsCoordinatorBridgePresenterDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MXSession *mxSession; // Phiên Matrix hiện tại
@property (strong, nonatomic) NotificationSettingsCoordinatorBridgePresenter *notificationSettingsBridgePresenter; // Dùng để điều hướng đến các trang con (Default, Mentions, Other)

// Phương thức khởi tạo mới, cần truyền MXSession
- (instancetype)initWithMxSession:(MXSession *)mxSession;

@end

NS_ASSUME_NONNULL_END
