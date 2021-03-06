//
//  Wildcard.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import UIKit


private let consonant = "[b-df-hj-np-tv-z]"
private let vowel = "[aeiou]"

let plurals: [(String, String)] = [
    ("(?<=f)oo(?=t)$|(?<=t)oo(?=th)$|(?<=g)oo(?=se)$", "ee"),
    ("(?<=i)fe$|(?<=[eao]l)f$|(?<=(l|sh)ea)f$", "ves"),
    ("(\\w{2,})[ie]x", "$1ices"),
    ("(?<=[ml])ouse$", "ice"),
    ("man$", "men"),
    ("child$", "children"),
    ("person$", "people"),
    ("eau$", "eaux"),
    ("(?<=-by)$", "s"),
    ("(?<=[^q]\(vowel)y)$", "s"),
    ("y$", "ies"),
    ("(?<=s|sh|tch)$", "es"),
    ("(?<=\(vowel)\(consonant)i)um", "a"),
    ("(?<=\\w)$", "s")
    //"a$": "ae",
    //"us$": "i"
    //"us$": "ora",
    //"us$": "era",
]

let singulars: [(String, String)] = [
    ("(?<=f)ee(?=t)$|(?<=t)ee(?=th)$|(?<=g)ee(?=se)$", "oo"),
    ("(?<=i)ves$", "fe"),
    ("(?<=[eao]l)ves$|(?<=(l|sh)ea)ves$", "f"),
    ("(?<=[ml])ice$", "ouse"),
    ("men$", "man"),
    ("children$", "child"),
    ("people$", "person"),
    ("eaux$", "eau"),
    ("(?<=-by)s$", ""),
    ("(?<=[^q]\(vowel)y)s$", ""),
    ("ies$", "y"),
    ("(?<=s|sh|tch)es$", ""),
    ("(?<=\(vowel)\(consonant)i)a", "um"),
    ("(?<=\\w)s$", "")
]

private let irregulars: [String:String] = [
    "potato": "potatoes",
    "di": "dice",
    "appendix": "appendices",
    "index": "indices",
    "matrix": "matrices",
    "radix": "radices",
    "vertex": "vertices",
    "radius": "radii",
    "goose": "geese"
]

infix operator =~ { associativity left precedence 140 }

/**
    Checks if the input matches the pattern

    :param: left   the input string
    :param: right    the pattern

    :returns:    returns true if pattern exists in the input string
*/
public func =~(left: String, right: String) -> Bool {
    return left.match(right) != nil
}

public extension String {
    
    /**
        Convert a string into an NSDate object. Currently supports both backslashes and hyphens in the following formats:
        
        * Y-m-d
        * m-d-Y
        * Y-n-j
        * n-j-Y
        
        :returns: a date
    */
    public func toDate() -> NSDate? {
        //println("to Date: \(self)")
        
        var patterns = [
            "\\w+ (\\w+) (\\d+) (\\d{1,2}):(\\d{1,2}):(\\d{1,2}) \\+\\d{4} (\\d{4})": ["month", "day", "hour", "minute", "second", "year"],
            "(\\d{4})[-\\/](\\d{1,2})[-\\/](\\d{1,2})(?: (\\d{1,2}):(\\d{1,2}):(\\d{1,2}))?": ["year", "month", "day", "hour", "minute", "second"],
            "(\\d{1,2})[-\\/](\\d{1,2})[-\\/](\\d{4})(?: (\\d{1,2}):(\\d{1,2}):(\\d{1,2}))?": ["month", "day", "year", "hour", "minute", "second"]
        ]
        
        for (pattern, map) in patterns {
            if let matches = self.match(pattern) {
                //println("Matches \(matches)")
                if(matches.count >= 4) {
                    var dictionary = [String:String]()
                    
                    for (i, item) in enumerate(map) {
                        if i + 1 < matches.count {
                            dictionary[item] = matches[i + 1]
                        } else {
                            break
                        }
                    }
                    
                    let calendar = NSCalendar.currentCalendar()
                    let comp = NSDateComponents()
                    
                    comp.year = 0
                    if let year = dictionary["year"]?.toInt() {
                        comp.year = year
                    }
                    
                    comp.month = 0
                    if let month = dictionary["month"] {
                        if let month = month.toInt() {
                            comp.month = month
                        } else {
                            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                            for (i, m) in enumerate(months) {
                                if month =~ m {
                                    comp.month = i
                                    break
                                }
                            }
                        }
                    }
                    
                    comp.day = 0
                    if let day = dictionary["day"]?.toInt() {
                        comp.day = day
                    }
                    
                    comp.hour = 0
                    if let hour = dictionary["hour"]?.toInt() {
                        comp.hour = hour
                    }
                    
                    comp.minute = 0
                    if let minute = dictionary["minute"]?.toInt() {
                        comp.minute = minute
                    }
                    
                    comp.second = 0
                    if let second = dictionary["second"]?.toInt() {
                        comp.second = second
                    }
                    
                    return calendar.dateFromComponents(comp)
                }
            }
        }
        return nil
    }

