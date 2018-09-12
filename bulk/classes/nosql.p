################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
nosql

@OPTIONS
dynamic

#
#	$nosql[^_classes[nosql;$options]]
#	$keys[^nosql.table[keys]]
#	####
#	$select[^nosql.select[$keys][
#		$.email[$hash.email]
#		$.server[$hash.server]
#	]]
#	^json:string[$select]
#	##
#	$keys[$keys.data]
#	$select[^nosql.select[$keys]($keys.email eq $hash.email && $keys.server eq $hash.server)]
#	^json:string[$select]
# ####
#	$insert[^nosql.insert[$keys;$hash]]
#	####
#	$update[^nosql.update[$table][
#		$.new_value[$new.email]
#	][
#		$.select_propery[$sort.server]
#	]]
#	####
#	$delete[^nosql.delete[$keys][
#		$.server[$hash.server]
#	]]
#

@create[][locals]
$options[^_options[system]]
$request:document-root[$options.local.document-root]
$self.path[$options.local.nosql]
$self.base[^_jsonFiles[$self.path]]

@pattern[name;data][locals]
$result[^hash::create[]]
$nosql[bone,connect,counter,keys,settings,sessions,alerts,requests,views]
$bone[^switch[$name]{
  ^case[bone]{name,count,created,updated,data}
	^case[connect]{id,server,host,name,user,pass,charset}
	^case[counter]{id,cID,md5,navigator,screen,timezone,created,updated}
  ^case[keys]{id,active,server,email,license,api,secret,public,access,reload,connect,created,expires}
	^case[settings]{id,group,link,key,value,icon}
	^case[sessions]{id,sID,cID,uID,uIP,created,updated}
	^case[alerts]{id,cID,type,success,message,data,timestamp}
	^case[requests]{id,server,key,request,timestamp}
	^case[views]{id,cID,path,timestamp}
  ^case[menu]{id,sort,parent,link,icon}
  ^case[refresh]{id,uid,md5,lifetime}
	^case[exceptions]{id,node,pattern,expression,rule}
	^case[DEFAULT]{id}
}]
$split[^bone.split[,]]
^split.menu{
	$result.[$split.piece][]
}
^if($data is hash){
	^data.foreach[key;value]{
		$result.[$key][$value]
	}
}

@table[table][locals]
^if($self.base.[${table}.json]){
	$name[$self.base.[${table}.json].name]
	$file[^file::load[binary;${self.path}/${name}]]
	$table[^_jsonTable[$file.text]]
	$result[$table]
}(!$self.base.[${table}.json]){
	$result[^make[$table]]
}

@hash[table][locals]
^if($self.base.[${table}.json]){
	$name[$self.base.[${table}.json].name]
	$file[^file::load[binary;${self.path}/${name}]]
	$hash[^_jsonHash[$file.text]]
	$result[$hash]
}(!$self.base.[${table}.json]){
	$result[^make[$table]]
}

@make[name][locals]
$table[^table::create{}]
$result[^pattern[bone][
	$.name[$name]
	$.count[^table.count[]]
	$.created[^_time[unix]]
	$.data[$table]
]]

@build[data][locals]
$result[^json:string[$data;
	$.indent(true)
	$.table[object]
]]

@save[table;build][locals]
$response[^file::create[binary;${table};^taint[${build}]]]
^response.save[binary;${self.path}/${table}.json]

@select[table;data;options][locals]
$options[^hash::create[$options]]
$params[^hash::create[]]
^options.foreach[k;v]{
  ^if($k eq "limit" || $k eq "offset" || $k eq "reverse"){
    $params.[$k]($v)
  }
}
^if($data is bool){
	$select[^table.select($data)[$params]]
	^if($select){
		$result[$select]
	}{
		$result[]
	}
}($data is hash){
	$response[^hash::create[]]
	$hash[^_tableHash[$table]]
	^process[$self]{@equal[a^;b]
	^$result(^data.foreach[field;]{^$a.$field eq ^$b.$field}[ && ])}
	^if(def $hash.data){
		^hash.data.foreach[col;row]{
			^if(^equal[$data;$row]){
				$response.$col[$row]
			}
		}
	}
	$result[$response]
}(!def $data){
	$result[$table]
}
^if(^options.contains[orderBy]){
  ^result.sort{$options.orderBy}
}

@insert[table;data][locals]
$data[^pattern[$table.name;$data]]
^if(!def $data.id){
	$data.id[^_uid64[]]
}
^if(!def $table.data){
	$body[^table::create{^data.foreach[col;]{$col}[^#09]}]
	^body.insert[^data.foreach[col;row]{^if(!def $row){null}($row is string){^taint[as-is][$row]}($row is hash){^child[$row]}($row is table){^child[$row]}}[^#09]]
	$table.count[^body.count[]]
	$table.updated[^_time[unix]]
	$table.data[$body]
}($table.data is table){
	$body[$table.data]
	^body.insert[^data.foreach[col;row]{^if(!def $row){null}($row is string){^taint[as-is][$row]}($row is hash){^child[$row]}($row is table){^child[$row]}}[^#09]]
	$table.count[^body.count[]]
	$table.updated[^_time[unix]]
	$table.data[$body]
}
$build[^build[$table]]
^save[$table.name;$build]
$result[$table.data.id]

@child[table][locals]
$string[^json:string[$table]]
$result[^to_url_safe[^string.base64[]]]

@update[table;data;options][locals]
$options[^hash::create[$options]]
$hash[^_tableHash[$table]]
$data[^hash::create[$data]]
$select[^self.select[$table;$options]]
^select.foreach[col;row]{
	^row.add[$data]
}
$hash.data[$select]
$hash.updated[^_time[unix]]
$table[^_hashTable[$hash]]
$build[^build[$table]]
^save[$table.name;$build]

@delete[table;data][locals]
$hash[^_tableHash[$table]]
$data[^hash::create[$data]]
$select[^self.select[$table;$data]]
^if(def $select){
	^select.foreach[col;row]{
		^hash.data.delete[$col]
	}
	$hash.count[^hash.data.count[]]
	$hash.updated[^_time[unix]]
	$table[^_hashTable[$hash]]
	$build[^build[$table]]
	^save[$table.name;$build]
}
