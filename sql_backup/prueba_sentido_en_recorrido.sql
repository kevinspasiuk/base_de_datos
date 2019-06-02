
select t1.id_parada,
	    t1.linea_colectivo,
		t1.sentido,
		t1.recorrido,
		t2.id_parada as parada_2
from colectivos_por_parada t1,colectivos_por_parada t2
where t1.id_parada > t2.id_parada and t1.linea_colectivo = t2.linea_colectivo 
		and t1.sentido = t2.sentido and t1.recorrido = t2.recorrido
and t1.linea_colectivo = 92;




with recorrido_linea_sentido as(
select distinct
	t1.linea_colectivo,
	t1.sentido,
	t1.recorrido,
	t2.geom
from colectivos_por_parada t1
inner join recorrido_colectivos t2 on ( t1.linea_colectivo = t2.linea and t1.sentido = t2.sentido and  t1.recorrido = t2.recorrido)
where id_parada = 1006366
intersect 
select distinct
	t1.linea_colectivo,
	t1.sentido,
	t1.recorrido,
	t2.geom
from colectivos_por_parada t1
inner join recorrido_colectivos t2 on ( t1.linea_colectivo = t2.linea and t1.sentido = t2.sentido and  t1.recorrido = t2.recorrido)
where id_parada = 1006945)

select 
	linea_colectivo,
	sentido,
	recorrido,
	geom,
	p1.id_parada as parada_ini,
	p2.id_parada as parada_fin,
	p1.point_posicion as point_ini,
	p2.point_posicion as point_fin,
	st_lineLocatePoint(geom,p1.point_posicion) as location_point_ini,
	st_lineLocatePoint(geom,p2.point_posicion) as location_point_fin,
	st_lineLocatePoint(geom,p1.point_posicion) <= st_lineLocatePoint(geom,p2.point_posicion) as sentido_correcto
	   
from recorrido_linea_sentido, paradas p1, paradas p2
where p1.id_parada = 1006945 and p2.id_parada = 1006366;

		
