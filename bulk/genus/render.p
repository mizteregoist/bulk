@CLASS
render

@create[options]
$self.options[^hash::create[$options]]
$result[^router[$options]]

@router[data][locals]
$data[$self.options]
$options[^_options[router]]
$result[$data]
#^controller[$data]

@tree[]
id	anc	dsc	level

@element[]
id	group	link	path	content_id

@content[]

@error[code][locals]
$code[^code.int[]]
^switch[$code]{
	^case(404){

	}
}
