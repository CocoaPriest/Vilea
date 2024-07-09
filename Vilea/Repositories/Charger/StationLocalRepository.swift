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

    func staticStations() -> [Station] {
        let fetchRequest = NSFetchRequest<Station>(entityName: "Station")

        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            OSLog.general.error("Could not fetch static stations \(error), \(error.userInfo)")
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

    // Create Stations from raw data
    private func mapEVSEData(_ root: EVSERoot) -> [Station] {
        return root.evseData.flatMap { $0.dataRecords }.compactMap { [weak self] in
            guard let self else { return nil }
            let station = Station(context: self.managedContext)
            station.stationId = $0.stationId
            station.lastUpdate = $0.lastUpdate
            station.latitude = $0.coordinates?.latitude ?? 0
            station.longitude = $0.coordinates?.longitude ?? 0

            let power = $0.facilities.max(by: { f1, f2 in
                f1.power < f2.power
            })?.power
            station.power = Int32(power ?? 0)

            return station
        }
    }
}
