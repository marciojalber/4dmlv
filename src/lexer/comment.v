module lexer

fn (mut self TokenHandler) get_comments() {
	self.tick()
	self.token = TokenTmp{
		kind: TKind.t_comment
		lin: self.lin
		col: self.col
	}

	for self.cursor < self.data.len {
		symbol := self.data[self.cursor]
		match symbol.str() {
			'\r' {}
			'\n' {
				self.token.val = self.token.val.trim_space()
				self.tokens << self.token.token()
				self.lin++
				self.col = 1
				self.token = TokenTmp{}
				self.tick()
				return
			}
			else {
				self.token.val += symbol
			}
		}
		self.tick()
	}

	self.add_token(false)
}
