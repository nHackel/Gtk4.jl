push!(w::GtkWidget, c::GtkEventController) = (G_.add_controller(w,c); w)
delete!(w::GtkWidget, c::GtkEventController) = (G_.remove_controller(w,c); w)

@doc """
    widget(c::GtkEventController)

Returns the widget associated with an event controller.
""" widget

observe_controllers(w::GtkWidget) = GListModel(G_.observe_controllers(w))

"""
    find_controller(w::GtkWidget, ::Type{T}) where T <: GtkEventController

Returns an event controller of type T connected to a widget, or nothing if one
doesn't exist. This function is intended for testing purposes (to simulate
events) and is not recommended otherwise, as there is a performance
penalty for creating a list of a widget's event controllers.

Related GTK function: [`gtk_widget_observe_controllers`](https://docs.gtk.org/gtk4/method.Widget.observe_controllers.html))
"""
function find_controller(w::GtkWidget, ::Type{T}) where T<: GtkEventController
    list = GListModel(G_.observe_controllers(w))
    i=findfirst(c->isa(c,T), list)
    i!==nothing ? list[i] : nothing
end

function GtkEventControllerMotion(widget::GtkWidget)
    g = G_.EventControllerMotion_new()
    push!(widget, g)
    g
end
function GtkEventControllerScroll(flags,widget::GtkWidget)
    g = G_.EventControllerScroll_new(flags)
    push!(widget, g)
    g
end
function GtkEventControllerKey(widget::GtkWidget)
    g = G_.EventControllerKey_new()
    push!(widget, g)
    g
end

function GtkGestureClick(widget::GtkWidget,button=1)
    g = G_.GestureClick_new()
    button != 1 && G_.set_button(g, button)
    push!(widget, g)
    g
end

function GtkGestureDrag(widget::GtkWidget)
    g = G_.GestureDrag_new()
    push!(widget, g)
    g
end

function GtkGestureZoom(widget::GtkWidget)
    g = G_.GestureZoom_new()
    push!(widget, g)
    g
end

function GtkEventControllerFocus(widget::GtkWidget)
    g = G_.EventControllerFocus_new()
    push!(widget, g)
    g
end

function on_signal_destroy(@nospecialize(destroy_cb::Function), widget::GtkWidget, vargs...)
    signal_connect(destroy_cb, widget, "destroy", Cvoid, (), vargs...)
end

reveal(w::GtkWidget) = G_.queue_draw(w)
