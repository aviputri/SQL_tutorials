CREATE TABLE land_saleh_06
AS SELECT s.Geometry,city.intval
From land_use l,surface_geometry s,cityobject_genericattrib city
where l.id = city.id
    And s.parent_id = l.lod0_multi_surface_id  
;

create table input_saleh_06
as 
select distinct on(sub.id)
sub.*
from
(select s.id,s.gmlid,s.geometry,city.intval
From land_use l,surface_geometry s,cityobject_genericattrib city,tin_relief tin,land_saleh_06 ls
where s.parent_id=tin.surface_geometry_id
and ST_CONTAINS(ls.geometry,s.geometry)
union
select tin.id, s.gmlid, s.geometry, 999 ST
From surface_geometry s, tin_relief tin
where s.parent_id=tin.surface_geometry_id) sub
order by id
;

create sequence seq_id_t increment 1 minvalue 0;
alter table input_saleh_06
add column id_t bigint default nextval ('seq_id_t') PRIMARY KEY;

create table dumppoints_saleh_06
as select
id_t,
ST_X(geom) as x_coor,
ST_Y(geom) as y_coor,
ST_Z(geom) as z_coor,
geom
from
(select 
id_t,
(ST_DUMPPOINTS(ST_REVERSE(ST_FORCERHR(geometry)))).*
from
input_000) sub;

create sequence seq_id_p_srt increment 1 minvalue 0;

alter table dumppoints_saleh_06
add column id_p_srt bigint default nextval ('seq_id_p_srt') ;

delete from dumppoints_saleh_06
where id_p_srt %4 = 3;

alter table dumppoints_saleh_06
drop column id_p_srt  ;

ALTER SEQUENCE seq_id_p_srt RESTART WITH 0; 

alter table dumppoints_saleh_06
add column id_p_srt bigint default nextval ('seq_id_p_srt') ;

create table points_saleh_06
as select distinct on(x,y,z)
d.x_coor,d.y_coor,d.z_coor,d.geom
from dumppoints_saleh_06 d;