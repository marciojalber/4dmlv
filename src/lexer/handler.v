module lexer

import os

struct TokenHandler {
	data 	[]rune

mut:
	cursor 			int
	lin 			int
	col 			int
	stmt_finished 	bool
	token 			TokenTmp
	tokens 			[]Token
}

pub fn TokenHandler.new(fname string) &TokenHandler {
	data := os.read_file(fname) or {
		eprintln('\n${@FILE}:${@LINE} - file ${fname} not found.')
		exit(1)
	}

	lin := 1
	col := 1

	return &TokenHandler{
		data: data.runes()
		lin: lin
		col: col
		stmt_finished: true
		token: TokenTmp{
			kind: TKind.t_unknown
			lin: lin
			col: col
		}
	}
}

pub fn (mut self TokenHandler) parse() {
	for self.cursor < self.data.len {
		symbol := self.data[self.cursor].str()
		match symbol {
			'"' {
				self.add_token(true)
				self.get_string()
			}
			'#' {
				self.add_token(true)
				self.get_comments()
			}
			'\r' {
				self.add_token(true)
				self.add_finish_stmt_token()
				self.tick()
			}
			',' {
				self.add_token(true)
				self.add_finish_stmt_token()
				self.tick()
			}
			'\n' {
				self.add_token(true)
				self.tick()
				self.lin++
				self.col = 1
			}
			' ' {
				self.add_token(true)
				self.tick()
			}
			else {
				self.evaluate_char()
			}
		}
	}

	self.add_token(true)
}

fn (mut self TokenHandler) add_token(finish_stmt bool) {
	// if self.token.val.len == 0 { return }
	if self.token.kind == .t_unknown { return }
	
	if self.token.kind == .t_ident {
		self.token.kind = TKind.get_keyword(
			self.token.val
			self.token.kind
		)
	}

	self.tokens << self.token.token()
	self.token = TokenTmp{}
	
	if finish_stmt {
		self.stmt_finished = false
	}
}

fn (mut self TokenHandler) add_finish_stmt_token() {
	if self.stmt_finished { return }
	self.stmt_finished = true
	self.token = TokenTmp{
		kind: .t_finish_stmt
		lin: self.lin
		col: self.col
	}
	self.add_token(false)
}

fn (mut self TokenHandler) tick() {
	self.cursor++
	self.col++
}

pub fn (self TokenHandler) str() string {
	mut res := "TokenHandler[${self.tokens.len} tokens]{\n"
	for tk in self.tokens {
		// if tk.kind != .t_unkown { continue }
		res += '  ${tk.lin}:${tk.col} - ${tk.kind.str()}: ${tk.val}\n'
	}
	/*
	for tk in self.tokens {
		if tk.kind == .t_unkown { continue }
		res += '  ${tk.lin}:${tk.col} - ${tk.kind.str()}: ${tk.val}\n'
	}
	*/
	res += "}"
	return res
}
