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
			lin: 	lin
			col: 	col
			kind: 	TKind.t_unknown
			ignore: false
		}
		kw_map: kw_map
	}
}

pub fn (mut self TokenHandler) parse() {
	for self.cursor < self.data.len {
		charac := self.data[self.cursor].str()
		match charac {
			' ', '\r' {
				self.add_token(true)
				self.tick()
			}
			'\n' {
				self.add_token(true)
				self.tick()
				self.lin++
				self.col = 1
			}
			else {
				self.evaluate_char()
			}
		}
	}

	self.add_token(true)
	// handler.get_statements()
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

/*
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
			.t_sign_mul,
			.t_sign_div,
			.t_sign_mod,

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
*/

const c_pink   = "\033[38;5;218m"
const c_purple = "\033[35m"
const c_red    = "\033[38;2;255;50;0m"
const c_orange = "\033[38;2;255;200;0m"
const c_blue   = "\033[94m"
const c_green  = "\033[92m"
const c_grey   = "\033[38;2;75;75;75m"
const c_normal = "\033[0m"

const s_bold  = "\033[1m"
const s_under = "\033[4m"

pub fn (self TokenHandler) str() string {
	mut res := "TokenHandler[${self.tokens.len} tokens]{\n"
	res += "\nTOKENS (${self.tokens.len}):\n\n"
	res += "    LIN:COL   IGN TOKEN           SCOPE VALUE\n"
	res += "----------------------------------------------------------------------\n"
	for i, tk in self.tokens {
		mut clr1 := ''
		mut clr2 := ''
		mut val := tk.val.replace('\r', '').replace('\n', '↵')
		if val.len > 30 {
			val = val[..28]+"..."
		}
		mut scope := '     '
		if i in self.scopes_indexes {
			if !self.scopes_indexes[i].closer {
				clr1 	= c_green
				scope 	= '  +  '
			} else {
				clr1 	= c_orange
				scope 	= '  -  '
			}
			clr2 = c_normal
		}
		mut ign := '   '
		if tk.ignore {
			ign  = 'Yes'
			clr1 = c_grey
			clr2 = c_normal
		}
		match tk.kind {
			.t_num, .t_decimal, .t_str, .t_str_raw {
				clr1 = c_purple
				clr2 = c_normal
			}
			else {}
		}
		res += clr1+'  ${tk.lin:5}:${tk.col:-5} ${ign} ${tk.kind.str():-15} ${scope} ${val}\n'+clr2
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
