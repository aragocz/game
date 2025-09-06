extends CharacterBody2D;
@export var gravity:int = 200; #p/s^2
@export var speed:int = 750; #p/s^2
@export var jump:int = 200; #p
var slowed:bool = false;
var falling:bool = false;
var recovering_timeslow:bool = false;
var timeslow_timer:Node = null; #node
var timeslow_recovery_timer:Node = null; #node
var timeslow:float = 5; #seconds
var timeslow_left:float = 5; # seconds
var timeslow_recovery_modifier:float = 1; #slowed seconds recovered per second
signal timeslow_tick(percentage_left:float, recovering:bool);

func _ready() -> void:
	timeslow_timer = get_node("timeslowTimer");
	timeslow_recovery_timer = get_node("timeslowRecovery");
	timeslow_timer.set_paused(true);
	timeslow_timer.start(timeslow);

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += Vector2(0, gravity*delta);
		move_and_slide();
		
		if not slowed:
			velocity = clamp(velocity + Input.get_vector("left", "right", "dev_null", "down") * speed * 0.3 * delta, Vector2(-5000,-5000), Vector2(5000, 5000));
			move_and_slide();
	#endif
	if is_on_floor():
		
		if (Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")) and not Input.is_action_pressed("slide"):
			velocity = clamp(velocity + Input.get_vector("left", "right", "dev_null", "down") * speed * delta, Vector2(-5000,-5000), Vector2(5000, 5000));
		if not(Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("slide")):
			velocity *= 0.85;
			
		if Input.is_action_just_pressed("up"):
			velocity.y -= jump;
		move_and_slide();
		#endif
	#endif
#endfunc

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("slow") and timeslow_left > 1:
		timeslow_timer.set_paused(false);
		slowed = true;
		Engine.time_scale = 0.2;
	#endif
	if Input.is_action_just_released("slow"):
		normalSpeed()
	#endif
	if slowed:
		emit_signal("timeslow_tick", (timeslow_timer.get_time_left()/timeslow)*100);
		#endif
	#endif
	
	if (is_on_floor() and timeslow_left < timeslow and not slowed):
		if(not recovering_timeslow):
			recovering_timeslow = true;
			timeslow_recovery_timer.start(timeslow_recovery_modifier);
		else:
			emit_signal("timeslow_tick", clamp((timeslow_left/timeslow)*100, 0, 100));
	else:
		if not slowed:
			emit_signal("timeslow_tick", clamp((timeslow_left/timeslow)*100, 0, 100));
		timeslow_recovery_timer.stop();
		recovering_timeslow = false;
	
	#DEBUG FUNCTION
	if Input.is_action_just_pressed("debug_restart"):
		velocity = Vector2(0,0);
		position = Vector2(575, 306);


func _on_timeslowTimeout() -> void:
	Input.action_release("slow");
	normalSpeed()
	emit_signal("timeslow_tick", 0);

func normalSpeed() -> void:
	slowed = false;
	Engine.time_scale = 1;
	timeslow_left = timeslow_timer.get_time_left();
	timeslow_timer.set_paused(true);

func _on_timeslowRecovery() -> void:
	timeslow_left = clamp(timeslow_left + timeslow_recovery_modifier, 0, timeslow);
	timeslow_timer.start(timeslow_left);
