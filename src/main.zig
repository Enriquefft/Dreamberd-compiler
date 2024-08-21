const std = @import("std");
const Parser = @import("parser.zig").Parser;
const Lexer = @import("lexer.zig").Lexer;

pub fn main() void {
    const input = "3 + 5 * (10 - 4) / 2";

    var lexer = Lexer{ .input = input };

    var parser = Parser{ .lexer = &lexer, .current_token = lexer.next_token() };

    const result = parser.parse();

    std.debug.print("Input: {s}\n", .{input});
    std.debug.print("Result: {}\n", .{result});
}
