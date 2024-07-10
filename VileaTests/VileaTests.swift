//
//  VileaTests.swift
//  VileaTests
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import XCTest
import Combine
@testable import Vilea

final class VileaTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Note: can be executed only after the first start
    func testLoadingCasheForOffline() async throws {
        let expectation = XCTestExpectation(description: "LoadState should have some stations")

        let repository = StationRepository()
        repository.$loadState
            .sink { newState in
                switch newState {
                case let .loaded(stations) where !stations.isEmpty:
                    expectation.fulfill()

                default:
                    break
                }
            }
            .store(in: &cancellables)

        repository.loadCachedData()

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testFetchStations() async throws {
        let expectation = XCTestExpectation(description: "LoadState should have some stations")

        let repository = StationRepository()
        repository.$loadState
            .sink { newState in
                switch newState {
                case let .loaded(stations) where !stations.isEmpty:
                    expectation.fulfill()

                default:
                    break
                }
            }
            .store(in: &cancellables)

        repository.fetchStations()

        await fulfillment(of: [expectation], timeout: 15.0)
    }
}
