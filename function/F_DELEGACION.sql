--------------------------------------------------------
--  DDL for Function F_DELEGACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DELEGACION" (
   pnrecibo IN NUMBER,
   pcempres IN NUMBER,
   pcagente IN NUMBER,
   pfecha IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
   F_DELEGACION   Devuelve "como valor" la delegación de un recibo
               o de un agente.
   ALLIBMFM

   Si no troba la delegació tornarà un 0, no
         un NULL.
***************************************************************************/
   delega         NUMBER;
   padre          NUMBER;
   tipage         NUMBER := 1;
   fbusca         DATE := pfecha;

   CURSOR delegacion IS
      SELECT cagente
        FROM recibosredcom
       WHERE nrecibo = pnrecibo
         AND cempres = pcempres
         AND ctipage = 1;   -- Delegación
BEGIN
   IF pnrecibo IS NOT NULL THEN
      IF pcempres IS NULL THEN
         RETURN 0;
      ELSE
         OPEN delegacion;

         FETCH delegacion
          INTO delega;

         IF delegacion%NOTFOUND THEN
            CLOSE delegacion;

            RETURN 0;
         ELSE
            CLOSE delegacion;

            RETURN NVL(delega, 0);
         END IF;
      END IF;
   ELSIF pcempres IS NULL
         OR pcagente IS NULL
         OR pfecha IS NULL THEN
      RETURN 0;
   ELSE
      IF f_buscapadre(pcempres, pcagente, tipage, fbusca, padre) = 0 THEN
         RETURN NVL(padre, 0);
      ELSE
         RETURN 0;
      END IF;
   END IF;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF delegacion%ISOPEN THEN
         CLOSE delegacion;
      END IF;

      RETURN 0;
END f_delegacion;

/

  GRANT EXECUTE ON "AXIS"."F_DELEGACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DELEGACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DELEGACION" TO "PROGRAMADORESCSI";
