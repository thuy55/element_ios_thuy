/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 */

#import "NotificationSettingsPageViewController.h"

// CÁC IMPORT BỊ THIẾU
#import "ThemeService.h"
//#import "RiotSettings.h"
//#import "AppDelegate.h"
#import "GeneratedInterface-Swift.h"
#import "MXKAccountManager.h"
#import "MXKAccount.h"
#import "MXKTableViewCellWithLabelAndSwitch.h"
#import "MXKTableViewCell.h"
//#import "MXKWeakify.h"
//#import "UIView+MatrixKit.h" // Cho hàm vc_setAccessoryDisclosureIndicator...
//#import "."


// Định nghĩa các hàng (rows) trong mục thông báo
typedef NS_ENUM(NSUInteger, NOTIFICATION_SETTINGS)
{
    NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX = 0,
    NOTIFICATION_SETTINGS_SYSTEM_SETTINGS,
    NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX,
    NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT,
    NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX,
    NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX,
    NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX,
    NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX,
    NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX,
};

@interface NotificationSettingsPageViewController ()
{
    // Observe kThemeServiceDidChangeThemeNotification to handle user interface theme change.
    __weak id kThemeServiceDidChangeThemeNotificationObserver;
    
    // Alert hiện tại
    __weak UIAlertController *currentAlert;
}

// Các thuộc tính (properties) đã được di chuyển từ SettingsViewController.m
@property (nonatomic) UNNotificationSettings *systemNotificationSettings;
@property (nonatomic, strong) NotificationSettingsCoordinatorBridgePresenter *notificationSettingsBridgePresenter;

@end

@implementation NotificationSettingsPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [VectorL10n settingsNotifications]; // Đặt tiêu đề cho trang
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever; // <-- Chữ nhỏ
    }
    
    // --- BẮT ĐẦU MÃ TẠO TABLEVIEW ---
    // 1. Khởi tạo tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    // 2. Đặt kích thước cho nó lấp đầy màn hình
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 3. Kết nối delegate và dataSource
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 4. Thêm nó vào view chính
    [self.view addSubview:self.tableView];
    // --- KẾT THÚC MÃ TẠO TABLEVIEW ---

    
    // Đăng ký các loại cell (ô)
    [self.tableView registerClass:MXKTableViewCellWithLabelAndSwitch.class forCellReuseIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier]];
    [self.tableView registerClass:MXKTableViewCell.class forCellReuseIdentifier:[MXKTableViewCell defaultReuseIdentifier]];
    
    // Cập nhật giao diện theo theme
    [self userInterfaceThemeDidChange];
    
    // Observe user interface theme change.
    kThemeServiceDidChangeThemeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kThemeServiceDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        [self userInterfaceThemeDidChange];
    }];
    
    // Lấy trạng thái cài đặt thông báo của hệ thống
    [self refreshSystemNotificationSettings];
}

- (void)dealloc
{
    if (kThemeServiceDidChangeThemeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kThemeServiceDidChangeThemeNotificationObserver];
        kThemeServiceDidChangeThemeNotificationObserver = nil;
    }
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    self.activityIndicator.backgroundColor = ThemeService.shared.theme.overlayBackgroundColor;
    
    // Đặt màu nền
    self.tableView.backgroundColor = ThemeService.shared.theme.thuybackgroundColor;
    self.view.backgroundColor = self.tableView.backgroundColor;
    self.tableView.separatorColor = ThemeService.shared.theme.lineBreakColor;
    
    [self.tableView reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ThemeService.shared.theme.statusBarStyle;
}

