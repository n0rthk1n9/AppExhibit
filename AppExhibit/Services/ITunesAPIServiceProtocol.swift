//
//  ITunesAPIServiceProtocol.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

protocol ITunesAPIServiceProtocol {
    func fetchAppDetails(for id: String) async throws -> [ITunesAPIResult]
    func fetchApps(for searchTerm: String) async throws -> [ITunesAPIResult]
    func fetchSoftwareDeveloper(for developerName: String) async throws -> iTunesAPISoftwareDeveloperResults
    func fetchDeveloperApps(for developerId: Int) async throws -> [ITunesAPIResult]
}
