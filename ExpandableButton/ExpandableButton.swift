//
//  ExpandableButton.swift
//  ExpandableButton
//
//  Created by Giovanne Bressam on 27/02/23.
//

import UIKit

// MARK: - Datasource and Delegate
protocol ExpandableButtonDelegate: AnyObject {
    func shouldExpand() -> Bool
    func shouldAddBlackLayer(for expandableButton: ExpandableButton) -> Bool
    func blockUserInteractionWhenExpanded() -> Bool
    func shouldChangeToCloseWhenExpanded() -> Bool
    func willToggleExpandableButton()
    func didExpandButton()
    func didCompressButton()
}

protocol ExpandableButtonDataSource: AnyObject {
    func buttonsToPresent(for expandableButton: ExpandableButton) -> [UIButton]
    func expansionType(for expandableButton: ExpandableButton) -> ExpandableButtonDirection
    func closeImage(for expandableButton: ExpandableButton) -> UIImage?
    func firstButtonSpacing(for expandableButton: ExpandableButton) -> CGFloat
}

// MARK: Delegate default implementation
extension ExpandableButtonDelegate where Self: UIResponder {
    func shouldExpand() -> Bool {
        return true
    }

    func shouldAddBlackLayer() -> Bool {
        return false
    }

    func shouldChangeToCloseWhenExpanded() -> Bool {
        return true
    }

    func blockUserInteractionWhenExpanded() -> Bool {
        return true
    }

    func willToggleExpandableButton() { }

    func didExpandButton() { }

    func didCompressButton() { }
}

extension ExpandableButtonDataSource where Self: UIResponder {
    func buttonsToPresent(for expandableButton: ExpandableButton) -> [UIButton] {
        return []
    }

    func expansionType(for expandableButton: ExpandableButton) -> ExpandableButtonDirection {
        return .bottom
    }

    func closeImage(for expandableButton: ExpandableButton) -> UIImage? {
        return UIImage(systemName: "xmark")
    }
    
    func firstButtonSpacing(for expandableButton: ExpandableButton) -> CGFloat {
        return 8
    }
}

enum ExpandableButtonDirection {
    case top, bottom, leftUp, leftDown, rightUp, rightDown
}

/// Custom expandable button. Customizable through its delegate and datasource
class ExpandableButton: UIButton {

    // MARK: UIElements
    private lazy var buttonsStack: UIStackView = {
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.distribution = .equalCentering
        buttonsStack.spacing = 8
        buttonsStack.alignment = .center
        buttonsStack.backgroundColor = .clear
        buttonsStack.tag = buttonStackTag
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        return buttonsStack
    }()

    private lazy var darkLayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        view.tag = darkLayerViewTag
        view.isUserInteractionEnabled = (delegate?.blockUserInteractionWhenExpanded() ?? true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var spaceBetweenButtons: CGFloat = 20
    var firstButtonSpacing: CGFloat = 0
    private let buttonStackTag: Int = 80000
    private let closeViewTag: Int = 80001
    private let darkLayerViewTag: Int = 80003
    private let buttonCopyTag: Int = 80004
    private lazy var createdViewsTags: [Int] = [buttonStackTag, closeViewTag, darkLayerViewTag, buttonCopyTag]

    private(set) var isExpanded: Bool = false
    private var closeButton: UIButton?

    // MARK: Delegates & Datasource
    weak var delegate: ExpandableButtonDelegate?
    weak var datasource: ExpandableButtonDataSource?

    /// Overrides original touchesBegan to intercept touches, if expandable handle it, otherwise just passthrough the touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let shouldExpand = delegate?.shouldExpand() ?? false
        // Ignore actions and do expansion
        if shouldExpand {
            handleToggleExpandedButtons()
        } else {
            // Do regular actions added to button
            super.touchesBegan(touches, with: event)
            //self?.sendActions(for: .touchUpInside)
        }
    }

    // MARK: - Public access in case any view needs to force it to compress/expand by any reason
    func expandButtons() {
        if !isExpanded { handleToggleExpandedButtons() }
    }

    func compressButtons() {
        if isExpanded { handleToggleExpandedButtons() }
    }

    // MARK: - Buttons actions
    @objc private func expandedButtonTapReceived() {
        compressButtons()
    }

    @objc private func copiedButtonTapped() {
        compressButtons()
    }

    @objc private func darkLayerTapped() {
        compressButtons()
    }
}

// MARK: - Main logic, expand, compress and updates
private extension ExpandableButton {

