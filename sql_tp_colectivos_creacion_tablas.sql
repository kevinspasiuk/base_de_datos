-- cargo tabla de colectivos por parada
DROP TABLE IF EXISTS colectivos_por_parada;

create table colectivos_por_parada (
	id_parada integer, 
	linea_colectivo integer
);

COPY colectivos_por_parada
FROM 'C:\Users\kspasiuk\Documents\base_de_datos\tp_colectivos\fuentes\paradas-de-colectivo-parseado.csv'
DELIMITER ';'
CSV HEADER         --para indicar que la primera l ́ınea es el encabezado
ENCODING 'LATIN1';

-- cargo tabla info de recorridos
DROP TABLE IF EXISTS info_recorridos;

create table info_recorridos(
	WKT text not null,
	ID integer not null,
	LINEA integer,
	TIPO_SERVICIO text,
	RAMAL text,
	SENTIDO text
);

COPY info_recorridos
FROM '/home/kevin/Documents/base_de_datos/fuentes/recorrido-colectivos.csv'
DELIMITER ';'
CSV HEADER         
ENCODING 'LATIN1';

-- creo tabla lineas 
DROP TABLE IF EXISTS lineas;

create table lineas as
select distinct 
	linea,
	ramal,
	sentido
from info_recorridos;

ALTER TABLE lineas ADD CONSTRAINT id_linea_ramal_sentido PRIMARY KEY (linea,ramal,sentido);

-- cargo tabla de info de paradas. 
DROP TABLE IF EXISTS info_paradas;

CREATE TABLE info_paradas (
	x double precision,
	y double precision,
	stop_id integer not null,
	tipo text,
	calle text,
	numero text,
	entre1 text,
	entre2 text,
	lineas text,
	dir_nor text,
	calle_nor text,
	ALTURA_NOR integer,
	COORDX text,
	COORDY text,
	METROBUS text,
	STOP_NAME text,
	STOP_DESC text,
	FUENTE text,
	VERIFICADA text,
	FECHA_ULTI date
);

COPY info_paradas
FROM 'C:\Users\kspasiuk\Documents\base_de_datos\tp_colectivos\fuentes\paradas-de-colectivo.csv'
DELIMITER ';'
CSV HEADER         --para indicar que la primera l ́ınea es el encabezado
ENCODING 'LATIN1';

-- creo tabla paradas 
DROP TABLE IF EXISTS paradas;

create table paradas as 
select 
	stop_id as id_parada,
	calle,
	numero as altura,
	st_makepoint(x,y) as point_posicion
from info_paradas
where (calle is not null and numero is not null and x is not null and y is not null);

--agrego clave primaria en paradas
ALTER TABLE paradas ADD CONSTRAINT id_parada PRIMARY KEY (id_parada);


-- creo tabla posiciones 
DROP TABLE IF EXISTS posiciones;

create table posiciones as 
select distinct 
	x as longitud,
	y as latitud,
	st_makepoint(x,y) as point_posicion
from info_paradas 
where x is not null and y is not null; 

-- agrego clave primaria en posiciones
ALTER TABLE posiciones ADD CONSTRAINT id_posicion PRIMARY KEY (point_posicion);

-- agrego clave foraneas en paradas
ALTER TABLE paradas ADD CONSTRAINT id_posicion FOREIGN KEY (point_posicion) REFERENCES posiciones;

