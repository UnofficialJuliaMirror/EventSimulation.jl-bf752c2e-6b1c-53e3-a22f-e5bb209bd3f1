__precompile__()

"""
EventSimulation is an event-based discrete event simulation engine.
"""
module EventSimulation

export # core.jl
       AbstractState, EmptyState, Scheduler,
       register!, bulk_register!, terminate!, go!,

       # resource.jl, queue.jl
       Resource, Queue, request!, provide!,

       # prioritytime.jl
       PriorityTime


include("core.jl")

"""
    dispatch!(s, r)
    dispatch!(s, q)

Internal function used for dispatching requests in `Resource` and `Queue`.
Puts appropriate `Action`s in `s` immediately.
"""
function dispatch! end


"""
    request!(s, r, quantity, request)
    request!(s, q, request)

Function used to register request for resource in `Resourse`
or object from `Queue.

Returns `true` if successfull and `false` when too many requests were made.

In `Resource` requested `quantity` must be provided and
`request` accepts only `Scheduler` argument (it must know what it wanted).

In `Queue` function `request` must accept two arguments `Scheduler` and object.
"""
function request! end


"""
    provide!(s, r, quantity)
    provide!(s, q, object)

Allows to fill `Resource` with `quantity` or `Queue` with `object`.

In `Resource` changes the balance of `r.quantity`. Given quantity may be
any number, but the balance of `Resource` will be changed
only in `lo`-`hi` range. Returns the actual change in `Resource` balance.

In `Queue` adds `object` to `q.queue`. Returns `true` on success and
`false` if there were too many objects in queue already.
"""
function provide! end

include("resource.jl")
include("queue.jl")

include("prioritytime.jl")

end # module
