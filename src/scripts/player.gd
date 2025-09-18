extends CharacterBody2D;
@export var speed:int = 750; #p/s^2
@export var jump:int = 200; #p
@export var dash_radius:int = 125; #p
@export var dashes = 3;
var dash_recovery:float = 2; #seconds
var slowed:bool = false;
var falling:bool = false;
var recovering_timeslow:bool = false;
var dash_recovery_timer:Timer = null; #node
var timeslow_timer:Timer = null; #node
var timeslow_recovery_timer:Timer = null; #node
var timeslow:float = 5; #seconds
var timeslow_left:float = 5; #seconds
var timeslow_recovery_cooldown:float = 1; #seconds till timeslow starts recovering on conditions met
var projection:Sprite2D = null; #projection during dash
var dashes_left:int = 0;
signal timeslow_tick(percentage_left:float);
signal dash(dashes_left:int);
signal setup(dashes:int);

func _ready() -> void:
	timeslow_timer = get_node("timeslowTimer");
	timeslow_recovery_timer = get_node("timeslowRecovery");
	dash_recovery_timer = get_node("dashRecovery");
	dashes_left = dashes;

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*delta;
		move_and_slide();
		
		if not slowed:
			velocity = clamp(velocity + Input.get_vector("left", "right", "dev_null", "down") * speed * 0.3 * delta, Vector2(-5000,-5000), Vector2(5000, 5000));
			move_and_slide();
	#endif
	if is_on_floor():
		if (Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")) and not Input.is_action_pressed("slide") and not slowed:
			velocity = clamp(velocity + Input.get_vector("left", "right", "dev_null", "down") * speed * delta, Vector2(-5000,-5000), Vector2(5000, 5000));
		if not(Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("slide")):
			velocity *= 0.85;
		
		if Input.is_action_just_pressed("up") and not slowed:
			velocity.y -= jump;
		move_and_slide();
		#endif
	#endif

	if slowed && dashes_left > 0:
		var spacestate = get_world_2d().direct_space_state;
		var ray = PhysicsRayQueryParameters2D.create(self.global_position, get_viewport().get_camera_2d().get_global_mouse_position());
		ray.exclude = [self, projection];
		var intersect = spacestate.intersect_ray(ray);
		if(intersect.is_empty() or (self.position.distance_to(intersect.position) > dash_radius)):
			projection.position = to_local(radialPosition(get_viewport().get_camera_2d().get_global_mouse_position(), dash_radius, self.position));
		elif(self.position.distance_to(intersect.position) <= dash_radius):
			projection.position = to_local(intersect.position);
		#endif
	#endif
#endfunc

func _process(_delta: float) -> void:
	#Time slow + dash
	if Input.is_action_just_pressed("slow") and timeslow_left > 0:
		timeslow_timer.start(timeslow_left);
		recovering_timeslow = false;
		slowed = true;
		Engine.time_scale = 0.2;
		if(dashes_left > 0):
			projection = Sprite2D.new();
			projection.texture = load("res://icon.svg");
			self.add_child(projection);
	#endif
	if Input.is_action_just_released("slow"):
		if is_instance_valid(projection) && dashes_left > 0:
				self.global_position = projection.global_position;
				dashes_left -= 1;
				emit_signal("dash", dashes_left);
		normalSpeed();
	#endif
	if slowed:
		emit_signal("timeslow_tick", (timeslow_timer.get_time_left()/timeslow)*100);
	#endif
	
	if(is_on_floor() and dashes > dashes_left):
		if(dash_recovery_timer.is_stopped()):
			dash_recovery_timer.start(dash_recovery);
	else:
		dash_recovery_timer.stop();
	
	if(is_on_floor() and timeslow_left < timeslow and not slowed):
		if(timeslow_recovery_timer.is_stopped() and not recovering_timeslow):
			timeslow_recovery_timer.start(timeslow_recovery_cooldown)
			
		if recovering_timeslow:
			emit_signal("timeslow_tick", ((timeslow - timeslow_timer.get_time_left())/timeslow)*100);
			timeslow_left = timeslow - timeslow_timer.get_time_left();
	elif recovering_timeslow:
		timeslow_timer.stop();
		recovering_timeslow = false;
	
	#DEBUG FUNCTION
	if Input.is_action_just_pressed("debug_restart"):
		velocity = Vector2(0,0);
		position = Vector2(575, 306);

func _on_timeslowTimeout() -> void:
	if(not recovering_timeslow):
		Input.action_release("slow");
		normalSpeed()
		emit_signal("timeslow_tick", 0);
	else:
		emit_signal("timeslow_tick", 100)
		timeslow_timer.stop();
		timeslow_left = timeslow;
		recovering_timeslow = false;

func normalSpeed() -> void:
	if slowed:
		slowed = false;
		Engine.time_scale = 1;
		timeslow_left = timeslow_timer.get_time_left();
		timeslow_timer.stop();
		if is_instance_valid(projection): projection.queue_free();

func componentClamp(vector:Vector2, minV:Vector2, maxV:Vector2) -> Vector2:
	return Vector2(clamp(vector.x, minV.x, maxV.x), clamp(vector.y, minV.y, maxV.y));

func radialPosition(vector:Vector2, radius:float, origin:Vector2) -> Vector2:
	return origin + Vector2.from_angle(origin.angle_to_point(vector))*radius

func minPreserveSign(args:Array[int]) -> int:
	var absd = args.map(func(i): return abs(i));
	return args[absd.find(absd.min())];

func _on_timeslow_recovery() -> void:
	timeslow_timer.start(timeslow - timeslow_left);
	recovering_timeslow = true;

func _on_HUD_ready() -> void:
	emit_signal("setup", dashes);

func _on_dash_recovery() -> void:
	emit_signal("dash", dashes_left);
	dashes_left += 1;
