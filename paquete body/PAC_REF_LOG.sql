--------------------------------------------------------
--  DDL for Package Body PAC_REF_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_LOG" IS

FUNCTION f_log_update (ptidentif in varchar2, pcpatch in varchar2,
      psentencia in varchar2) RETURN number IS

  -- tipos de datos para guardar los valores anteriores y actulizados de los campos
  type rvalcampos is record
    ( tcampo	  varchar2(30),
      cvalant	  varchar2(256),
      cvalact	  varchar2(256)
    );
  type tvalcampos is table of rvalcampos index by binary_integer;

  -- tipos de datos para guardar el valor del identificador de un registro y
  --   los valores de los campos que se actualizan
  type rupdate is record
     ( tident   varchar2(50),
	   valors   tvalcampos
	 );
  type tupdate is table of rupdate index by binary_integer;

  -- tipos de datos para guardar los campos que se actualizan
  type rcampos is record
    (tcampo	    varchar2(30),
	 cvalupd	varchar2(5000)
	);
  type tcampos is table of rcampos index by binary_integer;

  -- variables necesarias para el define_column
  u_cvalant		  varchar2(256);
  u_cvalact		  varchar2(256);
  u_cident		  varchar2(50);

  -- variables para valores y las posiciones
  vsent		   varchar2(5000);
  vtabla	   varchar2(25);
  vwhere	   varchar2(5000);
  vpos_tabla   number;
  vpos_set	   number;
  vpos_where   number;
  vpos_comaant number;
  vpos_comasig number;
  vpos_igual   number;

  vcamps	   tcampos;
  vupdate	   tupdate;

  i 		   number;

  -- variables para utilizar cursores dinámicos
  vcursor	   PLS_INTEGER;
  vnumrows	   number;
  vselect	   varchar2(5000);
  vsel_camps   varchar2(5000);

begin
  --obtenemos valores y posiciones iniciales
  vpos_where := instr(lower(psentencia),'where');
  vsent := replace(substr(lower(psentencia),1,vpos_where-1),' ','');
  vpos_tabla := 7;
  vpos_set := instr(vsent, 'set');
  vtabla :=  substr(vsent, vpos_tabla, vpos_set-vpos_tabla);
  vwhere := substr(lower(psentencia),vpos_where);
  vpos_comaant := vpos_set + 2;
  vupdate.delete;
  i := 1;

  --obtenemos los campos que vamos a actualizar
  loop
    vpos_igual := instr(vsent, '=', 1, i);
    vpos_comasig :=  instr(vsent, ',', 1, i);
    if vpos_igual = 0 then
	  exit;
	else
	  vcamps(i-1).tcampo := substr(vsent, vpos_comaant+1, vpos_igual-(vpos_comaant+1));
	  if vpos_comasig = 0 then
	    vcamps(i-1).cvalupd := substr(vsent, vpos_igual+1);
	  else
        vcamps(i-1).cvalupd := substr(vsent, vpos_igual+1, vpos_comasig-(vpos_igual+1));
	  end if;
	  vpos_comaant := vpos_comasig;
	  i := i + 1;
	end if;
  end loop;

  -- creamos el cursor que recuperará los valores anteriores a la actualización de
  --  todos los campos y del identificador que entra por parámetro
  vcursor := dbms_sql.OPEN_CURSOR;
  if vcamps.count() > 0 then
    vsel_camps := ptidentif||',';
    for j in 0.. vcamps.last loop
      vsel_camps := vsel_camps||vcamps(j).tcampo ||',';
      vsel_camps := vsel_camps||vcamps(j).cvalupd ||',';
    end loop;
  end if;

  vsel_camps := substr(vsel_camps,1,length(vsel_camps)-1);  --traiem la última coma
  vselect := 'select '||vsel_camps||' from '||vtabla||' '||vwhere;

dbms_output.put_line('la select: ');
  for i in 1..length(vselect)/255+1 loop
dbms_output.put_line(substr(vselect,(i-1)*255+1,255));
  end loop;

  dbms_sql.PARSE(vcursor, vselect, dbms_sql.NATIVE);
  --definimos las columnas que vamos a recuperar
  if vcamps.count() > 0 then
    dbms_sql.DEFINE_COLUMN(vcursor, 1, u_cident, 256);
    for j in 0.. vcamps.last loop
  	  dbms_sql.DEFINE_COLUMN(vcursor, 2*j+2, u_cvalant, 256);
   	  dbms_sql.DEFINE_COLUMN(vcursor, 2*j+3, u_cvalact, 256);
    end loop;
  end if;

  vnumrows := dbms_sql.EXECUTE(vcursor);

  i := 0;
  loop --bucle: por cada uno de los registros retornados
    if dbms_sql.FETCH_ROWS(vcursor) > 0 then
	  --recuperamos el valor del identificador
	  dbms_sql.COLUMN_VALUE(vcursor, 1, vupdate(i).tident);
      for j in 0.. vcamps.last loop
	    --recuperamos el valor de cada campo a actualizar, el valor anterior y el siguiente
        vupdate(i).valors(j).tcampo := vcamps(j).tcampo;
        dbms_sql.COLUMN_VALUE(vcursor, 2*j+2, vupdate(i).valors(j).cvalant);
		dbms_sql.COLUMN_VALUE(vcursor, 2*j+3, vupdate(i).valors(j).cvalact);
dbms_output.put_line('num_registro:'||to_char(i+1)||', num_campo:'||to_char(j+1)||'  ---  '||vupdate(i).valors(j).tcampo||'-'||vupdate(i).valors(j).cvalant||'-'||vupdate(i).valors(j).cvalact);
     end loop;
	 i := i + 1;
    else
	  exit;
	end if;
  end loop;
  dbms_sql.CLOSE_CURSOR(vcursor);

  --hacemos el insert en la tabla de log
  if vupdate.count() > 0 then
    for i in 0..vupdate.last loop
	  for j in 0..vupdate(i).valors.last loop
        insert into log_update
	     (tidentif, cidentif, cpatch, fmovdia, ttabla, tcampo, cvalant, cvalnou, tvalores)
	    values
	     (upper(ptidentif), upper(vupdate(i).tident), upper(pcpatch), f_sysdate, upper(vtabla),
	        upper(vupdate(i).valors(j).tcampo),
			upper(vupdate(i).valors(j).cvalant),
			upper(vupdate(i).valors(j).cvalact),
			upper(psentencia));
      end loop;
	end loop;
  end if;

  --hacemos el update pasado por parametro
  vcursor := dbms_sql.OPEN_CURSOR;
  dbms_sql.PARSE(vcursor, psentencia, dbms_sql.NATIVE);
  vnumrows := dbms_sql.EXECUTE(vcursor);
  dbms_sql.CLOSE_CURSOR(vcursor);

  return 0;

exception
 when others then
dbms_output.put_line('error: '||sqlerrm);
    dbms_sql.CLOSE_CURSOR(vcursor);
  return('151368');

end;

end PAC_REF_LOG;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "PROGRAMADORESCSI";
