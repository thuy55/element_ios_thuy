/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 * FILE HOÀN CHỈNH - ĐÃ SỬA LỖI KHAI BÁO TRÙNG LẶP PROPERTY
 */

#import "NotificationSettingsPageViewController.h"

// CÁC IMPORTS CẦN THIẾT
#import "ThemeService.h"
//#import "RiotSettings.h"
//#import "AppDelegate.h"
#import "GeneratedInterface-Swift.h"
#import "MXKAccountManager.h"
#import "MXKAccount.h"
#import "MXKTableViewCellWithLabelAndSwitch.h"
#import "MXKTableViewCell.h"
//#import "MXWeakify.h"
//#import "UIView+MatrixKit.h"
//#import "VectorL10n.h"
#import "MXKTools.h"
#import <UserNotifications/UserNotifications.h>

// Định nghĩa các ENUM (Không thay đổi)
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

typedef NS_ENUM(NSUInteger, NOTIFICATION_SETTINGS_SECTION)
{
    NOTIFICATION_SETTINGS_SECTION_GENERAL = 0,
    NOTIFICATION_SETTINGS_SECTION_PINNING,
    NOTIFICATION_SETTINGS_SECTION_RULES,
    NOTIFICATION_SETTINGS_SECTION_COUNT
};

// KHỐI CLASS EXTENSION (SỬA LỖI: Đảm bảo chỉ khai báo PROPERTY một lần ở đây)
@interface NotificationSettingsPageViewController () <NotificationSettingsCoordinatorBridgePresenterDelegate>
{
    // Chỉ chứa các IVAR (biến instance) không liên quan đến Property
    __weak id kThemeServiceDidChangeThemeNotificationObserver;
    __weak UIAlertController *currentAlert;
}

// KHAI BÁO CÁC PROPERTY DUY NHẤT VÀ RIÊNG TƯ CỦA CONTROLLER
@property (nonatomic) UNNotificationSettings *systemNotificationSettings;
//@property (nonatomic, strong) NotificationSettingsCoordinatorBridgePresenter *notificationSettingsBridgePresenter;

@end

@implementation NotificationSettingsPageViewController

#pragma mark - Initialisation

- (instancetype)initWithMxSession:(MXSession *)mxSession
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _mxSession = mxSession;
    }
    return self;
}

- (void)dealloc
{
    if (kThemeServiceDidChangeThemeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kThemeServiceDidChangeThemeNotificationObserver];
        kThemeServiceDidChangeThemeNotificationObserver = nil;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [VectorL10n settingsNotifications];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    // Khởi tạo và setup UITableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // Đăng ký cell
    [self.tableView registerClass:[MXKTableViewCellWithLabelAndSwitch class] forCellReuseIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier]];
    [self.tableView registerClass:[MXKTableViewCell class] forCellReuseIdentifier:[MXKTableViewCell defaultReuseIdentifier]];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    
    [self userInterfaceThemeDidChange];
    
    MXWeakify(self);
    kThemeServiceDidChangeThemeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kThemeServiceDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        MXStrongifyAndReturnIfNil(self);
        [self userInterfaceThemeDidChange];
    }];
    
    [self refreshSystemNotificationSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshSystemNotificationSettings];
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    
    self.tableView.backgroundColor = ThemeService.shared.theme.thuybackgroundColor;
    self.tableView.separatorColor = ThemeService.shared.theme.lineBreakColor;
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.tableView reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ThemeService.shared.theme.statusBarStyle;
}

// SỬA LỖI: Dùng self.systemNotificationSettings
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

#pragma mark - Utils

