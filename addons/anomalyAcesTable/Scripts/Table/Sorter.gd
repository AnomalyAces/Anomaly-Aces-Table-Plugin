const Table = preload("res://addons/anomalyAcesTable/Scene/Table/Table.gd")

var inner_column_name : String

func sort_row_by_column(table: Table, column_name: String, sorting_type):
	### Check ###
	if sorting_type == AceTableConstants.ColumnSort.NONE:
			push_warning("Sorting called but filter method is None")
			return
	
	### Init sorting and get data ###
	inner_column_name = column_name
	

	var rows_data: Array[Dictionary] = table.get_rows()
	
	
	#for row in rows_data:
		#rows_data.append(row)
	
	### Sort data ###
	match sorting_type:
		AceTableConstants.ColumnSort.SORT_ASCENDING:
			rows_data.sort_custom(_sort_ascending)
		
		AceTableConstants.ColumnSort.SORT_DESCENDING:
			rows_data.sort_custom(_sort_descending)
			
	### Sort rows ###
	var rows_parent: Node = table._rowContainer
	### probably not the most effcient way to do this but it will be accurate
	#Remove all children
	for n in rows_parent.get_children():
		rows_parent.remove_child(n)
	
	#Set the table data again
	table.set_data(rows_data)
	
	#Add Children back now that sort has happened
	#for i in range(rows_data.size()):
		#var row = rows_data_to_row[rows_data[i][inner_column_name]].node
		#rows_parent.add_child(row)
	
	
	
	#for i in range(rows_data.size()):
		#var row = rows_data_to_row[rows_data[i]].node
		#rows_parent.move_child(row, i)
		


func _sort_ascending(a, b):
	if a[inner_column_name] < b[inner_column_name]:
		return true
	
	return false


func _sort_descending(a, b):
	if a[inner_column_name] > b[inner_column_name]:
		return true
	
	return false

