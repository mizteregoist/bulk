@CLASS
core

@create[options][locals]
$self.options[^hash::create[$options]]

@router[][locals]
$exception[^_exception[]]
<pre>^json:string[$exception]</pre>

#$result[^pattern.match[^^\/\#(\w+)\#\/\#(\w+)\#^$][g]{$match.2}]
^rem{
$rules[$options.rules]
$nesting[$options.route.nesting]
$pattern[$options.route.pattern]
$pattern[^pattern.trim[both;/]]
$pattern[^pattern.split[/;l;part]]
$pattern[^pattern.menu{$.[^pattern.part.trim[both;#]][$pattern.part]}]
$pattern[^pattern.foreach[k;v]{^if($rules.$k){$.[$k][$rules.$k]}}]
<form class="test" action="?hola=fame" method="post">
	<input type="text" name="text">
	<input type="file" name="file">
	<input type="submit" name="send" value="Отправить">
</form>
}

@_exception[][locals]
$result[]
$nosql[^_use[nosql]]
$exceptions[^nosql.table[exceptions]]
^if(!$exceptions.data){
	$hash[^_options[exceptions]]
	^hash.foreach[k;h]{
		$insert[^nosql.insert[$exceptions;$h]]
	}
	^memory:compact[]
}{
	$url[^table::create{node}]
	$req[^self.options.url.trim[both;/]]
	$uri[^req.split[/;l;part]]
	^uri.sort(^uri.line[])[asc]
	^uri.menu{
		$path[${path}/${uri.part}]
		^url.insert[${path}]
	}
	^url.sort(^url.line[])[asc]
	^url.menu{
		$exception[^nosql.select[$exceptions.data]($exceptions.data.node eq $url.node)]
		^if(def $exception.id){
			^break[]
			^memory:compact[]
		}
	}
	$result[$exception]
}

@session[][locals]
$counter[^counter[]]
$ip[^ip_map[]]
id	md5	counter_id

@counter[][locals]
id	user_agent	...

@ip_map[][locals]
id	ip	session_id	counter_id
