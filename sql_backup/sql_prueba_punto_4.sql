-- prueba punto 4

-- ejemplo con parada inicial: id_parada = 1000046, y parada final: id_parada = 1004730 

select distinct
	  -- primer tramo
	  pi.id_parada as id_parada_ini,
	  pi.calle as calle_parada_ini,
	  pi.altura as altura_parada_ini,
	  pi.point_posicion as point_parada_ini,
	  cpi.linea_colectivo as linea_ini,
	  cpi.sentido as sentido_ini,
	  cpi.recorrido as recorrido_ini,
	  st_force2d(rci.geom) as geom_ini,
	  -- corte recorrido inicial
	  --st_force2d(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))) as corte_recorrido_ini,
	  --st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) as long_tramo_ini,
	  -- segundo tramo 
	  pf.id_parada as id_parada_fin,
	  pf.calle as calle_parada_fin,
	  pf.altura as altura_parada_fin,
	  pf.point_posicion as point_parada_fin,
	  cpf.linea_colectivo as linea_fin,
	  cpf.sentido as sentido_fin,
	  cpf.recorrido as recorrido_fin,
	  rcf.geom as geom_fin,
	  --corte recorrido final
	  --st_force2d(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))) as corte_recorrido_fin,
	  --st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography) as long_tramo_fin,
	  -- cálculos
	  --st_distance(st_force2d(rci.geom)::Geography,st_force2d(rcf.geom)::Geography) as distancia_recorrido,
	  --ST_ClosestPoint(rci.geom,rcf.geom) as punto_mas_cercano,
	  -- long recorrido total	
		st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) 
	  		+
	  	st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography)
			+
		st_distance(st_force2d(rci.geom)::Geography,st_force2d(rcf.geom)::Geography)
		as long_total_recorrido
		-- 
	
		
from paradas pi, paradas pf, 
	colectivos_por_parada cpi, recorrido_colectivos rci,
	colectivos_por_parada cpf, recorrido_colectivos rcf

where  
	  --pi.id_parada = 1000046 and pf.id_parada = 1004730 
	   
	  --paradas iniciales cercanas a x metros de la posición inicial 
	  ST_DistanceSphere(ST_MakePoint(-58.483011,-34.634962), pi.point_posicion) < 100 and
	  --paradas finales cercanas a x metros de la posición final 
	  ST_DistanceSphere(ST_MakePoint(-58.376903,-34.635533), pf.point_posicion) < 200 
	  --info primer tramo
	  and pi.id_parada = cpi.id_parada
	  and cpi.linea_colectivo = rci.linea and cpi.sentido = rci.sentido and cpi.recorrido = rci.recorrido
	  --info segundo tramo 
	  and pf.id_parada = cpf.id_parada
	  and cpf.linea_colectivo = rcf.linea and cpf.sentido = rcf.sentido and cpf.recorrido = rcf.recorrido
	  -- condición de sentido 
	  and st_lineLocatePoint(rci.geom,pi.point_posicion) <= st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom))
	  and st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)) <= st_lineLocatePoint(rcf.geom,pf.point_posicion)
	  -- elimino las lineas que viajan directo 
	  and cpi.linea_colectivo != cpf.linea_colectivo 
	  -- condición que la distancia entre los recorridos no supere x metros
	  and st_distance((rci.geom)::Geography,(rcf.geom)::Geography) < 400
order by long_total_recorrido;


-- parametrizada

select distinct
	  -- primer tramo
	  pi.id_parada as id_parada_ini,
	  pi.calle as calle_parada_ini,
	  pi.altura as altura_parada_ini,
	  cpi.linea_colectivo as linea_ini,
	  cpi.sentido as sentido_ini,
	  cpi.recorrido as recorrido_ini,
	  -- segundo tramo 
	  pf.id_parada as id_parada_fin,
	  pf.calle as calle_parada_fin,
	  pf.altura as altura_parada_fin,
	  cpf.linea_colectivo as linea_fin,
	  cpf.sentido as sentido_fin,
	  cpf.recorrido as recorrido_fin,
	  -- long recorrido total recorrido	
		st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),
						     st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) 
	  		+
	  	st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),
								   st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography)
			+
		st_distance((rci.geom)::Geography,(rcf.geom)::Geography)
		as long_total_recorrido
		-- 