    /// Add all buttons provided through datasoruce on stackView
    private func addButtonsToStack() {
        datasource?.buttonsToPresent(for: self).forEach({ button in
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandedButtonTapReceived))
            tapRecognizer.cancelsTouchesInView = false

            button.addGestureRecognizer(tapRecognizer)
            buttonsStack.addArrangedSubview(button)
        })
    }

    /// Do compress/expand and update layout
    private func handleToggleExpandedButtons() {
        delegate?.willToggleExpandableButton()
        if isExpanded {
            compress()
        } else {
            expand()
        }

        // Update new expanded/compressed style
        updateLayout()

        if isExpanded {
            delegate?.didExpandButton()
        } else {
            delegate?.didCompressButton()
        }
    }

    /// Internal expand. Use public access if manual expand needed
    private func expand() {
        // Create & position buttons
        addButtonsToStack()
        positionButtons()
        isExpanded = true

        // Animate
        animateViews(isFadeIn: true)
    }

    /// Internal compress. Use public access if manual expand needed
    private func compress() {
        isExpanded = false

        // Animate
        animateViews(isFadeIn: false) { [weak self] _ in
            self?.removeAuxiliaryViews()
        }
    }

    private func animateViews(isFadeIn: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        if let rootViews = getAppWindow()?.subviews {
            let addedViews = rootViews.filter { createdViewsTags.contains($0.tag) }
            for view in addedViews {
                isFadeIn ? view.fadeIn(onCompletion: completionHandler) : view.fadeOut(onCompletion: completionHandler)
            }
        }
    }

    // "Updates layout" to a close button layout, covering old button so there is
    // no need to save all old layout
    private func updateLayout() {
        if isExpanded {
            // Check if need to create copy of button over dark layer
            closeButton = createACopyIfneeded()

            // Adds new layer on button layout to become a "close button"
            if delegate?.shouldChangeToCloseWhenExpanded() ?? false {
                updateLayoutToCloseButton(on: closeButton)
            }
        }
    }
}

