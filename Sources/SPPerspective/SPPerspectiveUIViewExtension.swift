// The MIT License (MIT)
// Copyright © 2020 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit) && (os(iOS))
import UIKit

public extension UIView {
    
    /**
     SPPerspective: Apply perspective by config.
     
     - parameter config: Static or animatable config of perspective.
     */
    func applyPerspective(_ config: SPPerspectiveConfig) {
        switch config {
        case let animationConfig as SPPerspectiveAnimationConfig:
            applyAnimationPerspective(with: animationConfig)
        case let staticConfig as SPPerspectiveStaticConfig:
            applyStaticPerspective(with: staticConfig)
        default:
            break
        }
    }
    
    /**
     SPPerspective: Reset perspective configuration like transofrm and shadow.
     
     Always calling before apply new configuration - static or animatable.
     */
    func resetPerspective() {
        layer.transform = CATransform3DIdentity
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowColor = nil
        layer.removeAnimation(forKey: animationTransformKey)
        layer.removeAnimation(forKey: animationShadowKey)
    }
    
    /**
     SPPerspective: Apply static perspective config.
     
     - parameter config: Static config of perspective.
     */
    fileprivate func applyStaticPerspective(with config: SPPerspectiveStaticConfig) {
        
        resetPerspective()
        
        // Process 3D Animation
        
      let transform = SPPerspective.makeTransform(corner: config.corner, distortion: config.distortionPerspective, angle: config.angle, step: config.vectorStep)
        layer.transform = transform
        
        // Requesrid for remove cut bug.
        // Shoud be maximum.
        layer.zPosition = 999
        
        // Process shadow
        
        guard let shadowConfig = config.shadowConfig else { return }
      let shadowOffset = SPPerspective.makeShadowOffset(for: config.corner, config: shadowConfig)
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowConfig.blurRadius
        layer.shadowOpacity = Float(shadowConfig.opacity)
        layer.shadowColor = shadowConfig.color.cgColor
    }
    
    fileprivate var animationTransformKey: String { return "SPPerspective - Transform" }
    fileprivate var animationShadowKey : String { return "SPPerspective - Shadow" }
    
    /**
     SPPerspective: Apply animatable perspective config.
     
     - parameter config: Animation config of perspective.
     */
    fileprivate func applyAnimationPerspective(with config: SPPerspectiveAnimationConfig) {
        
        resetPerspective()
        
        // Process 3D Animation
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.duration = config.animationDuration
        transformAnimation.repeatCount = .infinity
        transformAnimation.fillMode = .forwards
        transformAnimation.isRemovedOnCompletion = false
        
        let distortion = config.distortionPerspective
        let angle = config.angle
        let step = config.vectorStep
        
        var cornersOrder = SPPerspectiveHighlightCorner.order(from: config.fromCorner, direction: config.direction)
        cornersOrder = cornersOrder + [cornersOrder.first!]
        
      let transformValues = cornersOrder.map { SPPerspective.makeTransform(corner: $0, distortion: distortion, angle: angle, step: step) }
        transformAnimation.values = transformValues
        
        let transformTimingStep = 1 / Double(transformValues.count - 1)
        var transformTimings: [NSNumber] = []
        for (index, _) in transformValues.enumerated() {
            transformTimings.append(NSNumber(value: transformTimingStep * Double(index)))
        }
        transformAnimation.keyTimes = transformTimings
        
        var transformTimingFunctions: [CAMediaTimingFunction] = []
        for _ in transformValues {
            let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            transformTimingFunctions.append(timingFunction)
        }
        transformAnimation.timingFunctions = transformTimingFunctions
        
        layer.add(transformAnimation, forKey: animationTransformKey)
        
        // Requesrid for remove cut bug.
        // Shoud be maximum.
        layer.zPosition = 999
        
        // Process shadow
        
        guard let shadowConfig = config.shadowConfig else { return }
        layer.shadowRadius = shadowConfig.blurRadius
        layer.shadowOpacity = Float(shadowConfig.opacity)
        layer.shadowColor = shadowConfig.color.cgColor
        
        let shadowAnimation = CAKeyframeAnimation(keyPath: "shadowOffset")
        shadowAnimation.duration = config.animationDuration
        shadowAnimation.repeatCount = .infinity
        shadowAnimation.fillMode = .forwards
        shadowAnimation.isRemovedOnCompletion = false
        
      let shadowOffsetValues = cornersOrder.map { SPPerspective.makeShadowOffset(for: $0, config: shadowConfig) }
        shadowAnimation.values = shadowOffsetValues
        
        let shadowTimingStep = 1 / Double(shadowOffsetValues.count - 1)
        var shadowTimings: [NSNumber] = []
        for (index, _) in shadowOffsetValues.enumerated() {
            shadowTimings.append(NSNumber(value: shadowTimingStep * Double(index)))
        }
        shadowAnimation.keyTimes = shadowTimings
        
        var shadowTimingFunctions: [CAMediaTimingFunction] = []
        for _ in transformValues {
            let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            shadowTimingFunctions.append(timingFunction)
        }
        shadowAnimation.timingFunctions = shadowTimingFunctions
        
        layer.add(shadowAnimation, forKey: animationShadowKey)
    }
    
    // MARK: - Makers
    
  
    
    
}
#endif
