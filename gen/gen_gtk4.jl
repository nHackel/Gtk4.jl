using GI

toplevel, exprs, exports = GI.output_exprs()

path="../src/gen"

ns = GINamespace(:Gtk,"4.0")
d = readxml("/usr/share/gir-1.0/$(GI.ns_id(ns)).gir")

## constants, enums, and flags, put in a "Constants" submodule

const_mod = Expr(:block)

const_exports = Expr(:export)

c = GI.all_const_exprs!(const_mod, const_exports, ns; skiplist= [:CssParserError,:CssParserWarning])
GI.append_const_docs!(const_mod.args, "gtk4", d, c)
push!(const_mod.args, const_exports)

push!(exprs, const_mod)

## export constants, enums, and flags code
GI.write_to_file(path,"gtk4_consts",toplevel)

## structs

toplevel, exprs, exports = GI.output_exprs()

# These are marked as "disguised" and what this means is not documentated AFAICT.
disguised = Symbol[]
struct_skiplist=vcat(disguised, [:PageRange])

GI.struct_cache_expr!(exprs)
struct_skiplist,c = GI.all_struct_exprs!(exprs,exports,ns;excludelist=struct_skiplist,import_as_opaque=[:BitsetIter,:BuildableParser],output_cache_init=false)
GI.append_struc_docs!(exprs, "gtk4", d, c, ns)

## objects

object_skiplist=[:CClosureExpression,:ClosureExpression,:ConstantExpression,:ObjectExpression,:PropertyExpression,:ParamSpecExpression,:PrintUnixDialog,:PageSetupUnixDialog]

c = GI.all_objects!(exprs,exports,ns,skiplist=object_skiplist,output_cache_define=false,output_cache_init=false)
GI.append_object_docs!(exprs, "gtk4", d, c, ns)
GI.all_interfaces!(exprs,exports,ns)

push!(exprs,exports)

GI.write_to_file(path,"gtk4_structs",toplevel)

## struct methods

toplevel, exprs, exports = GI.output_exprs()

GI.all_struct_methods!(exprs,ns,struct_skiplist=vcat(struct_skiplist,[:Bitset,:BitsetIter,:BuildableParseContext,:CssSection,:TextIter]);print_detailed=true)

## object methods

skiplist=[:create_closure,:activate_cell,:event,:start_editing,:filter_keypress,:trigger,:append_node,:im_context_filter_keypress,:get_backlog,:append_border,:append_inset_shadow,:append_outset_shadow,:push_rounded_clip,:get,:get_default,:get_for_display]

object_skiplist=vcat(object_skiplist,[:BoolFilter,:CellRenderer,:MnemonicAction,:NeverTrigger,:NothingAction,:NumericSorter,:PrintJob,:PrintSettings,:RecentManager,:StringFilter,:StringSorter,:ShortcutAction,:ShortcutTrigger])

# skips are to avoid method name collisions
GI.all_object_methods!(exprs,ns;skiplist=skiplist,object_skiplist=object_skiplist)

skiplist=[:start_editing,:install_properties]
# skips are to avoid method name collisions
GI.all_interface_methods!(exprs,ns;skiplist=skiplist,interface_skiplist=[:PrintOperationPreview])

GI.write_to_file(path,"gtk4_methods",toplevel)

## functions

toplevel, exprs, exports = GI.output_exprs()

skiplist=[:editable_install_properties,:value_set_expression,:value_take_expression]

GI.all_functions!(exprs,ns,skiplist=skiplist)

GI.write_to_file(path,"gtk4_functions",toplevel)
