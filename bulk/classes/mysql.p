################################################################
##		#####		##		##	##			##	##		##		##	######		##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####		##		##	##			####			##		##		##			##
##		##	##	##		##	##			## ## 		##		##		##			##
##		#####			####		######	##	##			####		######		##
################################################################

@CLASS
mysql

@OPTIONS
dynamic

################################################################
##
##	$delete[^self.delete[site][
##		$.title[= 'Bulk UI']
##		$.name[= 'Bulk UI']
##	][
##		$.orand[AND]
##		$.orderBy[]
##		$.limit(1)
##	]]
##
##	$insert[^self.insert[site][
##		$.title[Bulk UI]
##		$.name[Bulk UI]
##		$.catchword[New OGeneration]
##	]]
##
##	$select[^self.select[site][
##		$.name[= 'Bulk UI']
##	][
##		$.orand[AND]
##		$.groupBy[]
##		$.orderBy[]
##		$.having[]
##		$.limit(1)
##	]]
##
##	$update[^self.update[site][
##		$.name[Updated Bulk UI]
##	][
##		$.title[= 'Bulk UI']
##		$.orand[AND]
##	]]
##
################################################################

@create[options]
$genus[^_use[bulk/genus;genus]]
$nosql[^_classes[nosql;$options]]
$get[^_classes[get;$options]]

^rem{
SHOW CREATE DATABASE IF NOT EXISTS genus
SHOW COLUMNS FROM path FROM genus
SHOW CREATE TABLE genus.path
SHOW TABLES IN genus
}

@tables[][locals]
$mysql[site,keys,mark,groups,types,pattern,attributes,users,pages,path,content,profiles]
$develop[bankcard,basket,brands,bring,contacts,delivery,orders,payment,social,subscribers]
$result[^mysql.split[,]]

@pattern[table][locals]
$bone[^switch[$table]{
	^case[attributes;groups;pattern;types]{id,group,title,name,link,data}
	^case[site]{id,logo,name,tagline,title,keywords,description}
	^case[keys]{id,active,server,email,license,api,secret,public,access,reload,connect,created,expires}
	^case[mark]{id,salt,md5,lifetime}
	^case[path]{anc,dsc,lvl}
	^case[pages]{id,tID,uID,sort,active,created,updated}
	^case[content]{id,eID,since,until,slider,menu,title,keywords,description,link,path,name,img,content}
	^case[users]{id,gID,login,email,phone,created,pass}
	^case[profiles]{id,uID,name,surname,patronymic,birthday,gender}
	^case[DEFAULT]{}
}]
$result[^bone.split[,]]

@types[name][locals]
$bone[^switch[$name]{
	^case[id]{INT(10) UNSIGNED NOT NULL AUTO_INCREMENT}
	^case[uID;gID;tID;eID;sort]{INT(10) UNSIGNED NOT NULL}
	^case[anc;dsc;lvl]{INT(10) UNSIGNED NOT NULL DEFAULT '0'}
	^case[keywords;description;data;content;img;logo]{TEXT NOT NULL}
	^case[created;updated;expires;lifetime;since;until;birthday]{DATETIME NOT NULL}
	^case[DEFAULT]{char(255) NOT NULL}
}]
^return[`$name` $bone]

@init[][locals]
$true[^hash::create[]]
$false[^hash::create[]]
$table[^nosql.table[connect]]
$response[^hash::create[]]
^if(def $table.data){
	$tables[^self.tables[]]
	$tables[^tables.hash[piece][$.type[hash]]]
	$installed[^self.transaction{^table::sql{SHOW TABLE STATUS FROM $table.data.name}}]
	$installed[^installed.hash[Name][$.type[hash]]]
	^tables.foreach[k;v]{
		^if(^installed.contains[$k]){
			$true.$k(true)
		}{
			$false.$k(false)
		}
	}
	$true[^true.keys[]]
	$false[^false.keys[]]
	^if(def $false){
		^false.menu{
			^self.make[$false.key]
		}
		$result[
			$.progress[installation]
			$.status(301)
		]
	}(def $true && !def $false){
		$bulk[
			$.groups[
				$.admin[Администратор]
				$.redactor[Редактор]
				$.moderator[Модератор]
				$.manager[Менеджер]
				$.operator[Оператор]
				$.user[Пользователь]
				$.robot[Робот]
			]
			$.types[
				$.sections[Разделы]
				$.pages[Страницы]
				$.entries[Записи]
				$.stores[Витрины]
				$.goods[Товары]
				$.orders[Заказы]
			]
		]
		$status[
			$.site[^if(^self.select[site]){true}{false}]
			$.groups[^if(^self.select[groups]){true}{false}]
			$.types[^if(^self.select[types]){true}{false}]
			$.users[^if(^self.select[users]){true}{false}]
		]
		$request[^status.foreach[k;v]{
			^if($v eq 'false' && def $bulk.$k){
				$block[$k]
				^bulk.$k.foreach[k;v]{
					^self.insert[$block][
						$.name[$v]
						$.link[$k]
					]
				}
			}
		}]
		^if($status.site eq 'false'){
			$result[
				$.progress[tuning]
				$.status(301)
			]
			^if($status.users eq 'false'){
				$result[
					$.progress[tuning]
					$.status(301)
				]
			}
		}{
			$result[
				$.progress[ready]
				$.status(200)
			]
		}
	}
}{
	$result[
		$.progress[not_installed]
		$.status(404)
	]
}

