@_options[type][locals]
$handler[$[_${type}_]]
^if($handler is junction){
	$result[^handler[]]
}{
	$result[^hash::create[]]
}

@_system_[][locals]
$result[
	$.local[
		$.document-root[/web/lab/bulk]
		$.nosql[/nosql]
		$.cgi-bin[/cgi-bin]
	]
	$.public[
		$.document-root[/web/lab/bulk/public_html]
		$.api[/bulk/genus/api]
	]
	$.api[
		$.path[/bulk/genus/api]
	]
	$.genus[
		$.path[/bulk/genus]
	]
	$.classes[
		$.path[/bulk/classes]
	]
	$.manage[
		$.path[/bulk/genus/manage]
	]
	$.scripts[
		$.path[/bulk/scripts]
	]
	$.styles[
		$.path[/bulk/styles]
	]
	$.templates[
		$.path[/bulk/templates]
	]
]

@_session_[][locals]
$result[
	$.server[
		$.host[$env:HTTP_HOST]
		$.name[$env:SERVER_NAME]
		$.addr[$env:SERVER_ADDR]
		$.port[$env:SERVER_PORT]
		$.method[$env:REQUEST_METHOD]
	]
	$.session[
		$.addr[$env:REMOTE_ADDR]
		$.port[$env:REMOTE_PORT]
		$.uri[$env:REQUEST_URI]
		$.query[$env:QUERY_STRING]
	]
]


@_parent_[]

@_child_[]

@_path_[]


@_index_[]

@_DATA[type;raw]


^_component[slider][

][
	$.limit[]
]


EXCEPTION
id	component
1		geekco:catalog


/components/geekco/catalog/
	-	component.p	{data;options}
		use:
	-	methods.p
	-	options.p
	- template.p
	^_component[geekco/catalog;$data;$options]



id	level	parent	junction	template	pattern												nesting	junction
1		0			0				genus			manage		/genus/_parent_/_child_				6
2		1			1				api				api				/genus/api										0				base64 and process
3		0			0				shop			default		/shop/_path_									6				catalog

id	rule			mask				type
1		unit			#unit#			link
2		element		#element#		uuid

@_exceptions_[][locals]
$result[
	$.0[
		$.node[/genus]
		$.pattern[/genus/_section_/_item_]
		$.expression[^^(\/genus).+?^$]
		$.rule[manage]
	]
	$.1[
		$.node[/genus/api]
		$.pattern[/genus/api]
		$.expression[^^(\/genus\/api).+?^$]
		$.rule[api]
	]
]

@_router_[][locals]
$result[
	$.rules[
#	JUNCTION METHODS
		$.unit[
			$.mask[#unit#]
			$.type[link]
		]
		$.subunit[
			$.mask[#subunit#]
			$.type[link]
		]
#	URI METHODS
		$.path[
			$.mask[#path#]
			$.type[link]
		]
		$.partition[
			$.mask[#partition#]
			$.type[link]
		]
		$.element[
			$.mask[#element#]
			$.type[uuid]
		]
		$.filter[
			$.mask[#filter#]
			$.type[filter]
		]
	]
	$.route[
		$.template[default]
		$.pattern[/#partition#/#element#]
		$.nesting[4]
		$.junction[render]
	]
	$.exception[
#	UNIT
		$.genus[
##	MODEL
			$.template[manage]
			$.pattern[/genus/#partition#/#element#]
			$.nesting[4]
			$.junction[render]
##	SUBUNIT
			$.subunit[
###	UNIT
				$.api[
					$.template[api]
					$.pattern[/genus/api/#filter#]
					$.nesting[10]
					$.junction[api]
				]
			]
		]
#	UNIT
		$.shop[
			$.template[default]
			$.pattern[/shop/#path#]
			$.nesting[6]
			$.junction[catalog]
		]
	]
]
