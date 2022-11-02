import ArgumentParser
import SwiftSyntax
import SwiftParser
import Foundation


@main
struct LearnSwiftSyntaxCommand: ParsableCommand {
    mutating func run() throws {
        // Still hardcoded
        let url = URL(fileURLWithPath: "/Users/ambar.septian/Documents/LearnSwiftSyntax/Sources/LearnSwiftSyntax/File.swift")
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
        
        let trivia = node.funcKeyword.leadingTrivia.pieces.map({ $0.debugDescription})



        if trivia.contains(where: { $0.contains("Perf")}) {
            if let _ = node.tokens(viewMode: .all).first(where: { $0.tokenKind == .leftBrace }) {
                var new = node

                let newLineToken = TokenSyntax(.stringLiteral(""), leadingTrivia: .newline, trailingTrivia: [], presence: .present)
                let performanceMethod = ExprSyntax(IdentifierExprSyntax(identifier: .identifier("Performance"), declNameArguments: nil))

               let callPerformanceMethod = FunctionCallExprSyntax(
                  calledExpression: ExprSyntax(performanceMethod),
                  leftParen: .leftParenToken(),
                  argumentList: TupleExprElementListSyntax([]),
                  rightParen: .rightParenToken(),
                  trailingClosure: nil,
                  additionalTrailingClosures: nil
                )

                var statements = new.body!.statements
                statements = statements.inserting(.init(item: .init(callPerformanceMethod), semicolon: nil, errorTokens: nil), at: 0)

                statements = statements.inserting(.init(item: .tokenList(.init([newLineToken])), semicolon: nil, errorTokens: nil),
                                     at: 0)

                let block = CodeBlockSyntax.init(leftBrace: new.body!.leftBrace, statements: statements, rightBrace: new.body!.rightBrace)
                new = new.withBody(block)
                return super.visit(new)
            }

        }


        return super.visit(node)

    }
}
