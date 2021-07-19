//
//  ContentView.swift
//  Switch
//
//  Created by Alexander Gherardi on 7/19/21.
//

import SwiftUI

struct ContentView: View {
    func setupATEM() -> UInt32 {
        let failure = BMDSwitcher.connect()
        print(failure)
        return failure;
    }
    
    init() {
        self.setupATEM()
    }
    
    var body: some View {
        Text("The Switcher (BETA/INCOMPLETE)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
