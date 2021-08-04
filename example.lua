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
