# Expandable Button Study project

## Description
This is just a study project, used to create a new component that I saw on multiple applications I use, but never created anything similar.
So this is completely done by myself to understand how would be possible to create a component that is a button and behaves expanding other buttons options when tapped.

This project also uses some protocol and extensions to simplify code.
Also, I have done this study project to be able to easily add this feature on multiple apps that I created later, that ended up easily implementing and using this button style.

TODO: This code can be improved by changing the buttons to use their reference and not their tag, this is an easy but nice future improvement to be done.

## Sample
<img width=260px src="https://github.com/Bressam/expandableButton/blob/main/SampleResources/expandableButton_sample.gif">

## Usage
To use the button the view just need to change its class to ExpandableButton, and provide the wanted configuration through delegates and datasources, also providing each button.

Notifications and customizagtions provided by Delegate:
```swift
protocol ExpandableButtonDelegate: AnyObject {
    func shouldExpand() -> Bool
    func shouldAddBlackLayer(for expandableButton: ExpandableButton) -> Bool
    func blockUserInteractionWhenExpanded() -> Bool
    func shouldChangeToCloseWhenExpanded() -> Bool
    func willToggleExpandableButton()
    func didExpandButton()
    func didCompressButton()
}
```

Customizagtions provided by Datasource:
```swift
protocol ExpandableButtonDataSource: AnyObject {
    func buttonsToPresent(for expandableButton: ExpandableButton) -> [UIButton]
    func expansionType(for expandableButton: ExpandableButton) -> ExpandableButtonDirection
    func closeImage(for expandableButton: ExpandableButton) -> UIImage?
    func firstButtonSpacing(for expandableButton: ExpandableButton) -> CGFloat
}
```
