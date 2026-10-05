module lexer

struct TokenTmp {
pub mut:
    lin     int
    col     int
    kind    TKind
    ignore  bool
    val     string
}

fn (self TokenTmp) token() Token {
    return Token{
        lin:    self.lin
        col:    self.col
        kind:   self.kind
        ignore: self.ignore
        val:    self.val
    }
}

struct Token {
pub:
    lin     int
    col     int
    kind    TKind
    ignore  bool
    val     string
}
