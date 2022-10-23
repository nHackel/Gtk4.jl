module Gtk4TestModule
using Test

@testset "GLib" begin
include("keyfile.jl")
#include("date.jl")
include("datetime.jl")
include("bytes.jl")
#include("gstring.jl")
include("mainloop.jl")
include("list.jl")

include("gvalue.jl")

include("gfile.jl")
include("gmenu.jl")
include("action-group.jl")
end

@testset "Pango" begin
include("families.jl")
include("layout.jl")
end

@testset "GdkPixbuf" begin
include("gdkpixbuf.jl")
end

@testset "Gtk" begin
include("gui/dialogs.jl")
include("gui.jl")
include("comboboxtext.jl")
include("tree.jl")
include("text.jl")
end

GC.gc()

sleep(2)

end
