################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
jwt

@OPTIONS
dynamic

################################################################
##
##  $jwt[^_classes[jwt;$options]]
##
##  $encode[^jwt.encode[$hash;$secret]]
##
##  $decode[^jwt.decode[$encode;$secret]]
##
################################################################

@create[options]
$mysql[^_classes[mysql;$options]]
$nosql[^_classes[nosql;$options]]

@sign[header;payload;secret][locals]
$result[^to_safe[^math:digest[sha256;${header}.${payload}][
	$.format[base64]
	$.hmac[$secret]
]]]

@encode[payload;secret][locals]
$header[^json:string[
	$.alg[HS256]
	$.typ[JWT]
]]
$header[^to_safe[^header.base64[]]]
$payload[^json:string[$payload]]
$payload[^to_safe[^payload.base64[]]]
$signature[^sign[$header;$payload;$secret]]
$result[${header}.${payload}.${signature}]

@decode[token;secret][locals]
$result[]
$token[^token.split[.;h]]
$header[$token.0]
$payload[$token.1]
$signature[$token.2]
^if(^sign[$header;$payload;$secret] eq $signature){
	$result[^json:parse[^taint[as-is;^string:base64[^from_safe[$payload]]]]]
}

@to_safe[result][locals]
$replace[^table::create[nameless]{
^taint[^#0A]
+	-
/	_}]
$result[^result.replace[$replace]]

@from_safe[result][locals]
$replace[^table::create[nameless]{
-	+
_	/}]
$result[^result.replace[$replace]]
