//
//  ContentView.swift
//  Switch
//
//  Created by Alexander Gherardi on 7/19/21.
//

import SwiftUI
import ORSSerial

struct ContentView: View {
    @State var switcher = BMDSwitcher()
    @State var showDetails = false
    @State var live = false
    @AppStorage("ipAddr") var ipAddr: String = "0.0.0.0"
    @AppStorage("inputs") var inputs: [String] = ["Disabled", "Disabled", "Disabled", "Disabled", "Disabled"]

    func setTallyState(path: String, prev: Bool, prog: Bool) {
        if let port = ORSSerialPort(path: path) {
            // Ignore bluetooth related port
            if port.name == "Bluetooth-Incoming-Port" {
                return
            }
            port.open()
            // Set state
            if prev == true {
                port.send("prev_on\n".data(using: .utf8)!)
            } else {
                port.send("prev_off\n".data(using: .utf8)!)
            }
            usleep(10000)
            if prog == true {
                port.send("prog_on\n".data(using: .utf8)!)
            } else {
                port.send("prog_off\n".data(using: .utf8)!)
            }
            port.close()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !showDetails {
                Text("Connect to continue")
                TextField(
                        "Ip address",
                        text: $ipAddr
                )
                        .disableAutocorrection(true)
                        .padding(10)
                Button(action: {
                    // Connect to switcher
                    let result = switcher.connect(ipAddr)
                    if result == 0 {
                        // Show tally config details
                        withAnimation {
                            showDetails = true
                        }
                    }
                }) {
                    Text("Connect")
                }.padding(10)
            } else {
                List {
                    ForEach(0..<inputs.count, id: \.self) { inputNum in
                        VStack {
                            Picker(selection: $inputs[inputNum], label: Text("Input \(inputNum)")) {
                                Text("Disabled").tag("Disabled")
                                ForEach(ORSSerialPortManager.shared().availablePorts, id: \.self) { port in
                                    Text(port.path).tag(port.path)
                                }
                            }
                        }
                    }
                }
                if live == false {
                    Button(action: {
                        switcher.getInputs({ (status: InputStatus?) -> Void in
                            if let status = status {
                                if status.inputId < inputs.count {
                                    let path = inputs[Int(status.inputId)]
                                    if path != "Disabled" {
                                        setTallyState(path: path, prev: status.isPreview, prog: status.isProgram)
                                    }
                                }
                            }
                        })
                        withAnimation {
                            live = true
                        }
                    }
                    ) {
                        Text("Go Live")
                    }
                            .padding(10)
                } else {
                    Button(action: {}) {
                        Text("⚪ Live")
                    }
                            .background(Color.red)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .disabled(true)
                            .padding(10)

                }
            }
        }
                .padding(50)
                .frame(maxWidth: 500, maxHeight: 1000)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
                else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
                else {
            return "[]"
        }
        return result
    }
}
