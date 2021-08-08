//
//  ContentView.swift
//  Switch
//
//  Created by Alexander Gherardi on 7/19/21.
//

import SwiftUI

struct ContentView: View {
    @State var switcher = BMDSwitcher()
    @State var statusText: String = "Not Connected"
    @State var ipAddr: String = "0.0.0.0"
    @State var showDetails = false

    func turnOn() {
        // TODO: Get tally light file at runtime
        let fileDescriptor = open("/dev/cu.usbmodemTODO1", O_RDWR | O_NOCTTY | O_NONBLOCK);
        if fileDescriptor == -1 {
            print("failed to open port")
            return
        }
        write(fileDescriptor, "on\n", 4)
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
                    print(result)
                    self.statusText = String(result)

                    // Show tally config details
                    withAnimation {
                        showDetails.toggle()
                    }
                }) {
                    Text("Connect")
                }.padding(10)
            } else {
                Button(action: {
                    if let inputStatuses = switcher.getInputs() {
                        for status in inputStatuses {
                            print("ID: " + String(status.inputId) + " IsPreview: " + String(status.isPreview) + " IsProgram: " + String(status.isProgram))
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
