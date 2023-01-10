#!/bin/bash -e
#to be run by Ansible controller, NOT a remote host
scriptname="permissions.sqlite_merge_master.sh"
sqlite_dir="SECRET/roles/firefox/files/permissions.sqlite.d"
script_dir="roles/firefox/scripts"
master_name="permissions.sqlite.insert.cookies.master.sql"
master_name_withappend="permissions.sqlite.insert.cookies.master.withappend.sql"
appendpart_name="permissions.sqlite_appendtomaster.sql"

if [[ ! -d "$sqlite_dir" ]] ; then
	printf '%s\n' "$scriptname: ERROR: this folder doesn't exist, check current dir: $sqlite_dir"
	exit 1
fi

### Merge SQL scripts from each host and user ###
if [[ -f "$sqlite_dir/$master_name" ]] ; then
	cat "$sqlite_dir/$master_name" "$sqlite_dir"/permissions.sqlite.insert.cookies_* | sed 's;VALUES([0-9]*,;VALUES(NULL,;' | awk '!a[$0]++' > "$sqlite_dir/$master_name".tmp
else
	cat "$sqlite_dir"/permissions.sqlite.insert.cookies_* | sed 's;VALUES([0-9]*,;VALUES(NULL,;' | awk '!a[$0]++' > "$sqlite_dir/$master_name".tmp
fi
#cat outputs all SQL scripts, including the master script
#sed replaces IDs with NULL
#awk deduplicates exact duplicate rows
#Strange bug if > "$sqlite_dir/$master_name" instead of > "$sqlite_dir/$master_name".tmp:
	#changes to "$sqlite_dir/$master_name" get erased...
	#.tmp is a workaround
	#reason for issue is unclear

mv "$sqlite_dir/$master_name".tmp "$sqlite_dir/$master_name"

### Append SQL script to merge table to end of master ###
cp "$sqlite_dir/$master_name" "$sqlite_dir/$master_name_withappend"
cat "$script_dir/$appendpart_name" >> "$sqlite_dir/$master_name_withappend"
