################################################################
##
##  NUMBERS
##
################################################################

@_uuid[][locals]
$uuid[^math:uuid[]]
^return[^uuid.lower[]]

@_uid64[][locals]
$uid64[^math:uid64[]]
^return[^uid64.lower[]]

@_uid[][locals]
^return[^reflection:uid[$caller]]

################################################################
##
##  TIME
##
################################################################

@_time[type;roll][locals]
^if(def $roll){
	$time[^date::now($roll)]
}{
	$time[^date::now[]]
}
$result[^switch[$type]{
  ^case[now]{$time}
  ^case[gmt]{^time.gmt-string[]}
	^case[sql]{^time.sql-string[]}
  ^case[unix]{^time.unix-timestamp[]}
}]

################################################################
##
##  CONTROLLER
##
################################################################


@_dispatch[req][locals]
$url[^req.trim[both;/]]
$form[^hash::create[$form:fields]]
^form.delete[@]
$uri[^url.split[/;l;part]]
$result[
	$.request[
		$.scheme[$env:REQUEST_SCHEME]
		$.host[$env:HTTP_HOST]
		$.addr[$env:REMOTE_ADDR]
		$.port[$env:REMOTE_PORT]
		$.uri[$env:REQUEST_URI]
		$.url[/$url]
		$.level[^uri.count[]]
		$.query[$env:QUERY_STRING]
		$.method[$env:REQUEST_METHOD]
		$.form[$form]
	]
]
^rem{
$.anc[^uri.sort(^uri.line[])[asc]^uri.menu{^uri.offset(0)$uri.part^break[]}]
$.dsc[^uri.sort(^uri.line[])[desc]^uri.menu{^uri.offset(0)$uri.part^break[]}]
$.uri[^uri.sort(^uri.line[])[desc]^uri.menu{
	$.[^uri.offset[]][$uri.part]
}]
}

################################################################
##
##  USE .p FILES
##
################################################################

@_use[name;options][locals]
#	CLASS CONNECTION
#	USE:
#	$class[^_class[name;$options]]
$options[^hash::create[$options]]
$classes[^_sysFiles[classes;p]]
$engine[^_sysFiles[genus;p]]
^if(^_exist[$classes;${name}.p]){
	^_include[$classes.[${name}.p].path]
}(^_exist[$engine;${name}.p]){
	^_include[$engine.[${name}.p].path]
}{
	$result[]
}
^if(^reflection:def[class;$name]){
	$result[^reflection:create[
		$.class[$name]
		$.constructor[create]
		$.arguments[$options]
	]]
}

@_mixin[class][locals]
# MIXIN OBJECT OF CLASS IN CALLER
$result[^reflection:mixin[$class][
	$.to[$caller.self]
	$.overwrite(true)
]]

################################################################
##
##  FILES
##
################################################################

@_sysFiles[dir;type][locals]
#	HASH OF SYSTEM FILES
$options[^_options[system]]
$handler[$[_${type}Files]]
^if(def $options.[$dir].path && $handler is junction){
	$result[^handler[$options.[$dir].path]]
}{
	$result[^hash::create[]]
}

@_exist[hash;name][locals]
#	CHECK IF FILE EXIST IN HASH PATH
^if($hash.$name){
	$result(true)
}{
	$result(false)
}

@_search[dir;name][locals]
$files[^file:list[$dir][
	$.stat(true)
]]
^files.menu{
	^if(^files.dir.bool[]){
		$folder[$files.name]
		$find[^_search[${dir}/${folder};${name}]]
	}(!^files.dir.bool[] && $files.name eq $name){
		$find[hola]
	}
}
^return[$find]

^rem{
$folder[^file:list[$path;$.stat(true)]]
^folder.menu{
	$find[^file:find[$path/$folder.name/$name]{
		^_search[$path/$folder.name;$name]
	}]
	^return[$find]
}
^folder.menu{
	^if(^folder.dir.bool[]){

		$find[^file:find[${dir}/${folder.name}/${name}]{
			^_search[${dir}/${folder.name};${name}]
		}]

	}
}
}

@_include[filename][file]
#	INCLUDE .p FILES
^if(!$include.$filename){
	$file[^file::load[text;$filename]]
	^process[$caller.self]{^taint[as-is][$file.text]}[
		$.file[$filename]
	]
	$include[$include $.$filename(true)]
}

@_save[name;data;type;path][locals]
$file[^file::create[binary;${name};^taint[${build}]]]
^response.save[binary;${self.path}/^math:md5[${table}.json]]
$response[^file::create[binary;${table};^taint[${build}]]]


