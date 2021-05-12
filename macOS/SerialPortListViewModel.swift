//
//  SerialPortListViewModel.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import Combine

final class SerialPortListViewModel: ObservableObject {
  
  @Published private(set) var serialPorts: [SerialPort] = []
  
  private var cancellable: Set<AnyCancellable> = []
  private var pastboard: StringPastboard = .init()
  private var serialPortInspector: SerialPortInspectable

  // MARK: - Lifecycle
  
  init(
    serialPortInspector: SerialPortInspectable
  ) {
    self.serialPortInspector = serialPortInspector
  }
  
  // MARK: - Public
  
  func copyData(_ path: SerialPort) {
    pastboard.copy(path.bsdPath)
    SoundEffect.copy.play()
  }
  
//  func refresh() {
//    fetchPortsData()
//  }
  
  func fetchData() {
    fetchPortsData()
  }
  
  // MARK: - Private
  
  private func fetchPortsData() {
    cancellable.removeAll()
    
    serialPortInspector
      .serialPortPathsPublisher()
      .sink { (serialPorts) in
        self.serialPorts = serialPorts
      }
      .store(in: &cancellable)
  }
}
