import ArgumentParser
import SwiftSyntax
import SwiftParser
import Foundation

@main
struct LearnSwiftSyntaxCommand: ParsableCommand {
    mutating func run() throws {
        // Still hardcoded
        let url = URL(fileURLWithPath: "/Users/ichsan.wahyudi/IchsanIndraWahyudi/iOS/LearnSwiftSyntax/Sources/LearnSwiftSyntax/File.swift")
        let source = try String(contentsOf: url, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)
        let rewritten = ReadCommentSyntax().visit(sourceFile)
        let rewrittenString = rewritten.description

        do {
            try rewrittenString.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}


class ReadCommentSyntax: SyntaxRewriter {

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        
        let triviaPiece2 = node.funcKeyword.leadingTrivia
            .filter {
                guard case let .lineComment(comment) = $0 else { return false }
                return comment.contains("Perf")
            }

        if triviaPiece2.count == 0 {
            return super.visit(node)
        }
        
        var newNode = node
        
        let callPerformanceMethod = FunctionCallExprSyntax(
          calledExpression: ExprSyntax(
            IdentifierExprSyntax(
                identifier: .identifier("Measure"),
                declNameArguments: nil
            )
          ),
          leftParen: .leftParenToken(),
          argumentList: TupleExprElementListSyntax([]),
          rightParen: .rightParenToken(),
          trailingClosure: nil,
          additionalTrailingClosures: nil
        )

        var statements = newNode.body!.statements
        statements = statements.inserting(
            .init(
                item: .init(callPerformanceMethod.withLeadingTrivia(Trivia.spaces(4))),
                semicolon: nil,
                errorTokens: nil
            ),
            at: 0
        )
        
        let codeBlock = CodeBlockSyntax(
            leftBrace: newNode.body!.leftBrace,
            statements: statements,
            rightBrace: newNode.body!.rightBrace
        )

        newNode = newNode.withBody(codeBlock)

        return super.visit(newNode)
    }
}
