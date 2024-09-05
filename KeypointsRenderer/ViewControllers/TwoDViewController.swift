//
//  TwoDViewController.swift
//  KeypointsRenderer
//
//  Created by Rini Handini on 03/09/24.
//

import UIKit

class TwoDViewController: UIViewController {

    // IBOutlet for label to display the current zoom factor
    @IBOutlet weak var zoomLabel: UILabel!
    
    // IBOutlet for slider to adjust the zoom factor for 2D rendering mode
    // Range is 0-5, where higher values zoom in more
    @IBOutlet weak var zoomSlider: UISlider!
    
    // Outlet for the custom UIView (KeypointsView), where 2D rendering will occur
    @IBOutlet weak var twoDView: KeypointsView!
    
    // Array for parsed keypoints data
    var keypointsArray: [KeypointData] = []
    
    // Array for sorted 2D keypoints data
    var sortedKeypoints2D: [[CGFloat]] = []
    
    // Selected JSON file name to load keypoints
    var selectedSource: String = ""
    
    // Zoom factor to scale the 2D keypoints rendering
    var zoomFactor: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        zoomLabel.text = String(format: "2D Zoom Factor: %.1f", zoomFactor)
        zoomSlider.value = Float(zoomFactor)

        // Parses the JSON file to extract keypoints for 2D rendering
        if let path = Bundle.main.path(forResource: selectedSource, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonDecoder = JSONDecoder()
                keypointsArray = try jsonDecoder.decode([KeypointData].self, from: data)
                
                keypointsArray.sort { $0.id < $1.id }
                
                sortedKeypoints2D = keypointsArray.map { Array($0.keypoints.prefix(2)) }
                twoDView.updateKeypoints(sortedKeypoints2D, newZoomFactor: zoomFactor)
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    
    @IBAction func zoomValueChanged(_ sender: UISlider) {
        zoomLabel.text = String(format: "2D Zoom Factor: %.1f", sender.value)
        twoDView.updateKeypoints(sortedKeypoints2D, newZoomFactor: CGFloat(sender.value))
    }
}
