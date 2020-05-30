--------------------------------------------------------
--  DDL for Function F_COBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COBRADOR" (
   pccobban   IN OUT   NUMBER,
   pnnumnif   IN OUT   VARCHAR2,
   ptsufijo   IN OUT   VARCHAR2,
   pcdoment   IN OUT   NUMBER,
   pcempres   IN OUT   NUMBER,
   pcdomsuc   OUT      NUMBER,
   pncuenta   OUT      VARCHAR2,
   pnifcob    OUT      VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
--   LLIBRERIA: ALLIBADM.
-- FUNCIÓ QUE ACCEDEIX A LA TAULA COBBANCARIO I OBTÉ LES DADES DEL COBRADOR
-- BANCARI.
--  s'afegeix el nif del cobrador bancari, per quan el nif es diferent del de
--            l'empresa.
   error      NUMBER                     := 0;

   xncuenta   cobbancario.ncuenta%TYPE;
   xtsufijo   cobbancario.tsufijo%TYPE;
   xcempres   cobbancario.cempres%TYPE;
   xcdoment   cobbancario.cdoment%TYPE;
   xcdomsuc   cobbancario.cdomsuc%TYPE;
   xnifcob    cobbancario.nnumnif%TYPE;
   xnnumnif   cobbancario.nnumnif%TYPE;
   xccobban   cobbancario.ccobban%TYPE;
BEGIN
   IF pccobban IS NULL
   THEN
      xnnumnif := pnnumnif;
      error := f_nifempresa (xcempres, xnnumnif);

      IF error = 0
      THEN
         BEGIN
            SELECT ccobban,  ncuenta,  cdomsuc,  nnumnif
              INTO xccobban, xncuenta, xcdomsuc, xnifcob
              FROM cobbancario
             WHERE cempres = xcempres
               AND tsufijo = ptsufijo
               AND cdoment = pcdoment;

            pcempres := xcempres;
            pccobban := xccobban;
            pncuenta := xncuenta;
            pcdomsuc := xcdomsuc;
            pnifcob := xnifcob;
            RETURN 0;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 102374;     -- COBRADOR BANCARI NO TROBAT A COBBANCARIO
            WHEN TOO_MANY_ROWS
            THEN
               RETURN 102552;              -- REGISTRE DUPLICAT A COBBANCARIO
            WHEN OTHERS
            THEN
               RETURN 103941;         -- ERROR AL LLEGIR LA TAULA COBBANCARIO
         END;
      ELSE
         RETURN error;
      END IF;
   ELSE                                                -- PCCOBBAN IS NOT NULL
      BEGIN
         SELECT ncuenta,  tsufijo,  cempres,  cdoment,  cdomsuc,  nnumnif
           INTO xncuenta, xtsufijo, xcempres, xcdoment, xcdomsuc, xnifcob
           FROM cobbancario
          WHERE ccobban = pccobban;

         error := f_nifempresa (xcempres, xnnumnif);

         IF error = 0
         THEN
            pnnumnif := xnnumnif;
            pncuenta := xncuenta;
            ptsufijo := xtsufijo;
            pcempres := xcempres;
            pcdoment := xcdoment;
            pcdomsuc := xcdomsuc;
            pnifcob  := xnifcob;
            RETURN 0;
         ELSE
            RETURN error;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 102374;        -- COBRADOR BANCARI NO TROBAT A COBBANCARIO
         WHEN TOO_MANY_ROWS
         THEN
            RETURN 102552;                 -- REGISTRE DUPLICAT A COBBANCARIO
         WHEN OTHERS
         THEN
            RETURN 103941;            -- ERROR AL LLEGIR LA TAULA COBBANCARIO
      END;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COBRADOR" TO "PROGRAMADORESCSI";