- (void)refreshSystemNotificationSettings
{
    MXWeakify(self);
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MXStrongifyAndReturnIfNil(self);
            self.systemNotificationSettings = settings;
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Chỉ có 1 section là thông báo
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Đếm số lượng các mục cài đặt thông báo
    NSInteger rowCount = 8; // Số lượng mục cố định
    if (RiotSettings.shared.settingsScreenShowNotificationDecodedContentOption)
    {
        rowCount += 1; // Thêm mục "Show Decoded Content"
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSInteger row = indexPath.row;
    MXKAccount* account = [MXKAccountManager sharedManager].activeAccounts.firstObject;

    // Tái sử dụng logic từ SettingsViewController.m
    // (Đã điều chỉnh lại 'row' vì không còn các enum khác)
    
    if (row == NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX)
    {
        MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsEnablePushNotif];
        labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
        labelAndSwitchCell.mxkSwitch.enabled = YES;
        [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(togglePushNotifications:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL isPushEnabled = account.pushNotificationServiceIsActive;
        if (isPushEnabled && self.systemNotificationSettings)
        {
            isPushEnabled = self.systemNotificationSettings.authorizationStatus == UNAuthorizationStatusAuthorized;
        }
        labelAndSwitchCell.mxkSwitch.on = isPushEnabled;
        cell = labelAndSwitchCell;
    }
    else if (row == NOTIFICATION_SETTINGS_SYSTEM_SETTINGS)
    {
        cell = [self getDefaultTableViewCell:tableView];
        cell.textLabel.text = [VectorL10n settingsDeviceNotifications];
        cell.detailTextLabel.text = @"";
        [cell vc_setAccessoryDisclosureIndicatorWithCurrentTheme];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else if (row == NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX)
    {
        MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        labelAndSwitchCell.mxkLabel.text = VectorL10n.settingsEnableInappNotifications;
        labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.showInAppNotifications;
        labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
        labelAndSwitchCell.mxkSwitch.enabled = account.pushNotificationServiceIsActive;
        [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleShowInAppNotifications:) forControlEvents:UIControlEventTouchUpInside];
        cell = labelAndSwitchCell;
    }
    else if (row == NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT && RiotSettings.shared.settingsScreenShowNotificationDecodedContentOption)
    {
        MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsShowDecryptedContent];
        labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.showDecryptedContentInNotifications;
        labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
        labelAndSwitchCell.mxkSwitch.enabled = account.pushNotificationServiceIsActive;
        [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleShowDecodedContent:) forControlEvents:UIControlEventTouchUpInside];
        cell = labelAndSwitchCell;
    }
    else if (row == NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX)
    {
        MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsPinRoomsWithMissedNotif];
        labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.pinRoomsWithMissedNotificationsOnHome;
        labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
        labelAndSwitchCell.mxkSwitch.enabled = YES;
        [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(togglePinRoomsWithMissedNotif:) forControlEvents:UIControlEventTouchUpInside];
        cell = labelAndSwitchCell;
    }
    else if (row == NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX)
    {
        MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsPinRoomsWithUnread];
        labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.pinRoomsWithUnreadMessagesOnHome;
        labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
        labelAndSwitchCell.mxkSwitch.enabled = YES;
        [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(togglePinRoomsWithUnread:) forControlEvents:UIControlEventTouchUpInside];
        cell = labelAndSwitchCell;
    }
    else if (row == NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX || row == NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX || row == NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX)
    {
        cell = [self getDefaultTableViewCell:tableView];
        if (row == NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX)
        {
            cell.textLabel.text = [VectorL10n settingsDefault];
        }
        else if (row == NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX)
        {
            cell.textLabel.text = [VectorL10n settingsMentionsAndKeywords];
        }
        else if (row == NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX)
        {
            cell.textLabel.text = [VectorL10n settingsOther];
        }
        [cell vc_setAccessoryDisclosureIndicatorWithCurrentTheme];
    }
    
    // Fallback cell
    if (!cell)
    {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = @"Lỗi";
    }

    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
    {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = ThemeService.shared.theme.selectedBackgroundColor;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (row == NOTIFICATION_SETTINGS_SYSTEM_SETTINGS)
    {
        [self openSystemSettingsApp];
    }
    else if (row == NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenDefaultNotifications];
    }
    else if (row == NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenMentionsAndKeywords];
    }
    else if (row == NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenOther];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Các hàm (methods) được di chuyển từ SettingsViewController

// Sao chép và dán các hàm sau từ SettingsViewController.m vào đây:
// - (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
// - (MXKTableViewCell*)getDefaultTableViewCell:(UITableView*)tableView

- (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    MXKTableViewCellWithLabelAndSwitch *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier] forIndexPath:indexPath];
    
    cell.mxkLabelLeadingConstraint.constant = tableView.vc_separatorInset.left;
    cell.mxkSwitchTrailingConstraint.constant = 15;
    cell.mxkLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    [cell.mxkSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [cell layoutIfNeeded];
    
    return cell;
}

- (MXKTableViewCell*)getDefaultTableViewCell:(UITableView*)tableView
{
    MXKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCell defaultReuseIdentifier]];
    if (!cell) {
        cell = [[MXKTableViewCell alloc] init];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    cell.textLabel.accessibilityIdentifier = nil;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    
    return cell;
}


