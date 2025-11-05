/*
Copyright 2024 New Vector Ltd.
Copyright 2017 Vector Creations Ltd
Copyright 2015 OpenMarket Ltd

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
 */

#import "RecentTableViewCell.h"

#import "AvatarGenerator.h"

#import "MXEvent.h"
#import "MXRoom+Riot.h"

#import "ThemeService.h"
#import "GeneratedInterface-Swift.h"

#import "MXRoomSummary+Riot.h"

// --- BẠN THÊM VÀO ĐÂY ---
@interface RecentTableViewCell ()

@property (nonatomic, strong) UIImageView *groupIconViewFromCode;
@property (nonatomic, assign) CGFloat groupIconAspectRatio;

@end
// --- KẾT THÚC THÊM ---

@implementation RecentTableViewCell

#pragma mark - Class methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialize unread count badge
    [_missedNotifAndUnreadBadgeBgView.layer setCornerRadius:10];
    _missedNotifAndUnreadBadgeBgViewWidthConstraint.constant = 0;
    
    // --- BỔ SUNG: TẠO ICON NHÓM BẰNG CODE ---
    // --- BỔ SUNG: TẠO ICON NHÓM BẰNG CODE ---
        if (!self.groupIconViewFromCode) // Chỉ tạo 1 lần duy nhất
        {
            self.groupIconViewFromCode = [[UIImageView alloc] init];
            
            // 1. Lấy ảnh gốc (giữ màu)
            UIImage *originalImage = [UIImage imageNamed:@"nhom_chat_icon"]; // Tên mới của bạn
            UIImage *iconImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.groupIconViewFromCode.image = iconImage;
            
            // 2. Xoá nền
            self.groupIconViewFromCode.backgroundColor = [UIColor clearColor];
            
            // 3. Đặt là ScaleToFill để ảnh lấp đầy khung 40x40 (có thể bị méo nếu ảnh không vuông)
            // Hoặc dùng ScaleAspectFit (ảnh vừa vặn bên trong 40x40)
            self.groupIconViewFromCode.contentMode = UIViewContentModeScaleAspectFit;

            self.groupIconViewFromCode.hidden = YES; // Mặc định ẩn
            
            [self.contentView addSubview:self.groupIconViewFromCode];
        }
        // --- KẾT THÚC BỔ SUNG ---
        // --- KẾT THÚC BỔ SUNG ---
    
    
}

- (void)customizeTableViewCellRendering
{
    [super customizeTableViewCellRendering];
    
    self.contentView.backgroundColor = ThemeService.shared.theme.backgroundColor;
    self.roomTitle.textColor = ThemeService.shared.theme.textPrimaryColor;
    self.lastEventDescription.textColor = ThemeService.shared.theme.textSecondaryColor;
    self.lastEventDate.textColor = ThemeService.shared.theme.textSecondaryColor;
    self.missedNotifAndUnreadBadgeLabel.textColor = ThemeService.shared.theme.baseTextPrimaryColor;
    self.presenceIndicatorView.borderColor = ThemeService.shared.theme.backgroundColor;
    
    self.roomAvatar.defaultBackgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Round image view
    [_roomAvatar.layer setCornerRadius:_roomAvatar.frame.size.width / 2];
    _roomAvatar.clipsToBounds = YES;
}

