//
//  SerialPortConsoleView.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 21.04.2021.
//

import Foundation
import SwiftUI

struct SerialPortConsoleView: View {
  
  @ObservedObject var viewModel: SerialPortConsoleViewModel
  
  // MARK: - Override
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Group {
          serialPort()
          baudPicker()
          stopBitPicker()
          parityPicker()
          flowControlSelector()
          echoSelection()
          openPort()
        }
        
        Group {
          inputs()
          pinStates()
        }
        
        Spacer()
        summary()
      }
      .padding()

      Spacer()
    }
  }
  
  // MARK: - Private
  
  private func serialPort() -> some View {
    HStack {
      Text("Serial port: ")
      Spacer()
      if let path = viewModel.store.selectedPort?.bsdPath {
        Text(path)
          .lineLimit(nil)
          .background(Color.white)
        Spacer()
      }
    }
  }
  
  private func baudPicker() -> some View {
    Picker(
      selection: $viewModel.selectedBaudRate,
      label: Text("Baud")
    ) {
      ForEach(BaudRate.allCases) { baud in
        Text("\(baud.rawValue)")
          .tag(baud)
      }
    }
    .frame(width: 200)
  }
  
  fileprivate func stopBitPicker() -> some View {
    Picker(
      selection: $viewModel.selectedStopBit,
      label: Text("Stop bits")
    ) {
      ForEach(StopBits.allCases) { bit in
        Text("\(bit.rawValue)")
          .frame(width: 30)
          .tag(bit)
        
      }
    }
    .pickerStyle(RadioGroupPickerStyle())
    .horizontalRadioGroupLayout()
  }
  
  private func parityPicker() -> some View {
    Picker(
      selection: $viewModel.selectedParity,
      label: Text("Parity")
    ) {
      ForEach(Parity.allCases) { value in
        Text("\(value.rawValue)")
          .tag(value)
      }
    }
    .pickerStyle(RadioGroupPickerStyle())
    .horizontalRadioGroupLayout()
  }
  
  private func flowControlSelector() -> some View {
    Group {
        Text("Input/Output")
          .padding(.leading, 100)
      
      HStack {
        Text("FlowControl")
        
        VStack(alignment: .leading) {
          ForEach(0..<viewModel.flowControls.count) { index in
              Button(action: {
                viewModel.flowControls[index].isSelected =
                  !viewModel.flowControls[index].isSelected
              }) {
                HStack {
                  Image(systemName:
                          viewModel.flowControls[index].isSelected
                          ? "checkmark.circle.fill"
                          : "circle")
                    .foregroundColor(
                      viewModel.flowControls[index].isSelected
                        ? .green :
                        .primary)
                    .animation(.easeIn)
                  Text(viewModel.flowControls[index].value.rawValue)
                }
              }
              .buttonStyle(BorderlessButtonStyle())
          }
        }
        
      }
      
    }
  }
  
  private func echoSelection() -> some View {
    HStack {
      Button(action: {
        viewModel.isEchoEnabled = !viewModel.isEchoEnabled
      }, label: {
        
        HStack {
          Text("Enable echo")
          Toggle("", isOn: $viewModel.isEchoEnabled)
        }
      })
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  private func openPort() -> some View {
    HStack {
      Spacer()
      Button(viewModel.isConnected ? "Close" : "Open",
             action: viewModel.isConnected ? viewModel.close : viewModel.open)
    }
  }
  
  @State private var isSuffixEnabled: Bool = false
  
  private func inputs() -> some View {
    VStack {
      Group {
        Divider()
        
        VStack(alignment: .trailing) {
          TextField("Enter message:", text: $viewModel.messageToSend)
          
          HStack {
            Spacer()
            Toggle(
              isOn: $isSuffixEnabled,
              label: {
                Text("Add suffix")
              }
            )
            
            Picker(
              selection: $viewModel.messageSuffix,
              label: Text("")
            ) {
              ForEach(Suffix.allCases) { value in
                Text(value.description)
                  .tag(value)
              }
            }
            .frame(width: 100)
            .allowsHitTesting(isSuffixEnabled)
            
            Button("Send", action: viewModel.sendMessage)
          }
        }
        
        Divider()
        
        VStack(alignment: .trailing) {
          TextEditor(text: $viewModel.messages)
            .frame(
              idealHeight: 100,
              maxHeight: .infinity
            )
          HStack {
            Button("Clear", action: viewModel.clearOutput)
          }
        }
      }
      .disabled(!viewModel.isConnected)
    }
  }
  
  private func pinStates() -> some View {
    HStack {
      Text("PinState")
        .padding(.top, 25)
        .padding([.leading,.trailing], 10)
      VStack{
        Text("Output")
        HStack {
          Toggle("RTS", isOn: $viewModel.rtsOutput)
          Toggle("DTR", isOn: $viewModel.dtrOutput)
        }
        
      }
      Spacer()
      VStack {
        Text("Input")
        HStack {
          Toggle("CTS", isOn: $viewModel.ctsInput)
            .disabled(true)
          Toggle("DSR", isOn: $viewModel.dsrInput)
            .disabled(true)
          Toggle("DCD", isOn: $viewModel.dcdInput)
            .disabled(true)
        }
      }
    }
  }
  
  private func summary() -> some View {
    VStack {
      Divider()
      HStack{
        Spacer()
        Text("Port: " + (viewModel.store.selectedPort?.ttyName ?? " - "))
        VerticalDivider()
          .padding([.top, .bottom], 2)
        Text("Baud: ")
        Text("\(viewModel.selectedBaudRate.rawValue)")
        VerticalDivider()
          .padding([.top, .bottom], 2)
        Circle()
          .frame(width: 16, height: 16)
          .foregroundColor(viewModel.isConnected ? Color.green : Color.red)
      }
    }
    .frame(height: 30)
  }
}

// MARK: - Preview
  
struct SerialPortConsoleView_Previews: PreviewProvider {
  
  static var previews: some View {
    SerialPortConsoleView(viewModel: .init(store: .init()))
      .frame(width: 400, height: 600)
  }
}

struct VerticalDivider: View {
  
  var body: some View {
    Rectangle()
      .fill(Color.gray)
      .frame(width: 1)
  }
}
