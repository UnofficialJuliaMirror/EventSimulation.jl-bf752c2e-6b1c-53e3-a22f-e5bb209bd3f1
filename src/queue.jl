"""
Queue type for holding arbitrary objects `O`.
It allows objects to be waiting in a queue with optional maximum queue size.
Servers can get objects from the queue with optional maximum number of requests
pending for fulfillment.

Fields:
* `fifo_queue`    if `true` `queue` is fifo, otherwise lifo
* `max_queue`     maximum `queue` size
* `queue`         vector of objects in a queue
* `fifo_requests` if `true` `requests` is fifo, otherwise lifo
* `max_requests`  maximum `requests` size
* `requests`      vector of request functions

Functions in `requests` must accept two arguments `Scheduler` and `O`.
When `O` arrives to a queue there is a try to immediately dispatch it
to pending requests.
When new request arrives there is a try to immediately provide it with `O`.

Initially an empty `Queue` with no requests is constructed.
By default `queue` and `requests` have fifo policy and are unbounded.
"""
type Queue{O}
    fifo_queue::Bool
    max_queue::Int
    queue::Vector{O}
    fifo_requests::Bool
    max_requests::Int
    requests::Vector{Function}

    function Queue(;fifo_queue::Bool=true, max_queue::Int=typemax(Int),
                      fifo_requests::Bool=true,
                      max_requests::Int=typemax(Int))
        max_queue > 0 || error("max_queue must be positive")
        max_requests > 0 || error("max_requests must be positive")
        new(fifo_queue, max_queue, Vector{O}(),
            fifo_requests, max_requests, Vector{Function}())
    end
end

function dispatch!{O, S<:AbstractState, T<:Real}(s::Scheduler{S,T}, q::Queue{O})
    # thechnically could be if as it should never happen that
    # the loop executes more than once, but user might tweak the internals ...
    while !isempty(q.requests) && !isempty(q.queue)
        req = pop!(q.requests)
        obj = pop!(q.queue)
        register!(s, x -> req(x, obj)) # plan to execute request immediately
    end
end

function request!{O, S<:AbstractState, T<:Real}(s::Scheduler{S,T}, q::Queue{O}, request::Function)
    length(q.requests) < q.max_requests || return false
    qend = q.fifo_requests ? unshift! : push!
    qend(q.requests, request)
    dispatch!(s, q)
    return true
end

function provide!{O, S<:AbstractState, T<:Real}(s::Scheduler{S,T}, q::Queue{O}, object::O)
    if length(q.queue) < q.max_queue
        qend = q.fifo_queue ? unshift! : push!
        qend(q.queue, object)
        dispatch!(s, q)
        return true
    end
    return false
end