// - (void)togglePushNotifications:(UISwitch *)sender
- (void)togglePushNotifications:(UISwitch *)sender
{
    // ... (sao chép toàn bộ nội dung hàm từ SettingsViewController.m, dòng 1974)
    if (self.systemNotificationSettings.authorizationStatus == UNAuthorizationStatusDenied)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];
        
        __weak typeof(self) weakSelf = self;
        
        NSString *title = [VectorL10n settingsNotificationsDisabledAlertTitle];
        NSString *message = [VectorL10n settingsNotificationsDisabledAlertMessage];
        
        UIAlertController *showSettingsPrompt = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [showSettingsPrompt addAction:[UIAlertAction actionWithTitle:[VectorL10n cancel]
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                           if (weakSelf)
                                                           {
                                                               typeof(self) self = weakSelf;
                                                               self->currentAlert = nil;
                                                           }
                                                           
                                                       }]];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:[VectorL10n settings]
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                            if (weakSelf)
                                                            {
                                                                typeof(self) self = weakSelf;
                                                                self->currentAlert = nil;
                                                                
                                                                [self openSystemSettingsApp];
                                                            }
                                                        }];
        
        [showSettingsPrompt addAction:settingsAction];
        showSettingsPrompt.preferredAction = settingsAction;
        
        [showSettingsPrompt mxk_setAccessibilityIdentifier: @"SettingsVCPushNotificationsAlert"];
        [self presentViewController:showSettingsPrompt animated:YES completion:nil];
        currentAlert = showSettingsPrompt;
        
        // Keep the the switch off.
        sender.on = NO;
    }
    else if ([MXKAccountManager sharedManager].activeAccounts.count)
    {
        [self startActivityIndicator];
        
        MXKAccountManager *accountManager = [MXKAccountManager sharedManager];
        MXKAccount* account = accountManager.activeAccounts.firstObject;

        if (accountManager.apnsDeviceToken)
        {
            [account enablePushNotifications:!account.pushNotificationServiceIsActive success:^{
                [self stopActivityIndicator];
            } failure:^(NSError *error) {
                [self stopActivityIndicator];
            }];
        }
        else
        {
            // Obtain device token when user has just enabled access to notifications from system settings
            [[AppDelegate theDelegate] registerForRemoteNotificationsWithCompletion:^(NSError * error) {
                if (error)
                {
                    [sender setOn:NO animated:YES];
                    [self stopActivityIndicator];
                }
                else
                {
                    [account enablePushNotifications:YES success:^{
                        [self stopActivityIndicator];
                    } failure:^(NSError *error) {
                        [self stopActivityIndicator];
                    }];
                }
            }];
        }
    }
}

// - (void)toggleShowInAppNotifications:(UISwitch *)sender
- (void)toggleShowInAppNotifications:(UISwitch *)sender
{
    RiotSettings.shared.showInAppNotifications = sender.isOn;
}

// - (void)openSystemSettingsApp
- (void)openSystemSettingsApp
{
    NSURL *settingsAppURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsAppURL options:@{} completionHandler:nil];
}

// - (void)toggleShowDecodedContent:(UISwitch *)sender
- (void)toggleShowDecodedContent:(UISwitch *)sender
{
    RiotSettings.shared.showDecryptedContentInNotifications = sender.isOn;
}

// - (void)togglePinRoomsWithMissedNotif:(UISwitch *)sender
- (void)togglePinRoomsWithMissedNotif:(UISwitch *)sender
{
    RiotSettings.shared.pinRoomsWithMissedNotificationsOnHome = sender.isOn;
}

// - (void)togglePinRoomsWithUnread:(UISwitch *)sender
- (void)togglePinRoomsWithUnread:(UISwitch *)sender
{
    RiotSettings.shared.pinRoomsWithUnreadMessagesOnHome = sender.on;
}

// - (void)showNotificationSettings: (NotificationSettingsScreen)screen
- (void)showNotificationSettings: (NotificationSettingsScreen)screen API_AVAILABLE(ios(14.0))
{
    NotificationSettingsCoordinatorBridgePresenter *notificationSettingsBridgePresenter = [[NotificationSettingsCoordinatorBridgePresenter alloc] initWithSession:self.mainSession];
    notificationSettingsBridgePresenter.delegate = self;
    
    MXWeakify(self);
    [notificationSettingsBridgePresenter pushFrom:self.navigationController animated:YES screen:screen popCompletion:^{
        MXStrongifyAndReturnIfNil(self);
        self.notificationSettingsBridgePresenter = nil;
    }];
    
    self.notificationSettingsBridgePresenter = notificationSettingsBridgePresenter;
}

// - (void)notificationSettingsCoordinatorBridgePresenterDelegateDidComplete:(NotificationSettingsCoordinatorBridgePresenter *)coordinatorBridgePresenter
- (void)notificationSettingsCoordinatorBridgePresenterDelegateDidComplete:(NotificationSettingsCoordinatorBridgePresenter *)coordinatorBridgePresenter API_AVAILABLE(ios(14.0))
{
    [self.notificationSettingsBridgePresenter dismissWithAnimated:YES completion:nil];
    self.notificationSettingsBridgePresenter = nil;
}


@end
