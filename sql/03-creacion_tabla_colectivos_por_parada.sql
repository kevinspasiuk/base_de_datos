
-- correr despúes despues de carga_reocrrido_colectivos_lucas.sql
drop table if exists recorrido_colectivos;
create table recorrido_colectivos as
select 
	linea::integer,
	sentido,
	recorrido,
	st_linemerge(geom) as geom
from lineasnac_polyline 
where ST_GeometryType(st_linemerge(geom)) ilike '%st_l%';

-- creo la tabla de colectivos_por_parada 

-- creo tabla temporal donde cuenta la distancia entre el recorrido y la parada

create table tmp_t1 as (
	select 
	t1.id_parada,
	t1.linea_colectivo,
	sentido,
	recorrido,
	ST_Distance(t2.point_posicion,t3.geom) as distance
from colectivos_por_parada t1
inner join paradas t2 on (t1.id_parada = t2.id_parada)
inner join recorrido_colectivos t3 on (t1.linea_colectivo = t3.linea)
order by id_parada, linea_colectivo);

-- genero la tabla de colectivos por paradas, quedandome con el sentido que tenga menor distancia. 

drop table colectivos_por_parada;

create table colectivos_por_parada as(
select t1.id_parada,
	 t1.linea_colectivo,
	 t1.sentido,
	 t1.recorrido
from tmp_t1 t1 
inner join (
	select
		id_parada,
		linea_colectivo,
		min(distance) as min_distance
	from tmp_t1 t1
	group by
	id_parada,
	linea_colectivo) t2 on t2.id_parada = t1.id_parada and t1.linea_colectivo = t2.linea_colectivo and
	t2.min_distance = t1.distance);


drop table tmp_t1;
drop table info_paradas;
drop table info_recorridos;
drop table lineasnac_polyline;
