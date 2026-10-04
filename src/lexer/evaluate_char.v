module lexer

fn (mut self TokenHandler) evaluate_char() {
    // Update the begin of the token
    if self.token.val.len == 0 && self.token.kind == TKind.t_unknown {
        self.token.lin = self.lin
        self.token.col = self.col
    }

    if self.process_symbol() {
        return
    }

    symbol := self.data[self.cursor]

    // Get the kind when is the first char
    if self.token.val.len == 0 && self.token.kind == .t_unknown {
        match symbol {
            `-` {
                self.token.val += symbol
                if self.cursor + 1 < self.data.len &&
                    self.data[self.cursor + 1] >= `0` &&
                    self.data[self.cursor + 1] <= `9`{
                    self.token.kind = .t_num
                } else {
                    self.token.kind = .t_minus
                    self.add_token(true)
                }
            }

            `0` {
                self.token.kind = .t_num
            }

            `1`...`9` {
                self.token.kind = .t_num
                self.token.val += symbol
            }

            `A`...`Z`, `a`...`z`, `_` {
                self.token.kind = .t_ident
                self.token.val += symbol
            }

            else {
                self.token.kind = .t_invalid
                self.token.val += symbol
            }
        }

        self.tick()
        return
    }

    // Get the conmtinuation of the tokens
    match self.token.kind {
        .t_num {
            if symbol == `_` {
                self.tick()
                return
            }

            if symbol == `.` {
                self.token.kind = .t_decimal
                self.token.val += symbol
                self.tick()
                return
            }
        }
        else {}
    }

    self.token.val += symbol
    self.tick()
}

fn (mut self TokenHandler) process_symbol() bool {
    mut is_symbol := false
    for kgroup in TKind.group_by_size() {
        add_pos := kgroup.size - 1
        if self.cursor + add_pos >= self.data.len {
            continue
        }

        seq := self.data[self.cursor..self.cursor+kgroup.size]
        for kpattern in kgroup.group {
            if kpattern.pattern != seq {
                continue
            }
            
            is_symbol = true
            self.add_token(true)
            self.token = TokenTmp{
                kind: kpattern.kind
                lin: self.lin
                col: self.col
                val: seq.string()
            }
            self.add_token(true)
            self.cursor += add_pos
            break
        }
    }

    if is_symbol {
        self.tick()
        return true
    }

    return false
}