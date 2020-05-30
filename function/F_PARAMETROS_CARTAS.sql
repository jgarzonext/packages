--------------------------------------------------------
--  DDL for Function F_PARAMETROS_CARTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARAMETROS_CARTAS" (CMODELO IN NUMBER,
                CBLOQUE  IN NUMBER,CIDIOMA NUMBER,CPARAMETROS VARCHAR2)
  RETURN VARCHAR2 IS
 /************************************************************
   F_PARAMETROS_CARTAS Dado un modelo substituye los parametros d
   el texto por sus valores
 *************************************************************/
 RET VARCHAR2(2000):='';
 num_parmetres number;
 num_aux number;
 n1 number;
 n2 number;
 var1 varchar2(1000);
 var2 varchar2(1000);
BEGIN
 num_aux:=0;
 p_modelcarta (CMODELO,CBLOQUE,CIDIOMA,RET);
 if ret is not null then
  var2:=substr(CPARAMETROS,3,1000);
   num_parmetres:=to_number(substr(CPARAMETROS,0,1));
   while (num_aux<num_parmetres) loop
	var1:=substr(var2,1,1000);
	n1:=instr(var1,'#');
	var2:=substr(var1,0,n1-1);
	var1:=substr(var1,n1,1000);
	RET := replace (RET,'#'||num_aux||'#',var2);
    num_aux:=num_aux+1;
    var2:=substr(var1,2,1000);
   end loop;
   return RET;
 end if;
RETURN RET;
 EXCEPTION
  WHEN OTHERS THEN
   RETURN ('PROBLEMA AL FORMATEAR EL TETXO');
END F_PARAMETROS_CARTAS;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARAMETROS_CARTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARAMETROS_CARTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARAMETROS_CARTAS" TO "PROGRAMADORESCSI";
