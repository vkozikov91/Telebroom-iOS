//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ThemedLabel: UILabel {
    
    private enum ThemedLabelStyle: Int {
        case none = 0 // Uses the color set on the storyboard
        case darkText = 1 // Theme - dark text color
        case lightText = 2 // Theme - light text color
    }
    
    @IBInspectable var style: Int = 0 // Represents ThemedLabelStyle
    
    override var text: String? {
        didSet { self.setup() }
    }
    
    
    // MARK: -
    
    override func drawText(in rect: CGRect) {
        setup()
        super.drawText(in: rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let currentFontSize = self.font.pointSize
        let bold = self.font.fontName.lowercased().hasSuffix("bold")
        self.font = Theme.mainFont(currentFontSize, bold: bold)
        switch ThemedLabelStyle(rawValue: self.style)! {
        case .darkText:
            self.textColor = Theme.darkTextColor
        case .lightText:
            self.textColor = Theme.lightTextColor
        default:
            break
        }
    }
}

class ThemeGradientView: UIView {
    
    lazy var gradientLayer: CAGradientLayer = {
        let gLayer = CAGradientLayer()
        gLayer.colors = [Theme.mainBackgroundGradient.0.cgColor, Theme.mainBackgroundGradient.1.cgColor]
        gLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gLayer.endPoint = CGPoint(x: 0.2, y: 0.8)
        return gLayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = self.bounds
        self.layer.insertSublayer(self.gradientLayer, at: 0)
    }
    
}

class UnderlinedTextField: UITextField {
    
    private var lines = [UIView]()
    
    @IBInspectable var lineColor: UIColor = Theme.mainBackgroundColor {
        didSet {
            self.lines.forEach { $0.backgroundColor = lineColor }
            self.textColor = lineColor
        }
    }
    
    private let lineWidth: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.keyboardAppearance = .dark
        let bottomLine = UIView(frame: CGRect.zero)
        let rightLine = UIView(frame: CGRect.zero)
        let leftLine = UIView(frame: CGRect.zero)
        [bottomLine, rightLine, leftLine].forEach {
            $0.backgroundColor = self.lineColor
            $0.isUserInteractionEnabled = false
            self.addSubview($0)
            self.lines.append($0)
        }
        bottomLine.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(lineWidth)
        }
        rightLine.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(lineWidth)
        }
        leftLine.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(lineWidth)
        }
        self.font = Theme.mainFont(16.0, bold: true)
        self.textColor = self.lineColor
        self.tintColor = self.lineColor
        self.backgroundColor = UIColor.clear
        guard let placeholderText = self.placeholder else { return }
        let placeholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedStringKey.foregroundColor: self.lineColor.withAlphaComponent(0.4),
                         NSAttributedStringKey.font: Theme.mainFont(16.0),
                         NSAttributedStringKey.backgroundColor: UIColor.clear])
        self.attributedPlaceholder = placeholder
    }
}


class BorderedButton: UIButton {
    
    @IBInspectable var buttonColor: UIColor = Theme.mainColor {
        didSet { self.setup() }
    }
    
    private var activityIndicator: UIActivityIndicatorView!
    
    var isActivityIndicatorVisible = false {
        didSet { self.updateActivityIndicatorState() }
    }
    
    var text = "" {
        didSet {
            self.setTitle(text, for: .normal)
            self.setTitle(text, for: .highlighted)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + 20.0,
                      height: super.intrinsicContentSize.height + 10.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isActivityIndicatorVisible else { return }
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Private
    
    private func setup() {
        backgroundColor = .clear
        setTitleColor(self.buttonColor, for: .normal)
        setTitleColor(UIColor.lightText, for: .highlighted)
        setBackgroundImage(UIImage.from(color: UIColor.clear), for: .normal)
        setBackgroundImage(UIImage.from(color: self.buttonColor), for: .highlighted)
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = self.buttonColor.cgColor
        clipsToBounds = true
        
        let size = titleLabel!.font.pointSize
        titleLabel?.font = Theme.mainFont(size, bold: true)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.color = tintColor
        activityIndicator.stopAnimating()
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func updateActivityIndicatorState() {
        self.isActivityIndicatorVisible ?
            activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        self.titleLabel?.alpha = self.isActivityIndicatorVisible ? 0.25 : 1.0
    }

}
