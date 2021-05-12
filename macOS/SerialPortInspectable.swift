//
//  SerialPortInspectable.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import Combine
import IOKit
import IOKit.serial

protocol SerialPortInspectable {
  func serialPortPathsPublisher() -> AnyPublisher<[SerialPort], Never>
}

final class SerialPortDiscoverer: SerialPortInspectable {
  
  static let listener: SerialPortDiscoverer = .init()

  @Published private(set) var serialPorts: [SerialPort] = []
  
  private var processingIOKitQueue = DispatchQueue(label: "com.hbk.serialPortDiscoverer")
  private var portAddedNotificationIterator: io_iterator_t = 0
  private var portRemovedNotificationIterator: io_iterator_t = 0
  private var availablePorts: [SerialPort] = [] {
    didSet {
      serialPorts = availablePorts
    }
  }
  
  // MARK: - Lifecycle
  
  init() {
    fetchListOfPortsAndSubscribeToChange()
  }

  deinit {
    stop()
  }
    
  // MARK: - Public
  
  func serialPortPathsPublisher() -> AnyPublisher<[SerialPort], Never> {
    $serialPorts
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  func stop() {
    portAddedNotificationIterator = 0
    IOObjectRelease(portAddedNotificationIterator)
    
    portRemovedNotificationIterator = 0
    IOObjectRelease(portRemovedNotificationIterator)
  }
  
  // MARK: - Private
  
  private func fetchListOfPortsAndSubscribeToChange() {
    let adddedNotificationPort: IONotificationPortRef = IONotificationPortCreate(kIOMasterPortDefault)
    IONotificationPortSetDispatchQueue(adddedNotificationPort, processingIOKitQueue)
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       IONotificationPortGetRunLoopSource(adddedNotificationPort).takeUnretainedValue(),
                       CFRunLoopMode.defaultMode)
    
    var matchingDict = IOServiceMatching(kIOSerialBSDServiceValue) as NSDictionary as! [String: AnyObject]
    matchingDict[kIOSerialBSDTypeKey] = kIOSerialBSDAllTypes as AnyObject
    let cfMatchingDictionary = matchingDict as CFDictionary
    
    var portIterator: io_iterator_t = 0
    
    let callbackForAddedPort: @convention(c) (UnsafeMutableRawPointer?, io_iterator_t) -> Void = { refCon, iterator in
      if let refCon = refCon {
        let portDiscoverer = Unmanaged<SerialPortDiscoverer>.fromOpaque(refCon).takeUnretainedValue()
        
        let newPorts = portDiscoverer.extractSerialPaths(portIterator: iterator)
        newPorts.forEach(portDiscoverer.appendPort)
        
      } else {
        print("ref to content obj broken")
      }
    }
    
    let selfPtr = Unmanaged.passUnretained(self).toOpaque()
    
    let resultForPublish: kern_return_t = IOServiceAddMatchingNotification(
      adddedNotificationPort,
      kIOPublishNotification,
      cfMatchingDictionary,
      callbackForAddedPort,
      selfPtr,
      &portIterator
    )
    
    if resultForPublish == KERN_FAILURE {
      print("can't subscribe to addNewPortEvent")
      if portIterator != 0 {
        portIterator = 0
        IOObjectRelease(portIterator)
      }
      
      portAddedNotificationIterator = 0
      IOObjectRelease(portAddedNotificationIterator)
      
      return
    }
    
    portAddedNotificationIterator = portIterator
    
    availablePorts = extractSerialPaths(portIterator: portAddedNotificationIterator)
    
    let removalNotificationPort: IONotificationPortRef = IONotificationPortCreate(kIOMasterPortDefault)
    IONotificationPortSetDispatchQueue(removalNotificationPort, processingIOKitQueue)
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       IONotificationPortGetRunLoopSource(removalNotificationPort).takeUnretainedValue(),
                       CFRunLoopMode.defaultMode)
    
    let callbackForRemovedPort: @convention(c) (UnsafeMutableRawPointer?, io_iterator_t) -> Void = { refCon, iterator in
      if let refCon = refCon {
        let portDiscoverer = Unmanaged<SerialPortDiscoverer>.fromOpaque(refCon).takeUnretainedValue()
        
        let removedPorts = portDiscoverer.extractSerialPaths(portIterator: iterator)
        removedPorts.forEach(portDiscoverer.removePort)
        
      } else {
        print("ref to content obj broken")
      }
    }
    
