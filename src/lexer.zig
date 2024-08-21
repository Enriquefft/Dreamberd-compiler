const std = @import("std");

/// Represents the different types of tokens that can be identified in a mathematical expression.
pub const TokenType = enum {
    /// Represents a numeric value.
    Number,
    /// Represents the '+' operator.
    Plus,
    /// Represents the '-' operator.
    Minus,
    /// Represents the '*' operator.
    Multiply,
    /// Represents the '/' operator.
    Divide,
    /// Represents the '(' character.
    LeftParen,
    /// Represents the ')' character.
    RightParen,
    /// Represents the end of the input.
    EndOfFile,
    /// Represents an invalid or unrecognized token.
    Invalid,
};

/// A token with its type and optional value. Used by the parser to interpret the expression.
pub const Token = struct {
    kind: TokenType,
    value: ?f64 = null, // only used for numbers

    /// Formats the token for display.
    pub fn format(self: Token, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self.kind) {
            TokenType.Number => {
                if (self.value) |val| {
                    try writer.print("{any}", .{val});
                } else {
                    try writer.print("Invalid number", .{});
                }
            },
            TokenType.Plus => try writer.print("+", .{}),
            TokenType.Minus => try writer.print("-", .{}),
            TokenType.Multiply => try writer.print("*", .{}),
            TokenType.Divide => try writer.print("/", .{}),
            TokenType.LeftParen => try writer.print("(", .{}),
            TokenType.RightParen => try writer.print(")", .{}),
            TokenType.EndOfFile => try writer.print("EOF", .{}),
            TokenType.Invalid => try writer.print("Invalid token", .{}),
        }
    }
};

/// The `Lexer` structure processes a mathematical expression into a series of tokens.
pub const Lexer = struct {
    input: []const u8,
    current: usize = 0,

    /// Retrieves the next token from the input.
    ///
    /// # Returns
    /// A `Token` representing the next part of the expression.
    pub fn next_token(self: *Lexer) Token {
        // Skip any whitespace
        while (self.current < self.input.len and is_whitespace(self.input[self.current])) {
            self.current += 1;
        }

        if (self.current >= self.input.len) {
            return Token{ .kind = .EndOfFile };
        }

        const c = self.input[self.current];
        self.current += 1;

        // Match characters to their corresponding tokens
        switch (c) {
            '+' => return Token{ .kind = .Plus },
            '-' => return Token{ .kind = .Minus },
            '*' => return Token{ .kind = .Multiply },
            '/' => return Token{ .kind = .Divide },
            '(' => return Token{ .kind = .LeftParen },
            ')' => return Token{ .kind = .RightParen },
            else => {
                if (is_digit(c)) {
                    var number: f64 = 0;

                    number = @floatFromInt(c - '0');

                    // Process the complete number
                    while (self.current < self.input.len and is_digit(self.input[self.current])) {
                        number = number * 10 + @as(f64, @floatFromInt(self.input[self.current] - '0'));

                        self.current += 1;
                    }

                    return Token{ .kind = .Number, .value = number };
                } else {
                    return Token{ .kind = .Invalid };
                }
            },
        }
    }
};

/// Checks if a character is a digit.
///
/// # Parameters
/// - `c`: The character to check.
///
/// # Returns
/// `true` if the character is a digit, `false` otherwise.
fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}

/// Checks if a character is whitespace.
///
/// # Parameters
/// - `c`: The character to check.
///
/// # Returns
/// `true` if the character is a whitespace character, `false` otherwise.
fn is_whitespace(c: u8) bool {
    return c == ' ' or c == '\n' or c == '\t' or c == '\r';
}

test "lexer tokenizes basic mathematical expressions" {
    const input = "3 + 5 * (10 - 4) / 2";
    var lexer = Lexer{
        .input = input,
    };

    const tokens = [_]Token{
        Token{ .kind = .Number, .value = 3 },
        Token{ .kind = .Plus },
        Token{ .kind = .Number, .value = 5 },
        Token{ .kind = .Multiply },
        Token{ .kind = .LeftParen },
        Token{ .kind = .Number, .value = 10 },
        Token{ .kind = .Minus },
        Token{ .kind = .Number, .value = 4 },
        Token{ .kind = .RightParen },
        Token{ .kind = .Divide },
        Token{ .kind = .Number, .value = 2 },
        Token{ .kind = .EndOfFile },
    };

    var index: usize = 0;
    while (true) {
        const token = lexer.next_token();
        try std.testing.expectEqual(tokens[index].kind, token.kind);
        if (token.kind == .Number) {
            try std.testing.expectEqual(tokens[index].value.?, token.value.?);
        }
        if (token.kind == .EndOfFile) break;
        index += 1;
    }
}
