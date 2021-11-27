## A stripped version of @class Node.
# @desc This is an example class for testing Doctool's capabilities. It is based on @a Node,
#       but it does not feature everything that the original has.
#
#       The following functions are imported from @class Node:
#
#       @list_begin unordered
#       @item _enter_tree
#         The @function _enter_tree() function is supported.
#       @item _exit_tree
#         The @function _exit_tree() function is supported.
#         It's called when the node exits the tree.
#       @list_end
extends Object
class_name NodeCustom

## Process mode
enum ProcessMode {
    PROCESS_IDLE, ## Idle process
    PROCESS_PHYSICS ## Physics process
}

#       Imported signals:
#
#       @list_begin unordered
#       @item ready
#       The ready signal is supported.
#       It can be used the same way as the @class Node class.
#       @item renamed
#       The renamed signal is supported.
#       @list_end

## Emitted when a node is ready.
signal ready

## Emitted when a node is renamed.
signal renamed

## The name of the node.
# @type String
# @setter set_name(name)
# @getter get_name()
# @desc This name is unique among siblings of a node. If set to a name that already exists,
#       it is automatically renamed.
#
#       @b Note: auto-generated names can contain a '@' character, which is reserved for unique names
#       when adding a node with @function add_child(). When setting the name manually, all instances
#       of '@' will be removed.
var name : String = ""

## Called when a @class Node enters the scene tree.
# @virtual
# @desc If the node has children, the @function _enter_tree() of those children will be called
#       after this one has finished.
func _enter_tree() -> void: pass

## Called when a @class Node exits the scene tree.
# @virtual
# @desc If the node has children, the @function _exit_tree() of those children will be called
#       first, and this one last.
func _exit_tree() -> void: pass