    let resultForRemovel = IOServiceAddMatchingNotification(
      removalNotificationPort,
      kIOTerminatedNotification,
      cfMatchingDictionary,
      callbackForRemovedPort,
      selfPtr,
      &portIterator
    )
    
    if resultForRemovel == KERN_FAILURE {
      print("can't subscribe to removeNewPortEvent")
      if portIterator != 0 {
        portIterator = 0
        IOObjectRelease(portIterator)
      }
      
      portRemovedNotificationIterator = 0
      IOObjectRelease(portRemovedNotificationIterator)
      return
    }
    portRemovedNotificationIterator = portIterator
    
    var serialService: io_object_t
    repeat {
      serialService = IOIteratorNext(portRemovedNotificationIterator)
    } while serialService != 0
  }
  
  private func findSerialDevices(
    deviceType: String,
    serialPortIterator: inout io_iterator_t ) -> kern_return_t {
    var result: kern_return_t = KERN_FAILURE
    let classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue)
    result = IOServiceGetMatchingServices(
      kIOMasterPortDefault,
      classesToMatch,
      &serialPortIterator
    )
    return result
  }
  
  /// Sample Matching dictionary
  ///
  ///     {
  ///      IOProviderClass = kIOSerialBSDServiceValue;
  ///      kIOSerialBSDTypeKey = kIOSerialBSDAllTypes
  ///                             | kIOSerialBSDModemType
  ///                             | kIOSerialBSDRS232Type;
  ///      kIOTTYDeviceKey = <Raw Unique Device Name>;
  ///      kIOTTYBaseNameKey = <Raw Unique Device Name>;
  ///      kIOTTYSuffixKey = <Raw Unique Device Name>;
  ///      kIOCalloutDeviceKey = <Callout Device Name>;
  ///      kIODialinDeviceKey = <Dialin Device Name>;
  ///     }
  ///
  ///       kUSBVendorID
  ///       kUSBProductID
  ///
  private func extractSerialPaths(portIterator: io_iterator_t) -> [SerialPort] {
    var paths: [SerialPort] = []
    var serialService: io_object_t
    repeat {
      serialService = IOIteratorNext(portIterator)
      if (serialService != 0) {
        
        var serialPortInfo: SerialPort!
        
        [
          kIOCalloutDeviceKey,
          kIOTTYDeviceKey,
          kIOTTYBaseNameKey,
          kIODialinDeviceKey
        ].forEach { (inspectKey) in
          let currentKey: CFString = inspectKey as CFString
          let valueCFString =
            IORegistryEntryCreateCFProperty(
              serialService,
              currentKey,
              kCFAllocatorDefault,
              0
            )
            .takeUnretainedValue()
          if let value = valueCFString as? String {
            
            switch inspectKey {
              case kIOCalloutDeviceKey:
                serialPortInfo = .init(bsdPath: value)
              case kIOTTYBaseNameKey:
                serialPortInfo.ttyName = value
              case kIOTTYDeviceKey:
                serialPortInfo.ttyDevice = value
              case kIODialinDeviceKey:
                serialPortInfo.dialinPath = value
              default:
                break
            }
          }
        }
        if serialPortInfo != nil {
          paths.append(serialPortInfo)
        }
        
      }
    } while serialService != 0
    
    return paths
  }
  
  private func fetchSerialPortPaths() -> [SerialPort] {
    var portIterator: io_iterator_t = 0
    //    kIOSerialBSDRS232Type - Generic Serial RS-232 devices
    //    kIOSerialBSDModemType - Devices enumerated as modem
    let kernResult = findSerialDevices(
      deviceType: kIOSerialBSDAllTypes,
      serialPortIterator: &portIterator
    )
    
    if kernResult == KERN_SUCCESS {
      return extractSerialPaths(portIterator: portIterator)
    } else {
      return []
    }
  }
  
  private func appendPort(_ port: SerialPort) {
    if !availablePorts.contains(where: { $0.bsdPath == port.bsdPath }) {
      availablePorts.append(port)
    }
  }
  
  private func removePort(_ port: SerialPort) {
    availablePorts.removeAll(where: { $0.bsdPath == port.bsdPath })
  }
}
