SELECT DISTINCT cp.linea_colectivo, rc.recorrido as ramal, rc.sentido, p.calle as calle_parada_ida, p.altura, p2.calle as calle_parada_destino, p2.altura
FROM paradas p INNER JOIN colectivos_por_parada cp ON p.id_parada = cp.id_parada 
	 INNER JOIN recorrido_colectivos rc ON cp.linea_colectivo = rc.linea
	 INNER JOIN (paradas p2 INNER JOIN colectivos_por_parada cp2 ON p2.id_parada = cp2.id_parada 
	 INNER JOIN recorrido_colectivos rc2 ON cp2.linea_colectivo = rc2.linea) ON
	 cp.linea_colectivo = cp2.linea_colectivo AND rc.recorrido = rc2.recorrido AND rc.sentido = rc2.sentido
WHERE ST_DistanceSphere(ST_MakePoint('[longitud origen]','[latitud origen]'), p.point_posicion) < [Max caminata inicial]
AND ST_DistanceSphere(ST_MakePoint('[longitud destino]','[latitud destino]'), p2.point_posicion) < [Max caminata final]
AND st_line_Locate_Point(ST_lineMerge(rc.geom), p.point_posicion) <= st_line_Locate_Point(rc2.geom,p2.point_posicion)
