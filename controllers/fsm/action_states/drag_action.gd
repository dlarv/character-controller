extends ControllerActionState

@export var grabber: Grabber
## These are actions which connect to drag. Therefore, when these actions are active, grabber must be enabled
@export var watch_actions: Array[ControllerActionState]

func setup(controller: Node3D) -> void:
	super.setup(controller)
	if not grabber:
		push_warning("DragAction(%s) has no grabber assigned and therefore cannot work" % get_path())
		return

	if not self in watch_actions:
		watch_actions.append(self)

	controller.state_changed.connect(func(to):
		print(to)
		for action in watch_actions:
			if action.name == to:
				grabber.set_enabled(true)
				return
		grabber.set_enabled(false)
	)
