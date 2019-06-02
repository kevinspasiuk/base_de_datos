WITH paradas_colectivo AS (
	SELECT DISTINCT id_parada, recorrido
	FROM  colectivos_por_parada
	WHERE linea_colectivo = ['Numero de colectivo']
)
SELECT p.calle, pc.id_parada, pc.recorrido
FROM paradas p
INNER JOIN paradas_colectivo pc ON pc.id_parada = p.id_parada
INNER JOIN (SELECT DISTINCT pc1.id_parada 
					   FROM paradas_colectivo pc1
					   WHERE EXISTS((SELECT DISTINCT pc2.recorrido FROM paradas_colectivo pc2)
			  	  					EXCEPT
			  						(SELECT DISTINCT pc3.recorrido FROM paradas_colectivo pc3
			   						WHERE pc1.id_parada = pc3.id_parada)
									)
			) AS R on pc.id_parada = R.id_parada