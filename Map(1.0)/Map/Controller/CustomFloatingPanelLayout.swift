

import UIKit
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            // Full height state (600 points height)
            .full: FloatingPanelLayoutAnchor(
                absoluteInset: UIScreen.main.bounds.height - 800,
                edge: .top,
                referenceGuide: .superview),
            
            // Half height state (300 points height)
            .half: FloatingPanelLayoutAnchor(
                absoluteInset: 300,
                edge: .bottom,
                referenceGuide: .superview),
            
            // Tip height state (100 points height)
            .tip: FloatingPanelLayoutAnchor(
                absoluteInset: 70,
                edge: .bottom,
                referenceGuide: .superview)
        ]
    }
    
    // Add backdrop opacity for each state
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .full: return 0.3
        case .half: return 0.0
        case .tip: return 0.0
        default: return 0.0
        }
    }
}



