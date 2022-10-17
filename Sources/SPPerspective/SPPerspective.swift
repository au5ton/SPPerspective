//
//  File.swift
//  
//
//  Created by Austin Jackson on 10/17/22.
//

import Foundation
import UIKit

final class SPPerspective {
  public static func makeTransForm(with config: SPPerspectiveStaticConfig) -> CATransform3D {
    let transform = makeTransform(corner: config.corner, distortion: config.distortionPerspective, angle: config.angle, step: config.vectorStep)
    
    return transform
  }
  
    /**
     SPPerspective: Create tranform by `corner`, distortion
     angle in degres and vector values.
     
     - parameter corner: Highlight corner.
     - parameter distortion: Distortion of perspective.
     - parameter angle: Rotation in degress by vector.
     - parameter step: Value of range between steps.
     */
    public static func makeTransform(corner: SPPerspectiveHighlightCorner, distortion: CGFloat, angle: CGFloat, step: CGFloat) -> CATransform3D {
        let vector = makeVector(for: corner, step: step)
        return makeTransform(distortion: distortion, angle: angle, vector: vector)
    }
    
    /**
     SPPerspective: Create tranform by distortion,
     angle in degres and vector values.
     
     - parameter distortion: Distortion of perspective.
     - parameter angle: Rotation in degress by vector.
     - parameter vector: Vector of dicection for transform.
     */
    public static func makeTransform(distortion: CGFloat, angle: CGFloat, vector: SPPerspectiveVector) -> CATransform3D {
        var rotationAndPerspectiveTransform : CATransform3D = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / distortion
        rotationAndPerspectiveTransform = CATransform3DRotate(
            rotationAndPerspectiveTransform,
            CGFloat(angle * .pi / 180), vector.x, vector.y, vector.z
        )
        return rotationAndPerspectiveTransform
    }
  
  /**
   SPPerspective: Create vector for transform by `corner`.
   Step is value of range between steps.
   
   - parameter corner: Highlight corner.
   - parameter step: Value of range between steps.
   */
  public static func makeVector(for corner: SPPerspectiveHighlightCorner, step: CGFloat) -> SPPerspectiveVector {
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
   SPPerspective: Create offset shadow size for specific corner.
   Config need for get translation values.
   
   - parameter corner: Highlight corner.
   - parameter config: Shadow configuration.
   */
  public static func makeShadowOffset(for corner: SPPerspectiveHighlightCorner, config: SPPerspectiveShadowConfig) -> CGSize {
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
