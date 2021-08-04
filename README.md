behave
======

`behave` is a [Behavior Tree][1] library for lua, written in [Yuescript][2].

You can build this repo from source with `make build` or download a [release][3].


API
===

`behave`'s API is fairly straightforward. A behavior tree is given a set of
nodes and runs through them when `:run()` is called. `:run` will pass any
arguments it receives to individual nodes' `:run` method.

```
behave.Behavior
	behave.Behavior(name, nodes)
		ctor

	:add(node)
		add a single node to the container

	:reset()
		resets all tracked state

	:getStatus(node)
		returns the status of a specific node as of the last execution.
		if the node has not been executed or can't be found,
		behave.Node.status.unknown is returned.

	:run(...)
		executes all nodes, tracking their status.

behave.Leaf
	behave.Leaf(name, func)
		ctor
		`func` is any function, and should return one of the statuses
		from `behave.Node.status`.
	
	:run(...)
		executes `func` and returns the status.

behave.Selector
	behave.Selector(name, { node1, node2, ... })
		ctor

		the nodes in the set can be of any type, but should be unique.

	:run(...)
		executes each node until the first one returns a Node.status.success,
		at which point no further nodes are executed.

behave.Sequence
	behave.Sequence(name, { node1, node2, ... })
		ctor

		the nodes in the set can be of any type, but should be unique.

	:run(...)
		executes each node until the first Node.status.failure, at which
		point no further nodes are executed.
```

If you have a set of behaviors fleshed out, you may want to apply ad-hoc changes
to them before attaching to a new behavior set. You can use decorators for this.
They're currently a work-in-progress, though.

```lua
local behave = require("behave")

-- some already predefined behavior, imagine you've just imported it
local l = behave.Leaf("walk around", function()
	-- can't inject too much into something predefined, want to include it
	-- in a sequence but not have it trigger a failure?
	return behave.Node.status.failure
end)

-- this decorator wraps it to never fail
local new_l = behave.Decorators.Succeed(l)

-- or invert it; if it fails, it succeeds, or vice-versa
local new_l2 = behave.Decorators.Invert(l)

-- or repeat it until some other condition is met
local it = 0
local new_l3 = behave.Decorators.Until(l, function()
	it = it + 1

	-- run 5 times
	return it > 5
end)

local s = behave.Sequence("do stuff", { ..., l })
```

Full Example
=======

```lua
local behave = require("behave")

-- "nodes" can be single units of work or groups - eg Selectors or Sequences
local single = behave.Leaf("single-unit", function(v)
	if v == "example" then
		return behave.Node.status.success
	end

	return behave.Node.status.failure
end)

-- a selector runs until the first node succeeds.
local sel_leaf1 = behave.Leaf("sel-leaf-1", function()
	return behave.Node.status.success
end)

local sel_leaf2 = behave.Leaf("sel-leaf-2", function()
	print("I won't execute :(")

	return behave.Node.status.success
end)

local sel = behave.Selector("selector", { sel_leaf1, sel_leaf2 })

-- a sequence runs until the first node failure.
local seq_leaf1 = behave.Leaf("seq-leaf-1", function()
	return behave.Node.status.failure
end)

local seq_leaf2 = behave.Leaf("seq-leaf-2", function()
	print("I won't execute :(")
	return behave.Node.status.success
end)

local seq = behave.Sequence("sequence", { seq_leaf1, seq_leaf2 })

-- behavior is a container for any type of node.
-- it will run through all nodes it contains and track their state,
-- executing them regardless of status.
local b = behave.Behavior("behavior-one", { single, sel, seq })

b:run("example")

if b:getStatus(single) == behave.Node.status.success then
	print("the single leaf succeeded!")
end

if b:getStatus(sel) == behave.Node.status.success then
	print("the selector succeeded!")
end

if b:getStatus(seq) == behave.Node.status.failure then
	print("the sequence failed!")
end
```

TODOs
=====

- [ ] implement more decorator types


[1]: https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control)
[2]: https://github.com/pigpigyyy/Yuescript
[3]: https://github.com/chrsm/behave