@connect[][locals]
$result[]
$table[^nosql.table[connect]]
$table[$table.data]
^if(def $table){
	$result[mysql://${table.user}:${table.pass}@${table.host}/${table.name}?charset=${table.charset}]
}

@drop[table][locals]
^self.sql[void]{
	DROP TABLE IF EXISTS `$table`;
}
$result(0)

@make[table]
$col[^self.pattern[$table]]
^self.sql[void]{
	CREATE TABLE IF NOT EXISTS `$table` (
		^col.menu{
			^self.types[$col.piece]
		}[, ]
		^col.menu{
			^switch[$col.piece]{
				^case[id]{, PRIMARY KEY (id)}
				^case[uID]{, FOREIGN KEY (uID) REFERENCES users (id)}
				^case[gID]{, FOREIGN KEY (gID) REFERENCES groups (id)}
				^case[tID]{, FOREIGN KEY (tID) REFERENCES types (id)}
				^case[eID]{, FOREIGN KEY (eID) REFERENCES pages (id) ON DELETE CASCADE ON UPDATE CASCADE}
				^case[anc]{, PRIMARY KEY(anc, dsc, lvl)}
				^case[dsc]{, FOREIGN KEY (dsc) REFERENCES pages (id) ON DELETE CASCADE ON UPDATE CASCADE}
			}
		}
	)
	ENGINE=InnoDB
	DEFAULT CHARSET=utf8
	AUTO_INCREMENT=1
}

@select[table;query;params][locals]
$col[^self.pattern[$table]]
$col[^col.hash[piece][$.type[hash]]]
$query[^hash::create[$query]]
$params[^hash::create[$params]]
$request[^hash::create[]]
^col.foreach[k;v]{^if(def $query.$k){$request.$k[$query.$k]}}
^self.transaction{
	$result[^self.sql[table]{
		SELECT ^col.foreach[k;v]{`$k`}[, ]
		FROM `$table`
		WHERE ^if(def $request){^request.foreach[k;v]{${k} ${v}}[ $params.orand ]}{1=1}
		^if(def $params.groupBy){
			GROUP BY $params.groupBy
		}
		^if(def $params.having){
			HAVING $params.having
		}
		^if(def $params.orderBy){
			ORDER BY $params.orderBy
		}
	}[
		^if(def $params.limit){
			$.limit(^params.limit.int(0))
		}
	]]
}

@insert[table;data][locals]
$col[^self.pattern[$table]]
$col[^col.hash[piece][$.type[hash]]]
$data[^hash::create[$data]]
$request[^hash::create[]]
^col.foreach[k;v]{^if($k ne 'id'){$request.$k[$data.$k]}}
^self.sql[void]{
	INSERT INTO `$table` (^request.foreach[k;v]{`$k`}[, ])
	VALUES (^request.foreach[k;v]{'$v'}[, ])
}
$result(^self.sql[int]{
	SELECT LAST_INSERT_ID()
}[
	$.default(0)
])

@update[table;data;params][locals]
$col[^self.pattern[$table]]
$col[^col.hash[piece][$.type[hash]]]
$data[^hash::create[$data]]
$params[^hash::create[$params]]
$query[^hash::create[]]
$request[^hash::create[]]
^col.foreach[k;v]{^if(def $data.$k){$query.$k[$data.$k]}}
^col.foreach[k;v]{^if(def $params.$k){$request.$k[$params.$k]}}
^self.sql[void]{
	UPDATE $table
	SET ^query.foreach[k;v]{$k = '$v'}[, ]
	WHERE ^request.foreach[k;v]{${k} ${v}}[ $params.orand ]
}

@delete[table;query;params][locals]
$col[^self.pattern[$table]]
$col[^col.hash[piece][$.type[hash]]]
$query[^hash::create[$query]]
$params[^hash::create[$params]]
$request[^hash::create[]]
^col.foreach[k;v]{^if(def $query.$k){$request.$k[$query.$k]}}
^self.sql[table]{
	DELETE FROM $table
	WHERE ^request.foreach[k;v]{${k} ${v}}[ $params.orand ]
	^if(def $params.orderBy){
		ORDER BY $params.orderBy
	}
}[
	^if(def $params.limit){
		$.limit(^params.limit.int(0))
	}
]

@sql[type;code;params][locals]
^self.transaction{
	$result[^switch[$type]{
		^case[int]{^int:sql{$code}[$params]}
		^case[double]{^double:sql{$code}[$params]}
		^case[file]{^file::sql{$code}[$params]}
		^case[hash]{^hash::sql{$code}[$params]}
		^case[string]{^string:sql{$code}[$params]}
		^case[table]{^table::sql{$code}[$params]}
		^case[void]{^void:sql{$code}[$params]}
		^case[DEFAULT]{}
	}]
}

@transaction[code][locals]
$connect[^self.connect[]]
^if(def $connect){
	^connect[$connect]{
		^void:sql{BEGIN}
		^try{
			$result[$code]

			^void:sql{COMMIT}
		}{
			^void:sql{ROLLBACK}
		}
	}
}