    /**
        Split a string into an array of strings by slicing at delimiter
    
        :param: delimiter   character(s) to split string at

        :returns: an array of strings if delimiter matches, or an array with the original string as its only component
    */
    public func split(delimiter: String) -> [String] {
        var parsedDelimiter: String = NSRegularExpression.escapedPatternForString(delimiter)
        
        if let matches = self.scan("(.+?)(?:\(parsedDelimiter)|$)") {
            var arr = [String]()
            for match in matches {
                arr.append(match[1])
            }
            
            return arr
        } else {
            return [self]
        }
    }

    /**
        Substitute result of callback function for all occurences of pattern

        :param: pattern a regular expression string to match against
        :param: callback    a callback function to call on pattern match success
        
        :returns:    modified string
    */
    public func gsub(pattern: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern)
        return regex.gsub(self, callback: callback)
    }
    
    /**
        Substitute result of callback function for all occurences of pattern. The following flags are permitted:

        * i:    case-insenstive match
        * x:    ignore #-prefixed comments and whitespace in this pattern
        * s:    `.` matches `\n`
        * m:    `^`, `$` match the beginning and end of lines, respectively (set by default)
        * w:    use unicode word boundaries
        * c:    ignore metacharacters when matching (e.g, `\w`, `\d`, `\s`, etc..)
        * l:    use only `\n` as a line separator
    
        :param: pattern an ICU-style regular expression
        :param: options a string containing option flags
        :param: callback    a callback function to call on pattern match success
        
        :returns:    modified string
    */
    public func gsub(pattern: String, options: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, options)
        return regex.gsub(self, callback: callback)
    }

    /**
        Convenience wrapper for gsub with options
    */
    public func gsub(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, options)
        return regex.gsub(self, replacement)
    }

    /**
        Convenience wrapper for case-insenstive gsub
    */
    public func gsubi(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern,  "\(options)i")
        return regex.gsub(self, replacement)
    }

    /**
        Convenience wrapper for case-insensitive gsub with callback
    */
    public func gsubi(pattern: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, "i")
        return regex.gsub(self, callback: callback)
    }
    
    /**
        Convenience wrapper for case-insensitive gsub with callback and options
    */
    public func gsubi(pattern: String, options: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, "\(options)i")
        return regex.gsub(self, callback: callback)
    }
    
    
    /**
        Conveneience wrapper for first-match-only substitution
    */
    public func sub(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, options)
        return regex.sub(self, replacement)
    }
    
    /**
        Conveneience wrapper for case-insensitive first-match-only substitution
    */
    public func subi(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, "\(options)i")
        return regex.sub(self, replacement)
    }
    
    /**
        Scans and matches only the first pattern

        :param: pattern the pattern to search against
        :param:   (not-required) options for matching--see documentation for `gsub`; defaults to ""
    
        :returns:    an array of all matches to the first pattern
    */
    public func match(pattern: String, _ options: String = "") -> [String]? {
        return RegExp(pattern, options).match(self)
    }

    /**
        Scans and matches all patterns

        :param: pattern the pattern to search against
        :param:   (not-required) options for matching--see documentation for `gsub`; defaults to ""
    
        :returns:    an array of arrays of each matched pattern
    */
    public func scan(pattern: String, _ options: String = "") -> [[String]]? {
        return RegExp(pattern, options).scan(self)
    }

    /**
        Slices out the parts of the string that match the pattern
    
        :param: pattern the pattern to search against
    
        :returns:    an array of the slices
    */
    public mutating func slice(pattern: String) -> [[String]]? {
        var matches = self.scan(pattern)
        self = self.gsub(pattern, "")
        return matches
    }

    /**
        Strip white space or aditional specified characters from beginning or end of string
        
        :param: a string of any characters additional characters to strip off beginning/end of string
        
        :returns: trimmed string
    */
    public func trim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("^[\\s\(parsedCharacters)]+|[\\s\(parsedCharacters)]+$", "")
    }

    /**
        Strip white space or aditional specified characters from end of string
        
        :param: a string of any characters additional characters to strip off end of string
        
        :returns: trimmed string
    */
    public func rtrim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("[\\s\(parsedCharacters)]+$", "")
    }

    /**
        Strip white space or aditional specified characters from beginning of string
        
        :param: a string of any characters additional characters to strip off beginning of string
        
        :returns: trimmed string
    */
    public func ltrim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("^[\\s\(parsedCharacters)]+", "")
    }
    
    /**
        Converts Html special characters (e.g. '&#169;' => '©')
    
        :returns:    converted string
    */
    public func decodeHtmlSpecialCharacters() -> String {
        var regex = RegExp("&#[a-fA-F\\d]+;")
        
        return regex.gsub(self) { pattern in
            var hex = RegExp("[a-fA-F\\d]+")
            if let matches = hex.match(pattern) {
                if let sint = matches[0].toInt() {
                    var character = Character(UnicodeScalar(UInt32(sint)))
                    return "\(character)"
                }
            }
            println("There was an issue while trying to decode character '\(pattern)'")
            return ""
        }
    }

    /**
        Converts a string to camelcase. e.g.: 'hello_world' -> 'HelloWorld'
    
        :returns:   a formatted string
    */
    public func toCamelcase() -> String {
        return gsub("[_\\-\\s]\\w") { match in
            return match[advance(match.startIndex, 1)..<match.endIndex].uppercaseString
        }
    }

    /**
        Converts a string to snakecase. e.g.: 'HelloWorld' -> 'hello_world'

        :param: language (Reserved for future use)

        :returns:   a formatted string
    */
    public func toSnakecase() -> String {
        return gsub("[\\s-]\\w") { match in
            return "_" + match[advance(match.startIndex, 1)..<match.endIndex].lowercaseString
        }.gsub("(?<!^)\\p{Lu}") { match in
            return "_\(match.lowercaseString)"
        }.lowercaseString
    }

    /**
        DEVELOPMENTAL METHOD: Change String from singular to plural.
    
        :param: language (Reserved for future use)
    
        :returns:   a plural string
    */
    public func pluralize(language: String = "en/us") -> String {
        if let plural = irregulars[self] {
            return plural
        }
        
        for (regex, mod) in plurals {
            var replacement = self.gsubi(regex, mod)
            if replacement != self {
                return replacement
            }
        }
        
        return self
    }

    /**
        DEVELOPMENTAL METHOD: Change String from plural to singular.
        
        :returns:   a singular string
    */
    public func singularize(language: String = "en/us") -> String {
        if let plurals = irregulars.flip(), plural = plurals[self] {
            return plural
        }
        
        for (regex, mod) in singulars {
            var replacement = self.gsubi(regex, mod)
            if replacement != self {
                return replacement
            }
        }
        
        return self
    }

    /**
        Set the first letter to lowercase
        
        :returns:   formatted string
    */
    public func decapitalize() -> String {
        var prefix = self[startIndex..<advance(startIndex, 1)].lowercaseString
        var body = self[advance(startIndex, 1)..<endIndex]
        return "\(prefix)\(body)"
    }

    /**
        Set the first letter to uppercase
        
        :returns:   formatted string
    */
    public func capitalize() -> String {
        var prefix = self[startIndex..<advance(startIndex, 1)].uppercaseString
        var body = self[advance(startIndex, 1)..<endIndex]
        return "\(prefix)\(body)"
    }

    /**
        Repeat String x times.
    
        :param: the number of times to repeat
    
        :returns:   formatted string
    */
    public func repeat(times: Int) -> String {
        
        var rstring = ""
        if times > 0 {
            for i in 0...times {
                rstring = "\(rstring)\(self)"
            }
        }
        return rstring
    }
    

    /**
        Attribute matched subpatterns and trim. The following attributes are permitted:
        
        * UIFont    set the font
        * NSParagraphStyle  set paragraph styling
        * UIColor   set font color
        
        :param: attributes  a dictionary with the pattern as the key and an array of style attributes as values.
        :param: font    (optional) default font
        
        :returns: an attributed string with styles applied
    */
    public func attribute(attributes: [String: [AnyObject]], font: UIFont? = nil) -> NSAttributedString {
        var textAttrs = [TextAttribute]()
        
        for (pattern, attrs) in attributes {
            var map = [NSObject: AnyObject]()
            
            for attr in attrs {
                if attr is UIFont {
                    map[NSFontAttributeName] = attr
                } else if attr is NSParagraphStyle {
                    map[NSParagraphStyleAttributeName] = attr
                } else if attr is UIColor {
                    map[NSForegroundColorAttributeName] = attr
                }
            }
            
            textAttrs.append(TextAttribute(pattern: pattern, attribute: map))
        }
        
        return RegExp(attributes: textAttrs).attribute(self, font: font)
    }
    
    /**
        Attribute matched subpatterns and trim
        
        :param: attributes  an array of TextAttribute objects
        :param: font    default font
        
        :returns: an attributed string with styles applied
    */
    public func attribute(attributes: [TextAttribute], font: UIFont? = nil) -> NSAttributedString {
        return RegExp(attributes: attributes).attribute(self, font: font)
    }

    /**
        Helper method that parses an Html string and converts it to an attributed string. Currently the default styles are as follows:
    
        * p, ul, ol, div, section, main:

            * paragraph style:
            
                * firstLineHeadIndent:  17
                * headIndent:   20
                * paragraphSpacing: 12

        * li

            * paragraph style:

                * firstLineHeadIndent:  20
                * headIndent:   30
                * paragraphSpacing: 7

        * b, bold, strong:  boldSystemFontOfSize(12)
        * i, em:    italicSystemFontOfSize(12)
        * h1:   boldSystemFontOfSize(24)
        * h2:   boldSystemFontOfSize(20)
        * h3:   italicSystemFontOfSize(18)
        * h4:   boldSystemFontOfSize(16)
        * h5:   systemFontOfSize(15)
    
        To ovverride the defaults do something like this:

                var str = "Hello World"
                var style = NSParagraphStyle()
                style.setValue(CGFloat(16), forKey: "paragraphSpacing")
                var font = UIFont.systemFontOfSize(16)
                var attrStr = str.attributeHtml(map: ["p": [style, font]])

        :param: map override default html properties passing in an array of variables which can be either NSParagraphStyle, UIFont, or UIColor variables.
    
        :returns:    an attributed strings without html tags
    */
    public func attributeHtml(map: [String:[AnyObject]] = [String:[AnyObject]]()) -> NSAttributedString {
        var str = self.decodeHtmlSpecialCharacters().gsub("\\<.*br>", "\n")
        
        var paragraphStyle = NSParagraphStyle()
        paragraphStyle.setValue(CGFloat(17), forKey: "firstLineHeadIndent")
        paragraphStyle.setValue(CGFloat(20), forKey: "headIndent")
        paragraphStyle.setValue(CGFloat(12), forKey: "paragraphSpacing")
        
        var listStyle = NSParagraphStyle()
        listStyle.setValue(CGFloat(20), forKey: "firstLineHeadIndent")
        listStyle.setValue(CGFloat(30), forKey: "headIndent")
        listStyle.setValue(CGFloat(7), forKey: "paragraphSpacing")
        
        var attributes: [String:[AnyObject]] = [
            "li": [listStyle],
            "b": [UIFont.boldSystemFontOfSize(12)],
            "bold": [UIFont.boldSystemFontOfSize(12)],
            "strong": [UIFont.boldSystemFontOfSize(12)],
            "i": [UIFont.italicSystemFontOfSize(12)],
            "em": [UIFont.italicSystemFontOfSize(12)],
            "a": [UIFont.systemFontOfSize(12)],
            "p": [paragraphStyle],
            "ul": [paragraphStyle],
            "ol": [paragraphStyle],
            "div": [paragraphStyle],
            "section": [paragraphStyle],
            "main": [paragraphStyle],
            "h1": [UIFont.boldSystemFontOfSize(24)],
            "h2": [UIFont.boldSystemFontOfSize(20)],
            "h3": [UIFont.italicSystemFontOfSize(18)],
            "h4": [UIFont.boldSystemFontOfSize(16)],
            "h5": [UIFont.systemFontOfSize(15)],
        ]
        
        for (k, v) in map {
            attributes[k] = v
        }

        var parsedAttributes = [String:[AnyObject]]()
        
        
        
        for (el, attr) in attributes {
            parsedAttributes["\\<\(el).*?>(.+?)\\<\\/\(el)>"] = attr
        }
        
        return str.attribute(parsedAttributes)
    }

    internal func substringWithNSRange(range: NSRange) -> String {
        return substringWithRange(range.toStringIndexRange(self))
    }
    
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self)
    }
    
    internal func toMutable() -> NSMutableString {
        var capacity = Swift.count(self.utf16)
        var mutable = NSMutableString(capacity: capacity)
        mutable.appendString(self)
        return mutable
    }
    
    internal func toRange() -> NSRange {
        let capacity = Swift.count(self.utf16)
        return NSMakeRange(0, capacity)
    }
}

internal extension NSMutableString {
    internal func gsub(pattern: String, _ replacement: String) -> NSMutableString {
        var regex = RegExp(pattern)
        return regex.gsub(self, replacement)
    }
    
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self as String)
    }
}

internal extension NSMutableAttributedString {
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self)
    }
}

internal extension NSRange {
    internal func toStringIndexRange(input: String) -> Range<String.Index> {
        if location < count(input.utf16) {
            var startIndex = advance(input.startIndex, location)
            var endIndex = advance(input.startIndex, location + length)
            var range = Range(start: startIndex, end: endIndex)
            //println(input.substringWithRange(range))
            return range
        }
        
        //println("Count: \(count(input.utf16))")
        //println("Location: \(location)")
        return Range(start: input.startIndex, end: input.endIndex)
    }
}

internal extension Dictionary {
    
    internal func flip() -> Dictionary<Key, Value>? {
        if Key.self is Value.Type {
            var out = Dictionary<Key, Value>()
            
            for key in self.keys {
                if let value = self[key] as? Key, key = key as? Value {
                    out[value] = key
                }
            }
            
            return out.count > 0 ? out : nil
        }
        
        return nil
    }
}