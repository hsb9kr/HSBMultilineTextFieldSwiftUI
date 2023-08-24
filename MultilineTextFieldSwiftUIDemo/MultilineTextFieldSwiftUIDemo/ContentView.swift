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
//            ScrollView {
//                MultilineTextField(placeholder: "Placeholder", background: .white) { data in
//                    debugPrint(data)
//                }
//            }
//            .frame(height: 200)
            
            ScrollView {
                HSBMultilineTextField(data: [
                    .init(bold: true, fontSize: 14, text: "ABCDEF"),
                    .init(bold: false, fontSize: 17, text: "안녕하세요"),
                    .init(bold: false, fontSize: 17, text: "Hola"),
                    .init(bold: true, fontSize: 17, text: "하이"),
                ], placeholder: "Placeholder", background: .gray) { data in
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