- (void)render:(MXKCellData *)cellData
{
    // Hide by default missed notifications and unread widgets
    self.missedNotifAndUnreadIndicator.hidden = YES;
    self.missedNotifAndUnreadBadgeBgView.hidden = YES;
    self.missedNotifAndUnreadBadgeBgViewWidthConstraint.constant = 0;
    self.missedNotifAndUnreadBadgeLabel.text = @"";
    
    roomCellData = (id<MXKRecentCellDataStoring>)cellData;
    if (roomCellData)
    {
        // Report computed values as is
        self.roomTitle.text = roomCellData.roomDisplayname;
        self.lastEventDate.text = roomCellData.lastEventDate;
        
        // Manage lastEventAttributedTextMessage optional property
        if (!roomCellData.roomSummary.spaceChildInfo && [roomCellData respondsToSelector:@selector(lastEventAttributedTextMessage)])
        {
            // Attempt to correct the attributed string colors to match the current theme
            self.lastEventDescription.attributedText = [roomCellData.lastEventAttributedTextMessage fixForegroundColor];
        }
        else
        {
            self.lastEventDescription.text = roomCellData.lastEventTextMessage;
        }

        self.unsentImageView.hidden = roomCellData.roomSummary.sentStatus == MXRoomSummarySentStatusOk;
        self.lastEventDecriptionLabelTrailingConstraint.constant = self.unsentImageView.hidden ? 10 : 30;

        // Notify unreads and bing
        if (roomCellData.hasUnread)
        {
            self.missedNotifAndUnreadIndicator.hidden = NO;
            if (0 < roomCellData.notificationCount)
            {
                self.missedNotifAndUnreadIndicator.backgroundColor = roomCellData.highlightCount ? ThemeService.shared.theme.noticeColor : ThemeService.shared.theme.noticeSecondaryColor;

                self.missedNotifAndUnreadBadgeBgView.hidden = NO;
                self.missedNotifAndUnreadBadgeBgView.backgroundColor = self.missedNotifAndUnreadIndicator.backgroundColor;

                self.missedNotifAndUnreadBadgeLabel.text = roomCellData.notificationCountStringValue;
                [self.missedNotifAndUnreadBadgeLabel sizeToFit];

                self.missedNotifAndUnreadBadgeBgViewWidthConstraint.constant = self.missedNotifAndUnreadBadgeLabel.frame.size.width + 18;
            }
            else
            {
                self.missedNotifAndUnreadIndicator.backgroundColor = ThemeService.shared.theme.unreadRoomIndentColor;
            }

            // Use bold font for the room title
            self.roomTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        }
        else
        {
            self.lastEventDate.textColor = ThemeService.shared.theme.textSecondaryColor;

            // The room title is not bold anymore
            self.roomTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        }

        [self.roomAvatar vc_setRoomAvatarImageWith:roomCellData.avatarUrl
                                            roomId:roomCellData.roomIdentifier
                                       displayName:roomCellData.roomDisplayname
                                      mediaManager:roomCellData.mxSession.mediaManager];

//        if (roomCellData.directUserId)
//        {
//            [self.presenceIndicatorView configureWithUserId:roomCellData.directUserId presence:roomCellData.presence];
//        }
//        else
//        {
//            [self.presenceIndicatorView stopListeningPresenceUpdates];
//        }
        
        // --- BẮT ĐẦU THAY THẾ (LOGIC TÍNH TOÁN TỶ LỆ) ---
        // --- BẮT ĐẦU THAY THẾ (LOGIC KÍCH THƯỚC 40px) ---
                if (roomCellData.directUserId)
                {
                    // Đây là 1-1: Hiện chấm 1-1, Ẩn icon nhóm
                    [self.presenceIndicatorView configureWithUserId:roomCellData.directUserId presence:roomCellData.presence];
                    self.presenceIndicatorView.hidden = NO;
                    
                    if (self.groupIconViewFromCode)
                    {
                        self.groupIconViewFromCode.hidden = YES;
                    }
                }
                else
                {
                    // Đây là NHÓM: Ẩn chấm 1-1, Hiện icon nhóm
                    [self.presenceIndicatorView stopListeningPresenceUpdates];
                    self.presenceIndicatorView.hidden = YES;
                    
                    if (self.groupIconViewFromCode)
                    {
                        // --- LOGIC ĐẶT VỊ TRÍ MỚI ---
                        
                        // 1. ĐẶT KÍCH THƯỚC CỐ ĐỊNH 40px (Theo yêu cầu của bạn)
                        CGFloat iconWidth = 20.0;
                        CGFloat iconHeight = 20.0;

                        // 2. Lấy vị trí AVATAR
                        CGRect avatarFrame = self.roomAvatar.frame;
                        
                        // 3. Tính toán vị trí (canh lề phải và đáy của avatar)
                        CGFloat iconX = (avatarFrame.origin.x + avatarFrame.size.width) - iconWidth + 5.0f;
                        CGFloat iconY = (avatarFrame.origin.y + avatarFrame.size.height) - iconHeight + 5.0f;
                        
                        // 4. Đặt VỊ TRÍ (frame) với kích thước MỚI
                        self.groupIconViewFromCode.frame = CGRectMake(iconX, iconY, iconWidth, iconHeight);
                        
                        // 5. Xoá bo tròn
                        self.groupIconViewFromCode.layer.cornerRadius = 0;
                        self.groupIconViewFromCode.clipsToBounds = NO;
                        		
                        // 6. Hiển thị
                        self.groupIconViewFromCode.hidden = NO;
                        [self.contentView bringSubviewToFront:self.groupIconViewFromCode];
                    }
                }
                // --- KẾT THÚC THAY THẾ ---
    }
    else
    {
        self.lastEventDescription.text = @"";
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.presenceIndicatorView stopListeningPresenceUpdates];
}

+ (CGFloat)heightForCellData:(MXKCellData *)cellData withMaximumWidth:(CGFloat)maxWidth
{
    // The height is fixed
    return 74;
}

@end
