--------------------------------------------------------
--  DDL for Function F_CALCULO_DTOCAMPANYA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALCULO_DTOCAMPANYA" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcgarant IN NUMBER,
   pnmovima IN NUMBER,
   pfefecto IN DATE,
   piprinet IN NUMBER,
   pprorata IN NUMBER,
   pidtocam OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /********************************************************************
     Calcula el dto a una campaña aplicada a una
    garantia
   Se añade un nuevo parametro a la llamada a f_duracion_campanya
   *********************************************************************/
   vfefecto       DATE;
   vcactivi       NUMBER;
   vcforpag       NUMBER;
   vccampanya     NUMBER;
   vnversio       NUMBER;
   vsproduc       NUMBER;
   --
   vmeses         NUMBER;
   vmesdurac      NUMBER;
   num_err        NUMBER;
   vx_nmovimi     NUMBER;
   v_iprianu      NUMBER;
   vx_iprinet     NUMBER;

   --/*funcion añadida para mirar las campanya del movimiento anterior*/
   FUNCTION f_moviantgar(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovima IN NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
   BEGIN
      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovima = pnmovima
         AND nmovimi < (SELECT nmovimi
                          FROM garanseg
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND cgarant = pcgarant
                           AND nmovima = pnmovima
                           AND ffinefe IS NULL);

      RETURN v_nmovimi;
   END;
--
BEGIN
   --buscamos los datos del seguro
   BEGIN
      SELECT s.sproduc, pac_seguros.ff_get_actividad(s.sseguro, pnriesgo),
             DECODE(s.cforpag, 0, 1, s.cforpag), g.ccampanya, g.nversio, g.iprianu
        INTO vsproduc, vcactivi,
             vcforpag, vccampanya, vnversio, v_iprianu
        FROM seguros s, garanseg g, detcampanya d
       WHERE s.sseguro = psseguro
         AND g.sseguro = s.sseguro
         AND g.cgarant = pcgarant
         AND g.nmovima = pnmovima
         AND g.ffinefe IS NULL
         AND g.nriesgo = pnriesgo
         AND d.ccampanya = g.ccampanya
         AND d.nversio = g.nversio
         AND d.sproduc = s.sproduc
         AND d.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
         AND d.cgarant = g.cgarant
         AND d.caplidto = 2;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            --  : recibos_campanya
            -- si existia en el movimiento anterior
            -- si existia calculamos el dto normalmente sino
            -- el dto es cero.
            vx_nmovimi := f_moviantgar(psseguro, pnriesgo, pcgarant, pnmovima);

            SELECT s.sproduc, pac_seguros.ff_get_actividad(s.sseguro, pnriesgo),
                   DECODE(s.cforpag, 0, 1, s.cforpag), g.ccampanya, g.nversio, -g.iprianu
              INTO vsproduc, vcactivi,
                   vcforpag, vccampanya, vnversio, v_iprianu
              FROM seguros s, garanseg g, detcampanya d
             WHERE s.sseguro = psseguro
               AND g.sseguro = s.sseguro
               AND g.cgarant = pcgarant
               AND g.nmovima = pnmovima
               AND g.nriesgo = pnriesgo
               AND d.ccampanya = g.ccampanya
               AND d.nversio = g.nversio
               AND d.sproduc = s.sproduc
               AND d.cactivi = pac_seguros.ff_get_actividad(s.sseguro, pnriesgo)
               AND d.cgarant = g.cgarant
               AND d.caplidto = 2
               AND g.nmovimi = vx_nmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pidtocam := 0;
            WHEN OTHERS THEN
               RETURN 111078;
         END;
      WHEN OTHERS THEN
         RETURN 111078;
   END;

   IF vccampanya IS NOT NULL THEN
      BEGIN
         SELECT fefecto
           INTO vfefecto
           FROM movseguro m
          WHERE sseguro = psseguro
            AND nmovimi = pnmovima;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104394;   --Error al leer de movseguro
      END;

      IF vfefecto > pfefecto THEN
         RETURN 109632;   --Las fechas no són correctas
      END IF;

      vmeses := MONTHS_BETWEEN(TO_DATE(TO_CHAR(pfefecto, 'mmyyyy'), 'mmyyyy'),
                               TO_DATE(TO_CHAR(vfefecto, 'mmyyyy'), 'mmyyyy'));
      num_err := f_duracion_campanya(vccampanya, vnversio, vsproduc, vcactivi, pcgarant,
                                     psseguro, pnriesgo, pnmovima, vfefecto, vmesdurac);

      --DBMS_OUTPUT.put_line(' duarcion campanya ' || num_err);
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF piprinet = 0 THEN
         vx_iprinet := v_iprianu * pprorata;
      ELSE
         vx_iprinet := piprinet;
      END IF;

      IF vmeses <= vmesdurac THEN
         pidtocam := vx_iprinet;
      ELSE
         IF (vmeses - vmesdurac) >=(12 / vcforpag) THEN
            pidtocam := 0;
         ELSE
            pidtocam := ((12 / vcforpag) -(vmeses - vmesdurac))
                        *(vx_iprinet /(12 / vcforpag));
         END IF;
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 112147;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CALCULO_DTOCAMPANYA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALCULO_DTOCAMPANYA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALCULO_DTOCAMPANYA" TO "PROGRAMADORESCSI";
