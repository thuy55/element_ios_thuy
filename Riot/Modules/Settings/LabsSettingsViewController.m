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

#import "LabsSettingsViewController.h"

// --- CÁC IMPORT CẦN THIẾT (Đã bỏ comment) ---
#import "ThemeService.h"
//#import "RiotSettings.h" // Cần cho các thuộc tính RiotSettings
//#import "AppDelegate.h" // Cần cho enableThreads
//#import "MXSDKOptions.h" // Cần cho enableThreads
//#import "VectorL10n.h" // Chuỗi localized
#import "GeneratedInterface-Swift.h"
#import "MXKAccountManager.h"
#import "MXKAccount.h"
#import "MXKTableViewCellWithLabelAndSwitch.h"
#import "MXKTableViewCell.h"
//#import "UIView+MatrixKit.h" // Cho vc_separatorInset
//#import "MXWeakify.h" // Cần cho ThreadsBetaCoordinator
//#import "MXKTools.h" // Để lấy BuildSettings, v.v.

// Định nghĩa các hàng (rows) - Đã di chuyển từ SettingsViewController.m
typedef NS_ENUM(NSUInteger, LABS_ENABLE)
{
    LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX = 0,
    LABS_ENABLE_THREADS_INDEX,
    LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS,
    LABS_ENABLE_LIVE_LOCATION_SHARING,
    LABS_ENABLE_NEW_SESSION_MANAGER,
    LABS_ENABLE_NEW_CLIENT_INFO_FEATURE,
    LABS_ENABLE_WYSIWYG_COMPOSER,
    LABS_ENABLE_VOICE_BROADCAST
};


@interface LabsSettingsViewController () <UITableViewDelegate, UITableViewDataSource, ThreadsBetaCoordinatorBridgePresenterDelegate>
{
    __weak id kThemeServiceDidChangeThemeNotificationObserver;
    
    NSMutableArray<NSNumber*> *rows;
    
    // Khai báo cho hàm mainSession
    MXSession *_mainSession;
}

@property (nonatomic, strong) ThreadsBetaCoordinatorBridgePresenter *threadsBetaBridgePresenter;
//@property (strong, nonatomic) UITableView *tableView; // Khai báo rõ ràng

@end

@implementation LabsSettingsViewController

#pragma mark - MXKViewController Overrides

// Khai báo lại mainSession để có thể sử dụng
- (MXSession *)mainSession
{
    if (!_mainSession)
    {
        _mainSession = [AppDelegate theDelegate].mxSessions.firstObject;
    }
    return _mainSession;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [VectorL10n settingsLabs];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    // --- TẠO TABLEVIEW BẰNG CODE ---
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // Đăng ký cell
    [self.tableView registerClass:MXKTableViewCellWithLabelAndSwitch.class forCellReuseIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier]];
    
    // Đảm bảo Table View có thể tự co giãn chiều cao cell
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    
    // Khởi tạo mảng chứa các hàng
    rows = [NSMutableArray array];
    [self updateRows];

    // Cập nhật giao diện theo theme
    [self userInterfaceThemeDidChange];
    
    // Observe user interface theme change.
    kThemeServiceDidChangeThemeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kThemeServiceDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        [self userInterfaceThemeDidChange];
        [self.tableView reloadData];
    }];
}

- (void)dealloc
{
    if (kThemeServiceDidChangeThemeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kThemeServiceDidChangeThemeNotificationObserver];
        kThemeServiceDidChangeThemeNotificationObserver = nil;
    }
}

/**
 Cập nhật danh sách các hàng (rows) sẽ hiển thị dựa trên cấu hình.
 */
- (void)updateRows
{
    [rows removeAllObjects];
    
    // Đây là logic được di chuyển từ 'updateSections' của SettingsViewController.m
    [rows addObject:@(LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX)];
    
    // Kiểm tra tính năng Threads trước khi thêm vào
    if (BuildSettings.settingsScreenShowLabSettings) {
        [rows addObject:@(LABS_ENABLE_THREADS_INDEX)];
    }
    
    [rows addObject:@(LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS)];
    
    if (BuildSettings.locationSharingEnabled)
    {
        [rows addObject:@(LABS_ENABLE_LIVE_LOCATION_SHARING)];
    }
    
    [rows addObject:@(LABS_ENABLE_NEW_SESSION_MANAGER)];
    [rows addObject:@(LABS_ENABLE_NEW_CLIENT_INFO_FEATURE)];
    
    if (@available(iOS 15.0, *))
    {
        [rows addObject:@(LABS_ENABLE_WYSIWYG_COMPOSER)];
    }
    [rows addObject:@(LABS_ENABLE_VOICE_BROADCAST)];
    
    [self.tableView reloadData];
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    
    self.tableView.backgroundColor = ThemeService.shared.theme.thuybackgroundColor; // Đã sửa lỗi chính tả 'thuybackgroundColor'
    self.view.backgroundColor = self.tableView.backgroundColor;
    self.tableView.separatorColor = ThemeService.shared.theme.lineBreakColor;
    
    [self.tableView reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ThemeService.shared.theme.statusBarStyle;
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Chỉ có 1 section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rows.count; // Trả về số lượng hàng đã được tính toán
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowTag = [rows[indexPath.row] integerValue];
    UITableViewCell *cell;
    
    switch (rowTag) {
        case LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
            
            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableRingingForGroupCalls];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableRingingForGroupCalls animated:NO];
            
            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableRingingForGroupCalls:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_THREADS_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
            
            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableThreads];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableThreads animated:NO];
            
            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableThreads:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS:
        {
            cell = [self buildAutoReportDecryptionErrorsCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case LABS_ENABLE_LIVE_LOCATION_SHARING:
        {
            cell = [self buildLiveLocationSharingCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case LABS_ENABLE_NEW_SESSION_MANAGER:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableNewSessionManager];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableNewSessionManager animated:NO];

            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableNewSessionManager:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_NEW_CLIENT_INFO_FEATURE:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableNewClientInfoFeature];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableClientInformationFeature animated:NO];

            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableNewClientInfoFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_WYSIWYG_COMPOSER:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableWysiwygComposer];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableWysiwygComposer animated:NO];

            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableWysiwygComposerFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_VOICE_BROADCAST:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableVoiceBroadcast];
            
            [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableVoiceBroadcast animated:NO];

            [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableVoiceBroadcastFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        default:
            cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = [VectorL10n error];
            break;
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

#pragma mark - Các hàm (methods) được di chuyển từ SettingsViewController

- (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    MXKTableViewCellWithLabelAndSwitch *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier] forIndexPath:indexPath];
    
    // NOTE: Sửa lỗi: Cần đảm bảo tableView có vc_separatorInset và MXKTableViewCellWithLabelAndSwitch có các constraint
    // if ([tableView respondsToSelector:@selector(vc_separatorInset)]) {
    //     cell.mxkLabelLeadingConstraint.constant = tableView.vc_separatorInset.left;
    // }
    cell.mxkSwitchTrailingConstraint.constant = 15;
    cell.mxkLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    cell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;

    cell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    cell.mxkLabel.numberOfLines = 0;

    [cell.mxkSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [cell layoutIfNeeded];
    
    return cell;
}

