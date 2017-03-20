#!/bin/bash

function get_file_usage () {
	file=$1
	file_name=$(echo ${file##*/} | cut -d '.' -f 1)
	IFS=$'\n'
	first_letter=${file_name:0:1}

	regex="($first_letter|${first_letter,,})${file_name:1}"
	#echo $regex
	#exit
	#individual_usage=($(grep -rEnHo "$module_name/$file_name('|\")" $module_path | grep -v "$module_path$module_name" ))
	individual_usage=($(grep -rEnHo "$module_name/($regex('|\")|[a-zA-Z]+/"$file_name"\.php)" $module_path | grep -v "$module_path$module_name" ))

	if [ ! -z "$individual_usage" ]; then
		printf "**** Usage of $file ****\n"

		count=${#individual_usage[@]}

		for ((i=0;i<count;i++)) do
			printf "\t- ${individual_usage[$i]}"
			printf "\n"
			matched_files=("${matched_files[@]}" "${individual_usage[$i]}")
		done
	else
		unused_files=("${unused_files[@]}" "$file")
	fi
}

module_name=$1;
module_path="application/modules/"
module_usage_regex="module(?:\(?)('|\")$module_name\1?\/?";

# check if module is loaded from another modules
usage=$(grep -rElc "$module_usage_regex" $module_path)

echo $usage;
echo "##Looking for usage of individual modules...##"

matched_files=()
unused_files=()
i=0

for folders in application/modules/$module_name/*; do
	for file in ${folders}/*; do
		get_file_usage $file
	done

	printf "\n"
done

printf "Number of matched files: ${#matched_files[@]}"
printf "\n"
printf "Number of unused files: ${#unused_files[@]}"
printf "\n## Unused files:\n"

count=${#unused_files[@]}
for ((i=0;i<count;i++)) do

	printf "\tRemoving ${unused_files[$i]}"
	#$(rm ${unused_files[$i]})
	printf "\n"
done

