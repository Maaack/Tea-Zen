extends Node

export(Resource) var recipe_data : Resource

var running : bool = false

func start_recipe_job(job_time : float, source_container : ContainerData, destination_container : ContainerData):
	if running:
		return
	for recipe_quantity in recipe_data.recipe_input.get_quantities():
		var source_quantity : QuantityData = source_container.find_content(recipe_quantity.name)
		if source_quantity == null or source_quantity.quantity < recipe_quantity.quantity:
			return
	source_container.remove_contents(recipe_data.recipe_input.contents)
	running = true
	yield(get_tree().create_timer(job_time), "timeout")
	destination_container.add_contents(recipe_data.recipe_output.contents)
	running = false
	
