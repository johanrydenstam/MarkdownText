import SwiftUI
import Markdown

struct MarkdownTextBuilder: MarkupWalker {
    enum ListItemType {
        case unordered
        case ordered
    }

    var isNested: Bool = false
    var nestedBlockElements: [MarkdownElement] = []
    var inlineElements: [Component] = []
    var blockElements: [MarkdownElement] = []
    var listStack: [ListItemType] = []

    init(document: Document) {
        visit(document)
    }

    mutating func visitHeading(_ markdown: Heading) {
        descendInto(markdown)
        blockElements.append(.header(.init(level: markdown.level, inline: .init(components: inlineElements))))
        inlineElements = []
    }

    mutating func visitText(_ markdown: Markdown.Text) {
        var attributes: InlineAttributes = []
        var parent = markdown.parent
        var text = markdown.string

        while parent != nil {
            defer { parent = parent?.parent }

            if parent is Strong {
                attributes.insert(.bold)
            }

            if parent is Emphasis {
                attributes.insert(.italic)
            }

            if parent is Strikethrough {
                attributes.insert(.strikethrough)
            }

            if parent is InlineCode {
                attributes.insert(.code)
            }

            if let link = parent as? Markdown.Link {
                #warning("todo: Links")
                /*
                 One idea here could be to collect links like footnotes, reference them in the rendered result as such (at least by default) and then add actual buttons to the bottom of the rendered output?
                 */
                attributes.insert(.link)
                text = link.plainText //+ (link.destination.flatMap { " [\($0)]" } ?? "")
            }
        }

        inlineElements.append(.init(text: .init(text), attributes: attributes))
    }

    mutating func visitParagraph(_ markdown: Paragraph) {
        descendInto(markdown)

        if let listItem = markdown.parent as? ListItem {
//            switch listStack.last {
//            case .ordered:
//                blockElements.append(.orderedListItem(.init(
//                    level: listStack.count - 1,
//                    bullet: .init(order: listItem.indexInParent + 1),
//                    paragraph: .init(inline: .init(components: inlineElements))))
//                )
//            default:
//                if let checkbox = listItem.checkbox {
//                    blockElements.append(.checklistItem(.init(
//                        level: listStack.count - 1,
//                        bullet: .init(isChecked: checkbox == .checked),
//                        paragraph: .init(inline: .init(components: inlineElements))))
//                    )
//                } else {
//                    blockElements.append(.unorderedListItem(.init(
//                        level: listStack.count - 1,
//                        bullet: .init(),
//                        paragraph: .init(inline: .init(components: inlineElements))))
//                    )
//                }
//            }
        } else {
            if isNested {
                nestedBlockElements.append(.paragraph(.init(inline: .init(components: inlineElements))))
            } else {
                blockElements.append(.paragraph(.init(inline: .init(components: inlineElements))))
            }
        }

        inlineElements = []
    }

    mutating func visitImage(_ markdown: Markdown.Image) {
        blockElements.append(.image(.init(source: markdown.source, title: markdown.title)))
    }

    mutating func visitLink(_ markdown: Markdown.Link) {
        descendInto(markdown)
    }

    mutating func visitStrong(_ markdown: Strong) {
        descendInto(markdown)
    }

    mutating func visitEmphasis(_ markdown: Emphasis) {
        descendInto(markdown)
    }

    mutating func visitInlineCode(_ markdown: InlineCode) {
        inlineElements.append(.init(text: .init(markdown.code), attributes: .code))
    }

    mutating func visitStrikethrough(_ markdown: Strikethrough) {
        descendInto(markdown)
    }

    mutating func visitCodeBlock(_ markdown: CodeBlock) {
        blockElements.append(.code(.init(code: markdown.code, language: markdown.language)))
        inlineElements = []
    }

    mutating func visitSoftBreak(_ markdown: SoftBreak) {
        visitText(.init(markdown.plainText))
    }

    mutating func visitThematicBreak(_ markdown: ThematicBreak) {
        blockElements.append(.thematicBreak(.init()))
        descendInto(markdown)
    }

    mutating func visitOrderedList(_ markdown: OrderedList) {
        listStack.append(.ordered)
        descendInto(markdown)
        listStack.removeLast()
    }

    mutating func visitUnorderedList(_ markdown: UnorderedList) {
        listStack.append(.unordered)
        descendInto(markdown)
        listStack.removeLast()
    }

    mutating func visitListItem(_ markdown: Markdown.ListItem) {
        descendInto(markdown)
    }

    mutating func visitBlockQuote(_ markdown: BlockQuote) {
        isNested = true
        descendInto(markdown)

        for element in nestedBlockElements {
            if case let .paragraph(config) = element {
                blockElements.append(.quote(.init(paragraph: config)))
            }
        }

        inlineElements = []
        nestedBlockElements = []
        isNested = false
    }

    mutating func visitInlineHTML(_ markdown: InlineHTML) {
        #warning("TBD")
    }

    mutating func visitTable(_ markdown: Markdown.Table) {
        #warning("TBD")
    }

    mutating func visitTableRow(_ markdown: Markdown.Table.Row) {
        #warning("TBD")
    }

    mutating func visitTableBody(_ tableBody: Markdown.Table.Body) {
        #warning("TBD")
    }

    mutating func visitTableCell(_ tableCell: Markdown.Table.Cell) {
        #warning("TBD")
    }

    mutating func visitTableHead(_ tableHead: Markdown.Table.Head) {
        #warning("TBD")
    }

    mutating func visitSymbolLink(_ markdown: SymbolLink) { }
    mutating func visitBlockDirective(_ markdown: BlockDirective) { }
    mutating func visitCustomInline(_ customInline: CustomInline) { }
}
