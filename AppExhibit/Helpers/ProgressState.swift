// Original Source: https://github.com/FlineDev/HandySwiftUI/blob/main/Sources/HandySwiftUI/Other/ProgressState.swift

/// Represents the state of a progress operation.
enum ProgressState {
  /// The operation has not started yet.
  case notStarted

  /// The operation is currently in progress.
  case inProgress

  /// The operation failed with an error.
  case failed(error: AppExhibitError)

  /// The operation completed successfully.
  case successful
}
