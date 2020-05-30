--------------------------------------------------------
--  DDL for Function F_BUSCA_RESPUESTA_CUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCA_RESPUESTA_CUEST" (ptexto VARCHAR2, pnresp NUMBER)
  RETURN VARCHAR2 IS
    v_result		VARCHAR2(1000);
    v_pos_nresp		NUMBER;
    V_pos_return	NUMBER;
  BEGIN
    v_pos_nresp := instr(ptexto,pnresp||'-');
    IF v_pos_nresp = 0 THEN
      v_result := null;
    ELSE
      v_pos_return := instr(ptexto,chr(10),v_pos_nresp);

      SELECT substr(ptexto,  v_pos_nresp + 2,
                             decode(v_pos_return,0,length(ptexto) - v_pos_nresp - 1,
                                                   v_pos_return - v_pos_nresp - 2))
        INTO v_result
        FROM dual;
    END IF;
    return ( v_result );
  END f_busca_respuesta_cuest;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCA_RESPUESTA_CUEST" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCA_RESPUESTA_CUEST" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCA_RESPUESTA_CUEST" TO "PROGRAMADORESCSI";