- (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    MXKTableViewCellWithLabelAndSwitch *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier] forIndexPath:indexPath];
    
    cell.mxkLabelLeadingConstraint.constant = tableView.vc_separatorInset.left;
    cell.mxkSwitchTrailingConstraint.constant = 15;
    cell.mxkLabel.textColor = ThemeService.shared.theme.textPrimaryColor;

    cell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    cell.mxkLabel.numberOfLines = 0;
    
    [cell.mxkSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    cell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
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

    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;
    cell.textLabel.numberOfLines = 0;
    
    cell.textLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NOTIFICATION_SETTINGS_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NOTIFICATION_SETTINGS_SECTION_GENERAL:
        {
            NSInteger count = 3;
            if (RiotSettings.shared.settingsScreenShowNotificationDecodedContentOption)
            {
                count++;
            }
            return count;
        }
        case NOTIFICATION_SETTINGS_SECTION_PINNING:
            return 2;
        case NOTIFICATION_SETTINGS_SECTION_RULES:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NOTIFICATION_SETTINGS settingIndex = -1;
    
    switch (section) {
        case NOTIFICATION_SETTINGS_SECTION_GENERAL:
            if (row == 0) settingIndex = NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX;
            else if (row == 1) settingIndex = NOTIFICATION_SETTINGS_SYSTEM_SETTINGS;
            else if (row == 2) settingIndex = NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX;
            else if (row == 3 && RiotSettings.shared.settingsScreenShowNotificationDecodedContentOption) settingIndex = NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT;
            else return [self getDefaultTableViewCell:tableView];
            break;
        case NOTIFICATION_SETTINGS_SECTION_PINNING:
            settingIndex = (row == 0) ? NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX : NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX;
            break;
        case NOTIFICATION_SETTINGS_SECTION_RULES:
            if (row == 0) settingIndex = NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX;
            else if (row == 1) settingIndex = NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX;
            else settingIndex = NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX;
            break;
        default:
            return [self getDefaultTableViewCell:tableView];
    }

    UITableViewCell *cell = nil;
    MXKAccount* account = [MXKAccountManager sharedManager].activeAccounts.firstObject;

    // --- Cấu hình cho các công tắc (Switch Cells) ---
    if (settingIndex == NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX ||
        settingIndex == NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX ||
        settingIndex == NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT ||
        settingIndex == NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX ||
        settingIndex == NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX)
    {
        MXKTableViewCellWithLabelAndSwitch *switchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
        cell = switchCell;
        
        switch (settingIndex) {
            case NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX:
            {
                switchCell.mxkLabel.text = [VectorL10n settingsEnablePushNotif];
                
                // SỬA LỖI: Dùng property self.systemNotificationSettings
                BOOL isPushEnabled = account.pushNotificationServiceIsActive;
                if (isPushEnabled && self.systemNotificationSettings)
                {
                    isPushEnabled = self.systemNotificationSettings.authorizationStatus == UNAuthorizationStatusAuthorized;
                }
                
                [switchCell.mxkSwitch setOn:isPushEnabled animated:NO];
                [switchCell.mxkSwitch addTarget:self action:@selector(togglePushNotifications:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX:
            {
                switchCell.mxkLabel.text = VectorL10n.settingsEnableInappNotifications;
                [switchCell.mxkSwitch setOn:RiotSettings.shared.showInAppNotifications animated:NO];
                switchCell.mxkSwitch.enabled = account.pushNotificationServiceIsActive;
                [switchCell.mxkSwitch addTarget:self action:@selector(toggleShowInAppNotifications:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT:
            {
                switchCell.mxkLabel.text = [VectorL10n settingsShowDecryptedContent];
                [switchCell.mxkSwitch setOn:RiotSettings.shared.showDecryptedContentInNotifications animated:NO];
                switchCell.mxkSwitch.enabled = account.pushNotificationServiceIsActive;
                [switchCell.mxkSwitch addTarget:self action:@selector(toggleShowDecodedContent:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX:
            {
                switchCell.mxkLabel.text = [VectorL10n settingsPinRoomsWithMissedNotif];
                [switchCell.mxkSwitch setOn:RiotSettings.shared.pinRoomsWithMissedNotificationsOnHome animated:NO];
                [switchCell.mxkSwitch addTarget:self action:@selector(togglePinRoomsWithMissedNotif:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX:
            {
                switchCell.mxkLabel.text = [VectorL10n settingsPinRoomsWithUnread];
                [switchCell.mxkSwitch setOn:RiotSettings.shared.pinRoomsWithUnreadMessagesOnHome animated:NO];
                [switchCell.mxkSwitch addTarget:self action:@selector(togglePinRoomsWithUnread:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            default:
                break;
        }
    }
    // --- Cấu hình cho các ô điều hướng (Default Cells) ---
    else
    {
        cell = [self getDefaultTableViewCell:tableView];
        
        switch (settingIndex) {
            case NOTIFICATION_SETTINGS_SYSTEM_SETTINGS:
                cell.textLabel.text = [VectorL10n settingsDeviceNotifications];
                break;
            case NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX:
                cell.textLabel.text = [VectorL10n settingsDefault];
                [cell vc_setAccessoryDisclosureIndicatorWithCurrentTheme];
                break;
            case NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX:
                cell.textLabel.text = [VectorL10n settingsMentionsAndKeywords];
                [cell vc_setAccessoryDisclosureIndicatorWithCurrentTheme];
                break;
            case NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX:
                cell.textLabel.text = [VectorL10n settingsOther];
                [cell vc_setAccessoryDisclosureIndicatorWithCurrentTheme];
                break;
            default:
                break;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = ThemeService.shared.theme.thuybackgroundColor;
    cell.textLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    
    return cell;
}

#pragma mark - UITableViewDelegate

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case NOTIFICATION_SETTINGS_SECTION_GENERAL:
//            return [VectorL10n settingsNotifications];
//        case NOTIFICATION_SETTINGS_SECTION_PINNING:
//            return [VectorL10n settingsPinRoomsWithMissedNotif];
//        case NOTIFICATION_SETTINGS_SECTION_RULES:
//            return [VectorL10n settingsDefault];
//        default:
//            return nil;
//    }
//}

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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NOTIFICATION_SETTINGS settingIndex = -1;
    
    switch (section) {
        case NOTIFICATION_SETTINGS_SECTION_GENERAL:
            if (row == 0) settingIndex = NOTIFICATION_SETTINGS_ENABLE_PUSH_INDEX;
            else if (row == 1) settingIndex = NOTIFICATION_SETTINGS_SYSTEM_SETTINGS;
            else if (row == 2) settingIndex = NOTIFICATION_SETTINGS_SHOW_IN_APP_INDEX;
            else if (row == 3 && RiotSettings.shared.settingsScreenShowNotificationDecodedContentOption) settingIndex = NOTIFICATION_SETTINGS_SHOW_DECODED_CONTENT;
            else return;
            break;
        case NOTIFICATION_SETTINGS_SECTION_PINNING:
            settingIndex = (row == 0) ? NOTIFICATION_SETTINGS_PIN_MISSED_NOTIFICATIONS_INDEX : NOTIFICATION_SETTINGS_PIN_UNREAD_INDEX;
            break;
        case NOTIFICATION_SETTINGS_SECTION_RULES:
            if (row == 0) settingIndex = NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX;
            else if (row == 1) settingIndex = NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX;
            else settingIndex = NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX;
            break;
        default:
            return;
    }

    if (settingIndex == NOTIFICATION_SETTINGS_SYSTEM_SETTINGS)
    {
        [self openSystemSettingsApp];
    }
    else if (settingIndex == NOTIFICATION_SETTINGS_DEFAULT_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenDefaultNotifications];
    }
    else if (settingIndex == NOTIFICATION_SETTINGS_MENTION_AND_KEYWORDS_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenMentionsAndKeywords];
    }
    else if (settingIndex == NOTIFICATION_SETTINGS_OTHER_SETTINGS_INDEX)
    {
        [self showNotificationSettings:NotificationSettingsScreenOther];
    }
}

#pragma mark - Action Handlers

// SỬA LỖI: Dùng self.systemNotificationSettings
- (void)togglePushNotifications:(UISwitch *)sender
{
    MXKAccountManager *accountManager = [MXKAccountManager sharedManager];
    MXKAccount* account = accountManager.activeAccounts.firstObject;

    if (sender.on)
    {
        if (self.systemNotificationSettings.authorizationStatus == UNAuthorizationStatusDenied)
        {
            [sender setOn:NO animated:YES];
            [self openSystemSettingsApp];
        }
        else if (accountManager.apnsDeviceToken)
        {
            [account enablePushNotifications:YES success:^{} failure:^(NSError *error) {
                [sender setOn:NO animated:YES];
            }];
        }
        else
        {
            [[AppDelegate theDelegate] registerForRemoteNotificationsWithCompletion:^(NSError * error) {
                if (error)
                {
                    [sender setOn:NO animated:YES];
                }
                else
                {
                    [account enablePushNotifications:YES success:^{} failure:^(NSError *error) {
                        [sender setOn:NO animated:YES];
                    }];
                }
            }];
        }
    }
    else
    {
        [account enablePushNotifications:NO success:^{} failure:^(NSError *error) {
             [sender setOn:YES animated:YES];
        }];
    }
}

- (void)toggleShowInAppNotifications:(UISwitch *)sender
{
    RiotSettings.shared.showInAppNotifications = sender.isOn;
}

- (void)toggleShowDecodedContent:(UISwitch *)sender
{
    RiotSettings.shared.showDecryptedContentInNotifications = sender.isOn;
}

- (void)togglePinRoomsWithMissedNotif:(UISwitch *)sender
{
    RiotSettings.shared.pinRoomsWithMissedNotificationsOnHome = sender.isOn;
}

- (void)togglePinRoomsWithUnread:(UISwitch *)sender
{
    RiotSettings.shared.pinRoomsWithUnreadMessagesOnHome = sender.isOn;
}

- (void)openSystemSettingsApp
{
    NSURL *settingsAppURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsAppURL options:@{} completionHandler:nil];
}

#pragma mark - Sub-Page Navigation
//
//- (void)showNotificationSettings: (NotificationSettingsScreen)screen API_AVAILABLE(ios(14.0))
//{
//    if (!self.mxSession) {
//        MXLogError(@"[NotificationSettingsPageViewController] Cannot show notification settings, mxSession is nil.");
//        return;
//    }
//    
//    NotificationSettingsCoordinatorBridgePresenter *notificationSettingsBridgePresenter = [[NotificationSettingsCoordinatorBridgePresenter alloc] initWithSession:self.mxSession];
//    notificationSettingsBridgePresenter.delegate = self;
//    
//    MXWeakify(self);
//    [notificationSettingsBridgePresenter pushFrom:self.navigationController animated:YES screen:screen popCompletion:^{
//        MXStrongifyAndReturnIfNil(self);
//        self.notificationSettingsBridgePresenter = nil;
//    }];
//    
//    self.notificationSettingsBridgePresenter = notificationSettingsBridgePresenter;
//}


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

#pragma mark - NotificationSettingsCoordinatorBridgePresenterDelegate

- (void)notificationSettingsCoordinatorBridgePresenterDelegateDidComplete:(NotificationSettingsCoordinatorBridgePresenter *)coordinatorBridgePresenter API_AVAILABLE(ios(14.0))
{
    [self.notificationSettingsBridgePresenter dismissWithAnimated:YES completion:nil];
    self.notificationSettingsBridgePresenter = nil;
}

@end
