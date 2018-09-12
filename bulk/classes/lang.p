################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
lang

@OPTIONS
dynamic

################################################################
##
##  $lang[^_classes[lang;$options]]
##  $lang[^lang.select[]]
##  $lang.[$key].name
##
################################################################

@create[options]
$self.options[^hash::create[$options]]
$genus[^_use[bulk/genus;genus]]
$get[^_classes[get;$self.options]]

@file[type][locals]
$cache[^_classes[cache;$self.options]]
$result[]
^switch[$type]{
  ^case[admin]{
    $name[admin]
    $path[/bulk/genus/admin]
    $current[^self.current[]]
    $lang[$current.1]
    $file[^file::load[binary;${path}/lang/${lang}.json]]
    $base64[^cache.init[system;${name}_${lang};31536000]{^file.base64[]}]
  }
  ^case[current]{
    $name[$self.options.settings.site.template_name]
    $path[$self.options.settings.site.template_path]
    $current[^self.current[]]
    $lang[$current.1]
    $file[^file::load[binary;${path}/lang/${lang}.json]]
    $base64[^cache.init[system;${name}_${lang};31536000]{^file.base64[]}]
  }
  ^case[DEFAULT]{
    $file[^file::load[binary;/bulk/classes/lang.json]]
    $base64[^cache.init[system;lang;31536000]{^file.base64[]}]
  }
}
^if(def $base64){
  $result[$base64]
}

@hash[][locals]
$file[^file::base64[^self.file[]]]
$table[^get._jsonTable[$file.text]]
$hash[^table.hash[1]]
$result[]
^if($hash is hash){
  $result[$hash]
}

@table[][locals]
$file[^file::base64[^self.file[]]]
$table[^get._jsonTable[$file.text]]
$result[]
^if($table is table){
  $result[$table]
}

@current[][locals]
$hash[^self.hash[]]
$lang[$self.options.settings.site.lang]
$result[]
^if(def $hash.$lang){
  $result[$hash.$lang]
}

@select[type][locals]
$file[^file::base64[^self.file[$type]]]
$hash[^get._jsonGroupHash[link;$file.text]]
$result[]
^if(def $hash){
  $result[$hash]
}

@icon[lang][locals]
$icon[<i class="icon flag-icon flag-icon-${lang}"></i>]
$result[$icon]
