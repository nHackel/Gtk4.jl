_g_callback(cb::Function) = Cint(cb())

"""
    g_timeout_add(f, interval, priority=PRIORITY_DEFAULT)

Add a function `f` that will be called every `interval` milliseconds by the GTK
main loop. The function is expected to return a `Cint`. If it returns a nonzero 
value, the function will be called again after another `interval` milliseconds.
Otherwise it will not be called again. The optional `priority` argument, which
is an integer, sets the priority of the event source (smaller is higher priority).
The GLib main loop uses this priority value to decide what sources to handle next.

This function returns an event source ID that can be used with `g_source_remove`
to stop the timeout.

Related GTK function: [`g_timeout_add`()]($(gtkdoc_func_url("glib","timeout_add")))
"""
function g_timeout_add(cb::Function, interval::Integer, priority=PRIORITY_DEFAULT)
    callback = @cfunction(_g_callback, Cint, (Ref{Function},))
    ref, deref = gc_ref_closure(cb)
    return ccall((:g_timeout_add_full, libglib),Cint,
        (Cint, UInt32, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        Int32(priority), UInt32(interval), callback, ref, deref)
end

"""
    g_idle_add(f, priority=PRIORITY_DEFAULT_IDLE)

Add a Julia function `f` that will be called when there are no higher priority
GTK events to be processed. This function can be used from any thread. The
optional `priority` argument, which is an integer, sets the priority of the
event source (smaller is higher priority). The GLib main loop uses this priority
value to decide what sources to handle next.

See also [`@idle_add`](@ref).

Related GTK function: [`g_idle_add_full`()]($(gtkdoc_func_url("glib","idle_add_full")))
"""
function g_idle_add(cb::Function, priority=PRIORITY_DEFAULT_IDLE)
    callback = @cfunction(_g_callback, Cint, (Ref{Function},))
    ref, deref = gc_ref_closure(cb)
    return ccall((:g_idle_add_full , libglib),Cint,
        (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        Int32(priority), callback, ref, deref)
end

"""
    @idle_add(ex)

Create a function from an expression `ex` that will be called when there are no
higher priority GTK events to be processed. This function can be used from any
thread.

See also [`g_idle_add`](@ref).

Related GTK function: [`g_idle_add`()]($(gtkdoc_func_url("glib","idle_add")))
"""
macro idle_add(ex)
    quote
    g_idle_add() do
        $(esc(ex))
        return false
      end
    end
end

"""
    g_source_remove(id::Integer)

Remove the event source identified by `id` from the GLib main loop. The `id` is
returned by `g_idle_add` and `g_timeout_add`. The main loop reuses `id`'s so care
should be taken that the source intended to be removed is still active.

Related GTK function: [`g_source_remove`()]($(gtkdoc_func_url("glib","source_remove")))
"""
g_source_remove(id) = G_.source_remove(id)

const g_main_running = Ref{Bool}(true)

glib_main() = GLib.g_sigatom() do
    # gtk_main() was deprecated in GTK 4.0, hence we iterate the loop ourselves
    while g_main_running[]
        ccall((:g_main_context_iteration, libglib), Cint, (Ptr{Cvoid}, Cint), C_NULL, true)
    end
end

"""
    start_main_loop()

If the default GLib main event loop is not already running, start a Julia task
that runs it.

See also [`stop_main_loop`](@ref).
"""
function start_main_loop()
    # if g_main_depth > 0, a glib main-loop is already running,
    # so we don't need to start a new one
    if ccall((:g_main_depth, libglib), Cint, ()) == 0
        global glib_main_task = schedule(Task(glib_main))
    end
end

"""
    stop_main_loop()

Stops the default GLib main loop after the next iteration. Does not affect loop
operation if GApplication's `run()` method is being used instead of
`GLib.start_main_loop()`.

See also [`start_main_loop`](@ref).
"""
function stop_main_loop()
    g_main_running[] = false
    ccall((:g_main_context_wakeup, libglib), Cvoid, (Ptr{Cvoid},), C_NULL)
end

GApplication(id = nothing, flags = GLib.ApplicationFlags_FLAGS_NONE) = G_.Application_new(id,flags)

function run(app::GApplication)
    ccall(("g_application_run", libgio), Int32, (Ptr{GObject}, Int32, Ptr{Cstring}), app, 0, C_NULL)
end
register(app::GApplication) = G_.register(app, nothing)
activate(app::GApplication) = G_.activate(app)
