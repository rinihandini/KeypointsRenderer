//
//  KeypointData.swift
//  KeypointsDrawer
//
//  Created by Rini Handini on 31/08/24.
//

import UIKit

// Data structure to represent each keypoint and its ID
struct KeypointData: Decodable {
    let id: Int
    let keypoints: [CGFloat]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        
        let rawKeypoints = try container.decode([Double].self, forKey: .keypoints)
        self.keypoints = rawKeypoints.map { CGFloat($0) }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case keypoints
    }
}
