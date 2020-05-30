--------------------------------------------------------
--  DDL for Function F_CAPRIESGO_SEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPRIESGO_SEP" (
   pssesion   NUMBER,
   porigen    NUMBER,
   psseguro   NUMBER,
   pnriesgo   NUMBER,
   pedad      NUMBER,
   pfecha     NUMBER
)
   RETURN NUMBER
IS
/*
  Descr : Retorna el capital en risc d'un sepeli.
    Funció creada per se cridada des de SGT. Tarificació.
    porigen = 1 - Taules EST
    porigen = 2 - Taules SEG
  Autor : ATS5656.
  Fecha : 25-05-2007.
*/
   v_sumcap    NUMBER;
   v_provmat   NUMBER;
BEGIN
   IF pedad > 14 THEN
      v_sumcap :=
           NVL (f_capgar_seg (pssesion, porigen, psseguro, pnriesgo, 103, pfecha), 0)
         + NVL (f_capgar_seg (pssesion, porigen, psseguro, pnriesgo, 104, pfecha), 0);
      v_provmat := NVL (fultprovcalc (pssesion, psseguro, pnriesgo, NULL, pfecha, 3), 0);

      IF v_sumcap > v_provmat * 0.25 THEN
         RETURN v_sumcap - v_provmat;
      ELSE
         RETURN 0;
      END IF;
   ELSE
      RETURN 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error (SYSDATE, F_USER, 'F_CAPRIESGO_SEG', NULL,
                   'SSEG=' || psseguro || 'NRIES=' || pnriesgo || 'FECHA=' || pfecha, SQLERRM);
      RETURN NULL;
END f_capriesgo_sep;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPRIESGO_SEP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPRIESGO_SEP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPRIESGO_SEP" TO "PROGRAMADORESCSI";
