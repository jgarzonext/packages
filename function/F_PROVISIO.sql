--------------------------------------------------------
--  DDL for Function F_PROVISIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROVISIO" (
   pnsinies IN NUMBER,
   pprovisio IN OUT NUMBER,
   DATA IN DATE,
   prestot NUMBER DEFAULT 0,
   pcgarant IN NUMBER DEFAULT NULL)--Bug 35670- 202759 KJSC Añadir nuevo parámetro garantía pcgarant
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   NOMBRE:        F_PROVISIO
   PROPÓSITO:     Cálculo de la provisión del siniestro.
                  ALLIBSIN - Funciones de siniestros
                  Modificacions: Afegim un parametre d'entrada que ens
                  indiqui fins a quina data hem de realitzar els càlculs
                  No tindrem en compte els recobros quan calculem la provisió.

     REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        16/06/2009   DCT             Bug 10328 - CRE - Incidencia cierre contable mayo09 - Provisión por prestaciones
                                            en productos de baja.
   2.0        02/11/2009  APD              Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   3.0        23/11/2009  JGR              Bug 12078: CRE - Prov. pdtes de Liquidación del producto Credit Baixa
   4.0        21/04/2010  ASN              Bug 14200: CEM800 - Provisiones por prestaciones
   5.0        22/04/2015  KJSC             Bug 35670- 202759 Añadir nuevo parámetro garantía pcgarant
***********************************************************************/
   xvaloracions   NUMBER;
   xvalor         NUMBER;
   xpagaments     pagosini.isinret%TYPE;
   num_err        NUMBER;
   w_sseguro      sin_siniestro.sseguro%TYPE;
   w_ncuacoa      sin_siniestro.ncuacoa%TYPE;
   w_ctipcoa      seguros.ctipcoa%TYPE;
   w_ploccoa      coacuadro.ploccoa%TYPE;
   w_cpagcoa      pagosini.cpagcoa%TYPE;
   apl_coa_prov   BOOLEAN;
   apl_coa_pag    BOOLEAN;
   v_cempres      seguros.cempres%TYPE;
BEGIN

   BEGIN
      num_err := 105144;

      -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- está en el módulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se está
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT sseguro, ncuacoa
           INTO w_sseguro, w_ncuacoa
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT sseguro, ncuacoa
              INTO w_sseguro, w_ncuacoa
              FROM siniestros
             WHERE nsinies = pnsinies;
      END;
   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   END;

   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   -- Ahora que ya se tiene el sseguro se busca la empresa del seguro para buscar el
   -- valor del parempresa 'MODULO_SINI'
   SELECT cempres
     INTO v_cempres
     FROM seguros
    WHERE sseguro = w_sseguro;

   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   num_err := pac_llibsin.datos_coa_sin(w_sseguro, w_ncuacoa, w_ctipcoa, w_ploccoa);

   IF num_err <> 0 THEN
      RETURN(num_err);
   END IF;

   num_err := pac_llibsin.valida_aplica_coa(w_ctipcoa, pnsinies, w_cpagcoa, apl_coa_prov,
                                            apl_coa_pag);

   IF num_err <> 0 THEN
      RETURN(num_err);
   END IF;

   num_err := 100539;   -- Error al calcular valoracions

   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      -- BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa
      xvaloracions := 0;

      FOR rval IN (SELECT DISTINCT cgarant
                              FROM valorasini
                             WHERE nsinies = pnsinies) LOOP
         num_err := pac_sin.f_valoracio_sini(pnsinies, rval.cgarant, DATA, xvalor);
         xvaloracions := xvaloracions + xvalor;
      END LOOP;
   -- Fin BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa
   ELSE
      -- BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa

      --Bug 35670- 202759 KJSC Añadir nuevo parámetro garantía pcgarant
      num_err := pac_siniestros.f_sin_reserva(pnsinies, DATA, xvaloracions, prestot,pcgarant);

      -- Fin BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa
   END IF;

   -- BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa
   IF num_err <> 0 THEN
      RETURN(num_err);
   END IF;

   -- Fin BUG 12078 - 23/11/2009 - JGR - Prov. pdtes de Liquidación del producto Credit Baixa

   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF apl_coa_prov = TRUE THEN
      xvaloracions := xvaloracions * w_ploccoa / 100;
   END IF;

   num_err := 100540;   -- Error al calcular pagaments

-- Modificació: Només tenim en compte els pagaments (2) i els recobraments (7)
-- Modificació: I les anulacions (3,8)
-- Modificació: No tindrem en compte el ICONRET
--BUG10328 - 18/06/2009 - DCT -
   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT SUM(DECODE(ctippag,
                        8, NVL(isinret, 0),
                        2, NVL(isinret, 0),
                        3, 0 - NVL(isinret, 0),
                        7, 0 - NVL(isinret, 0),
                        0))
        INTO xpagaments
        FROM pagosini
       WHERE nsinies = pnsinies
         AND TRUNC(fordpag) <= TRUNC(DATA)
         --AND cestpag <> 8;
         AND cestpag NOT IN(3, 8);   -- rechazado, anulado
/*   ELSE - Bug.14200:ASN:21/04/2010
      SELECT SUM(DECODE(p.ctippag,
                        8, NVL(p.isinret, 0),
                        2, NVL(p.isinret, 0),
                        3, 0 - NVL(p.isinret, 0),
                        7, 0 - NVL(p.isinret, 0),
                        0))
        INTO xpagaments
        FROM sin_tramita_pago p, sin_tramita_movpago m
       WHERE p.nsinies = pnsinies
         AND TRUNC(p.fordpag) <= TRUNC(DATA)
         --AND cestpag <> 8;
         AND p.sidepag = m.sidepag
         AND m.nmovpag = (SELECT MAX(nmovpag)
                            FROM sin_tramita_movpago
                           WHERE sidepag = m.sidepag)
         AND m.cestpag NOT IN(3, 8);   -- rechazado, anulado
*/
   ELSE   -- Bug.14200:ASN:02/06/2010
      xpagaments := 0;
   END IF;

   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros

   --FI BUG10328 - 18/06/2009 - DCT -
   IF apl_coa_pag = TRUE THEN
      xpagaments := xpagaments * w_ploccoa / 100;
   END IF;

   pprovisio := NVL(xvaloracions, 0) - NVL(xpagaments, 0);

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN num_err;
END f_provisio;

/

  GRANT EXECUTE ON "AXIS"."F_PROVISIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROVISIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROVISIO" TO "PROGRAMADORESCSI";
