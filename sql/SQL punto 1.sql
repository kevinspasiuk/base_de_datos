SELECT DISTINCT p.calle, p.altura, cp.linea_colectivo
FROM paradas p inner join colectivos_por_parada cp on p.id_parada = cp.id_parada
WHERE ST_DistanceSphere(ST_MakePoint(<long_pto_deseado>, <lat_pto_deseado>), p.point_posicion) < [Distancia_Deseada];

