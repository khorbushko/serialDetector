//
//  ContentView.swift
//  Shared
//
//  Created by Kyryl Horbushko on 19.04.2021.
//

import SwiftUI
import AppKit

struct SerialPortListView: View {
  
  @ObservedObject var viewModel: SerialPortListViewModel
  @Environment(\.settingsStore) private var store: SettingsStore
  @State private var angle: Double = 0
  
  var body: some View {
    VStack(spacing: 0) {
      
      HStack {
        Text("found \(viewModel.serialPorts.count) serial ports:")
          .padding(.leading)
        Spacer()
        ActivityIndicator()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray)
          .padding()
      }
      
      List {
        ForEach(viewModel.serialPorts) { port in
          VStack(alignment: .leading, spacing: 0) {
            
            Text(verbatim: port.ttyName ?? "")
              .lineLimit(nil)
              .font(.system(size: 10, weight: .bold))
              .padding(.bottom, -2)
            
            HStack {
              Text(verbatim: port.bsdPath)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .font(.system(size: 12))
              Spacer()
              
              Button {
                store.selectedPort = port
                
                guard store.selectedPort != nil else {
                  return
                }
                
                let view = SerialPortConsoleView(viewModel: .init(store: store))

                let controller = NSHostingController(rootView: view)
                let window = NSWindow(contentViewController: controller)
                window.styleMask = [.titled, .closable, .miniaturizable]
                window.title = "Console \(port.bsdPath)"
                let size = NSSize(width: 400, height: 600)
                window.minSize = size
                window.maxSize = size
                window.setContentSize(size)
                window.contentMinSize = size
                window.contentMaxSize = size
                window.makeKeyAndOrderFront(nil)
                                
//                Window.console.open()
              } label: {
                Image(systemName: "text.and.command.macwindow")
              }
              Button {
                viewModel.copyData(port)
              } label: {
                Image(systemName: "doc.on.doc")
              }
            }
          }
          .animation(nil)
          .frame(height: 44)
        }
        .animation(.default)
        
        Spacer()
      }
      .padding(.bottom)
    }
    .onAppear(perform: viewModel.fetchData)
    
  }
}

struct SerialPortList_Previews: PreviewProvider {
  static var previews: some View {
    SerialPortListView(viewModel: .init(
      serialPortInspector: SerialPortDiscoverer()
    ))
    .frame(width: 250, height: 200)
  }
}
