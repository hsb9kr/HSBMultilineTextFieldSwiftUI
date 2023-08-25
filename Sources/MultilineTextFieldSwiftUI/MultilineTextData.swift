//
//  MultilinTextData.swift
//  HSBMultilineTextField
//
//  Created by Red on 2023/08/22.
//

import SwiftUI

public struct MultilineTextData: Codable {
    public let bold: Bool
	public let italic: Bool
    public let fontSize: CGFloat
    public let text: String
    
    public init(bold: Bool, italic: Bool, fontSize: CGFloat, text: String) {
        self.bold = bold
        self.italic = italic
        self.fontSize = fontSize
        self.text = text
    }
}
