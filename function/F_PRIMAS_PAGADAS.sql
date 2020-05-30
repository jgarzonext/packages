--------------------------------------------------------
--  DDL for Function F_PRIMAS_PAGADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMAS_PAGADAS" (
   psseguro IN NUMBER,
   pfdesde IN DATE,
   pfhasta IN DATE,
   pprimas OUT NUMBER)
   RETURN NUMBER IS
   /******************************************************************************
     NOMBRE:       f_primas_pagadas
     PROPÓSITO:  Función que calcula las primas o aportaciones pagadas de una póliza en un período determinado.

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        07/03/2007   APD               1. Creación del package. Bug.: 9940
     2.0        01/12/2009   JGM               2. Millora de la select
     3.0        03/11/2011   JMF               3. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
BEGIN
   SELECT NVL(SUM(DECODE(ctiprec, 9, -vdr.itotpri, 13, -vdr.itotpri, vdr.itotpri)), 0)   -- 9 = Extorno, 13=Retorno
     INTO pprimas
     FROM recibos r, vdetrecibos vdr
    WHERE r.nrecibo = vdr.nrecibo
      AND r.sseguro = psseguro
      AND f_cestrec(r.nrecibo, pfhasta) = 1
      AND r.ctiprec <> 10
      AND EXISTS(SELECT 1
                   FROM movrecibo mr
                  WHERE mr.cestrec = 1   -- Recibo Cobrado
                    AND TRUNC(mr.fmovdia) >= pfdesde
                    AND TRUNC(mr.fmovdia) <= pfhasta
                    AND r.nrecibo = mr.nrecibo);

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_PRIMAS_PAGADAS', NULL,
                  'psseguro = ' || psseguro || '  pfdesde = ' || pfdesde || '  pfhasta = '
                  || pfhasta,
                  SQLERRM);
      RETURN(105299);   -- Error al calcular la prima
END;

/

  GRANT EXECUTE ON "AXIS"."F_PRIMAS_PAGADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMAS_PAGADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMAS_PAGADAS" TO "PROGRAMADORESCSI";
