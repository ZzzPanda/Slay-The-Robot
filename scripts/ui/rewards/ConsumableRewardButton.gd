extends BaseRewardButton

func init(_action_on_click: BaseAction, _reward_group: int) -> void:
	super(_action_on_click, _reward_group)
	
	var consumable_id: String = _action_on_click.values.get("consumable_id", "")
	var consumable_data: ConsumableData = Global.get_consumable_data(consumable_id)
	if consumable_data != null:
		text = consumable_data.consumable_name
		if consumable_data.consumable_texture_path != "":
			icon = load(consumable_data.consumable_texture_path)