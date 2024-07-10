//
//  StationLocalRepository.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import UIKit
import CoreData
import OSLog

class StationLocalRepository {
    
    // Here we should use DI
    private var managedContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        return appDelegate.persistentContainer.viewContext
    }
    
    // Load cached stations
    @MainActor
    func stations() -> [Station] {
        let fetchRequest = NSFetchRequest<Station>(entityName: "Station")
        fetchRequest.relationshipKeyPathsForPrefetching = ["power"]

        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            OSLog.general.error("Could not load cached stations \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    // Load cached availabilities
    @MainActor
    func evseStates() -> [EvseState] {
        let fetchRequest = NSFetchRequest<State>(entityName: "State")
        
        do {
            let states = try managedContext.fetch(fetchRequest)
            return states.compactMap { state in
                guard let evseId = state.evseId,
                      let availability = state.availability else { return nil }
                return EvseState(evseId: evseId,
                                 availability: EvseAvailability(rawValue: availability) ?? .unknown)
            }

        } catch let error as NSError {
            OSLog.general.error("Could not load cached states \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    @MainActor
    func storeStaticStationData(_ evseRootData: EVSERoot) -> [Station] {
        let staticStations = mapEVSEData(evseRootData)
        
        do {
            try managedContext.save()
            OSLog.general.log("Saving static station data successfully")
            return staticStations
        } catch let error as NSError {
            OSLog.general.error("Saving static station data failed: \(error)")
        }
        
        return []
    }
    
    @MainActor
    func storeDynamicStationData(_ evseStatusesRoot: EVSEStatusesRoot) -> [EvseState] {
        let evseStates = evseStatusesRoot.statuses.flatMap { $0.statusRecords }.map {
            EvseState(evseId: $0.evseId, availability: EvseAvailability(rawValue: $0.status) ?? .unknown)
        }
        
        // Delete all existing records
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "State")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Store new states
        evseStates.forEach { [weak self] stationState in
            guard let self else { return }
            let state = State(context: self.managedContext)
            state.evseId = stationState.evseId
            state.availability = stationState.availability.rawValue
        }
        
        do {
            try managedContext.execute(batchDeleteRequest)
            try managedContext.save()
            OSLog.general.log("Saving dynamic station data successfully")
        } catch let error as NSError {
            OSLog.general.error("Saving dynamic station data failed: \(error)")
        }
        
        return evseStates
    }
    
    // Create Stations from raw data
    private func mapEVSEData(_ root: EVSERoot) -> [Station] {
        return root.evseData.flatMap { $0.dataRecords }.compactMap { [weak self] in
            guard let self else { return nil }
            let station = Station(context: self.managedContext)
            station.stationId = $0.stationId
            station.evseId = $0.evseId
            station.lastUpdate = $0.lastUpdate
            station.latitude = $0.coordinates?.latitude ?? 0
            station.longitude = $0.coordinates?.longitude ?? 0
            
            let powerObj = $0.facilities.map { facility in
                let power = Power(context: self.managedContext)
                power.val = Int32(facility.power)
                return power
            }
            
            station.power = NSSet(array: powerObj)
            
            return station
        }
    }
}
