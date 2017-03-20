#!/bin/bash

function get_function_usage () {
	model=$1
	class_name=$(echo $model | rev | cut -d '/' -f 1 | rev | cut -d '.' -f 1 ) # hack echo, reverse, cut first field then reverse then cut again
	printf "Class name: $class_name\n"
	IFS=$'\n'

	## get functions of a model
	## skipping __construct, __* name [^__]
	func_list=($(grep -Eo "function [^__][a-z_A-Z0-9]+"  $model))

	first_letter=${class_name:0:1}
	regex="($first_letter|${first_letter,,})${class_name:1}"

	# example usage
		# $this->searcher_model->get_searcher_detail($qr->users_id);
		# $this->get_searcher_detail($qr->users_id);
		# self::get_searcher_detail($qr->users_id);
		# ClassName::get_searcher_detail($qr->users_id);

	count=${#func_list[@]}
	printf "Number of functions: $count\n"
	for ((i=0;i<count;i++)) do
		function_name=$( echo ${func_list[$i]} | cut -d ' ' -f 2)

		printf "Searching for usage of function: $function_name \n"

		usage=($(grep -rEnHo "($regex\->|$class_name::)$function_name(\ |\n?)\(.*(\n?)" $module_path ))
		internal_usage=($(grep -rEnHo "(\->|self::)$function_name(\ |\n?)\(.*(\n?)" $model ))

		usage_count=${#usage[@]}
		internal_usage_count=${#internal_usage[@]}

		if [ $usage_count == 0 ] && [ $internal_usage_count == 0 ]; then
			# not used
			printf "\t- none"
			unused_functions=("${unused_functions[@]}" "$function_name")
			printf "\n"
		else
			for ((j=0;j<usage_count;j++)) do
				printf "\t- ${usage[$j]}"
				printf "\n"
				matched_functions=("${matched_functions[@]}" "$function_name")
			done

			for ((j=0;j<internal_usage_count;j++)) do
				printf "\t- ${internal_usage[$j]}"
				printf "\n"
				matched_functions=("${matched_functions[@]}" "$function_name")
			done
		fi
	done
}

model_path=$1;
module_path="application/modules/"

matched_functions=()
unused_functions=()
i=0

get_function_usage $model_path
printf "\n"

printf "Number of matched functions: ${#matched_functions[@]}"
printf "\n"
printf "Number of unused functions: ${#unused_functions[@]}"

printf "\n## Unused functions:\n"
count=${#unused_functions[@]}

for ((i=0;i<count;i++)) do
	printf "\t${unused_functions[$i]}"
	# TODO delete function block
	printf "\n"
done
#echo ${matched_functions[2]}

