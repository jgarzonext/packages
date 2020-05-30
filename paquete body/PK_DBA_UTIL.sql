--------------------------------------------------------
--  DDL for Package Body PK_DBA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_DBA_UTIL" 
AS

------------------

PROCEDURE rename_CK_NN_table (nom_tabla VARCHAR2)
IS

sentencia   VARCHAR2(500):=NULL;
tabla       VARCHAR2(30);
constr      VARCHAR2(30);
condicion   VARCHAR2(30000);
tipo_constr VARCHAR2(1);
existe      number;

CURSOR cons_col
IS
select constraint_name, column_name
from all_cons_columns
where table_name = tabla;

CURSOR all_cons IS
select search_condition, constraint_type
from all_constraints
where table_name = tabla
and constraint_name = constr;

BEGIN

tabla := UPPER(nom_tabla);

for c1 in cons_col
loop
  constr := c1.constraint_name;
  for c2 in all_cons
  loop
    condicion := c2.search_condition;
    existe := instr(condicion,'NOT NULL');
    if existe > 0
    then
      tipo_constr := 'N';
    else
      existe := instr(condicion,'IN (');
	if existe > 0
      then
	  tipo_constr := 'C';
	else
	  tipo_constr := NULL;
	end if;
    end if;
    if tipo_constr = 'C'
    then
	sentencia := 'alter table '||tabla||' drop constraint '||constr||' ;';
	DBMS_OUTPUT.PUT_LINE (sentencia);
      if length(tabla)>21
      then
     	  sentencia := 'alter table '||tabla||' ADD CONSTRAINT '||substr(tabla,1,21)||'_'||substr(c1.column_name,1,5)||'_CK CHECK ('||condicion||');';
      else
	  sentencia := 'alter table '||tabla||' ADD CONSTRAINT '||tabla||'_'||substr(c1.column_name,1,26-length(tabla))||'_CK CHECK ('||condicion||');';
      end if;
	DBMS_OUTPUT.PUT_LINE (sentencia);
    elsif tipo_constr = 'N'
    then
	sentencia := 'alter table '||tabla||' drop constraint '||constr||' ;';
	DBMS_OUTPUT.PUT_LINE (sentencia);
      if length(tabla)>21
      then
	  sentencia := 'alter table '||tabla||' MODIFY ('||c1.column_name||' CONSTRAINT '||substr(tabla,1,21)||'_'||substr(c1.column_name,1,5)||'_NN NOT NULL);';
      else
	  sentencia := 'alter table '||tabla||' MODIFY ('||c1.column_name||' CONSTRAINT '||tabla||'_'||substr(c1.column_name,1,26-length(tabla))||'_NN NOT NULL);';
      end if;
	DBMS_OUTPUT.PUT_LINE (sentencia);
    end if;
  end loop;
end loop;

END rename_CK_NN_table;

-------------------

PROCEDURE rename_CK_NN
IS

v_table VARCHAR2(30);

CURSOR cur_tablas
IS
select table_name
from user_tables;

BEGIN

  DBMS_OUTPUT.PUT_LINE ('spool rename_CK_NN.log');

  for c1 in cur_tablas
  loop
    v_table := c1.table_name;
    DBMS_OUTPUT.PUT_LINE ('prompt ******************* Tabla: '||v_table);
    rename_CK_NN_table(v_table);
  end loop;

  DBMS_OUTPUT.PUT_LINE ('spool off');

END;

------------------

PROCEDURE drop_pk
IS

v_sentencia       VARCHAR2(500):=NULL;
v_constraint_name VARCHAR2(30);
v_table_name      VARCHAR2(30);

CURSOR cons_pk
IS
select table_name, constraint_name
from user_constraints
where constraint_type='P';

BEGIN

DBMS_OUTPUT.PUT_LINE ('spool drop_PK.log');
for c1 in cons_pk
loop
  v_constraint_name := c1.constraint_name;
  v_table_name      := c1.table_name;

  v_sentencia := 'alter table '||v_table_name||' drop constraint '||v_constraint_name||' ;';
  DBMS_OUTPUT.PUT_LINE (v_sentencia);
end loop;
DBMS_OUTPUT.PUT_LINE ('spool off');

