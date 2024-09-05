//
//  KeypointsView.swift
//  KeypointsDrawer
//
//  Created by Rini Handini on 31/08/24.
//

import UIKit

class KeypointsView: UIView {
    // Array for 2D keypoints to be drawn
    var keypoints: [[CGFloat]] = []
    
    // Zoom factor to scale the 2D keypoints rendering
    var zoomFactor: CGFloat = 3.0
    
    // Custom draw function to render the 2D keypoints on the view
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !keypoints.isEmpty else { return }

        context.setLineWidth(2.0)
        context.setShouldAntialias(true)  // Enable antialiasing for smoother lines
        
        guard keypoints.count > 1 else { return }
        
        // Calculate the center of the view and the scaling factors
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        let scaleX = (rect.width / 2) * zoomFactor
        let scaleY = (rect.height / 2) * zoomFactor
        
        // Iterate through coordinates to create a line path
        for i in 0..<keypoints.count - 1 {
            let path = UIBezierPath()

            // Calculate startPoint and endPoint by scaling and centering the keypoints
            // The formula scales the normalized keypoints (assuming they are in a normalized range, e.g., [0, 1]) to fit within the view's dimensions:
            // scaled_point = center + (normalized_value * scale_factor)
            let startPoint = CGPoint(x: centerX + keypoints[i][0] * scaleX, y: centerY + keypoints[i][1] * scaleY)
            let endPoint = CGPoint(x: centerX + keypoints[i + 1][0] * scaleX, y: centerY + keypoints[i + 1][1] * scaleY)
            path.move(to: startPoint)
            path.addLine(to: endPoint)

            // Create a gradient color based on the position of the keypoint
            let red = CGFloat(i) / CGFloat(keypoints.count)
            let green = 1.0 - CGFloat(i) / CGFloat(keypoints.count)
            let blue: CGFloat = 0.0
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
           
            color.setStroke()
            path.lineWidth = 2.0
            path.stroke()
        }
    }
    
    func updateKeypoints(_ newKeypoints: [[CGFloat]], newZoomFactor: CGFloat) {
        keypoints = newKeypoints // Update keypoints data
        zoomFactor = newZoomFactor // Update zoom factor
        setNeedsDisplay() // Mark the view to be redrawn
    }
}

