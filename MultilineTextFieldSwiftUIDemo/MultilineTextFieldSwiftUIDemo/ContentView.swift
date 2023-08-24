//
//  ContentView.swift
//  MultilineTextFieldSwiftUIDemo
//
//  Created by Red on 2023/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var text: String = ""
    
    var body: some View {
        VStack {
            HSBMultilineTextField(placeholder: "Placeholder", data: [
                .init(bold: true, fontSize: 14, text: "ABCDEF"),
                .init(bold: false, fontSize: 17, text: "안녕하세요"),
                .init(bold: false, fontSize: 17, text: "Hola"),
                .init(bold: true, fontSize: 17, text: "하이"),
            ], background: .gray) { data in
                debugPrint(data)
            }
            .frame(height: 100)
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
