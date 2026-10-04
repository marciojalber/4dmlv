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
	kw_map 			map[string]TKind
}

pub fn TokenHandler.new(fname string, kw_map map[string]TKind) &TokenHandler {
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
		kw_map: kw_map
	}
}

pub fn (mut self TokenHandler) parse() {
	for self.cursor < self.data.len {
		charac := self.data[self.cursor].str()
		match charac {
			string_char {
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
			self.kw_map
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
	res += "    LIN:COL   TOKEN           VALUE\n"
	res += "-----------------------------------\n"
	for tk in self.tokens {
		mut val := tk.val.replace('\r', '').replace('\n', '↵')
		if val.len > 30 {
			val = val[..27]+"..."
		}
		res += '  ${tk.lin:5}:${tk.col:-5} ${tk.kind.str():-15} ${val}\n'
	}
	res += "}"
	return res
}
