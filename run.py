#!/usr/bin/env python3

from vunit import VUnit

vu = VUnit.from_argv(compile_builtins=False)
vu.add_verilog_builtins()

lib = vu.add_library('lib')
lib.add_source_files('design/**/*.sv', include_dirs=['design/include'])
lib.add_source_files('verif/**/*.sv', include_dirs=['design/include', 'verif/include'])

vu.main()