from paradas pi, paradas pf, 
	colectivos_por_parada cpi, recorrido_colectivos rci,
	colectivos_por_parada cpf, recorrido_colectivos rcf
where  
	  --paradas iniciales cercanas a x metros de la posición inicial 
	  ST_DWITHIN(ST_MakePoint(['Long_Ini'],['Lat_Ini'])::Geography, pi.point_posicion,'Max_Distancia') and
	  --paradas finales cercanas a x metros de la posición final 
	  ST_DWITHIN(ST_MakePoint(['Long_Fin'],['Lat_Fin'])::Geography, pf.point_posicion,'Max_Distancia') 
	  --info primer tramo
	  and pi.id_parada = cpi.id_parada
	  and cpi.linea_colectivo = rci.linea and cpi.sentido = rci.sentido and cpi.recorrido = rci.recorrido
	  --info segundo tramo 
	  and pf.id_parada = cpf.id_parada
	  and cpf.linea_colectivo = rcf.linea and cpf.sentido = rcf.sentido and cpf.recorrido = rcf.recorrido
	  -- condición de sentido 
	  and st_lineLocatePoint(rci.geom,pi.point_posicion) <= 
	  st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom))
	  and st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)) <= 
	  st_lineLocatePoint(rcf.geom,pf.point_posicion)
	  -- elimino las lineas que viajan directo 
	  and cpi.linea_colectivo != cpf.linea_colectivo 
	  -- condición que la distancia entre los recorridos no supere x metros
	  and st_distance((rci.geom)::Geography,(rcf.geom)::Geography) < 'Max_Distancia'
order by long_total_recorrido;





-- Ejemplo Output con dos paradas





drop table if exists  tmp_recorrido ;
create table tmp_recorrido as(
select distinct
	  -- primer tramo
	  pi.id_parada as id_parada_ini,
	  pi.calle as calle_parada_ini,
	  pi.altura as altura_parada_ini,
	  pi.point_posicion as point_parada_ini,
	  cpi.linea_colectivo as linea_ini,
	  cpi.sentido as sentido_ini,
	  cpi.recorrido as recorrido_ini,
	  st_force2d(rci.geom) as geom_ini,
	  -- corte recorrido inicial
	  st_force2d(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))) as corte_recorrido_ini,
	  st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) as long_tramo_ini,
	  -- segundo tramo 
	  pf.id_parada as id_parada_fin,
	  pf.calle as calle_parada_fin,
	  pf.altura as altura_parada_fin,
	  pf.point_posicion as point_parada_fin,
	  cpf.linea_colectivo as linea_fin,
	  cpf.sentido as sentido_fin,
	  cpf.recorrido as recorrido_fin,
	  rcf.geom as geom_fin,
	  --corte recorrido final
	  st_force2d(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))) as corte_recorrido_fin,
	  st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography) as long_tramo_fin,
	  -- cálculos
	  st_distance(st_force2d(rci.geom)::Geography,st_force2d(rcf.geom)::Geography) as distancia_recorrido,
	  ST_ClosestPoint(rci.geom,rcf.geom) as punto_mas_cercano,
	  -- long recorrido total	
		st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) 
	  		+
	  	st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography)
			+
		st_distance(st_force2d(rci.geom)::Geography,st_force2d(rcf.geom)::Geography)
		as long_total_recorrido
		-- 
from paradas pi, paradas pf, 
	colectivos_por_parada cpi, recorrido_colectivos rci,
	colectivos_por_parada cpf, recorrido_colectivos rcf
where  
	  pi.id_parada = 1000046 and pf.id_parada = 1004730 
	  --info primer tramo
	  and pi.id_parada = cpi.id_parada
	  and cpi.linea_colectivo = rci.linea and cpi.sentido = rci.sentido and cpi.recorrido = rci.recorrido
	  --info segundo tramo 
	  and pf.id_parada = cpf.id_parada
	  and cpf.linea_colectivo = rcf.linea and cpf.sentido = rcf.sentido and cpf.recorrido = rcf.recorrido
	  -- condición de sentido 
	  and st_lineLocatePoint(rci.geom,pi.point_posicion) <= 
	  st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom))
	  and st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)) <= 
	  st_lineLocatePoint(rcf.geom,pf.point_posicion)
	  -- elimino las lineas que viajan directo 
	  and cpi.linea_colectivo != cpf.linea_colectivo 
	  -- condición que la distancia entre los recorridos no supere x metros
	  and st_distance((rci.geom)::Geography,(rcf.geom)::Geography) < 300
