//
//  ContentView.swift
//  MultilineTextFieldSwiftUIDemo
//
//  Created by Red on 2023/08/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ScrollView {
                MultilineTextField(placeholder: "Placeholder", background: .white) { data in
                    debugPrint(data)
                }
            }
            .frame(height: 200)
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
