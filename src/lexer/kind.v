module lexer

pub enum TKind {
    // Basic
    t_unknown
    t_invalid
    t_ident
    t_comment
    t_collon
    t_range
    t_attrib
    t_finish_stmt

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
    t_sign
    t_sign_plus
    t_sign_minus
    t_sign_mul
    t_sign_div
    t_sign_mod

    // Keywords
    t_begin
    t_end
    t_object
}

fn (self TKind) str() string {
    return match self {
        // Basic
        .t_unknown			{ 't_unknown' 		}
        .t_invalid 			{ 't_invalid' 		}
        .t_ident 			{ 't_ident' 		}
        .t_comment 			{ 't_comment' 		}
        .t_collon 			{ 't_collon' 		}
        .t_range 			{ 't_range' 		}
        .t_attrib       	{ 't_attrib' 	    }
        .t_finish_stmt   	{ 't_finish_stmt'   }
    
        // Values
        .t_str 				{ 't_str' 			}
        .t_str_raw 			{ 't_str_raw' 		}
        .t_bool 			{ 't_bool' 			}
        .t_num  			{ 't_num' 			}
        .t_decimal			{ 't_decimal'		}
        
        // Scopes
        .t_curly_open 		{ 't_curly_open' 	}
        .t_curly_close 		{ 't_curly_close' 	}
        .t_paren_open 		{ 't_paren_open'	}
        .t_paren_close 		{ 't_paren_close' 	}
        .t_bracket_open 	{ 't_bracket_open' 	}
        .t_bracket_close 	{ 't_bracket_close' }

        // match
        .t_plus             { 't_plus'          }
        .t_minus            { 't_minus'         }
        .t_mul              { 't_mul'           }
        .t_div              { 't_div'           }
        .t_mod              { 't_mod'           }
        .t_plus_plus        { 't_plus_plus'     }
        .t_minus_minus      { 't_minus_minus'   }
        
        // sign
        .t_sign             { 't_sign'          }
        .t_sign_plus        { 't_sign_plus'     }
        .t_sign_minus       { 't_sign_minus'    }
        .t_sign_mul         { 't_sign_mul'      }
        .t_sign_div         { 't_sign_div'      }
        .t_sign_mod         { 't_sign_mod'      }

        // Keywords
        .t_begin         	{ 't_begin' 	    }
        .t_end          	{ 't_end'           }
        .t_object        	{ 't_object'        }
    }
}

fn TKind.get_keyword(val string, cur_kind TKind) TKind {
    return match val {
        'ini'       { .t_begin  }
        'fim'       { .t_end    }
        'obj'       { .t_object }
        else        { cur_kind  }
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

fn TKind.group_by_size() []KindGroup {
    return [
        KindGroup{
            size: 2
            group: [
                // basic
                KindPattern{'..'.runes(), .t_range           }

                // match
                KindPattern{'++'.runes(), .t_plus_plus       }
                KindPattern{'--'.runes(), .t_minus_minus     }

                // sign
                KindPattern{'+='.runes(), .t_sign_plus       }
                KindPattern{'-='.runes(), .t_sign_minus      }
                KindPattern{'*='.runes(), .t_sign_mul        }
                KindPattern{'*='.runes(), .t_sign_div        }
                KindPattern{'/='.runes(), .t_sign_mod        }
            ]
        }

        KindGroup{
            size: 1
            group: [
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
                KindPattern{'='.runes(),  .t_sign            }
            ]
        }
    ]
}

fn (self TKind) is_one_of(kinds ...TKind) bool {
    for kind in kinds {
        if self == kind {
            return true
        }
    }

    return false
}
