################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
cache

@OPTIONS
dynamic

################################################################
##
##	$cache[^_classes[cache;$options]]
##
##	^cache.init[folder;name;3600]{$code}
##
##	^cache.delete[name]
##
##	^cache.clean[]
##
################################################################

@create[options]
$self.path[/bulk/cache]
$self.base[^file:list[$self.path;$.stat(true)]]
$self.base[^base.hash[name]]
$self.options[^hash::create[$options]]
$nosql[^_classes[nosql;$options]]

@search[path;name][locals]
$folder[^file:list[$path;$.stat(true)]]
^folder.menu{
	$find[^file:find[$path/$folder.name/$name]{
		^search[$path/$folder.name;$name]
	}]
	^return[$find]
}

@init[folder;name;time;code][locals]
$search[^search[$self.path;$name]]
$path[$self.path/$folder/$name]
^if(-f $search){
	^cache[$path]($time){
		$code
	}
}{
	$cache[^nosql.table[cache]]
	$roll($time/60/60/24)
	$expires[^_time[unix](+$roll)]
	$hash[
		$.name[$name]
		$.path[$path]
		$.time[$time]
		$.expires[$expires]
	]
	$insert[^nosql.insert[$cache;$hash]]
	^cache[$path]($time){
		$code
	}
}

@delete[name][locals]
$search[^search[$self.path;$name]]
^if(-f $search){
	$cache[^nosql.table[cache]]
	$delete[^nosql.delete[$cache][
		$.name[$name]
	]]
	^cache[$search]
}

@clean[][locals]
$time[^_time[unix]]
$cache[^nosql.table[cache]]
$select[^nosql.select[$cache]($cache.expires <= $time)]
^select.menu{
	^if(-f $select.path){
		^cache[$select.path]
	}
}
