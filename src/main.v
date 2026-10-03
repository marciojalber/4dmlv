module main

import lexer

fn main() {
	fname := "examples/curso.4dml"
	handler := lexer.TokenHandler.new(fname)
	handler.parse()
	println(handler)
}
