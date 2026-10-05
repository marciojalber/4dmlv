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

    if self.token.val.len == 0 && self.token.kind == .t_unknown {
        self.process_first_char()
        return
    }

    self.process_continued_char()
}

fn (mut self TokenHandler) process_symbol() bool {
    mut is_symbol := false
    for kgroup in TKind.group_by_size() {
        add_pos := kgroup.size - 1
        if self.cursor + add_pos >= self.data.len {
            continue
        }

        seq := self.data[self.cursor..self.cursor+kgroup.size]
        for kptrn in kgroup.group {
            if kptrn.pattern != seq {
                continue
            }
            
            match kptrn.kind {
                .t_sign_str {
                    self.add_token(true)
                    self.cursor += kgroup.size
                    self.col    += kgroup.size
                    self.get_string()
                    return true
                }
                .t_sign_cmt_line {
                    self.add_token(true)
                    self.cursor += kgroup.size
                    self.col    += kgroup.size
                    self.get_comments()
                    return true
                }
                else {}
            }

            is_symbol = true
            self.add_token(true)
            self.token = TokenTmp{
                kind: kptrn.kind
                lin: self.lin
                col: self.col
                val: seq.string()
            }

            if closer := kptrn.kind.get_scope_closer_by_opener() {
                self.scopes_pending << self.tokens.len
                self.scopes_closers << closer
                self.scopes_indexes[self.tokens.len] = TokenHandlerScope{
                    pos: self.tokens.len
                    closer: false
                }
            } else if kptrn.kind.is_scope_closer() {
                if self.scopes_pending.len == 0 || kptrn.kind != self.scopes_closers.last() {
                    closer1 := self.scopes_closers.last().get_pattern()
                    closer2 := kptrn.pattern.string()
                    self.errors << TokenError{
                        lin: self.lin
                        col: self.col
                        msg: 'Expected `${closer1}`, not `${closer2}`.'
                    }
                } else {
                    self.scopes_pending.pop()
                    self.scopes_closers.pop()
                    self.scopes_indexes[self.tokens.len] = TokenHandlerScope{
                        pos: self.tokens.len
                        closer: true
                    }
                }
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

fn (mut self TokenHandler) process_first_char() {
    symbol := self.data[self.cursor]

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
}

fn (mut self TokenHandler) process_continued_char() {
    symbol := self.data[self.cursor]

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
