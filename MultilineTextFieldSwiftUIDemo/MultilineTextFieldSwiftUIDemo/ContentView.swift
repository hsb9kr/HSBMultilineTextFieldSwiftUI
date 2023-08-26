//
//  ContentView.swift
//  MultilineTextFieldSwiftUIDemo
//
//  Created by Red on 2023/08/23.
//

import SwiftUI

struct ContentView: View {
    
	private let backgroundColor: Color = Color(uiColor: UIColor.systemBackground)
	private let padding: CGFloat = 4
    @State var text: String = ""
    @State var show: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                MultilineTextFieldView(placeholder: "Placeholder", data: [
                    .init(bold: true, italic: false, fontSize: 14, text: "ABCDEF"),
                    .init(bold: false, italic: false, fontSize: 17, text: "안녕하세요"),
                    .init(bold: false, italic: true, fontSize: 17, text: "Hola"),
                    .init(bold: true, italic: true, fontSize: 17, text: "하이"),
                ], background: .gray) { data in
                    debugPrint(data)
                } toolBar: { viewModel in
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            viewModel.focused?.bold.toggle()
                            viewModel.bold = viewModel.focused?.bold
                        } label: {
                            Image(systemName: "bold")
                                .padding(padding)
                                .background(viewModel.bold == true ? backgroundColor.cornerRadius(4) : nil)
                        }
                        Button {
                            viewModel.focused?.fontSize = viewModel.fontSizeList[0]
                            viewModel.fontSize = viewModel.focused?.fontSize
                        } label: {
                            Image(systemName: "textformat.size.smaller")
                                .padding(padding)
                                .background(viewModel.fontSize == viewModel.fontSizeList[0] ? backgroundColor.cornerRadius(4) : nil)
                        }
                        Button {
                            viewModel.focused?.fontSize = viewModel.fontSizeList[1]
                            viewModel.fontSize = viewModel.focused?.fontSize
                        } label: {
                            Image(systemName: "textformat.size.larger")
                                .padding(padding)
                                .background(viewModel.fontSize == viewModel.fontSizeList[1] ? backgroundColor.cornerRadius(4) : nil)
                        }
                        Spacer()
                        Button {
                            show = true
                        } label: {
                            Text("show")
                        }
                        NavigationLink {
                            MultilineTextFieldView(background: .brown) { data in

                            } toolBar: { model in
                                ToolbarItem(id: "test", placement: .keyboard) {
                                    Button {
                                        model.focused?.fontSize = model.fontSizeList[1]
                                        model.fontSize = model.focused?.fontSize
                                    } label: {
                                        Image(systemName: "textformat.size.larger")
                                            .padding(padding)
                                            .background(model.fontSize == model.fontSizeList[1] ? backgroundColor.cornerRadius(4) : nil)
                                    }
                                }
                            }
                        } label: {
                            Text("next")
                        }
                    }
                }
                .frame(height: 100)
                Spacer()
            }
            .padding()
            .sheet(isPresented: $show) {
                NavigationView {
                    MultilineTextFieldView(background: .brown) { data in

                    } toolBar: { model in
                        ToolbarItemGroup(placement: .keyboard) {
                            Button {
                                model.focused?.fontSize = model.fontSizeList[1]
                                model.fontSize = model.focused?.fontSize
                            } label: {
                                Image(systemName: "textformat.size.larger")
                                    .padding(padding)
                                    .background(model.fontSize == model.fontSizeList[1] ? backgroundColor.cornerRadius(4) : nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
