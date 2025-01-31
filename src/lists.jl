## GtkComboBox

GtkComboBox() = G_.ComboBox_new()

setindex!(f::GtkComboBox, w::Union{Nothing,GtkWidget}) = G_.set_child(f,w)
getindex(f::GtkComboBox) = G_.get_child(f)

GtkComboBoxText(with_entry::Bool = false) =
        if with_entry
            G_.ComboBoxText_new_with_entry()
        else
            G_.ComboBoxText_new()
        end
push!(cb::GtkComboBoxText, text::AbstractString) = (G_.append_text(cb, text); cb)
pushfirst!(cb::GtkComboBoxText, text::AbstractString) = (G_.prepend_text(cb, text); cb)
insert!(cb::GtkComboBoxText, i::Integer, text::AbstractString) = (G_.insert_text(cb, i - 1, text); cb)

push!(cb::GtkComboBoxText, id::Union{AbstractString, Symbol}, text::AbstractString) = (G_.append(cb, id, text); cb)
pushfirst!(cb::GtkComboBoxText, id::Union{AbstractString, Symbol}, text::AbstractString) = (G_.prepend(cb, id, text); cb)
insert!(cb::GtkComboBoxText, i::Integer, id::Union{AbstractString, Symbol}, text::AbstractString) = (G_.insert(cb, i - 1, id, text); cb)

empty!(cb::GtkComboBoxText) = (G_.remove_all(cb); cb)

delete!(cb::GtkComboBoxText, i::Integer) = (G_.remove(cb, i-1); cb)

## GtkStringList

GtkStringList(list = nothing) = G_.StringList_new(list)
push!(sl::GtkStringList, str) = (G_.append(sl, str); sl)
length(sl::GtkStringList) = length(GListModel(sl))
getindex(sl::GtkStringList, i::Integer) = G_.get_string(sl, i - 1)
eltype(::Type{GtkStringList}) = String

## GtkDropdown

GtkDropDown(model=nothing) = G_.DropDown_new(model, nothing)
GtkDropDown(a::Vector{String}) = G_.DropDown_new_from_strings(a)
GtkDropDown(a::AbstractArray) = GtkDropDown(string.(collect(a)))
selected_string(d::GtkDropDown) = G_.get_selected_item(d).string

## GtkListView and GtkGridView

GtkListView(model=nothing, factory=nothing) = G_.ListView_new(model, factory)
GtkGridView(model=nothing, factory=nothing) = G_.GridView_new(model, factory)

GtkColumnView(model=nothing) = G_.ColumnView_new(model)
GtkColumnViewColumn(title="", factory=nothing) = G_.ColumnViewColumn_new(title, factory)

GtkSignalListItemFactory() = G_.SignalListItemFactory_new()
GtkSingleSelection(model) = G_.SingleSelection_new(model)
GtkMultiSelection(model) = G_.MultiSelection_new(model)

getindex(li::GtkListItem) = G_.get_item(li)
set_child(li::GtkListItem, w) = G_.set_child(li, w)
get_child(li::GtkListItem) = G_.get_child(li)

GtkTreeExpander() = G_.TreeExpander_new()
set_list_row(te::GtkTreeExpander, w) = G_.set_list_row(te, w)
set_child(te::GtkTreeExpander, w) = G_.set_child(te, w)
get_child(te::GtkTreeExpander) = G_.get_child(te)

get_item(trl::GtkTreeListRow) = G_.get_item(trl)

function GtkTreeListModel(root::GListModel, passthrough, autoexpand, create_func)
    create_cfunc = @cfunction($create_func, Ptr{GObject}, (Ptr{GObject}, Ptr{Nothing}))
    ret = ccall(("gtk_tree_list_model_new", libgtk4), Ptr{GObject}, (Ptr{GObject}, Cint, Cint, Ptr{Nothing}, Ptr{Nothing}, Ptr{Nothing}), root, passthrough, autoexpand, create_cfunc, C_NULL, C_NULL)
    convert(GtkTreeListModel, ret, true)
end
