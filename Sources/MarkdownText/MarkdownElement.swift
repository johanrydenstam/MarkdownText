import SwiftUI

indirect enum MarkdownListElement {
    case list(MarkdownListElement)
    case ordered(OrderedListItemMarkdownConfiguration)
    case unordered(UnorderedListItemMarkdownConfiguration)
    case checklist(CheckListItemMarkdownConfiguration)
}

enum MarkdownElement {
    case header(HeaderMarkdownConfiguration)
    case paragraph(ParagraphMarkdownConfiguration)
    case quote(QuoteMarkdownConfiguration)

    case list(MarkdownListElement)
//    case orderedListItem(OrderedListItemMarkdownConfiguration)
//    case unorderedListItem(UnorderedListItemMarkdownConfiguration)
//    case checklistItem(CheckListItemMarkdownConfiguration)

    case code(CodeMarkdownConfiguration)
    case thematicBreak(ThematicMarkdownConfiguration)

    case inline(InlineMarkdownConfiguration)
    case image(ImageMarkdownConfiguration)
}

public struct ChecklistItem {
    public var isChecked: Bool
    public var paragraph: ParagraphMarkdownConfiguration
}

public struct OrderedItem {
    public var order: Int?
    public var paragraph: ParagraphMarkdownConfiguration
}

public struct UnorderedItem {
    public var paragraph: ParagraphMarkdownConfiguration
}

internal struct Component {
    var text: String
    var attributes: InlineAttributes = []
}

internal struct InlineAttributes: OptionSet, CustomStringConvertible {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let bold = InlineAttributes(rawValue: 1 << 0)
    static let italic = InlineAttributes(rawValue: 1 << 1)
    static let strikethrough = InlineAttributes(rawValue: 1 << 2)
    static let code = InlineAttributes(rawValue: 1 << 3)
    static let link = InlineAttributes(rawValue: 1 << 4)

    var description: String {
        var elements: [String] = []
        if contains(.bold) { elements.append("bold") }
        if contains(.italic) { elements.append("italic") }
        if contains(.strikethrough) { elements.append("strikethrough") }
        if contains(.code) { elements.append("code") }
        if contains(.link) { elements.append("link") }
        return elements.joined(separator: ", ")
    }
}

internal extension Text {
    func apply(
        strong: StrongMarkdownStyle,
        emphasis: EmphasisMarkdownStyle,
        strikethrough: StrikethroughMarkdownStyle,
        link: InlineLinkMarkdownStyle,
        attributes: InlineAttributes
    ) -> Self {
        var text = self

        if attributes.contains(.bold) {
            text = strong.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.italic) {
            text = emphasis.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.strikethrough) {
            text = strikethrough.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.link) {
            text = link.makeBody(configuration: .init(content: text))
        }

        return text
    }
}
