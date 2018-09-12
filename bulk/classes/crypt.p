################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
crypt

@OPTIONS
dynamic

################################################################
##
##  $crypt[^_classes[crypt;$options]]
##
##  $encrypt[^crypt.encrypt[$string;$secret][
##    $.type[aes|des]
##    $.encode[hex|base64]
##  ]]
##
##  $decrypt[^crypt.decrypt[$encrypt;$secret][
##    $.type[aes|des]
##    $.encode[hex|base64]
##  ]]
##
##  $token[^crypt.makeToken[$hash;$secret][
##    $.type[aes|des]
##    $.encode[hex|base64]
##  ]]
##
##  $validate[^crypt.validateToken[$token;$secret][
##    $.type[aes|des]
##    $.encode[hex|base64]
##  ]]
##
################################################################

@create[options]
$mysql[^_classes[mysql;$options]]

@encrypt[data;secret;options][locals]
$options[^hash::create[$options]]
$result[^mysql.sql[string]{
  select sql_no_cache
  ^if($options.encode eq 'hex'){hex}
  ^if($options.encode eq 'base64'){to_base64}
  (
    ^if($options.type eq 'aes'){aes_encrypt}
    ^if($options.type eq 'des'){des_encrypt}
    ('^taint[$data]', '^taint[$secret]')
  )
}]

@decrypt[data;secret;options][locals]
$options[^hash::create[$options]]
$result[^mysql.sql[string]{
  select sql_no_cache
  ^if($options.type eq 'aes'){aes_decrypt}
  ^if($options.type eq 'des'){des_decrypt}
  (
    ^if($options.encode eq 'hex'){unhex}
    ^if($options.encode eq 'base64'){from_base64}
    ('^taint[$data]'), '^taint[$secret]'
  )
}]

@makeToken[data;secret;options][locals]
$options[^hash::create[$options]]
$result[^data.foreach[k;v]{${k}=${v}}[|]]
$result[^encrypt[${result}|^math:crypt[$result|$secret;^$apr1^$];$secret][
  $.type[$options.type]
  $.encode[$options.encode]
]]

@validateToken[token;secret;options][locals]
$result[^hash::create[]]
$options[^hash::create[$options]]
$token[^decrypt[^token.trim[both];$secret][
  $.type[$options.type]
  $.encode[$options.encode]
]]
$parts[^token.split[|;lv]]
^if($parts < 2){^return[invalid]}
^parts.foreach[k;v]{
  $str[$v.piece]
  $key[^str.match[(.+)\=(.+)][g]{$match.1}]
  $value[^str.match[(.+)\=(.+)][g]{$match.2}]
  ^if($k == ($parts - 1)){
    $signature[$v.piece]
    ^break[]
  }
  $result.[$key][$value]
}
$data[^token.left(^token.length[] - ^signature.length[] - 1)]
^if(!def $signature || $signature ne ^math:crypt[${data}|$secret;$signature]){
  ^return[invalid]
}
