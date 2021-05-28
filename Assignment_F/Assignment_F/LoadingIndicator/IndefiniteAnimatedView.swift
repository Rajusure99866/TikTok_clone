//
//  IndefiniteAnimatedView.swift
//  Assignment_F
//
//  Created by Raju on 25/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit

open class CustomProgressIndicator: UIView {

    public static let name = "CustomProgressIndicator"

    private let pi = 3.14159265359

    public enum SpinnerSize: Int {
        case SpinnerSizeMini
        case SpinnerSizeSmall
        case SpinnerSizeMedium
        case SpinnerSizeLarge
        case SpinnerSizeVeryLarge
    }

    open var spinnerSize: SpinnerSize?

    open var spinnerColor: UIColor? = .gray
 
    open var spinnerImage: UIImage?

    open var spinnerGradientColors: [CGColor]?

    open var angleSpinner: Double = 360

    var stopShowingAndDismissingAnimation: Bool?

    private var disableEntireUserInteraction: Bool? {
        didSet {
            if disableEntireUserInteraction == true {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
    }
    
    private var viewActivitySquare: UIView?
    
    var isAnimating: Bool?
    
    private var lineWidth: CGFloat = 4.0

    private var defaultFrame: CGRect = .zero

    private var imageView: UIImageView?

    private func DEGREES_TO_RADIANS(degrees: Double) -> CGFloat {
        return CGFloat(((pi * degrees) / 180))
    }

    private func configure() {
        if let spinnerSize = spinnerSize {
            guard let spinnerSizeType = SpinnerSize.init(rawValue: spinnerSize.rawValue) else { return }
            switch spinnerSizeType {
            case .SpinnerSizeMini:
                frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                defaultFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
                lineWidth = 2.0
            case .SpinnerSizeSmall:
                frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                defaultFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                lineWidth = 4.0
            case .SpinnerSizeMedium:
                frame = CGRect(x: 0, y: 0, width: 150, height: 150)
                defaultFrame = CGRect(x: 0, y: 0, width: 82, height: 82)
                lineWidth = 8.0
            case .SpinnerSizeLarge:
                frame = CGRect(x: 0, y: 0, width: 185, height: 185)
                defaultFrame = CGRect(x: 0, y: 0, width: 120, height: 120)
                lineWidth = 10.0
            case .SpinnerSizeVeryLarge:
                frame = CGRect(x: 0, y: 0, width: 220, height: 220)
                defaultFrame = CGRect(x: 0, y: 0, width: 150, height: 150)
                lineWidth = 12.0
            }
            heightAnchor.constraint(equalToConstant: frame.height).isActive = true
            widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        }
        if spinnerGradientColors == nil {
            spinnerGradientColors = [(spinnerColor?.cgColor)!,
                                     (spinnerColor)!.withAlphaComponent(0.5).cgColor,
                                     (spinnerColor)!.withAlphaComponent(0.25).cgColor,
                                     (spinnerColor)!.withAlphaComponent(0.0).cgColor]
        }
    }

    @objc private func rotationAnimation() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = NSNumber(value: 0.0)
        rotate.toValue = NSNumber(value: 6.2)
        rotate.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        rotate.duration = 1.5
        viewActivitySquare?.layer .add(rotate, forKey: "rotateRepeatedly")
    }

    private func createGradientLayer(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = spinnerGradientColors!
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }

    private func createShapeLayer(path: UIBezierPath) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineCap = CAShapeLayerLineCap.round
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = lineWidth
        return shape
    }

    open func startAnimating() {
        configure()
        viewActivitySquare = UIView(frame: defaultFrame)
        let lowerPath = UIBezierPath(arcCenter: (viewActivitySquare?.center)!,
                                     radius: (viewActivitySquare?.frame.size.width)! / 2.2,
                                     startAngle: DEGREES_TO_RADIANS(degrees: -5),
                                     endAngle: DEGREES_TO_RADIANS(degrees: angleSpinner),
                                     clockwise: true)
        
        let lowerShape = self.createShapeLayer(path: lowerPath)
        let gradientLayer = createGradientLayer(frame: defaultFrame)
        gradientLayer.mask = lowerShape
        viewActivitySquare?.layer.addSublayer(gradientLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(rotationAnimation),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
        viewActivitySquare?.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        if let spinnerImage = spinnerImage {
            createSpinnerWith(spinnerImage: spinnerImage)
        }
        self.addSubview(viewActivitySquare!)
        self.rotationAnimation()
        self.isAnimating = true
        UIView.animate(withDuration: (stopShowingAndDismissingAnimation == true) ? 0.0 : 0.5) { () -> Void in
            self.alpha = 1.0
        }
    }

    private func createSpinnerWith(spinnerImage: UIImage) {
        guard let viewActivity = viewActivitySquare else { return }
        imageView = UIImageView(image: spinnerImage)
        imageView?.frame = defaultFrame
        viewActivity.addSubview(imageView!)
        imageView?.center = CGPoint(x: viewActivity.frame.size.width / 2,
                                    y: viewActivity.frame.size.height / 2)
    }

    open func stopAnimating() {
        UIView.animate(withDuration: (stopShowingAndDismissingAnimation == true) ? 0.0 : 0.5, animations: { () -> Void in
            self.alpha = 0.0
        }) { (finished) -> Void in
            if (finished == true) {
                self.isAnimating = false
                for view: UIView in self.subviews {
                    view.removeFromSuperview()
                }
                if (self.disableEntireUserInteraction == true) {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
            }
        }
    }
}