END drop_pk;

----------------------

PROCEDURE drop_fk
IS

v_sentencia       VARCHAR2(500):=NULL;
v_constraint_name VARCHAR2(30);
v_table_name      VARCHAR2(30);

CURSOR cons_pk
IS
select table_name, constraint_name
from user_constraints
where constraint_type='R';

BEGIN

DBMS_OUTPUT.PUT_LINE ('spool drop_FK.log');
for c1 in cons_pk
loop
  v_constraint_name := c1.constraint_name;
  v_table_name      := c1.table_name;

  v_sentencia := 'alter table '||v_table_name||' drop constraint '||v_constraint_name||' ;';
  DBMS_OUTPUT.PUT_LINE (v_sentencia);
end loop;
DBMS_OUTPUT.PUT_LINE ('spool off');

END drop_fk;

------------------

PROCEDURE drop_uk
IS

v_sentencia       VARCHAR2(500):=NULL;
v_constraint_name VARCHAR2(30);
v_table_name      VARCHAR2(30);

CURSOR cons_uk
IS
select table_name, constraint_name
from user_constraints
where constraint_type='U';

BEGIN

DBMS_OUTPUT.PUT_LINE ('spool drop_UK.log');
for c1 in cons_uk
loop
  v_constraint_name := c1.constraint_name;
  v_table_name      := c1.table_name;

  v_sentencia := 'alter table '||v_table_name||' drop constraint '||v_constraint_name||' ;';
  DBMS_OUTPUT.PUT_LINE (v_sentencia);
end loop;
DBMS_OUTPUT.PUT_LINE ('spool off');

END drop_uk;

----------------------

PROCEDURE add_pk_table(p_table_name VARCHAR2)
IS

v_sentencia       VARCHAR2(500):=NULL;
v_table           VARCHAR2(30);
v_column_name     VARCHAR2(4000);
v_list_columns    VARCHAR2(4000):=NULL;
v_tablespace_name VARCHAR2(30);
v_pct_free        NUMBER;
v_initial_extent  NUMBER;
v_next_extent     NUMBER;
v_min_extents     NUMBER;
v_max_extents     NUMBER;
v_new_constraint  VARCHAR2(30):=NULL;
v_position        NUMBER;

CURSOR list_columns
IS
select column_name
from   user_cons_columns,
       user_constraints
where  user_cons_columns.table_name      = v_table
and    user_cons_columns.table_name      = user_constraints.table_name
and    user_cons_columns.constraint_name = user_constraints.constraint_name
and    constraint_type = 'P'
order by position;

CURSOR index_info
IS
select tablespace_name,
       pct_free,
       initial_extent,
       next_extent,
       min_extents,
       max_extents
from   user_indexes,
       user_constraints
where  user_indexes.table_name = v_table
and    user_indexes.table_name = user_constraints.table_name
and    user_indexes.index_name = user_constraints.constraint_name
and    user_constraints.constraint_type ='P';

BEGIN

v_table := UPPER(p_table_name);

for c1 in list_columns
loop
  v_column_name := c1.column_name;
  if v_list_columns IS NULL
  then
    v_list_columns := v_column_name;
  else
    v_list_columns := v_list_columns || ', '||v_column_name;
  end if;
end loop;

for c2 in index_info
loop
  v_tablespace_name := c2.tablespace_name;
  v_pct_free        := c2.pct_free;
  v_initial_extent  := c2.initial_extent;
  v_next_extent     := c2.next_extent;
  v_min_extents     := c2.min_extents;
  v_max_extents     := c2.max_extents;

  if length(v_table) > 27
  then
    v_new_constraint := substr(v_table,1,27)||'_PK';
  else
    v_new_constraint := v_table||'_PK';
  end if;

  v_sentencia := 'alter table '||v_table||'
add constraint '||v_new_constraint||'
primary key ('||v_list_columns||')
using index
tablespace '||v_tablespace_name||'
pctfree '||to_char(v_pct_free)||'
storage ( pctincrease 0
initial '||v_initial_extent||'
next '||v_next_extent||'
minextents '||v_min_extents||'
maxextents '||v_max_extents||');';

  v_position := 0;

  if length(v_sentencia) > 255
  then
    while substr(v_sentencia,255-v_position,1) != ' '
    loop
      v_position := v_position + 1;
    end loop;
    DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,1               ,255 - v_position));
    DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,256 - v_position,255             ));
  else
    DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,1,255));
  end if;

