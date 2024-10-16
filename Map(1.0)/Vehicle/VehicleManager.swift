//
//  VehicleManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 14/11/2024.
//

protocol VehicleManagerDelegate {
    func didAddVehicle()
    func failToAddVehicle(_ error: String)
    func didFetchVehicle(_ vehiclesModel: [VehicleModel])
    func failToFetchVehicle()
    func didDeleteVehicle()
    func didUpdateVehicle()
    func failToUpdateVehicle()
}

extension VehicleManagerDelegate {
    
    func didAddVehicle() {
        print("did add vehicle (default delegate)")
    }
    
    func failToAddVehicle(_ error: String) {
        print("fail to add vehicle (default delegate)")
    }
    
    func didFetchVehicle(_ vehiclesModel: [VehicleModel]) {
        print("did fetch vehicle (default delegate)")
    }
    
    func failToFetchVehicle() {
        print("fail to fetch vehicle (default delegate)")
    }
    
    func didDeleteVehicle() {
        print("did delete vehicle (default delegate)")
    }
    
    func didUpdateVehicle() {
        print("did update vehicle (default delegate)")
    }
    
    func failToUpdateVehicle(){
        print("fail to update vehicle (default delegate)")
    }
}

class VehicleManager {
    
    static let shared = VehicleManager()
    private let supabase = SupabaseManager.shared.client
    var delegate: VehicleManagerDelegate?
    
    func addVehicle(plateNumber: String, color: String, description: String) {
        Task {
            do {
                let user = await SupabaseManager.shared.getUser()
                guard let user = user else {
                    print("Failed to get user.")
                    return
                }
                
                let existingVehicle: [VehicleModel] = try await supabase
                    .from("vehicles")
                    .select()
                    .eq("user_id", value: user.id)
                    .eq("plate_number", value: plateNumber)
                    .execute()
                    .value
                
                if !existingVehicle.isEmpty {
                    let error = "Plate Number have been added."
                    print("Duplicate Plate Numbner")
                    delegate?.failToAddVehicle(error)
                }
                
                let vehicleModel = VehicleModel(user: user.id, plateNumber: plateNumber, description: description, color: color)
                print("Attempting to add vehicle:", vehicleModel)
                
                try await supabase
                    .from("vehicles")
                    .insert(vehicleModel)
                    .execute()
                
                delegate?.didAddVehicle()
            } catch {
                let error = "\(error.localizedDescription)"
                delegate?.failToAddVehicle(error)
            }
        }
    }
    
    func fetchVehicle() {
        Task{
            do{
                let user = await SupabaseManager.shared.getUser()
                
                guard let user = user else {
                    print("fail to get user data")
                    return
                }
                
                let vehiclesModel: [VehicleModel] = try await supabase
                    .from("vehicles")
                    .select()
                    .eq("user_id", value: user.id)
                    .execute()
                    .value
                
                delegate?.didFetchVehicle(vehiclesModel)
                print(vehiclesModel)
            }catch{
                let error = "\(error.localizedDescription)"
                delegate?.failToAddVehicle(error)
            }
        }
    }
    
    func deleteVehicle(_ vehicleModel: VehicleModel) {
        Task{
            do{
                guard let user = await SupabaseManager.shared.getUser() else {
                    print("Fail to get user data")
                    return
                }
                
                let plateNumber = vehicleModel.plateNumber
                try await supabase
                  .from("vehicles")
                  .delete()
                  .eq("user_id", value: user.id)
                  .eq("plate_number", value: plateNumber)
                  .execute()
                
                delegate?.didDeleteVehicle()
                print("did delete vehicle")
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateVehicle(oldVehicleModel: VehicleModel, plateNumber: String, color: String, description: String) {
        Task {
            do {
                guard let user = await SupabaseManager.shared.getUser() else {
                    print("Fail to get user data")
                    return
                }
                
                // Step 1: Check for an existing vehicle with the new plate number, excluding the current vehicle
                let existingVehicle: [VehicleModel] = try await supabase
                    .from("vehicles")
                    .select()
                    .eq("user_id", value: user.id)
                    .eq("plate_number", value: plateNumber)
                    .not("plate_number", operator: .eq, value: oldVehicleModel.plateNumber)
                    .execute()
                    .value
                
                // Step 2: If a duplicate is found, exit early and notify the delegate
                guard existingVehicle.isEmpty else {
                    let error = "Plate number has already been added by another vehicle."
                    print("Duplicate plate number detected.")
                    delegate?.failToUpdateVehicle()
                    return
                }
                
                // Step 3: Proceed to update by deleting the old vehicle and inserting the new data
                try await supabase
                    .from("vehicles")
                    .delete()
                    .eq("user_id", value: user.id)
                    .eq("plate_number", value: oldVehicleModel.plateNumber)
                    .execute()
                
                let vehicleModel = VehicleModel(user: user.id, plateNumber: plateNumber, description: description, color: color)
                print("Attempting to add updated vehicle:", vehicleModel)
                
                try await supabase
                    .from("vehicles")
                    .insert(vehicleModel)
                    .execute()
                
                delegate?.didUpdateVehicle()
            } catch {
                let errorMessage = "\(error.localizedDescription)"
                delegate?.failToUpdateVehicle()
            }
        }
    }

}
