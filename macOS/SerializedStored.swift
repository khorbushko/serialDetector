//
//  SerializedStored.swift
//  serialDetector
//
//  Created by Kyryl Horbushko on 21.04.2021.
//

import Foundation

@propertyWrapper
public struct SerializedStored<T: Codable> {
  
  private let key: String
  private let defaultValue: T?
  
  // MARK: - LifeCycle
  
  public init(_ key: String, defaultValue: T? = nil) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  public var wrappedValue: T? {
    get {
      let decoder = JSONDecoder()
      
      if let objectSting = UserDefaults.standard.string(forKey: key),
         let data = objectSting.data(using: .utf8),
         let object = try? decoder.decode(T.self, from: data) {
        return object
      }
      
      return defaultValue
    }
    set {
      let encoder = JSONEncoder()
      
      if let objectData = try? encoder.encode(newValue),
         let stringFromData = String(bytes: objectData, encoding: .utf8) {
        UserDefaults.standard.set(stringFromData, forKey: key)
      } else {
        UserDefaults.standard.removeObject(forKey: key)
      }
      
    }
  }
}
