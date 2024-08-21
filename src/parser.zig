const std = @import("std");
const TokenType = @import("lexer.zig").TokenType;
const Token = @import("lexer.zig").Token;
const Lexer = @import("lexer.zig").Lexer;

/// The `Parser` structure processes tokens into an evaluated result.
///
/// The parser uses a recursive descent method to handle the grammar of basic
/// arithmetic expressions.
pub const Parser = struct {
    lexer: *Lexer,
    current_token: Token,

    /// Advances to the next token in the input stream.
    fn advance(self: *Parser) void {
        self.current_token = self.lexer.next_token();
    }

    /// Parses the expression and evaluates it.
    ///
    /// # Returns
    /// The result of the evaluated mathematical expression as a `f64`.
    pub fn parse(self: *Parser) f64 {
        return self.parse_expression();
    }

    /// Parses and evaluates an expression, which may consist of one or more terms
    /// combined by `+` or `-` operators.
    ///
    /// # Returns
    /// The result of the evaluated expression.
    fn parse_expression(self: *Parser) f64 {
        var result = self.parse_term();

        // Handle addition and subtraction operators
        while (self.current_token.kind == .Plus or self.current_token.kind == .Minus) {
            const token = self.current_token;
            self.advance();

            if (token.kind == .Plus) {
                result += self.parse_term();
            } else if (token.kind == .Minus) {
                result -= self.parse_term();
            }
        }

        return result;
    }

    /// Parses and evaluates a term, which may consist of one or more factors
    /// combined by `*` or `/` operators.
    ///
    /// # Returns
    /// The result of the evaluated term.
    fn parse_term(self: *Parser) f64 {
        var result = self.parse_factor();

        // Handle multiplication and division operators
        while (self.current_token.kind == .Multiply or self.current_token.kind == .Divide) {
            const token = self.current_token;
            self.advance();

            if (token.kind == .Multiply) {
                result *= self.parse_factor();
            } else if (token.kind == .Divide) {
                result /= self.parse_factor();
            }
        }

        return result;
    }

    /// Parses and evaluates a factor, which is the most basic unit of an expression,
    /// such as a number or a parenthesized sub-expression.
    ///
    /// # Returns
    /// The result of the evaluated factor.
    fn parse_factor(self: *Parser) f64 {
        const token = self.current_token;
        self.advance();

        switch (token.kind) {
            .Number => return token.value.?,
            .LeftParen => {
                const result = self.parse_expression();
                if (self.current_token.kind != .RightParen) {
                    std.debug.print("Expected ')'", .{});
                }
                self.advance();
                return result;
            },
            else => {
                std.debug.print("Unexpected token: {s}\n", .{token});
                return 0.0;
            },
        }
    }
};

test "parser evaluates simple expressions" {
    try test_parser("3 + 5", 8.0);
    try test_parser("10 - 4", 6.0);
    try test_parser("7 * 2", 14.0);
    try test_parser("20 / 4", 5.0);
}

test "parser handles operator precedence" {
    try test_parser("3 + 5 * 2", 13.0); // 5 * 2 + 3 = 13
    try test_parser("10 - 4 / 2", 8.0); // 4 / 2 = 2; 10 - 2 = 8
    try test_parser("(3 + 5) * 2", 16.0); // (3 + 5) = 8; 8 * 2 = 16
    try test_parser("20 / (4 + 1)", 4.0); // 4 + 1 = 5; 20 / 5 = 4
}

test "parser evaluates nested expressions" {
    try test_parser("(3 + (5 * 2))", 13.0); // 5 * 2 = 10; 3 + 10 = 13
    try test_parser("((10 - 4) * 2)", 12.0); // 10 - 4 = 6; 6 * 2 = 12
    try test_parser("((20 / 4) + 5)", 10.0); // 20 / 4 = 5; 5 + 5 = 10
}

fn test_parser(input: []const u8, expected: f64) !void {
    var lexer = Lexer{
        .input = input,
    };

    var parser = Parser{ .lexer = &lexer, .current_token = lexer.next_token() };
    const result = parser.parse();

    try std.testing.expectEqual(expected, result);
}
