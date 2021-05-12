//
//  SerialPortConsoleViewModel.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation
import Combine
import ORSSerial

final class SerialPortConsoleViewModel: ObservableObject {
  
  private class SerialPortConsoleDelegate: NSObject, ORSSerialPortDelegate {
    
    private weak var parent: SerialPortConsoleViewModel?
    
    init(parent: SerialPortConsoleViewModel) {
      self.parent = parent
    }
    
    // MARK: - ORSSerialPortDelegate
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
      parent?.isConnected = false
      
      parent?.printToConsole(
        message: "Port \(serialPort.path) has been removed",
        prefix: .newLine,
        suffix: .newLine
      )
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
      let receivedString = String(data: data, encoding: .utf8) ?? .empty
      parent?.printToConsole(message: receivedString)
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
      if let parent = parent {
        parent.isConnectionInProgress = false
        parent.printToConsole(
          message: "--> Err: " + error.localizedDescription,
          prefix: .newLine,
          suffix: .newLine
        )
      }
    }
        
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
      parent?.isConnectionInProgress = false
      parent?.isConnected = true
      parent?.printToConsole(
        message: "Port \(serialPort.path) was opened",
        prefix: .newLine,
        suffix: .newLine
      )
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
      parent?.isConnectionInProgress = false
      parent?.isConnected = false
      parent?.printToConsole(
        message: "Port \(serialPort.path) was closed",
        prefix: .newLine,
        suffix: .newLine
      )
    }
  }
    
  @Published var selectedBaudRate: BaudRate = ._9600
  @Published var selectedStopBit: StopBits = .zero
  @Published var selectedParity: Parity = .none
  @Published var isEchoEnabled: Bool = false
  @Published var flowControls: [FlowControlValue] = FlowControl.allCases.map({ .init(value: $0) })
  
  @Published var messageToSend: String = .empty
  @Published var messages: String = .empty
  @Published var messageSuffix: Suffix = .none

  @Published var isConnected: Bool = false
  @Published var isConnectionInProgress: Bool = false
  
  @Published var rtsOutput: Bool = false
  @Published var dtrOutput: Bool = false
  @Published var ctsInput: Bool = false
  @Published var dsrInput: Bool = false
  @Published var dcdInput: Bool = false
  
  private(set) var store: SettingsStore

  private var port: ORSSerialPort?
  private var portDelegate: ORSSerialPortDelegate!
  private var subscriptions: Set<AnyCancellable> = []
  
  // MARK: - Lifecycle
  
  init(store: SettingsStore) {
    self.store = store
    self.portDelegate = SerialPortConsoleDelegate(parent: self)
  }
  
  deinit {
    port?.close()
  }
  
  func open() {
    if let selectedPort = store.selectedPort {
      if isConnectionInProgress {
        return
      }
      isConnectionInProgress = true
            
      port = ORSSerialPort(path: selectedPort.bsdPath)
      port?.delegate = portDelegate

      configurePort()
      
      cleanUpSubscriptions()
      subscribeToPublishers()
      subscribeToKVO()
      
      port?.open()
      
    } else {
      fatalError("no selected port available")
    }
  }
  
  func close() {
    if port?.isOpen == true {
      port?.close()
      port?.delegate = nil
      port = nil
      
      isConnected = false
    }
  }
  
  func sendMessage() {
    let message = messageToSend + messageSuffix.rawValue
    
    if let dataToSend = message.data(using: .utf8) {
      port?.send(dataToSend)
      printToConsole(
        message: "--> \"\(message)\"",
        prefix: .newLine,
        suffix: .newLine
      )
    } else {
      printToConsole(
        message: "--> Err: Can't send data \"\(message)\"",
        prefix: .newLine,
        suffix: .newLine
      )
    }
    
    messageToSend = .empty
  }
  
  func clearOutput() {
    messages = .empty
  }
  
  // MARK: - Private
  
  private func printToConsole(
    message: String,
    prefix: String = .empty,
    suffix: String = .empty
  ) {
    messages += (prefix + message + suffix)
  }
  
  private func configurePort() {
    port?.baudRate = NSNumber(value: selectedBaudRate.rawValue)
    port?.parity = selectedParity.toORSerialParity
    port?.numberOfStopBits = selectedStopBit.toORSerialStopBits
    port?.usesRTSCTSFlowControl = flowControls
      .contains(where: { $0.value == .rts_cts && $0.isSelected == true })
    port?.usesDTRDSRFlowControl = flowControls
      .contains(where: { $0.value == .dtr_dsr && $0.isSelected == true })
    port?.usesDCDOutputFlowControl = flowControls
      .contains(where: { $0.value == .dcd && $0.isSelected == true })
    port?.shouldEchoReceivedData = isEchoEnabled
    port?.rts = rtsOutput
    port?.dtr = dtrOutput

  }
  
  private func cleanUpSubscriptions() {
    subscriptions.removeAll()
  }
  
  private func subscribeToPublishers() {
    
    $selectedBaudRate
      .removeDuplicates()
      .sink { [weak self] value in
        self?.port?.baudRate = NSNumber(value: value.rawValue)
      }
      .store(in: &subscriptions)
    
    $selectedParity
      .removeDuplicates()
      .sink { [weak self] value in
        self?.port?.parity = value.toORSerialParity
      }
      .store(in: &subscriptions)
    
    $selectedStopBit
      .removeDuplicates()
      .sink { [weak self] value in
        self?.port?.numberOfStopBits = value.toORSerialStopBits
      }
      .store(in: &subscriptions)
    
    $flowControls
      .sink { [weak self] value in
        self?.port?.usesRTSCTSFlowControl = value
          .contains(where: { $0.value == .rts_cts && $0.isSelected == true })
        self?.port?.usesDTRDSRFlowControl = value
          .contains(where: { $0.value == .dtr_dsr && $0.isSelected == true })
        self?.port?.usesDCDOutputFlowControl = value
          .contains(where: { $0.value == .dcd && $0.isSelected == true })
      }
      .store(in: &subscriptions)
    
    $isEchoEnabled
      .removeDuplicates()
      .sink { [weak self] value in
        self?.port?.shouldEchoReceivedData = value
      }
      .store(in: &subscriptions)
    
    $rtsOutput
      .removeDuplicates()
      .sink { value in
        self.port?.rts = value
      }
      .store(in: &subscriptions)
    
    $dtrOutput
      .removeDuplicates()
      .sink { value in
        self.port?.dtr = value
      }
      .store(in: &subscriptions)
    
    $isConnected
      .receive(on: DispatchQueue.main)
      .sink { _ in
        self.ctsInput = self.port?.cts == true
        self.dsrInput = self.port?.dsr == true
        self.dcdInput = self.port?.dcd == true
      }
      .store(in: &subscriptions)
  }
  
  private func subscribeToKVO() {
    port?
      .publisher(for: \.cts)
      .sink { [weak self] value in
        self?.ctsInput = value
      }
      .store(in: &subscriptions)
    port?
      .publisher(for: \.dsr)
      .sink { [weak self] value in
        self?.dsrInput = value
      }
      .store(in: &subscriptions)
    port?
      .publisher(for: \.dcd)
      .sink { [weak self] value in
        self?.dcdInput = value
      }
      .store(in: &subscriptions)
  }
}

fileprivate extension Parity {
  
  var toORSerialParity: ORSSerialPortParity {
    switch self {
      case .even:
        return .even
      case .none:
        return .none
      case .odd:
        return .none
    }
  }
}

fileprivate extension StopBits {
  
  var toORSerialStopBits: UInt {
    switch self {
      case .one:
        return 0
      case .zero:
        return 1
    }
  }
}
