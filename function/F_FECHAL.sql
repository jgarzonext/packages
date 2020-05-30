--------------------------------------------------------
--  DDL for Function F_FECHAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FECHAL" (fecha date, idioma NUMBER)
	   	  		  RETURN varchar2 IS
/***********************************************************
 Retorna la data 'fecha' en un format de lletres segons
 l'idioma que s'introdueixi.
***********************************************************/
dia number;
mes number;
año NUMBER;
mesl varchar2(20);
data_final varchar2(30);
begin
dia :=to_number(to_char(fecha,'dd'));
mes :=to_number(TO_CHAR(fecha,'mm'));
año :=to_number(TO_CHAR(fecha,'yyyy'));
select tatribu into mesl from detvalores
 where cvalor=54 and cidioma=idioma and catribu=mes;
if idioma = 2 then   --Castellà
   data_final:=dia||' de '||mesl||' de '||año;
elsif idioma = 1 then   --Català
	  if mes in (4,8,10) then
	  	 mesl:=' d´'||mesl;
	  else
	  	 mesl:=' de '||mesl;
	  end if;
	  data_final:=dia||mesl||' de '||año;
end if;
return data_final;
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FECHAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FECHAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FECHAL" TO "PROGRAMADORESCSI";