- (UITableViewCell *)buildAutoReportDecryptionErrorsCellForTableView:(UITableView*)tableView
                                             atIndexPath:(NSIndexPath*)indexPath
{
    MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
    
    labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableAutoReportDecryptionErrors];

    [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableUISIAutoReporting animated:NO];
    
    labelAndSwitchCell.mxkSwitch.enabled = YES;
    [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableAutoReportDecryptionErrors:) forControlEvents:UIControlEventTouchUpInside];
    
    return labelAndSwitchCell;
}

- (UITableViewCell *)buildLiveLocationSharingCellForTableView:(UITableView*)tableView
                                                  atIndexPath:(NSIndexPath*)indexPath
{
    MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
    
    labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableLiveLocationSharing];

    [labelAndSwitchCell.mxkSwitch setOn:RiotSettings.shared.enableLiveLocationSharing animated:NO];
    
    labelAndSwitchCell.mxkSwitch.enabled = YES;
    [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableLiveLocationSharing:) forControlEvents:UIControlEventTouchUpInside];
    
    return labelAndSwitchCell;
}

#pragma mark - Action Handlers

- (void)toggleEnableRingingForGroupCalls:(UISwitch *)sender
{
    RiotSettings.shared.enableRingingForGroupCalls = sender.isOn;
}

- (void)toggleEnableThreads:(UISwitch *)sender
{
    MXSession *session = self.mainSession;

    if (sender.isOn && !session.store.supportedMatrixVersions.supportsThreads)
    {
        MXWeakify(self);
        if (self.threadsBetaBridgePresenter)
        {
            [self.threadsBetaBridgePresenter dismissWithAnimated:YES completion:nil];
            self.threadsBetaBridgePresenter = nil;
        }

        self.threadsBetaBridgePresenter = [[ThreadsBetaCoordinatorBridgePresenter alloc] initWithThreadId:@""
                                                                                                 infoText:VectorL10n.threadsDiscourageInformation1
                                                                                           additionalText:VectorL10n.threadsDiscourageInformation2];
        self.threadsBetaBridgePresenter.delegate = self;

        [self.threadsBetaBridgePresenter presentFrom:self.presentedViewController?:self animated:YES];
        return;
    }

    [self enableThreads:sender.isOn];
}

- (void)enableThreads:(BOOL)enable
{
    RiotSettings.shared.enableThreads = enable;
    MXSDKOptions.sharedInstance.enableThreads = enable;
    
    // NOTE: Cần MXKRoomDataSourceManager (không có import)
    // [[MXKRoomDataSourceManager sharedManagerForMatrixSession:self.mainSession] reset];
    
    // NOTE: Cần AppDelegate (có import)
    // [[AppDelegate theDelegate] restoreEmptyDetailsViewController];
}

- (void)toggleEnableNewSessionManager:(UISwitch *)sender
{
    RiotSettings.shared.enableNewSessionManager = sender.isOn;
    [self updateRows];
}

- (void)toggleEnableNewClientInfoFeature:(UISwitch *)sender
{
    BOOL isEnabled = sender.isOn;
    RiotSettings.shared.enableClientInformationFeature = isEnabled;
    MXSDKOptions.sharedInstance.enableNewClientInformationFeature = isEnabled;
    
    // NOTE: Cần mainSession (đã khai báo)
    // [self.mainSession updateClientInformation];
}

- (void)toggleEnableWysiwygComposerFeature:(UISwitch *)sender
{
    RiotSettings.shared.enableWysiwygComposer = sender.isOn;
}

- (void)toggleEnableVoiceBroadcastFeature:(UISwitch *)sender
{
    RiotSettings.shared.enableVoiceBroadcast = sender.isOn;
}

- (void)toggleEnableAutoReportDecryptionErrors:(UISwitch *)sender
{
    RiotSettings.shared.enableUISIAutoReporting = sender.isOn;
}

- (void)toggleEnableLiveLocationSharing:(UISwitch *)sender
{
    RiotSettings.shared.enableLiveLocationSharing = sender.isOn;
}



@end