@_files[dir][locals]
#	FIND ALL FILES IN DIRECTORY
$files[^file:list[$dir][
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_images[dir;name][locals]
#	FIND IMAGES FILES IN DIRECTORY
^if(def $name){
	$file[^_search[$dir;$name]]
	$result[$file]
}{
	$files[^file:list[$dir][
		$.filter[^^(\w+)(\.jpg||\.jpeg||\.png||\.gif||\.ico||\.svg||\.tif)^$]
		$.stat(true)
	]]
	$files[^files.hash[name]]
	^files.foreach[k;v]{
		^v.add[$.path[${dir}/${k}]]
	}
	$result[$files]
}

@_pFiles[dir][locals]
#	FIND SYSTEM FILES .p IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.p^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_pngFiles[dir][locals]
#	FIND IMAGE FILES .png IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.png^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_jpgFiles[dir][locals]
#	FIND IMAGE FILES .jpg IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.jpg^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_pdfFiles[dir][locals]
#	FIND .pdf FILES IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.pdf^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_xmlFiles[dir][locals]
#	FIND .xml FILES IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.xml^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_jsFiles[dir][locals]
#	FIND .js FILES IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.js^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

@_jsonFiles[dir][locals]
#	FIND .json FILES IN DIRECTORY
$files[^file:list[$dir][
	$.filter[^^(\w+)\.json^$]
	$.stat(true)
]]
$files[^files.hash[name]]
^files.foreach[k;v]{
	^v.add[$.path[${dir}/${k}]]
}
$result[$files]

###########################################################################


@to_safe[result][locals]
$replace[^table::create[nameless]{
\
^taint[^#09]
^taint[^#0A]}]
$result[^result.replace[$replace]]

@to_url_safe[result][locals]
$replace[^table::create[nameless]{
^taint[^#0A]
+	-
/	_}]
$result[^result.replace[$replace]]

@from_url_safe[result][locals]
$replace[^table::create[nameless]{
-	+
_	/}]
$result[^result.replace[$replace]]

@_jsonHash[field][locals]
$string[^taint[clean;$field]]
$result[^json:parse[$string]]

@_jsonTable[field][locals]
$string[^taint[clean;$field]]
$result[^json:parse[$string;$.array[$_parseData]]]

@_jsonGroupHash[group;field][locals]
$string[^taint[clean;$field]]
$table[^json:parse[$string;$.array[$_parseData]]]
$hash[^table.hash[$group]]
$result[$hash]

@_nosqlGroupTable[group;table][locals]
$_group[^table.hash[$group][
	$.type[table]
	$.distinct(true)
]]
$groups[^_group.keys[]]
$_hash[^groups.menu{
	$group[$groups.key]
	$_table[$_group.$group]
	$.$group[$_table]
}]
$result[$_hash]

@_nosqlGroupHash[group;table][locals]
$_group[^table.hash[$group][
	$.type[table]
	$.distinct(true)
]]
$groups[^_group.keys[]]
$_hash[^groups.menu{
	$group[$groups.key]
	$_table[$_group.$group]
	$.$group[^_table.foreach[pos;row]{
		$link[$row.link]
		$keys[^row.columns[]]
		$.$link[^keys.menu{
			$key[$keys.column]
			$.$key[$row.$key]
		}]
	}]
}]
$result[$_hash]

@_hashTable[hash][locals]
$hash[^hash::create[$hash]]
^if(def $hash.data){
	^if($hash.data.0){
    $keys[^hash.data.at(0)]
  }{
    $keys[$hash.data]
  }
	$keys[^keys.keys[]]
  $data[^table::create{^keys.foreach[k;v]{$v.key}[^#09]}]
  ^if($hash.data.0){
    ^hash.data.foreach[k;v]{
  		^data.append[$v]
  	}
  }{
    ^data.append[$hash.data]
  }
	^hash.foreach[k;v]{
    ^if($k eq data){
      $hash.$k[$data]
    }{
      $hash.$k[$v]
    }
  }
  $result[$hash]
}(!def $hash.data){
  $hash.data[^table::create{}]
  $result[$hash]
}

@_tableHash[table][locals]
$json[^json:string[$table]]
$result[^_jsonHash[$json]]

@_parseData[key;value][locals]
$result[]
^if($value){
  $keys[^value.0.keys[]]
  $result[^process{^^table::create{^keys.foreach[k;v]{$v.key}[^#09]}}]
  ^value.foreach[k;v]{
    ^result.append[$v]
  }
}

@_formHash[fields;options][locals]
$fields[^hash::create[$fields]]
$options[^hash::create[$options]]
$result[
	^fields.foreach[key;value]{
		^switch[$key]{
			^case[link]{$.url[$value]}
			^case[catalog]{$.catalog[$value]}
			^case[attr]{$.attr[$value]}
			^case[login]{$.login[$value]}
			^case[email]{$.email[$value]}
			^case[name]{$.name[$value]}
			^case[lastname]{$.lastname[$value]}
			^case[pwd]{$.pass[$value]}
			^case[enter]{$.submit[login]}
			^case[register]{$.submit[register]}
			^case[fileform]{}
			^case[DEFAULT]{$.[$key][$value]}
		}
	}
	^options.foreach[key;value]{
		$.[$key][$value]
	}
]

@variations[num;nominative;genitive_singular;genitive_plural][locals]
^if($num > 10 && (($num % 100) \ 10) == 1){
        $result[$genitive_plural]
}{
        ^switch($num % 10){
                ^case(1){$result[$nominative]}
                ^case(2;3;4){$result[$genitive_singular]}
                ^case(5;6;7;8;9;0){$result[$genitive_plural]}
        }
}

@printSettings[data;parent][locals]
$lang[^_classes[lang;$options]]
$lang[^lang.select[admin]]
^data.sort[k;v]{$k}
$table[$data.$parent]
$result[]
^if($table){
	$result[<ul class="control">^table.menu{
		<li>
			<div class="name">$lang.[$table.link].name</div>
			<div class="buttons">
				<div class="button"><a href="?edit=${table.id}&type=ns&tbl=settings"><i class="icon mbri-edit2"></i></a></div>
				<div class="button"><a href="?delete=${table.id}&type=ns&tbl=settings"><i class="icon mbri-trash"></i></a></div>
			</div>
		</li>
		^printSettings[$data;$table.link]
	}</ul>]
}

@printAdminMenu[data;parent][locals]
$lang[^_classes[lang;$options]]
$lang[^lang.select[admin]]
^data.sort[k;v]{$k}
$table[$data.$parent]
$result[]
^if($table){
	^table.sort($table.sort)
	$result[<ul>^table.menu{
		^if($request:uri eq '/genus/$table.link'){
			<li class="current">$lang.[$table.link].name</li>
		}{
			<li><a href="/genus/$table.link" title="$lang.[$table.link].name">$lang.[$table.link].name</a></li>
		}
		^printAdminMenu[$data;$table.link]
	}</ul>]
}

@printSortMenu[data;parent][locals]
^data.sort[k;v]{$k}
$table[$data.$parent]
$result[]
^if($table){
	^table.sort($table.sort)
	$result[<ul>^table.menu{
		<li>$table.name</li>
		^printSortMenu[$data;$table.link]
	}</ul>]
}

@_printMenu_old[tree;pID][locals]
^tree.sort[k;v]($k)
$pID(^pID.int(^tree._at[first;key]))
$cID[$tree.$pID]

$result[]
^if($cID){
	^cID.sort($cID.sort)
	$result[<ul>^cID.menu{
		^if($request:uri eq '/admin/$cID.link'){
			<li class="current">$cID.name</li>
		}{
			<li><a href="/admin/$cID.link" title="$cID.name">$cID.name</a></li>
		}
		^_printMenu[$tree;$cID.id]
	}</ul>]
}

@query[params]
$table[$params.table]
$type[$params.type]
$rows[^switch[$params.table]{
	^case[site]{id, logo, name, catchword, title, keywords, description}
	^case[contacts]{id, email, phonenumber, address, schedule, gps_width, gps_length}
	^case[social]{id, img, name, link}
	^case[subscribers]{id, email, phone, name, lastname}
	^case[groups]{id, img, name, link}
	^case[users]{uID, gID, login, email, phone, name, surname, patronymic, gender, birthday, pass, registered}
	^case[counter]{id, cID, md5, navigator, screen, timezone, create_at}
	^case[views]{id, sID, cID, page, view_at}
	^case[sessions]{id, uID, uIP, sID, cID, create_at}
	^case[types]{id, img, name, link}
	^case[pattern]{id, img, name, link}
	^case[delivery]{id, img, name, link}
	^case[payment]{id, img, name, link}
	^case[pages]{eID, tID, uID, sort, active, slider, menu, title, keywords, description, url, (
		SELECT GROUP_CONCAT(u.url ORDER BY u.eID SEPARATOR '/')
		FROM pages AS u
		JOIN path AS r ON (u.eID = r.anc)
		WHERE 1 = 1
			AND p.dsc = r.dsc
			AND r.anc > 0
	) AS uri, name, content, img, price, create_at, update_at}
	^case[brands]{id, img, name, link}
	^case[attributes]{id, eID, img, name, type, link, attr}
	^case[path]{anc, dsc, lvl}
	^case[basket]{id, bID, items, create_at}
	^case[orders]{oID, number, uID, sID, cID, bID, dID, pID, items, order_at}
	^case[bring]{oID, name, lastname, email, phone, address, status}
	^case[bankcard]{id, uID, number, holder, valid, cvv}
	^case[DEFAULT]{*}
}]
$select[$params.select]
$orand[^switch[$params.orand]{
	^case[AND]{ AND }
	^case[OR]{ OR }
	^case[DEFAULT]{ AND }
}]
$options[$params.options]

$result[
	$.table[$table]
	$.type[$type]
	$.rows[$rows]
	^if(def $select){
		$.select[^select.foreach[key;value]{
			$.[$key][$value]
		}]
	}
	^if(def $options){
		$.options[^options.foreach[key;value]{
			$.[$key][$value]
		}]
	}
	$.orand[$orand]
]

@request[data]
^self._transaction{
	^switch[$data.type]{
			^case[table]{
				$result[^table::sql{
					SELECT $data.rows
					FROM $data.table
					^if($data.table eq pages){
						AS n
						JOIN path AS p ON (p.dsc = n.eID AND p.lvl = 1)
					}
					^if($data.select){WHERE ^data.select.foreach[key;value]{${key} ${value}}[$data.orand]}
					^if(def $data.options.order){
						ORDER BY $data.options.order ^if(def $data.options.sort){$data.options.sort}
					}
					^if(def $data.options.group){
						GROUP BY $data.options.group
					}
				}[
					^if(def $data.options.limit){
						$.limit(^data.options.limit.int(0))
					}
					^if(def $data.options.offset){
						$.offset(^data.options.offset.int(0))
					}
					^if(def $data.options.distinct){
						$.distinct($data.options.distinct)
					}
					^if(def $data.options.type){
						$.type[$data.options.type]
					}
				]]
			}
			^case[hash]{
				$result[^hash::sql{
					SELECT $data.rows
					FROM $data.table
					^if($data.table eq pages){
						AS n
						JOIN path AS p ON (p.dsc = n.eID AND p.lvl = 1)
					}
					^if($data.select){WHERE ^data.select.foreach[key;value]{${key} ${value}}[$data.orand]}
					^if(def $data.options.order){
						ORDER BY $data.options.order ^if(def $data.options.sort){$data.options.sort}
					}
					^if(def $data.options.group){
						GROUP BY $data.options.group
					}
				}[
					^if(def $data.options.limit){
						$.limit(^data.options.limit.int(0))
					}
					^if(def $data.options.offset){
						$.offset(^data.options.offset.int(0))
					}
					^if(def $data.options.distinct){
						$.distinct($data.options.distinct)
					}
					^if(def $data.options.type){
						$.type[$data.options.type]
					}
				]]
			}
			^case[DEFAULT]{
				$result[^table::sql{
					SELECT $data.rows
					FROM $data.table
					^if($data.table eq pages){
						AS n
						JOIN path AS p ON (p.dsc = n.eID AND p.lvl = 1)
					}
					^if($data.select){WHERE ^data.select.foreach[key;value]{${key} ${value}}[$data.orand]}
					^if(def $data.options.order){
						ORDER BY $data.options.order ^if(def $data.options.sort){$data.options.sort}
					}
					^if(def $data.options.group){
						GROUP BY $data.options.group
					}
				}[
					^if(def $data.options.limit){
						$.limit(^data.options.limit.int(0))
					}
					^if(def $data.options.offset){
						$.offset(^data.options.offset.int(0))
					}
					^if(def $data.options.distinct){
						$.distinct($data.options.distinct)
					}
					^if(def $data.options.type){
						$.type[$data.options.type]
					}
				]]
			}
	}
}

@_transaction[code][locals]
^connect[$self.connect_string]{
	^void:sql{BEGIN}
	^try{
		$result[$code]

		^void:sql{COMMIT}
	}{
		^void:sql{ROLLBACK}
	}
}
