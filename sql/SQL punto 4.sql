/*
Resolución Requerimiento 4.
Parámetros: 
	['Long_Ini'],['Lat_Ini']: Posición inicial
	['Long_Fin'],['Lat_Fin']: Posición Final
	'Max_Distancia': Distancia a recorrer
*/

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

