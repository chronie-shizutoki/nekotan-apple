//
//  DependencyContainer.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

/// A dependency injection container for managing app dependencies
class DependencyContainer {
    // MARK: - Shared Instance
    
    /// Shared instance of the dependency container
    static let shared = DependencyContainer()
    
    // MARK: - Private Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Services
    
    /// Creates and returns a diary data service
    /// - Returns: An instance of DiaryDataService
    func makeDiaryDataService() -> DiaryDataService {
        return DiaryDataManager()
    }
    
    /// Creates and returns a diary view model with the appropriate dependencies
    /// - Returns: An instance of DiaryViewModel
    func makeDiaryViewModel() -> DiaryViewModel {
        return DiaryViewModel(diaryService: makeDiaryDataService())
    }
}

/// A protocol for types that can be injected with dependencies
protocol DependenciesInjected: AnyObject {
    var dependencies: DependencyContainer { get }
}

/// Default implementation of DependenciesInjected
extension DependenciesInjected {
    var dependencies: DependencyContainer {
        return DependencyContainer.shared
    }
}