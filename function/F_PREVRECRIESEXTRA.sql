--------------------------------------------------------
--  DDL for Function F_PREVRECRIESEXTRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PREVRECRIESEXTRA" (
   psseguro IN NUMBER,
   pcempres IN NUMBER,
   psproces IN NUMBER,
   pmodo IN VARCHAR2,
   pnrecibo OUT NUMBER)
   RETURN NUMBER IS
/****************************************************************************
  F_PREVRECRIESEXTRA:

      Rutina previa al calculo del recibo de conceptos
      extraordinarios. En esta función se calculan las parametros
      necesarios para la generación del recibo.
****************************************************************************/
   w_error        NUMBER(10);
   w_ctipreb      seguros.ctipreb%TYPE;
   w_cagente      seguros.cagente%TYPE;
   w_fefecto      seguros.fefecto%TYPE;
   w_fcaranu      seguros.fcaranu%TYPE;
   w_ccobban      seguros.ccobban%TYPE;
   w_fanulac      seguros.fanulac%TYPE;
   w_nmovimi      movseguro.nmovimi%TYPE;
   w_ximport2     NUMBER(15, 2);
   v_cmodcom      comisionprod.cmodcom%TYPE;
BEGIN
--
-- Si dicho seguro no tiene datos en la tabla de Conceptos Extraord., simplemente
--   no se genera el recibo
--
   BEGIN
      SELECT COUNT(*)
        INTO w_error
        FROM extrarec
       WHERE sseguro = psseguro
         AND nrecibo IS NULL;
   EXCEPTION
      WHEN OTHERS THEN
         w_error := 0;
   END;

   IF w_error = 0 THEN
      RETURN 112229;   -- No hay registros a tratar en la tabla de conceptos extraordinarios
   END IF;

--
-- Extraccion de datos de la tabla SEGUROS
--
   BEGIN
      SELECT ctipreb, cagente, NVL(fcarant, fefecto) fefecto, ccobban, fcaranu, fanulac
        INTO w_ctipreb, w_cagente, w_fefecto, w_ccobban, w_fcaranu, w_fanulac
        FROM seguros
       WHERE sseguro = psseguro
         AND cempres = pcempres;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101903;   -- Seguro no encontrado en la tabla SEGUROS
      WHEN OTHERS THEN
         RETURN 101919;   -- Error leyendo datos de la tabla SEGUROS
   END;

--
-- Comprobacion de que la poliza siga vigente
--
   w_error := f_vigente(psseguro, NULL, f_sysdate);

   IF w_error <> 0 THEN
      RETURN w_error;
   END IF;

   BEGIN
      SELECT MAX(nmovimi)
        INTO w_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 112158;   -- Seguro no encontrado en la tabla MOVSEGURO
      WHEN OTHERS THEN
         RETURN 104349;   -- Error al leer de la tabla MOVSEGURO
   END;

   -- Bug 19777/95194 - 26/10/2011 -AMC
   IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
      v_cmodcom := 2;
   ELSE   -- si es 1 es nueva produccion
      v_cmodcom := 1;
   END IF;

   w_error := f_recriesextra(w_ctipreb, psseguro, w_cagente, f_sysdate, w_fefecto,
                             w_fefecto + 1, 1, NULL, NULL, w_ccobban, NULL, psproces, 1, pmodo,
                             v_cmodcom, w_fcaranu, 0, NULL, pcempres, w_nmovimi, NULL,
                             w_ximport2, pnrecibo);
   -- Fi Bug 19777/95194 - 26/10/2011 -AMC
   RETURN w_error;
END f_prevrecriesextra;
 

/

  GRANT EXECUTE ON "AXIS"."F_PREVRECRIESEXTRA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PREVRECRIESEXTRA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PREVRECRIESEXTRA" TO "PROGRAMADORESCSI";
