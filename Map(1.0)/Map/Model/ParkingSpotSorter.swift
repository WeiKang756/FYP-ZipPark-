import Foundation
import CoreLocation

class ParkingSpotSorter {
    // Scoring weights
    private struct Weights {
        static let distance: Double = 0.4        // 40% weight for distance
        static let availability: Double = 0.4    // 40% weight for street availability
        static let parkingType: Double = 0.2     // 20% weight for parking type
    }
    
    // Type preference scores
    private struct TypePreference {
        static func score(for type: String) -> Double {
            switch type.lowercased() {
            case "green": return 1.0   // Most preferred
            case "yellow": return 0.8   // Medium preference
            case "red": return 0.6      // Least preferred
            default: return 0.0
            }
        }
    }
    
    static func sortParkingSpots(
        spots: [ParkingSpotModel],
        streetInfo: [String: StreetInfoData]
    ) -> [ParkingSpotModel] {
        // Create array to store spots with their scores
        var spotsWithScores: [(spot: ParkingSpotModel, score: Double)] = []
        
        for spot in spots {
            let score = calculateSpotScore(spot: spot, streetInfo: streetInfo[spot.streetName])
            spotsWithScores.append((spot, score))
            
            // Print detailed scoring information
            printSpotScoring(spot: spot, streetInfo: streetInfo[spot.streetName], finalScore: score)
        }
        
        // Sort by score
        spotsWithScores.sort { $0.score > $1.score }
        
        // Print final sorted order
        print("\n=== Final Sorting Order ===")
        for (index, spotWithScore) in spotsWithScores.enumerated() {
            print("[\(index + 1)] Parking \(spotWithScore.spot.parkingSpotID) - Score: \(String(format: "%.3f", spotWithScore.score))")
        }
        
        return spotsWithScores.map { $0.spot }
    }
    
    private static func calculateSpotScore(
        spot: ParkingSpotModel,
        streetInfo: StreetInfoData?
    ) -> Double {
        let distanceScore = calculateDistanceScore(distance: spot.distance ?? 5000)
        let availabilityScore = calculateAvailabilityScore(streetInfo: streetInfo, spotType: spot.type)
        let typeScore = TypePreference.score(for: spot.type)
        
        return (distanceScore * Weights.distance) +
               (availabilityScore * Weights.availability) +
               (typeScore * Weights.parkingType)
    }
    
    private static func calculateDistanceScore(distance: Double) -> Double {
        let maxDistance = 5000.0 // 5km as maximum reasonable distance
        let normalizedDistance = min(distance, maxDistance) / maxDistance
        return 1.0 - normalizedDistance
    }
    
    private static func calculateAvailabilityScore(
        streetInfo: StreetInfoData?,
        spotType: String
    ) -> Double {
        guard let info = streetInfo else { return 0.0 }
        
        let typeAvailability: Double = {
            switch spotType.lowercased() {
            case "green":
                return Double(info.numGreen) / Double(info.totalSpots)
            case "red":
                return Double(info.numRed) / Double(info.totalSpots)
            case "yellow":
                return Double(info.numYellow) / Double(info.totalSpots)
            default:
                return 0.0
            }
        }()
        
        let overallAvailability = Double(info.numAvailable) / Double(info.totalSpots)
        return (typeAvailability * 0.6) + (overallAvailability * 0.4)
    }
    
    private static func printSpotScoring(
        spot: ParkingSpotModel,
        streetInfo: StreetInfoData?,
        finalScore: Double
    ) {
        print("\n=== Scoring Details for Parking Spot \(spot.parkingSpotID) ===")
        print("Location: \(spot.streetName), \(spot.areaName)")
        print("Type: \(spot.type)")
        print("Distance: \(String(format: "%.1f", spot.distance ?? 0))m")
        
        // Distance Score
        let distanceScore = calculateDistanceScore(distance: spot.distance ?? 5000)
        print("Distance Score: \(String(format: "%.3f", distanceScore)) (weighted: \(String(format: "%.3f", distanceScore * Weights.distance)))")
        
        // Availability Score
        let availabilityScore = calculateAvailabilityScore(streetInfo: streetInfo, spotType: spot.type)
        print("Availability Score: \(String(format: "%.3f", availabilityScore)) (weighted: \(String(format: "%.3f", availabilityScore * Weights.availability)))")
        
        if let info = streetInfo {
            print("  - Street Total Spots: \(info.totalSpots)")
            print("  - Street Available Spots: \(info.numAvailable)")
            print("  - Type-specific availability: \(getTypeSpecificCount(info: info, type: spot.type))")
        } else {
            print("  - No street info available")
        }
        
        // Type Score
        let typeScore = TypePreference.score(for: spot.type)
        print("Type Score: \(String(format: "%.3f", typeScore)) (weighted: \(String(format: "%.3f", typeScore * Weights.parkingType)))")
        
        // Final Score
        print("Final Score: \(String(format: "%.3f", finalScore))")
        print("----------------------------------------")
    }
    
    private static func getTypeSpecificCount(info: StreetInfoData, type: String) -> Int {
        switch type.lowercased() {
        case "green": return info.numGreen
        case "red": return info.numRed
        case "yellow": return info.numYellow
        default: return 0
        }
    }
}
