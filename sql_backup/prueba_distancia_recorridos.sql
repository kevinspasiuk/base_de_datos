
-- parada inicial
drop table  if exists tmp_colectivos_iniciales;
create table tmp_colectivos_iniciales as 
select *
from colectivos_por_parada 
where id_parada = 1000046;

-- parada final 
drop table if exists tmp_colectivos_finales;
create table tmp_colectivos_finales as
select * 
from colectivos_por_parada 
where id_parada = 1004730;

-- eliminación del recorrido que lleva directo 
select * from tmp_colectivos_iniciales 
except 
(select * from tmp_colectivos_iniciales  intersect select * from tmp_colectivos_finales);


-- me fijo si las distancias de las geometrias
drop table if exists tmp_recorridos_intersect;
create table tmp_recorridos_intersect as 
(
select t1.id_parada, 
	   t1.linea_colectivo,
	   t1.sentido,
	   t1.recorrido,
	   st_force2d(t3.geom) as geom,
	   st_geometrytype(t3.geom),
	   t2.id_parada as parada2,
	   t2.linea_colectivo as linea2,
	   t2.sentido as sentido2,
	   t2.recorrido as recorrido2,
	   st_force2d(t4.geom) as geom2,
	   st_distance(st_force2d(t3.geom)::Geography,st_force2d(t4.geom)::Geography) as distancia_recorrido,
	   st_force2d(st_intersection(t3.geom,t4.geom)) as intereseccion,
	   ST_ClosestPoint(t3.geom,t4.geom) as punto_mas_cercano
from tmp_colectivos_iniciales t1, tmp_colectivos_finales t2, recorrido_colectivos t3, recorrido_colectivos t4
where  t1.linea_colectivo = t3.linea and t1.sentido = t3.sentido and t1.recorrido = t3.recorrido and
	   t2.linea_colectivo = t4.linea and t2.sentido = t4.sentido and t2.recorrido = t4.recorrido
order by t1.linea_colectivo	   
limit 1);


select geom 
from tmp_recorridos_intersect
union 
select geom2 
from tmp_recorridos_intersect
union 
select punto_mas_cercano 
from tmp_recorridos_intersect
