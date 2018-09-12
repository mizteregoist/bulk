@USE
/bulk/genus/methods.p
/bulk/genus/options.p

@main[]
$core[^_use[core][^_dispatch[$form:@]]]
^core.router[]


@event[event;method;data]
$handler[$[$method]]
^if($handler is junction){
	^handler[;$.[$event][$data]]
}

@listener[data;options]
$data[^hash::create[$data]]
$options[^hash::create[$options]]
$result[^hash::create[]]
^if(def $options.before){
	^result.add[$options.before]
}
^if(def $data){
	^result.add[$data]
}
^if(def $options.after){
	^result.add[$options.after]
}