end loop;

END add_pk_table;

----------------------

PROCEDURE add_fk_table(p_table_name VARCHAR2)
IS

v_sentencia                VARCHAR2(500):=NULL;
v_table                    VARCHAR2(30);
v_r_table                  VARCHAR2(30);
v_constraint_name          VARCHAR2(30);
v_r_constraint_name        VARCHAR2(30);
constraint_name_to_compare VARCHAR2(30);
v_column_name              VARCHAR2(4000);
v_list_columns             VARCHAR2(4000):=NULL;
v_r_list_columns           VARCHAR2(4000):=NULL;
v_new_constraint           VARCHAR2(200);

CURSOR cons_fk
IS
select cons.constraint_name,
       cons.r_constraint_name,
       referenced.table_name
from   user_constraints cons, user_constraints referenced
where  cons.table_name       = v_table
and    cons.constraint_type = 'R'
and    referenced.constraint_name = cons.r_constraint_name;

CURSOR list_columns
IS
select column_name
from   user_cons_columns
where  user_cons_columns.constraint_name = constraint_name_to_compare
order by position;

CURSOR r_list_columns
IS
select column_name
from   user_cons_columns
where  user_cons_columns.constraint_name = constraint_name_to_compare
and    user_cons_columns.table_name = v_r_table
order by position;

BEGIN
v_table := UPPER(p_table_name);
for c1 in cons_fk
loop

  v_list_columns   := NULL;
  v_r_list_columns := NULL;

  v_constraint_name   := c1.constraint_name;
  v_r_constraint_name := c1.r_constraint_name;
  v_r_table           := c1.table_name;

  constraint_name_to_compare := v_constraint_name;
  for c2 in list_columns
  loop
    v_column_name := c2.column_name;
    if v_list_columns IS NULL
    then
      v_list_columns := v_column_name;
    else
      v_list_columns := v_list_columns || ', '||v_column_name;
    end if;
  end loop;

  constraint_name_to_compare := v_r_constraint_name;
  for c3 in r_list_columns
  loop
    v_column_name := c3.column_name;
    if v_r_list_columns IS NULL
    then
      v_r_list_columns := v_column_name;
    else
      v_r_list_columns := v_r_list_columns || ', '||v_column_name;
    end if;
  end loop;

if    (v_r_list_columns = 'CUSUARI' and v_r_list_columns <> v_list_columns)
   or (v_r_list_columns = 'SPERSON' and v_r_list_columns <> v_list_columns)
then
  if length(v_table) > 19
  then
    v_new_constraint := substr(v_table,1,27-length(v_list_columns))||'_'||v_list_columns||'_FK';
  else
    v_new_constraint := v_table||'_'||v_list_columns||'_FK';
  end if;
else
  if length(v_table||v_r_table) > 26
  then
    v_new_constraint := v_table ||'_'||substr(v_r_table,1,26-length(v_table))||'_FK';
  else
    v_new_constraint := v_table ||'_'||v_r_table||'_FK';
  end if;
end if;

  v_sentencia := 'alter table '||v_table||' add constraint '||v_new_constraint||'
foreign key ('||v_list_columns||')
references '||v_r_table||' ('||v_r_list_columns||') ;';
  DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,1,255));
  DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,256,500));

end loop;

END add_fk_table;

----------------------

PROCEDURE add_uk_table(p_table_name VARCHAR2)
IS

v_sentencia       VARCHAR2(500):=NULL;
v_table           VARCHAR2(30);
v_constraint_name VARCHAR2(30);
v_column_name     VARCHAR2(4000);
v_list_columns    VARCHAR2(4000):=NULL;
v_tablespace_name VARCHAR2(30);
v_pct_free        NUMBER;
v_initial_extent  NUMBER;
v_next_extent     NUMBER;
v_min_extents     NUMBER;
v_max_extents     NUMBER;
v_new_constraint  VARCHAR2(30):=NULL;
v_counter         NUMBER :=0;
v_position        NUMBER;

