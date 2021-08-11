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
    @State var statusText: String = "Not Connected"
    @State var ipAddr: String = "0.0.0.0"
    @State var showDetails = false

    func turnOn() {
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
            // Ignore bluetooth related port
            if port.name == "Bluetooth-Incoming-Port" {
                continue
            }
            port.open()
            port.send("on\n".data(using: .utf8)!)
            port.close()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !showDetails {
                Text("Status: " + statusText).padding(10)
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
                            showDetails.toggle()
                        }
                    }
                }) {
                    Text("Connect")
                }.padding(10)
            } else {
                Button(action: {
                    if let inputStatuses = switcher.getInputs() {
                        for status in inputStatuses {
                            print("ID: " + String(status.inputId) + " IsPreview: " + String(status.isPreview) + " IsProgram: " + String(status.isProgram))
                            if status.inputId == 1 && status.isProgram == true {
                                turnOn()
                            }
                        }
                    }
                }) {
                    Text("Get Status")
                }.padding(10)
            }
        }
                .padding(50)
                .frame(maxWidth: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
