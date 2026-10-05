module main

import lexer

fn main() {
	fname := "examples/curso_dados.4dml"
	kw_map 	:= {
		'ini': 		lexer.TKind.t_begin
		'fim': 		lexer.TKind.t_end
		'obj': 		lexer.TKind.t_object
		'MODULO': 	lexer.TKind.t_module
		'var': 		lexer.TKind.t_var
		'use': 		lexer.TKind.t_use
		'como': 	lexer.TKind.t_as
		'com': 		lexer.TKind.t_with
	}
	handler := lexer.TokenHandler.new(fname, kw_map)
	handler.parse()
	handler.get_statements()
	println(handler)
}
