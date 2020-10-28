// The MIT License (MIT)
// Copyright © 2020 Ivan Varabei (varabeis@icloud.com)
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
// SOFTWARE. IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

public extension UIView {
    
    /**
     Apply perspective by config.
     
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
     Apply static perspective config.
     
     - parameter config: Static config of perspective.
     */
    fileprivate func applyStaticPerspective(with config: SPPerspectiveStaticConfig) {
        
        // Process 3D Animation
        
        let transform = makeTransform(corner: config.corner, distortion: config.distortionPerspective, angle: config.angle, step: config.vectorStep)
        layer.transform = transform
        
        // Process shadow
        
        guard let shadowConfig = config.shadowConfig else { return }
        let shadowOffset = makeShadowOffset(for: config.corner, config: shadowConfig)
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowConfig.blurRadius
        layer.shadowOpacity = Float(shadowConfig.opacity)
        layer.shadowColor = shadowConfig.color.cgColor
    }
    
    /**
     Apply animatable perspective config.
     
     - parameter config: Animation config of perspective.
     */
    fileprivate func applyAnimationPerspective(with config: SPPerspectiveAnimationConfig) {
        
        // Process 3D Animation
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.duration = config.animationDuration
        transformAnimation.repeatCount = .infinity
        transformAnimation.fillMode = .forwards
        transformAnimation.isRemovedOnCompletion = false
        
        let distortion = config.distortionPerspective
        let angle = config.angle
        let step = config.vectorStep
        
        var cornersOrder = SPPerspectiveHighlightCorner.clockwise(from: config.fromCorner)
        cornersOrder = cornersOrder + [cornersOrder.first!]
        
        let transformValues = cornersOrder.map { makeTransform(corner: $0, distortion: distortion, angle: angle, step: step) }
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
        
        layer.add(transformAnimation, forKey: "SPPerspective - Transform")
        
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
        
        let shadowOffsetValues = cornersOrder.map { makeShadowOffset(for: $0, config: shadowConfig) }
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
        
        layer.add(shadowAnimation, forKey: "SPPerspective - Shadow")
    }
    
    // MARK: - Makers
    
    /**
     Create tranform by `corner`, distortion
     angle in degres and vector values.
     
     - parameter corner: Highlight corner.
     - parameter distortion: Distortion of perspective.
     - parameter angle: Rotation in degress by vector.
     - parameter step: Value of range between steps.
     */
    fileprivate func makeTransform(corner: SPPerspectiveHighlightCorner, distortion: CGFloat, angle: CGFloat, step: CGFloat) -> CATransform3D {
        let vector = makeVector(for: corner, step: step)
        return makeTransform(distortion: distortion, angle: angle, vector: vector)
    }
    
    /**
     Create tranform by distortion,
     angle in degres and vector values.
     
     - parameter distortion: Distortion of perspective.
     - parameter angle: Rotation in degress by vector.
     - parameter vector: Vector of dicection for transform.
     */
    fileprivate func makeTransform(distortion: CGFloat, angle: CGFloat, vector: SPPerspectiveVector) -> CATransform3D {
        var rotationAndPerspectiveTransform : CATransform3D = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / distortion
        rotationAndPerspectiveTransform = CATransform3DRotate(
            rotationAndPerspectiveTransform,
            CGFloat(angle * .pi / 180), vector.x, vector.y, vector.z
        )
        return rotationAndPerspectiveTransform
    }
    
    /**
     Create vector for trnaform by `corner`.
     Step is value of range between steps.
     
     - parameter corner: Highlight corner.
     - parameter step: Value of range between steps.
     */
    fileprivate func makeVector(for corner: SPPerspectiveHighlightCorner, step: CGFloat) -> SPPerspectiveVector {
        switch corner {
        case .topMedium: return SPPerspectiveVector(x: step * 2, y: 0, z: 0)
        case .topRight: return SPPerspectiveVector(x: step, y: step, z: 0)
        case .mediumRight: return SPPerspectiveVector(x: 0, y: step * 2, z: 0)
        case .bottomRight: return SPPerspectiveVector(x: -step, y: step, z: 0)
        case .bottomMedium: return SPPerspectiveVector(x: -step * 2, y: 0, z: 0)
        case .bottomLeft: return SPPerspectiveVector(x: -step, y: -step, z: 0)
        case .mediumLeft: return SPPerspectiveVector(x: 0, y: -step * 2, z: 0)
        case .topLeft: return SPPerspectiveVector(x: step, y: -step, z: 0)
        }
    }
    
    /**
     Create offset shadow size for specific corner.
     Config need for get trnslation values.
     
     - parameter corner: Highlight corner.
     - parameter config: Shadow configuration.
     */
    fileprivate func makeShadowOffset(for corner: SPPerspectiveHighlightCorner, config: SPPerspectiveShadowConfig) -> CGSize {
        switch corner {
        case .topMedium:
            return CGSize(width: 0, height: config.startVerticalOffset)
        case .topRight:
            return CGSize(width: config.maximumHorizontalOffset / 2, height: config.startCornerVerticalMedian)
        case .mediumRight:
            return CGSize(width: config.maximumHorizontalOffset, height: config.cornerVerticalOffset)
        case .bottomRight:
            return CGSize(width: config.maximumHorizontalOffset / 2, height: config.cornerVerticalOffset)
        case .bottomMedium:
            return CGSize(width: 0, height: config.maximumVerticalOffset)
        case .bottomLeft:
            return CGSize(width: -config.maximumHorizontalOffset / 2, height: config.cornerVerticalOffset)
        case .mediumLeft:
            return CGSize(width: -config.maximumHorizontalOffset, height: config.cornerVerticalOffset)
        case .topLeft:
            return CGSize(width: -config.maximumHorizontalOffset / 2, height: config.startCornerVerticalMedian)
        }
    }
}
