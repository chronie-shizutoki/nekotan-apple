//
//  DiaryError.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import Foundation

/// Errors that can occur during diary operations
enum DiaryError: Error, LocalizedError {
    /// Failed to save diary data
    case saveFailed
    
    /// Failed to load diary data
    case loadFailed
    
    /// Failed to delete diary data
    case deleteFailed
    
    /// Failed to export diary data
    case exportFailed
    
    /// Failed to import diary data
    case importFailed
    
    /// Invalid CSV format
    case invalidCSVFormat
    
    /// Missing required fields in diary entry
    case missingRequiredFields
    
    /// File not found
    case fileNotFound
    
    /// Permission denied
    case permissionDenied
    
    // MARK: - LocalizedError implementation
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "日記の保存に失敗しました。にゃん～"
        case .loadFailed:
            return "日記の読み込みに失敗しました。にゃん～"
        case .deleteFailed:
            return "日記の削除に失敗しました。にゃん～"
        case .exportFailed:
            return "日記のエクスポートに失敗しました。にゃん～"
        case .importFailed:
            return "日記のインポートに失敗しました。にゃん～"
        case .invalidCSVFormat:
            return "CSVファイルの形式が正しくありません。にゃん～"
        case .missingRequiredFields:
            return "必要な情報が不足しています。にゃん～"
        case .fileNotFound:
            return "ファイルが見つかりませんでした。にゃん～"
        case .permissionDenied:
            return "ファイルへのアクセス権がありません。にゃん～"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .loadFailed, .deleteFailed:
            return "アプリを再起動してみてください。それでも解決しない場合は、バックアップファイルを確認してください。"
        case .exportFailed, .importFailed, .invalidCSVFormat:
            return "ファイル形式が正しいか確認してください。"
        case .missingRequiredFields:
            return "全ての必須フィールドを入力してください。"
        case .fileNotFound:
            return "ファイルの場所を確認してください。"
        case .permissionDenied:
            return "アプリのファイルアクセス権限を確認してください。"
        }
    }
}