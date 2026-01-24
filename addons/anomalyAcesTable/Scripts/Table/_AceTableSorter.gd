@tool
class_name _AceTableSorter extends Node

var inner_column_name : String

func sort_row_by_column(table: _AceTable, column_name: String, sorting_type):
	
	### Init sorting and get data ###
	inner_column_name = column_name
	

	var rows_data: Array[Dictionary] = table.get_sorted_rows()
	
	
	#for row in rows_data:
		#rows_data.append(row)
	
	### Sort data ###
	match sorting_type:
		AceTableConstants.ColumnSort.SORT_ASCENDING:
			rows_data.sort_custom(_sort_ascending)
		
		AceTableConstants.ColumnSort.SORT_DESCENDING:
			rows_data.sort_custom(_sort_descending)

		AceTableConstants.ColumnSort.NONE:
			#No sorting
			rows_data = table.get_rows()
			
	### Clear rows ###
	table._clear_rows()
	
	#Set the table data again
	table._set_sorted_data(rows_data)
	
		


func _sort_ascending(a, b):
	if a[inner_column_name] < b[inner_column_name]:
		return true
	
	return false


func _sort_descending(a, b):
	if a[inner_column_name] > b[inner_column_name]:
		return true
	
	return false

