drop table if exists prueba_punto_1;
/* creo un punto Rivadavia al 8300, Punto en maps : -34.633608,-58.481118 */
create table prueba_punto_1 as
SELECT ST_MakePoint( -58.481118,-34.633608) as p1;


drop table if exists prueba_punto_2;
/*RIvadavia al 9000 Punto en maps -34.635922, -58.490640*/
create table prueba_punto_2 as 
select ST_MakePoint( -58.490640,-34.635922) as p2;

select punto1.p1,
	    punto2.p2,
		ST_Distance_Sphere(geometry(punto1.p1), geometry(punto2.p2))
from prueba_punto_1 punto1 
inner join prueba_punto_2 punto2 on ST_Distance_Sphere(geometry(punto1.p1), geometry(punto2.p2)) < 1000;

