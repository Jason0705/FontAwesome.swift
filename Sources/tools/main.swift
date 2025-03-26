#!/usr/bin/swift

import Foundation

typealias Icons = [String: Icon]

struct Icon: Codable {
    let changes: [String]
    let styles: [String]
    let aliases: Aliases?
    let unicode: String
    let label: String
}

struct Aliases: Codable {
    let names: [String]?
}

extension String {
    public func camelCased(with separator: Character) -> String {
        return split(separator: separator).reduce("") { result, element in
            "\(result)\(result.count > 0 ? String(element.capitalized) : String(element))"
        }
    }

    public func filteredKeywords() -> String {
        if self == "500px" {
            return "fiveHundredPixels"
        }
        if self == "subscript" {
            return "`subscript`"
        }
        if self == "0" {
            return "zero"
        }
        if self == "00" {
            return "doubleZero"
        }
        if self == "1" {
            return "one"
        }
        if self == "2" {
            return "two"
        }
        if self == "3" {
            return "three"
        }
        if self == "4" {
            return "four"
        }
        if self == "5" {
            return "five"
        }
        if self == "6" {
            return "six"
        }
        if self == "7" {
            return "seven"
        }
        if self == "8" {
            return "eight"
        }
        if self == "9" {
            return "nine"
        }
        if self == "360-degrees" {
            return "threeHundredAndSixtyDegrees"
        }
        if self == "42-group" {
            return "fortyTwoGroup"
        }
        if self == "repeat" {
            return "`repeat`"
        }
        if self == "try" {
            return "`try`"
        }
        if self == "100" {
            return "oneHundred"
        }

        return self
    }
}

guard let json = FileManager.default.contents(atPath: "fontawesome-pro/metadata/icons.json") else {
    fatalError("Could not find JSON metadata file")
}

let icons = try JSONDecoder().decode(Icons.self, from: json)

// Start writing FontAwesome enum
var fontAwesomeEnum = ""

fontAwesomeEnum += """
// Enum.swift
//
// Copyright (c) 2014-present FontAwesome.swift contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// DO NOT EDIT! This file is auto-generated. To regenerate it, update
// Font-Awesome submodule and run `./codegen.swift`.

/// An enumaration of FontAwesome icon names.
// swiftlint:disable file_length type_body_length identifier_name switch_case_alignment
public enum FontAwesome: String, CaseIterable {

"""

let sortedKeys = Array(icons.keys).sorted(by: <)
sortedKeys.forEach { key in
    guard let value = icons[key] else { return }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += """
        case \(enumKeyName) = \"fa-\(key)\"

    """

    if let aliases = value.aliases, let names = aliases.names {
        for name in names {
            let enumKeyName = name.filteredKeywords().camelCased(with: "-")
            fontAwesomeEnum += """
            case \(enumKeyName) = \"fa-\(name)\"
        
        """
        }
    }
}

fontAwesomeEnum += """

    /// An unicode code of FontAwesome icon
    public var unicode: String {
        switch self {

"""


sortedKeys.forEach { key in
    guard let value = icons[key] else { return }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += """
                case .\(enumKeyName): return \"\\u{\(value.unicode)}\"
    """
    fontAwesomeEnum += "\n"
    
    if let aliases = value.aliases, let names = aliases.names {
        for name in names {
            let enumKeyName = name.filteredKeywords().camelCased(with: "-")
            fontAwesomeEnum += """
                        case .\(enumKeyName): return \"\\u{\(value.unicode)}\"
            """
            fontAwesomeEnum += "\n"
        }
    }
}

fontAwesomeEnum += """
        }
    }
"""

fontAwesomeEnum += """


    /// Supported styles of each FontAwesome font
    public var supportedStyles: [FontAwesomeStyle] {
        switch self {

"""

sortedKeys.forEach { key in
    guard let value = icons[key] else { return }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += """
                case .\(enumKeyName): return [.\(value.styles.joined(separator: ", ."))]
    """
    fontAwesomeEnum += "\n"
    
    
    if let aliases = value.aliases, let names = aliases.names {
        for name in names {
            let enumKeyName = name.filteredKeywords().camelCased(with: "-")
            fontAwesomeEnum += """
                        case .\(enumKeyName): return [.\(value.styles.joined(separator: ", ."))]
            """
            fontAwesomeEnum += "\n"
        }
    }
}

fontAwesomeEnum += """
        }
    }
}

/// An enumaration of FontAwesome Brands icon names
public enum FontAwesomeBrands: String {

"""

let brandsIcons = icons.filter { $0.value.styles.contains("brands") }
let sortedBrandsKeys = Array(brandsIcons.keys).sorted(by: <)
sortedBrandsKeys.forEach { key in
    guard brandsIcons[key] != nil else { return }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += """
        case \(enumKeyName) = \"fa-\(key)\"

    """
}


fontAwesomeEnum += """

    /// An unicode code of FontAwesome icon
    public var unicode: String {
        switch self {

"""

sortedBrandsKeys.forEach { key in
    guard let value = brandsIcons[key] else { return }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += """
                case .\(enumKeyName): return \"\\u{\(value.unicode)}\"
    """
    if key != sortedBrandsKeys.last {
        fontAwesomeEnum += "\n"
    }
}

fontAwesomeEnum += """

        }
    }
}

"""

FileManager.default.createFile(atPath: "Enum.swift", contents: fontAwesomeEnum.data(using: .utf8), attributes: nil)
