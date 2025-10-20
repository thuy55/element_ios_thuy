/*
Copyright 2024 New Vector Ltd.
Copyright 2020 Vector Creations Ltd

SPDX-License-Identifier: AGPL-3.0-only
Please see LICENSE in the repository root for full details.
*/

import UIKit
import Reusable

@objcMembers
final class LaunchLoadingView: UIView, NibLoadable, Themable {
    
    // MARK: - Properties
    
    // ĐÃ XÓA: IBOutlet cho animationView cũ không còn cần thiết
    // @IBOutlet private weak var animationView: ElementView!
    
    @IBOutlet private weak var progressContainer: UIStackView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var statusLabel: UILabel!
    
    // ĐÃ THÊM: Thuộc tính để giữ loading spinner
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    // MARK: - Setup
    
    static func instantiate(startupProgress: MXSessionStartupProgress?) -> LaunchLoadingView {
        let view = LaunchLoadingView.loadFromNib()
        startupProgress?.delegate = view
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupActivityIndicator()
        
        progressContainer.isHidden = true
    }
    
    // ĐÃ THÊM: Hàm mới để thiết lập loading spinner
    private func setupActivityIndicator() {
        // Thêm spinner vào view
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Dùng Auto Layout để căn spinner vào giữa màn hình
        // Hằng số `constant` được dùng để đẩy spinner lên trên thanh progress một chút
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -80) // Điều chỉnh để có vị trí đẹp
        ])
        
        // Bắt đầu chạy animation quay tròn
        activityIndicator.startAnimating()
    }
    
    // MARK: - Public
    
    func update(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        // Cập nhật màu cho spinner để phù hợp với theme (sáng/tối)
        self.activityIndicator.color = theme.textPrimaryColor
    }
}

// MARK: - MXSessionStartupProgressDelegate
extension LaunchLoadingView: MXSessionStartupProgressDelegate {
    func sessionDidUpdateStartupProgress(state: MXSessionStartupProgress.State) {
        update(with: state)
    }
    
    private func update(with state: MXSessionStartupProgress.State) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.update(with: state)
            }
            return
        }
        
        // Khi thanh tiến trình bắt đầu hiển thị, ẩn spinner đi
        if progressContainer.isHidden == false {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        CATransaction.begin()
        progressContainer.isHidden = false
        progressView.progress = Float(state.progress)
        statusLabel.text = state.showDelayWarning ? VectorL10n.launchLoadingDelayWarning : VectorL10n.launchLoadingGeneric
        CATransaction.commit()
    }
}
