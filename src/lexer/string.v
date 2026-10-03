module lexer

fn (mut self TokenHandler) get_string() {
	self.tick()
	self.token = TokenTmp{
		kind: .t_str
		lin: self.lin
		col: self.col
	}

	for self.cursor < self.data.len {
		symbol := self.data[self.cursor]
		match symbol.str() {
			'"' {
				self.tokens << self.token.token()
				self.token = TokenTmp{}
				self.tick()
				return
			}
			'\n' {
				self.lin++
				self.col = 0
				self.token.val += symbol
			}
			else {
				self.token.val += symbol
			}
		}
		self.tick()
	}

	self.add_token(false)
}
