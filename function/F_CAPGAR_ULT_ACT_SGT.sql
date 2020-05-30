--------------------------------------------------------
--  DDL for Function F_CAPGAR_ULT_ACT_SGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPGAR_ULT_ACT_SGT" (psseguro IN NUMBER, pfecha IN NUMBER)
  RETURN number authid current_user IS
  /******************************************************************************
     NOMBRE:       F_CAPGAR_ULT_ACT_SGT
     DESCRIPCION:  Busca el capital garantizado calculado en la última actualizacion antes de una fecha determinada.
                   Esta función es identica a F_CAPGAR_ULT_ACT pero recibiendo un NUMBER como pfecha de entrada. (por SGT)
     REVISIONES:
     Ver        Date         Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        13/05/2008   RSC(CSI)         CREACION DE LA FUNCIÓN
     PARAMETROS:
     INPUT:
            PSSEGUR(number) --> Clave del seguro
            PFECHA (number) --> Fecha
     RETORNA VALUE:
            VALOR(FECHA)-----> FECHA
  ******************************************************************************/
  valor    number;
  vfecha   date;
BEGIN
   vfecha := to_date(pfecha,'yyyymmdd');
   valor := NULL;

   BEGIN
     FOR regs IN (SELECT ccapgar
                  FROM ctaseguro c, ctaseguro_libreta cl
                  WHERE c.sseguro = psseguro
                    and c.sseguro = cl.sseguro
                    and c.nnumlin = cl.nnumlin
                    AND c.cmovimi = 0
                    AND c.cmovanu <> 1  -- 1 = Anulado
                    AND c.fvalmov<= vfecha
                  order by c.fvalmov desc, c.nnumlin desc) LOOP

        valor := regs.ccapgar;
        EXIT;
     END LOOP;
     RETURN VALOR;
   EXCEPTION
     WHEN OTHERS THEN
      RETURN NULL;
   END;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPGAR_ULT_ACT_SGT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPGAR_ULT_ACT_SGT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPGAR_ULT_ACT_SGT" TO "PROGRAMADORESCSI";
