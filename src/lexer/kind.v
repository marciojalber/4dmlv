module lexer

const string_char = '`'

pub enum TKind {
    // Basic
    t_unknown
    t_invalid
    t_ident
    t_comment
    t_collon
    t_range
    t_sep_items
    t_end_stmt

    // Signs
    t_sign_str
    t_sign_cmt_line
    
    // Values
    t_str
    t_str_raw
    t_bool
    t_num
    t_decimal
    
    // Scopes
    t_curly_open
    t_curly_close
    t_paren_open
    t_paren_close
    t_attrib_open
    t_bracket_open
    t_bracket_close

    // match
    t_plus
    t_minus
    t_mul
    t_div
    t_mod
    t_plus_plus
    t_minus_minus
    
    // sign
    t_assign
    t_assign_plus
    t_assign_minus
    t_assign_mul
    t_assign_div
    t_assign_mod

    // Keywords
    t_begin
    t_end
    t_object
    t_module
    t_var
    t_use
    t_as
    t_with
}

fn (self TKind) str() string {
    return match self {
        // Basic
        .t_unknown			{ 'T_UNKNOWN' 		}
        .t_invalid 			{ 'T_INVALID' 		}
        .t_ident 			{ 'T_IDENT' 		}
        .t_comment 			{ 'T_COMMENT' 		}
        .t_collon 			{ 'T_COLLON' 		}
        .t_range 			{ 'T_RANGE' 		}
        .t_sep_items      	{ 'T_SEP_ITEMS'     }
        .t_end_stmt      	{ 'T_END_STMT'      }

        // Signs
        .t_sign_str         { 'T_SIGN_STR'      }
        .t_sign_cmt_line    { 'T_SIGN_CMT_LINE' }
    
        // Values
        .t_str 				{ 'T_STR' 			}
        .t_str_raw 			{ 'T_STR_RAW' 		}
        .t_bool 			{ 'T_BOOL' 			}
        .t_num  			{ 'T_NUM' 			}
        .t_decimal			{ 'T_DECIMAL'		}
        
        // Scopes
        .t_curly_open 		{ 'T_CURLY_OPEN' 	}
        .t_curly_close 		{ 'T_CURLY_CLOSE' 	}
        .t_paren_open 		{ 'T_PAREN_OPEN'	}
        .t_paren_close 		{ 'T_PAREN_CLOSE' 	}
        .t_attrib_open   	{ 'T_ATTRIB_OPEN' 	}
        .t_bracket_open 	{ 'T_BRACKET_OPEN' 	}
        .t_bracket_close 	{ 'T_BRACKET_CLOSE' }

        // match
        .t_plus             { 'T_PLUS'          }
        .t_minus            { 'T_MINUS'         }
        .t_mul              { 'T_MUL'           }
        .t_div              { 'T_DIV'           }
        .t_mod              { 'T_MOD'           }
        .t_plus_plus        { 'T_PLUS_PLUS'     }
        .t_minus_minus      { 'T_MINUS_MINUS'   }
        
        // sign
        .t_assign             { 'T_ASSIGN'      }
        .t_assign_plus        { 'T_ASSIGN_PLUS' }
        .t_assign_minus       { 'T_ASSIGN_MINUS'}
        .t_assign_mul         { 'T_ASSIGN_MUL'  }
        .t_assign_div         { 'T_ASSIGN_DIV'  }
        .t_assign_mod         { 'T_ASSIGN_MOD'  }

        // Keywords
        .t_begin            { 'T_BEGIN'         }
        .t_end              { 'T_END'           }
        .t_object           { 'T_OBJECT'        }
        .t_module           { 'T_MODULE'        }
        .t_var              { 'T_VAR'           }
        .t_use              { 'T_USE'           }
        .t_as               { 'T_AS'            }
        .t_with             { 'T_WITH'          }
    }
}

struct KindGroup {
    pub:
        size    int
        group   []KindPattern
}

struct KindPattern {
    pub:
        pattern []rune
        kind    TKind
}

fn (self TKind) is_code_usefull() bool {
    return match self {
        .t_comment  { false }
        else        { true }
    }
}

fn TKind.group_by_size() []KindGroup {
    return [
        KindGroup{
            size: 2
            group: [
                // basic
                KindPattern{'..'.runes(), .t_range          }

                // Signs
                KindPattern{'//'.runes(), .t_sign_cmt_line  }

                // match
                KindPattern{'++'.runes(), .t_plus_plus      }
                KindPattern{'--'.runes(), .t_minus_minus    }

                // sign
                KindPattern{'+='.runes(), .t_assign_plus    }
                KindPattern{'-='.runes(), .t_assign_minus   }
                KindPattern{'*='.runes(), .t_assign_mul     }
                KindPattern{'*='.runes(), .t_assign_div     }
                KindPattern{'/='.runes(), .t_assign_mod     }
                KindPattern{'@['.runes(), .t_attrib_open    }
            ]
        }

        KindGroup{
            size: 1
            group: [
                // Basic
                KindPattern{':'.runes(), .t_collon           }
                KindPattern{','.runes(), .t_sep_items        }
                KindPattern{';'.runes(), .t_end_stmt         }

                // Signs
                KindPattern{'`'.runes(), .t_sign_str         }

                // Scopes
                KindPattern{'{'.runes(), .t_curly_open       }
                KindPattern{'}'.runes(), .t_curly_close      }
                KindPattern{'('.runes(), .t_paren_open       }
                KindPattern{')'.runes(), .t_paren_close      }
                KindPattern{'['.runes(), .t_bracket_open     }
                KindPattern{']'.runes(), .t_bracket_close    }

                // match
                KindPattern{'+'.runes(), .t_plus             }
                KindPattern{'*'.runes(), .t_mul              }
                KindPattern{'*'.runes(), .t_div              }
                KindPattern{'/'.runes(), .t_mod              }

                // sign
                KindPattern{'='.runes(),  .t_assign          }
            ]
        }
    ]
}

fn (self TKind) get_pattern() string {
    return match self {
        // basic
        .t_range            {'..'}
        .t_collon           {':'}

        // match
        .t_plus_plus        {'++'}
        .t_minus_minus      {'--'}

        // sign
        .t_assign_plus      {'+='}
        .t_assign_minus     {'-='}
        .t_assign_mul       {'*='}
        .t_assign_div       {'*='}
        .t_assign_mod       {'/='}
        .t_attrib_open      {'@['}

        // Scopes
        .t_curly_open       {'{'}
        .t_curly_close      {'}'}
        .t_paren_open       {'('}
        .t_paren_close      {')'}
        .t_bracket_open     {'['}
        .t_bracket_close    {']'}

        // match
        .t_plus             {'+'}
        .t_mul              {'*'}
        .t_div              {'*'}
        .t_mod              {'/'}
        else                {''}
    }
}

fn (self TKind) is_scope_closer() bool {
    return match self {
        .t_curly_close,
        .t_paren_close,
        .t_bracket_close { true }
        else { false }
    }
}

fn (self TKind) get_scope_closer_by_opener() ?TKind {
    return match self {
        .t_curly_open { .t_curly_close }
        .t_paren_open { .t_paren_close }
        .t_attrib_open { .t_bracket_close }
        .t_bracket_open { .t_bracket_close }
        else { none }
    }
}

fn TKind.get_keyword(val string, self TKind, kw_map map[string]TKind) TKind {
    for key, kw in kw_map {
        if val == key {
            return kw
        }
    }

    return self
}

fn (self TKind) is_one_of(kinds ...TKind) bool {
    for kind in kinds {
        if self == kind {
            return true
        }
    }

    return false
}
