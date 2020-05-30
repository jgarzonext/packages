--------------------------------------------------------
--  DDL for Function F_PERMF2000
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERMF2000" 
          (ptabla      IN number,
		   pedad       in number,
		   psexo       in number,
		   pnano_nacim in  number,
		   ptipo       in number,
		   psimbolo	   in varchar2)
		   RETURN NUMBER IS

v_lx 	   number := 0;
v_dx 	   number := 0;
v_qx 	   number := 0;
v_px 	   number := 0;
resultado  NUMBER := 0;

begin
  begin
    select decode(psexo,1, vmascul, 2, vfemeni)
      into v_lx
      from mortalidad
     where ctabla = ptabla
       and nedad = pedad
	   and nano_nacim = pnano_nacim
	   and ctipo = ptipo;

    select v_lx - decode(psexo,1, vmascul, 2, vfemeni),
	       decode(psexo,1, vmascul, 2, vfemeni) / v_lx
	  into v_dx, v_px
      from mortalidad
     where ctabla = ptabla
       and nedad = pedad+1
	   and nano_nacim = pnano_nacim
	   and ctipo = ptipo;

    select v_dx / v_lx
	  into v_qx
	  from dual;

  end;
  select decode(upper(psimbolo), 'LX', v_lx, 'DX', v_dx, 'QX', v_qx, 'PX', v_px)
    into resultado
	from dual;
  RETURN resultado;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 111419;
END F_permf2000;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERMF2000" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERMF2000" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERMF2000" TO "PROGRAMADORESCSI";