order by long_total_recorrido
limit(1));
	


select  
corte_recorrido_ini
from tmp_recorrido
union 
select 
corte_recorrido_fin
from tmp_recorrido
union 
select
punto_mas_cercano
from tmp_recorrido

-- prueba con

SET max_parallel_workers_per_gather to 1024;

CREATE INDEX point_index ON paradas USING GIST (point_posicion);
CREATE INDEX geom_recorridos on recorrido_colectivos USING GIST(geom);

select distinct
	   -- primer tramo
	  pi.id_parada as id_parada_ini,
	  pi.calle as calle_parada_ini,
	  pi.altura as altura_parada_ini,
	  pi.point_posicion as point_parada_ini,
	  cpi.linea_colectivo as linea_ini,
	  cpi.sentido as sentido_ini,
	  cpi.recorrido as recorrido_ini,
	  st_force2d(rci.geom) as geom_ini,
	  -- corte recorrido inicial
	  st_force2d(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))) as corte_recorrido_ini,
	  st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) as long_tramo_ini,
	  -- segundo tramo 
	  pf.id_parada as id_parada_fin,
	  pf.calle as calle_parada_fin,
	  pf.altura as altura_parada_fin,
	  pf.point_posicion as point_parada_fin,
	  cpf.linea_colectivo as linea_fin,
	  cpf.sentido as sentido_fin,
	  cpf.recorrido as recorrido_fin,
	  rcf.geom as geom_fin,
	  --corte recorrido final
	  st_force2d(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))) as corte_recorrido_fin,
	  st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography) as long_tramo_fin,
	  -- cálculos
	  st_distance((rci.geom)::Geography,(rcf.geom)::Geography) as distancia_recorrido,
	  ST_ClosestPoint(rci.geom,rcf.geom) as punto_mas_cercano,
	  -- long recorrido total	
		st_length(ST_LineSubstring(rci.geom,st_lineLocatePoint(rci.geom,pi.point_posicion),st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom)))::Geography) 
	  		+
	  	st_length(ST_LineSubstring(rcf.geom,st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)),st_lineLocatePoint(rcf.geom,pf.point_posicion))::Geography)
			+
		st_distance((rci.geom)::Geography,(rcf.geom)::Geography)
		as long_total_recorrido
		-- 		
from paradas pi, paradas pf, 
	colectivos_por_parada cpi, recorrido_colectivos rci,
	colectivos_por_parada cpf, recorrido_colectivos rcf

where  
	  --pi.id_parada = 1000046 and pf.id_parada = 1004730 
	   
	  --paradas iniciales cercanas a x metros de la posición inicial 
	  ST_DWITHIN(ST_MakePoint(-58.483011,-34.634962)::Geography, pi.point_posicion,300) and
	  --paradas finales cercanas a x metros de la posición final 
	  ST_DWITHIN(ST_MakePoint(-58.376903,-34.635533)::Geography, pf.point_posicion,300)
	  --info primer tramo
	  and pi.id_parada = cpi.id_parada
	  and cpi.linea_colectivo = rci.linea and cpi.sentido = rci.sentido and cpi.recorrido = rci.recorrido
	  --info segundo tramo 
	  and pf.id_parada = cpf.id_parada
	  and cpf.linea_colectivo = rcf.linea and cpf.sentido = rcf.sentido and cpf.recorrido = rcf.recorrido
	  -- condición de sentido 
	  and st_lineLocatePoint(rci.geom,pi.point_posicion) <= st_lineLocatePoint(rci.geom, ST_ClosestPoint(rci.geom,rcf.geom))
	  and st_lineLocatePoint(rcf.geom, ST_ClosestPoint(rci.geom,rcf.geom)) <= st_lineLocatePoint(rcf.geom,pf.point_posicion)
	  -- elimino las lineas que viajan directo 
	  and cpi.linea_colectivo != cpf.linea_colectivo 
	  -- condición que la distancia entre los recorridos no supere x metros
	  and st_distance((rci.geom)::Geography,(rcf.geom)::Geography) < 400
order by long_total_recorrido;





