--------------------------------------------------------
--  DDL for Function F_SITUAREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUAREC" (
   pnrecibo IN NUMBER,
   pfestrec IN DATE,
   pcestrec IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   NOMBRE:      F_SITUAREC
   PROPÓSITO:   Obtener la situación de un recibo en una fecha determinada.
   ALLIBADM - Sección correspondiente al módulo de recibos
   Modificació: Cambio del select por un cursor para poder seleccionar
                la última situación del recibo en el caso de una selección
                múltiple
   Modificació: Si es un coaseguro aceptado el estado depende si esta
                pendiente o no de verificar.
             Esta funcion debe ser igual f_cestaux
   Modificació: debido a una modificación en la función f_movrecibo que
                graba las fechas de inicio y fin truncadas podemos
                optimizar este proceso ya que para varios movimientos en el
                mismo día nos devolverá directamente el último.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ---------------------------------------
    1.0       30/06/2010  JGR              15211: CRE800 - Modificación de recibos
    2.0       12/07/2010  ETM              15353: MDP - Impagos de recibos
***********************************************************************/
   err_num        NUMBER := 0;
   xcestaux       NUMBER;
BEGIN
   -- 1.0  30/06/2010  JGR  15211: CRE800 - Modificación de recibos - inici
   pcestrec := f_cestrec(pnrecibo, pfestrec);

   IF pcestrec IS NULL THEN
      pcestrec := f_cestrec(pnrecibo, NULL);
   END IF;

--12/07/2010 --ETM--15353--se contralon los posibles errores y se retorna
   IF pcestrec IS NULL THEN
      RETURN 101915;
   ELSE
      RETURN 0;
   END IF;
--12/07/2010 --ETM--15353--se contralon los posibles errores y se retorna --fin

-- 1.0  30/06/2010  JGR  15211: CRE800 - Modificación de recibos - fi

/*
   -- 1.0  30/06/2010  JGR  15211: CRE800 - Modificación de recibos --
   MODIFICACIÓ:
   Comentem tot el codi i el substituïm per una crida a F_CESTREC,
   aquesta funció retornava un NULL que provocaba molts errors quan la
   data d'efecte del rebut es superior a avui.
   No cridem a la F_CESTREC_MV perquè des de les crides a F_SITUAREC no
   tracten les situacions de rebuts 3 i 4.
   4 -- Impagado: si ha sido devuelto
   3 -- Gestión Cobro: si no han pasado 35 días


   SELECT NVL(cestaux, 0)
     INTO xcestaux
     FROM recibos
    WHERE nrecibo = pnrecibo;

   IF xcestaux = 0 THEN   -- Vàlid (en vigor)
      SELECT cestrec
        INTO pcestrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo
         AND TRUNC(pfestrec) >= fmovini
         AND(TRUNC(pfestrec) < fmovfin
             OR fmovfin IS NULL);
   ELSIF xcestaux = 2 THEN   -- Vàlid (en vigor)
      -- Bug 9383 - 01/04/2009 - RSC - CRE: Unificación de recibos
      -- Si cestaux = 2 entonces es que se trata de tema de recibos
      -- unificados
      SELECT cestrec
        INTO pcestrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo
         AND TRUNC(pfestrec) >= fmovini
         AND(TRUNC(pfestrec) < fmovfin
             OR fmovfin IS NULL);
   ELSE
      pcestrec := NULL;
      err_num := 105591;   -- Recibo de coaseguro aceptado pendiente de validar
   END IF;

   RETURN err_num;
EXCEPTION
   WHEN OTHERS THEN
      pcestrec := NULL;
      RETURN 101915;   -- Valor incorrecto del estado del recibo

      */
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SITUAREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUAREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUAREC" TO "PROGRAMADORESCSI";
