//
//  ThreeDViewController.swift
//  KeypointsRenderer
//
//  Created by Rini Handini on 03/09/24.
//

import SceneKit
import UIKit

class ThreeDViewController: UIViewController {
    // IBOutlet for label to display the current camera distance for 3D mode
    @IBOutlet weak var distanceLabel: UILabel!
    
    // IBOutlet for slider to adjust the camera distance for 3D rendering mode
    // Range is 0-40, where higher values move the camera further away
    @IBOutlet weak var distanceSlider: UISlider!
    
    // Outlet for SceneKit view, where 3D rendering will occur
    @IBOutlet weak var ThreeDSCNView: SCNView!
    
    // Selected JSON file name to load keypoints
    var selectedSource: String = ""
    
    // Distance of the camera from the scene
    var cameraDistance: CGFloat = 30

    // Array to store parsed 3D coordinates from JSON
    var coordinates: [(x: Float, y: Float, z: Float)] = []
    
    // Property to store the camera node
    var cameraNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceLabel.text = String(format: "3D Camera Distance: %.1f", cameraDistance)
        distanceSlider.value = Float(cameraDistance)
        
        coordinates = parseJSON()
        setupScene()
    }
    
    func setupScene() {
        let scene = SCNScene()
        ThreeDSCNView.scene = scene
        ThreeDSCNView.allowsCameraControl = true // Enables user interaction to control the camera
        ThreeDSCNView.autoenablesDefaultLighting = true // Automatically adds lighting to the scene

        // Draws the 3D path based on keypoints
        drawPath()
        
        // Configures the camera and adds lighting to the scene
        setupCameraAndLighting()
    }

    // Parses the JSON file to extract keypoints for 3D rendering
    func parseJSON() -> [(x: Float, y: Float, z: Float)] {
        guard let path = Bundle.main.path(forResource: selectedSource, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Failed to load JSON file.")
            return []
        }

        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            
            let sortedJsonArray = jsonArray?.sorted { dict1, dict2 in
                let id1 = dict1["id"] as? Int ?? 0
                let id2 = dict2["id"] as? Int ?? 0
                return id1 < id2
            }
            
            let coordinates: [(x: Float, y: Float, z: Float)] = sortedJsonArray?.compactMap { dict in
                if let keypoints = dict["keypoints"] as? [NSNumber], keypoints.count == 3 {
                    return (keypoints[0].floatValue, keypoints[1].floatValue, keypoints[2].floatValue)
                }
                return nil
            } ?? []
            
            print("Parsed coordinates: \(coordinates)")
            return coordinates
        } catch {
            print("Error parsing JSON: \(error)")
            return []
        }
    }
    
    // Draws a 3D path connecting keypoints using cylinders (tubes)
    func drawPath() {
        guard !coordinates.isEmpty else { return }

        // Calculate the range of x, y, z coordinates to determine scene boundaries
        let range = calculateRange(coordinates: coordinates)

        // Calculate the visible range in SceneKit
        let xRange = range.xMax - range.xMin
        let yRange = range.yMax - range.yMin
        let zRange = range.zMax - range.zMin

        // Calculate the center of the coordinates to adjust positions to be centered in the scene
        let centerX = (range.xMax + range.xMin) / 2
        let centerY = (range.yMax + range.yMin) / 2
        let centerZ = (range.zMax + range.zMin) / 2

        var previousNode: SCNNode?

        // Iterate through coordinates to create nodes and draw paths
        for (_, coordinate) in coordinates.enumerated() {
            // Normalize the coordinates and adjust positions based on center
            // Formula: normalized = ((original_value - min_value) / range * scale) - (center_value / range * scale)
            // Negating Y to flip Y axis
            // The scale 5 is chosen to scale the normalized values into a range that fits well within the SceneKit view.
            let normalizedX = ((coordinate.x - range.xMin) / xRange * 5) - (centerX / xRange * 5)
            let normalizedY = -(((coordinate.y - range.yMin) / yRange * 5) - (centerY / yRange * 5))
            let normalizedZ = ((coordinate.z - range.zMin) / zRange * 5) - (centerZ / zRange * 5)

            // Create a node at the normalized position
            let currentNode = SCNNode()
            currentNode.position = SCNVector3(normalizedX, normalizedY, normalizedZ)

            if let previousNode = previousNode {
                // Calculate the distance between the current node and the previous node and draw a tube
                let distanceBetweenNodes = distance(from: previousNode.position, to: currentNode.position)
                let tube = SCNCylinder(radius: 0.05, height: CGFloat(distanceBetweenNodes))
                tube.firstMaterial?.diffuse.contents = UIColor.green

                let tubeNode = SCNNode(geometry: tube)
                tubeNode.position = SCNVector3((previousNode.position.x + currentNode.position.x) / 2,
                                               (previousNode.position.y + currentNode.position.y) / 2,
                                               (previousNode.position.z + currentNode.position.z) / 2)
                tubeNode.look(at: currentNode.position)
                ThreeDSCNView.scene?.rootNode.addChildNode(tubeNode)
            }

            previousNode = currentNode
        }
    }

    // Calculates the distance between two SCNVector3 points using Euclidean distance formula
    func distance(from: SCNVector3, to: SCNVector3) -> Float {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let dz = to.z - from.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    // Configures the camera position and lighting in the SceneKit scene
    func setupCameraAndLighting() {
        // Set up the camera only once and update its position later
        if cameraNode == nil {
            cameraNode = SCNNode()
            cameraNode?.camera = SCNCamera()
            ThreeDSCNView.scene?.rootNode.addChildNode(cameraNode!)
        }

        // Set up the camera
        // let cameraNode = SCNNode()
        // cameraNode.camera = SCNCamera()
        cameraNode?.position = SCNVector3(x: 0, y: 0, z: Float(cameraDistance))
        // ThreeDSCNView.scene?.rootNode.addChildNode(cameraNode)

        // Set up the lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        ThreeDSCNView.scene?.rootNode.addChildNode(lightNode)
        
        // Add ambient light to reduce shadows
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
        ThreeDSCNView.scene?.rootNode.addChildNode(ambientLightNode)
    }

    // Calculates the min and max range for x, y, and z coordinates from the parsed data
    func calculateRange(coordinates: [(x: Float, y: Float, z: Float)]) -> (xMin: Float, xMax: Float, yMin: Float, yMax: Float, zMin: Float, zMax: Float) {
        var xMin = Float.greatestFiniteMagnitude
        var xMax = -Float.greatestFiniteMagnitude
        var yMin = Float.greatestFiniteMagnitude
        var yMax = -Float.greatestFiniteMagnitude
        var zMin = Float.greatestFiniteMagnitude
        var zMax = -Float.greatestFiniteMagnitude
        
        for coordinate in coordinates {
            xMin = min(xMin, coordinate.x)
            xMax = max(xMax, coordinate.x)
            yMin = min(yMin, coordinate.y)
            yMax = max(yMax, coordinate.y)
            zMin = min(zMin, coordinate.z)
            zMax = max(zMax, coordinate.z)
        }
        
        return (xMin, xMax, yMin, yMax, zMin, zMax)
    }
    
    @IBAction func distanceValueChanged(_ sender: UISlider) {
        distanceLabel.text = String(format: "3D Camera Distance: %.1f", sender.value)
        cameraNode?.position = SCNVector3(x: 0, y: 0, z: Float(sender.value))
    }
}
