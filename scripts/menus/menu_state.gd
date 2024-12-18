class_name MenuState
extends BaseState

func _ready():
    self.visible = active

func _set_active(value: bool) -> void:
    super(value)
    self.visible = value