//
//  ReportManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//

import UIKit
import Supabase

protocol ReportManagerDelegate {
    func didSubmitReport()
    func failToSubmitReport(_ error: String)
}

struct ReportManager {
    let supabase = SupabaseManager.shared.client
    var delegate: ReportManagerDelegate?
    
    func submitReport(parkingSpot: ParkingSpotModel, issueType: String, description: String, images: [UIImage]) {
        Task {
            do {
                // 1. Get current user
                guard let user = await SupabaseManager.shared.getUser() else {
                    delegate?.failToSubmitReport("User not found")
                    return
                }
                
                // 2. Create report record
                let reportData = ReportData(id: nil, userID: user.id, parkingSpotID: parkingSpot.parkingSpotID, issueType: issueType, description: description, status: "Pending", date: nil)
            

                let response: PostgrestResponse<[ReportData]> = try await supabase
                    .from("reports")
                    .insert(reportData)
                    .select()
                    .execute()

                guard let reportId = response.value.first?.id else {
                    delegate?.failToSubmitReport("Failed to get report ID")
                    return
                }
                
                print("Response:", response)
                print("Response data:", response.data)
                
                guard let reportId = response.value.first?.id else {
                    delegate?.failToSubmitReport("Failed to get report ID")
                    return
                }
                
                print(reportId)

                // 3. Upload images
                for (index, image) in images.enumerated() {
                    guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
                    let fileName = "\(reportId)_\(index).jpg"
                    
                    // Upload image to storage
                    _ = try await supabase.storage
                        .from("report-images")
                        .upload(
                            fileName,
                            data: imageData,
                            options: FileOptions(
                                cacheControl: "3600",
                                contentType: "image/jpg"
                            )
                        )
                    
                    
                    let imageRecord = ImageRecord(reportID: reportId, imageURL: fileName)
                    
                    _ = try await supabase
                        .from("report_images")
                        .insert(imageRecord)
                        .execute()
                }
                
                delegate?.didSubmitReport()
                
            } catch {
                print(error.localizedDescription)
                delegate?.failToSubmitReport(error.localizedDescription)
            }
        }
    }
}