// MARK: - Layout rules, positioning buttons and layouts
extension ExpandableButton {
    // Adds an image over the the original button (or over the copy over the dark layer)
    // of an "X" icon, or to a custom image provided through datasource
    private func updateLayoutToCloseButton(on button: UIButton? = nil) {
        guard let closeImage = datasource?.closeImage(for: self) else { return }

        // no copy over dark layer, update current button
        let buttonToAddLayer = button ?? self

        // Adds an image over the button, so later is just necessary to remove it
        // searching by tag instead of reconfiguring button image and other properties
        let coverView = UIView()
        coverView.isUserInteractionEnabled = false
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = .white
        coverView.tag = closeViewTag
        coverView.translatesAutoresizingMaskIntoConstraints = false

        let coverImageView = UIImageView()
        coverImageView.isUserInteractionEnabled = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.image = closeImage.withAlignmentRectInsets(.init(top: 2, left: 2, bottom: 2, right: 2))
        coverImageView.tintColor = .purple
        coverImageView.contentMode = .scaleAspectFit

        // View container to easily manage margins from image to button
        coverView.addSubview(coverImageView)
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: coverView.topAnchor, constant: 8),
            coverImageView.bottomAnchor.constraint(equalTo: coverView.bottomAnchor, constant: -8),
            coverImageView.leadingAnchor.constraint(equalTo: coverView.leadingAnchor, constant: 8),
            coverImageView.trailingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: -8)
        ])
        
        // Same size as button
        buttonToAddLayer.addSubview(coverView)
        NSLayoutConstraint.activate([
            coverView.centerYAnchor.constraint(equalTo: buttonToAddLayer.centerYAnchor),
            coverView.centerXAnchor.constraint(equalTo: buttonToAddLayer.centerXAnchor),
            coverView.heightAnchor.constraint(equalTo: buttonToAddLayer.heightAnchor),
            coverView.widthAnchor.constraint(equalTo: buttonToAddLayer.widthAnchor)
        ])
        coverView.layer.cornerRadius = buttonToAddLayer.layer.cornerRadius
        coverView.clipsToBounds = buttonToAddLayer.clipsToBounds
        coverView.layoutIfNeeded()
    }

    // ****** Only workaround I thought about  ******
    // If on delegate is set to create a dark layer under button, we run into 1 of these 2 issues:
    // 1 - Create a dark layer over whole app, that makes the original button dark
    // 2 - Or create a layer just under the button: that would make any navigation/tabbar not dark
    // Therefore the only solution I could think to make darkLayer cover whole app and keep
    // button with regular appearance was to clone the button and present its clone over the dark layer, one same position and covering button under it.

    /// Duplicates button to create exact copy over dark layer. If delegate is set to not show dark layer, the clone is not created and the button layer is updated to close button layout.
    private func createACopyIfneeded() -> UIButton? {
        guard delegate?.shouldAddBlackLayer(for: self) ?? false,
              let newButton = try? self.copyView() as? UIButton,
              let rootView = getAppWindow() else { return nil }

        // Configure copy
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.setTitle(nil, for: .normal)
        newButton.tag = buttonCopyTag
        newButton.addTarget(self, action: #selector(copiedButtonTapped), for: .touchUpInside)

        // Add to root view on same position, and copy same frame
        newButton.frame = self.frame
        newButton.layer.cornerRadius = self.layer.cornerRadius
        newButton.layer.masksToBounds = self.layer.masksToBounds

        rootView.addSubview(newButton)
        NSLayoutConstraint.activate([
            newButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            newButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            newButton.widthAnchor.constraint(equalTo: self.widthAnchor),
            newButton.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        newButton.setNeedsLayout()
        
        return newButton
    }

    /// remove all auxiliary views and close button image to show regular button
    private func removeAuxiliaryViews() {
        guard let rootView = getAppWindow() else { return }

        // Remove every button from stack' arranged views and from their superview
        for buttonView in buttonsStack.arrangedSubviews {
            buttonsStack.removeArrangedSubview(buttonView)
            buttonView.removeFromSuperview()
        }

        // Remove stack
        for view in rootView.subviews {
            if createdViewsTags.contains(view.tag) {
                view.removeFromSuperview()
            }
        }
    }

    /// Adds black layer if needed and also  position the stack of buttons at the provided position
    private func positionButtons() {
        guard let rootView = getAppWindow() else { return }

        let hasDarkLayer = delegate?.shouldAddBlackLayer(for: self) ?? false
        if hasDarkLayer {
            rootView.addSubview(darkLayerView)
            NSLayoutConstraint.activate([
                darkLayerView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
                darkLayerView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
                darkLayerView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
                darkLayerView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
                darkLayerView.topAnchor.constraint(equalTo: rootView.topAnchor),
                darkLayerView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
            ])
            darkLayerView.layoutIfNeeded()
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(darkLayerTapped))
            darkLayerView.addGestureRecognizer(tapGesture)
        }

        rootView.addSubview(buttonsStack)

        firstButtonSpacing = datasource?.firstButtonSpacing(for: self) ?? 0
        buttonsStack.spacing = spaceBetweenButtons
        guard let type = datasource?.expansionType(for: self) else { return }
        switch type {
        case .top:
            NSLayoutConstraint.activate([
                buttonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                buttonsStack.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -firstButtonSpacing)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                buttonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                buttonsStack.topAnchor.constraint(equalTo: self.bottomAnchor, constant: firstButtonSpacing)
            ])
        case .leftUp:
            buttonsStack.alignment = .trailing
            NSLayoutConstraint.activate([
                buttonsStack.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -firstButtonSpacing),
                buttonsStack.rightAnchor.constraint(equalTo: self.leftAnchor, constant: -firstButtonSpacing)
            ])
        case .leftDown:
            buttonsStack.alignment = .trailing
            NSLayoutConstraint.activate([
                buttonsStack.topAnchor.constraint(equalTo: self.centerYAnchor, constant: firstButtonSpacing),
                buttonsStack.rightAnchor.constraint(equalTo: self.leftAnchor, constant: -firstButtonSpacing)
            ])
        case .rightUp:
            buttonsStack.alignment = .leading
            NSLayoutConstraint.activate([
                buttonsStack.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -firstButtonSpacing),
                buttonsStack.leftAnchor.constraint(equalTo: self.rightAnchor, constant: firstButtonSpacing)
            ])
        case .rightDown:
            buttonsStack.alignment = .leading
            NSLayoutConstraint.activate([
                buttonsStack.topAnchor.constraint(equalTo: self.centerYAnchor, constant: firstButtonSpacing),
                buttonsStack.leftAnchor.constraint(equalTo: self.rightAnchor, constant: firstButtonSpacing)
            ])
        }
    }
}



/// Just to simplify UIWindow
private extension ExpandableButton {
    func getAppWindow() -> UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
