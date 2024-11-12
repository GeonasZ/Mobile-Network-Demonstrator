extends Control

@onready var obs_button = $".."
@onready var anime_player = $AnimationPlayer

const sqrt2 = 1.414

var stretch = 6

func _draw():
	draw_line(Vector2(-(obs_button.button_radius)/sqrt2, -(obs_button.button_radius)/sqrt2)+Vector2(stretch,stretch), Vector2((obs_button.button_radius)/sqrt2, (obs_button.button_radius)/sqrt2)+Vector2(-stretch,-stretch), Color8(150,150,150), 7, true)
	draw_line(Vector2((obs_button.button_radius)/sqrt2, -(obs_button.button_radius)/sqrt2)+Vector2(-stretch,stretch), Vector2(-(obs_button.button_radius)/sqrt2, (obs_button.button_radius)/sqrt2)+Vector2(stretch,-stretch), Color8(150,150,150), 7, true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(obs_button.button_radius, obs_button.button_radius)
	self.scale = Vector2(1,1)

func appear_with_anime():
	self.visible = true
	anime_player.play("appear")
	
	
func disappear_with_anime():
	anime_player.play("disappear")
	await anime_player.animation_finished
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