CURSOR cons_uk
IS
select cons.constraint_name
from   user_constraints cons
where  cons.table_name       = v_table
and    cons.constraint_type = 'U';

CURSOR list_columns
IS
select column_name
from   user_cons_columns
where  user_cons_columns.table_name      = v_table
and    user_cons_columns.constraint_name = v_constraint_name
order by position;

CURSOR index_info
IS
select tablespace_name,
       pct_free,
       initial_extent,
       next_extent,
       min_extents,
       max_extents
from   user_indexes
where  user_indexes.table_name = v_table
and    user_indexes.index_name = v_constraint_name;

BEGIN

v_table := UPPER(p_table_name);

for c1 in cons_uk
loop
  v_constraint_name := c1.constraint_name;
  v_list_columns    := NULL;
  v_counter         := v_counter + 1;
  for c2 in list_columns
  loop
    v_column_name := c2.column_name;
    if v_list_columns IS NULL
    then
      v_list_columns := v_column_name;
    else
      v_list_columns := v_list_columns || ', '||v_column_name;
    end if;
  end loop;

  for c3 in index_info
  loop
    v_tablespace_name := c3.tablespace_name;
    v_pct_free        := c3.pct_free;
    v_initial_extent  := c3.initial_extent;
    v_next_extent     := c3.next_extent;
    v_min_extents     := c3.min_extents;
    v_max_extents     := c3.max_extents;

    if length(v_table) > 26
    then
      v_new_constraint := substr(v_table,1,26)||'_UK'||to_char(v_counter);
    else
      v_new_constraint := v_table||'_UK'||to_char(v_counter);
    end if;

    v_sentencia := 'alter table '||v_table||'
add constraint '||v_new_constraint||'
unique ('||v_list_columns||')
using index
tablespace '||v_tablespace_name||'
pctfree '||to_char(v_pct_free)||'
storage ( pctincrease 0
initial '||v_initial_extent||'
next '||v_next_extent||'
minextents '||v_min_extents||'
maxextents '||v_max_extents||');';

    v_position := 0;

    if length(v_sentencia) > 255
    then
      while substr(v_sentencia,255-v_position,1) != ' '
      loop
        v_position := v_position + 1;
      end loop;
      DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,1               ,255 - v_position));
      DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,256 - v_position,255             ));
    else
      DBMS_OUTPUT.PUT_LINE (substr(v_sentencia,1,255));
    end if;

  end loop;
end loop;

END add_uk_table;

----------------

PROCEDURE add_pk
IS

v_table VARCHAR2(30);

CURSOR cur_tablas
IS
select table_name
from user_tables;

BEGIN

  DBMS_OUTPUT.PUT_LINE ('spool add_PK.log');

  for c1 in cur_tablas
  loop
    v_table := c1.table_name;
    DBMS_OUTPUT.PUT_LINE ('prompt ******************* Tabla: '||v_table);
    add_pk_table(v_table);
  end loop;

  DBMS_OUTPUT.PUT_LINE ('spool off');

END add_pk;

----------------

PROCEDURE add_fk
IS

v_table VARCHAR2(30);

CURSOR cur_tablas
IS
select table_name
from user_tables;

BEGIN

  DBMS_OUTPUT.PUT_LINE ('spool add_FK.log');

  for c1 in cur_tablas
  loop
    v_table := c1.table_name;
    DBMS_OUTPUT.PUT_LINE ('prompt ******************* Tabla: '||v_table);
    add_fk_table(v_table);
  end loop;

  DBMS_OUTPUT.PUT_LINE ('spool off');

END add_fk;

----------------

PROCEDURE add_uk
IS

v_table VARCHAR2(30);

CURSOR cur_tablas
IS
select table_name
from user_tables;

BEGIN

  DBMS_OUTPUT.PUT_LINE ('spool add_UK.log');

  for c1 in cur_tablas
  loop
    v_table := c1.table_name;
    DBMS_OUTPUT.PUT_LINE ('prompt ******************* Tabla: '||v_table);
    add_uk_table(v_table);
  end loop;

  DBMS_OUTPUT.PUT_LINE ('spool off');

END add_uk;

----------------------

END pk_dba_util;

/

  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "PROGRAMADORESCSI";
