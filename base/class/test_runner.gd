class_name TestRunner
signal completed

var list_of_tests := []
var current_test_index := 0
var ongoing_tests := 0
var total_tests := 0
var completed_tests := 0

var scene:Node
var scroll_container : ScrollContainer
var container :HFlowContainer

# Called when the node enters the scene tree for the first time.
func _init(p_scene: Node) -> void:
	scene = p_scene
	
	scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Global.WINDOW_SIZE + Vector2(10,0) # +10 for the scrollbar
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	container = HFlowContainer.new()
	container.layout_mode=1
	container.size = Global.WINDOW_SIZE
	container.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	container.size_flags_vertical=Control.SIZE_EXPAND_FILL
	container.set("theme_override_constants/h_separation", 0)
	container.set("theme_override_constants/v_separation", 0)

	scroll_container.add_child(container)
	scene.add_child(scroll_container)

func add_test(node: PhysicsTest2D):
	list_of_tests.append(node.duplicate())
	total_tests += 1
	
func start():
	var available := Global.MAXIMUM_PARALLEL_TESTS - ongoing_tests
	var remaining_test = total_tests - current_test_index
	while available > 0 and remaining_test != 0:
		var node = list_of_tests[current_test_index]
		var texture_rect = TextureRect.new()
		texture_rect.ignore_texture_size = true
		texture_rect.size = Global.WINDOW_SIZE / Global.NUMBER_TEST_PER_ROW
		texture_rect.custom_minimum_size = Global.WINDOW_SIZE / Global.NUMBER_TEST_PER_ROW

		var viewport = SubViewport.new()
		viewport.disable_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		viewport.add_child(node)
		viewport.size =  Global.WINDOW_SIZE
		viewport.size_2d_override = Global.WINDOW_SIZE
		
		texture_rect.add_child(viewport)
		container.add_child(texture_rect)
		texture_rect.texture=viewport.get_texture()
		
		var callable = self.update_test.bind(node)
		node.completed.connect(callable)
		node.start()
		current_test_index += 1
		ongoing_tests += 1
		available = Global.MAXIMUM_PARALLEL_TESTS - ongoing_tests
		remaining_test = total_tests - current_test_index

func update_test(node):
	var texture_rect: Node= node.get_parent().get_parent()
	texture_rect.queue_free()
	completed_tests += 1
	ongoing_tests -= 1
	if completed_tests == total_tests:
		completed.emit()
	else:
		start()

func reset():
	if scroll_container:
		scroll_container.queue_free()
	current_test_index = 0
	ongoing_tests = 0
	total_tests = 0
	completed_tests = 0
