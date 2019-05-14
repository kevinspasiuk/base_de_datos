
-- correr despúes despues de carga_reocrrido_colectivos_lucas.sql
drop table if exists recorrido_colectivos_alternativo;
create table recorrido_colectivos_alternativo as
select 
	linea::integer,
	sentido,
	recorrido,
	st_linemerge(geom) as geom
from lineasnac_polyline ;

-- creo la tabla de colectivos_por_parada 
with tabla_2 as (
select  id_parada, 
	    linea_colectivo,
		count( distinct sentido) as q
from (
select 
	t1.id_parada,
	t1.linea_colectivo,
	sentido,
	recorrido
from colectivos_por_parada t1
inner join paradas t2 on (t1.id_parada = t2.id_parada)
inner join recorrido_colectivos_alternativo t3 on (t1.linea_colectivo = t3.linea and ST_Distance(t2.point_posicion,t3.geom) < 0.1)
order by id_parada, linea_colectivo
) as tabla
group by id_parada, linea_colectivo)
select 
q,
count (q)
from tabla_2
group by q;


select 
	t1.id_parada,
	t1.linea_colectivo,
	sentido,
	recorrido,
	ST_Distance(t2.point_posicion,t3.geom) as distance
from colectivos_por_parada t1
inner join paradas t2 on (t1.id_parada = t2.id_parada)
inner join recorrido_colectivos_alternativo t3 on (t1.linea_colectivo = t3.linea and ST_Distance(t2.point_posicion,t3.geom) < 0.1)
order by id_parada, linea_colectivo