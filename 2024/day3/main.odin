package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"

Token :: enum{None, Mul, Do, Dont, LBracket, RBracket, Comma, Number, Eof}
TokenVal :: struct {
    tok: Token,
    val: int,
}

/// Day 3
///
/// P1: Tokenise a string looking for mul(x,y) and sum the multiplications
/// P2: As part 1 but Do and Don't commands toggle multiplication on and off
///
main :: proc() {
    start_time := time.now()
    data := os.read_entire_file("input.txt") or_else os.exit(1)
    defer delete(data)
    text := string(data)

    p1, p2 := run_multiplications(text)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

run_multiplications :: proc(text: string) -> (int, int) {
    sum1 := 0
    sum2 := 0

    tokens: [dynamic]TokenVal
    defer delete(tokens)

    head := 0
    tok_val := TokenVal{}
    for tok_val.tok != Token.Eof {
        tok_val, head = scan_token(text, head)
        append(&tokens, tok_val)
    }

    mul_enabled_multiplier := 1
    for t, i in tokens {
        if t.tok == Token.Do {
            mul_enabled_multiplier = 1
        }
        else if t.tok == Token.Dont {
            mul_enabled_multiplier = 0
        }
        else if i < len(tokens) - 5 && t.tok == Token.Mul {
            if tokens[i+1].tok == Token.LBracket && tokens[i+2].tok == Token.Number && tokens[i+3].tok == Token.Comma && tokens[i+4].tok == Token.Number && tokens[i+5].tok == Token.RBracket {
                product := tokens[i+2].val * tokens[i+4].val 
                sum1 += product
                sum2 += product * mul_enabled_multiplier
            }
        }
    }

    return sum1, sum2
}

scan_token :: proc(text: string, i:  int) -> (TokenVal, int) {
    i := i
    l := len(text)
    for i < l {
        if i < l-3 && text[i:i+3] == "mul" {
            return {Token.Mul, 0}, i + 3
        }

        if i < l-4 && text[i:i+4] == "do()" {
            return {Token.Do, 0}, i + 4
        }

        if i < l-7 && text[i:i+7] == "don't()" {
            return {Token.Dont, 0}, i + 7
        }

        if text[i] == '(' {
            return {Token.LBracket, 0}, i + 1
        }

        if text[i] == ')' {
            return {Token.RBracket, 0}, i + 1
        }

        if text[i] == ',' {
            return {Token.Comma, 0}, i + 1
        }

        if text[i] >= '0' && text[i] <= '9' {
            num, h := parse_number(text, i)
            return {Token.Number, num}, h
        }

        return {Token.None, 0}, i + 1 //TODO: don't emit a none token for each char, group them all together
    }

    return {Token.Eof, 0}, i
}

parse_number :: proc(text: string, i: int) -> (int, int) {
    j := i
    for text[j] >= '0' && text[j] <= '9' {
        j += 1
    }

    return strconv.atoi(text[i:j]), j
}
