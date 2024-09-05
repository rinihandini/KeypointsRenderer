//
//  ViewController.swift
//  KeypointsRenderer
//
//  Created by Rini Handini on 03/09/24.
//

import UIKit

class ViewController: UIViewController {

    // IBOutlet for segmented control to select rendering mode (2D or 3D)
    @IBOutlet weak var renderModeSegmentedControl: UISegmentedControl!
    
    // IBOutlet for segmented control to select the source of keypoints (TW_Keypoints or CA_Keypoints)
    @IBOutlet weak var sourceSegmentedControl: UISegmentedControl!
    
    // IBOutlet for label to display the current zoom factor for 2D mode
    @IBOutlet weak var zoomLabel: UILabel!
    
    // IBOutlet for slider to adjust the zoom factor for 2D rendering mode
    // Range is 0-5, where higher values zoom in more
    @IBOutlet weak var zoomSlider: UISlider!
    
    // IBOutlet for label to display the current camera distance for 3D mode
    @IBOutlet weak var distanceLabel: UILabel!
    
    // IBOutlet for slider to adjust the camera distance for 3D rendering mode
    // Range is 0-40, where higher values move the camera further away
    @IBOutlet weak var distanceSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomLabel.text = String(format: "2D Zoom Factor: %.1f", zoomSlider.value)
        distanceLabel.text = String(format: "3D Camera Distance: %.1f", distanceSlider.value)
    }

    @IBAction func zoomValueChanged(_ sender: UISlider) {
        zoomLabel.text = String(format: "2D Zoom Factor: %.1f", sender.value)
    }

    @IBAction func distanceValueChanged(_ sender: UISlider) {
        distanceLabel.text = String(format: "3D Camera Distance: %.1f", sender.value)
    }
    
    @IBAction func viewButtonTapped(_ sender: UIButton) {
        if renderModeSegmentedControl.selectedSegmentIndex == 0 {
            // 2D mode
            let twoDVC = storyboard?.instantiateViewController(withIdentifier: "TwoDViewController") as! TwoDViewController
            twoDVC.selectedSource = sourceSegmentedControl.selectedSegmentIndex == 0 ? "TW_Keypoints" : "CA_Keypoints"
            twoDVC.zoomFactor = CGFloat(zoomSlider.value)
            navigationController?.pushViewController(twoDVC, animated: true)
            
        } else {
            // 2D mode
            let threeDVC = storyboard?.instantiateViewController(withIdentifier: "ThreeDViewController") as! ThreeDViewController
            threeDVC.selectedSource = sourceSegmentedControl.selectedSegmentIndex == 0 ? "TW_Keypoints" : "CA_Keypoints"
            threeDVC.cameraDistance = CGFloat(distanceSlider.value)
            navigationController?.pushViewController(threeDVC, animated: true)
        }
    }
}

