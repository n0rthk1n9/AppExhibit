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
}
