module lexer

import os

struct TokenHandlerScope {
	pos 	int
	closer  bool
}

struct TokenError {
	lin int
	col int
	msg string
}

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
	scopes_pending 	[]int
	scopes_closers 	[]TKind
	scopes_indexes 	map[int]TokenHandlerScope
	errors 			[]TokenError
	statements		[][]int
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

fn (mut self TokenHandler) tick() {
	self.cursor++
	self.col++
}

// @todo To revise
pub fn (mut self TokenHandler) get_statements() {
	if self.errors.len != 0 { return }

	mut statement := []int{}
	for i, tk in self.tokens {
		match tk.kind {
			.t_collon {
				if statement.len == 0 {
					self.errors << TokenError {
						col: self.col
						lin: self.lin
						msg: 'No instruction on the statmenet before `${tk.kind.get_pattern()}`.'
					}
				}
				statement << i
				self.statements << statement
				statement = []int{}
			}

			.t_sign,
			.t_sign_plus,
			.t_sign_minus,
			.t_sign_minus,

			.t_sep_items,
			.t_paren_open,
			.t_paren_close,
			.t_attrib_open,
			.t_bracket_open,
			.t_bracket_close,
			.t_curly_open,
			.t_curly_close {
				if statement.len != 0 {
					self.statements << statement
					statement = []int{}
				}
				statement << i
				self.statements << statement
				statement = []int{}
			}

			.t_end_stmt {
				if statement.len != 0 {
					self.statements << statement
					statement = []int{}
				}
			}

			else {
				statement << i
			}
		}
	}

	if statement.len != 0 {
		self.statements << statement
	}
}

pub fn (self TokenHandler) str() string {
	mut res := "TokenHandler[${self.tokens.len} tokens]{\n"
	res += "\nTOKENS (${self.tokens.len}):\n\n"
	res += "    LIN:COL   TOKEN           SCOPE VALUE\n"
	res += "-----------------------------------------\n"
	for i, tk in self.tokens {
		mut val := tk.val.replace('\r', '').replace('\n', '↵')
		if val.len > 30 {
			val = val[..27]+"..."
		}
		mut scope := '     '
		if i in self.scopes_indexes {
			if !self.scopes_indexes[i].closer {
				scope = '  +  '
			} else {
				scope = '  -  '
			}
		}
		res += '  ${tk.lin:5}:${tk.col:-5} ${tk.kind.str():-15} ${scope} ${val}\n'
	}

	if self.errors.len != 0 {
		res += "\nERRORS (${self.errors.len}):\n\n"
		res += "    LIN:COL   MESSAGE\n"
		res += "---------------------\n"
		for err in self.errors {
			res += '  ${err.lin:5}:${err.col:-5} ${err.msg}\n'
		}
		res += "}"
		return res
	}

	res += "\n[NO ERRORS]\n"
	res += "\nSTATEMENTS:\n"
	for stmt in self.statements {
		for i in stmt {
			res += ' ${i}'
		}
		res += '\n'
	}
	res += "}"

	return res
}
