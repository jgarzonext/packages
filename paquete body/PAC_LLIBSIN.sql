--------------------------------------------------------
--  DDL for Package Body PAC_LLIBSIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LLIBSIN" IS
/******************************************************************************
   NOMBRE:     Pac_Llibsin
   PROPÓSITO:  Funciones para siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        30/04/2009   APD                2. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
   3.0        16/06/2009   ETM                3. 0010462: IAX - REA - Eliminar tabla FACPENDIENTES
   4.0        14/05/2010   AVT                4. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                en varias agrupaciones de producto
   5.0        11/04/2011   APD                5. 0018225: AGM704 - Realizar la modificación de precisión el cagente
   6.0        08/07/2011   APD                6. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
                                                 Se debe especificar la columna nversio si es de la tabla
                                                 contratos o agr_contratos
   7.0        17/10/2011   JMP                7. 0019027: LCOL760 - Tamany del camp CRAMO
   8.0        07/10/2013   HRE                8. Bug 0028462: HRE - Cambio dimension campo sseguro
   9.0        07/10/2013   JMG                9. 0028462-155008 : Modificación de campos clave que actualmente estan definidos
                                                 en la base de datos como NUMBER(X) para dejarlos como NUMBER
******************************************************************************/
--
--  Recupera los siniestros a tratar: aquellos con pagos en el año
--  solicitado, más los siniestros abiertos el último dia del
--  mes solicitado tanto si tienen pagos como si no
   CURSOR cur_sini(pany_ant DATE, pmes_seg DATE, pempres NUMBER) IS
      -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT DISTINCT si.nsinies nsin, si.fsinies fsin, si.sseguro sseg, si.nriesgo nrie,
                      TO_CHAR(si.fsinies, 'yyyy') anyo, s.cagente agen, s.cramo ramo,
                      s.cmodali moda, s.ctipseg tips, s.ccolect cole,
                      pac_seguros.ff_get_actividad(s.sseguro, si.nriesgo) acti,
                      s.npoliza npol, s.ncertif cert, si.cestsin ests, si.festsin fest,
                      si.fnotifi fnot, si.ncuacoa ncua, s.nanuali nanu, s.cagrpro agpr
                 FROM pagosini ps, siniestros si, seguros s
                WHERE si.sseguro = s.sseguro
                  AND ps.nsinies(+) = si.nsinies
                  AND s.cempres = pempres
                  AND si.fnotifi < pmes_seg
                  AND(ps.cestpag <> 8
                      OR ps.cestpag IS NULL)
                  AND((ps.fordpag > pany_ant
                       AND ps.fordpag < pmes_seg)
                      OR si.cestsin = 0
                      OR(si.cestsin = 1
                         AND si.festsin >= pmes_seg)
                      OR(si.cestsin = 1
                         AND si.festsin > pany_ant
                         AND si.festsin < pmes_seg))
             ORDER BY si.sseguro, si.fsinies;

   -- Bug 9685 - APD - 30/04/2009 - Fin

   --
-- Recupera las garantias valoradas
   CURSOR cur_val(w_nsini NUMBER, pmes_seg DATE) IS
      SELECT v.cgarant cgar, v.fvalora fval, v.ivalora ival
        FROM valorasini v
       WHERE v.nsinies = w_nsini
         AND v.fvalora = (SELECT MAX(v1.fvalora)
                            FROM valorasini v1
                           WHERE v1.nsinies = v.nsinies
                             AND v1.cgarant = v.cgarant
                             AND v1.fvalora < pmes_seg)
         AND v.ivalora <> 0;

-- variables que guardan importes a nivel de siniestro
   wsin_ipagoany_nliq reasiniaux.ipagoany_nliq%TYPE;   --    wsin_ipagoany_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagoany_liq reasiniaux.ipagoany_liq%TYPE;   --    wsin_ipagoany_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagoany  reasiniaux.ipago_any%TYPE;   --    wsin_ipagoany  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_recobros  reasiniaux.ipago_any%TYPE;   --NUMBER(13, 2);
   wsin_ivalora   reasiniaux.valora%TYPE;   --    wsin_ivalora   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_valora31d reasiniaux.valora31d%TYPE;   --    wsin_valora31d NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipago_nliq reasiniaux.ipago_nliq%TYPE;   --    wsin_ipago_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipago_liq reasiniaux.ipago_liq%TYPE;   --    wsin_ipago_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipago     reasiniaux.ipago%TYPE;   --    wsin_ipago     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_provisio  reasiniaux.provisio%TYPE;   --    wsin_provisio  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_provisio31d reasiniaux.provisio31d%TYPE;   --    wsin_provisio31d NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagoany_coa_nliq reasiniaux.ipagoany_coa_nliq%TYPE;   --    wsin_ipagoany_coa_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagoany_coa_liq reasiniaux.ipagoany_coa_liq%TYPE;   --    wsin_ipagoany_coa_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagoany_coa reasiniaux.ipagoany_coa%TYPE;   --    wsin_ipagoany_coa NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprov_coa reasiniaux.prov_coa%TYPE;   --    wsin_iprov_coa NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_coa reasiniaux.prov31d_coa%TYPE;   --    wsin_prv31d_coa NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagcuop_nliq reasiniaux.pag_cuopart_nliq%TYPE;   --    wsin_ipagcuop_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagcuop_liq reasiniaux.pag_cuopart_liq%TYPE;   --    wsin_ipagcuop_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagcuop  reasiniaux.pag_cuopart%TYPE;   --    wsin_ipagcuop  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprovcuop reasiniaux.prov_cuopart%TYPE;   --    wsin_iprovcuop NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_cuopart reasiniaux.prov31d_cuopart%TYPE;   --    wsin_prv31d_cuopart NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagexc_nliq reasiniaux.pag_exc_nliq%TYPE;   --    wsin_ipagexc_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagexc_liq reasiniaux.pag_exc_liq%TYPE;   --    wsin_ipagexc_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagexc   reasiniaux.pag_exc%TYPE;   --    wsin_ipagexc   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprovexc  reasiniaux.prov_exc%TYPE;   --    wsin_iprovexc  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_exc reasiniaux.prov31d_exc%TYPE;   --    wsin_prv31d_exc NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagfacob_nliq reasiniaux.pag_facob_nliq%TYPE;   --    wsin_ipagfacob_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagfacob_liq reasiniaux.pag_facob_liq%TYPE;   --    wsin_ipagfacob_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagfacob reasiniaux.pag_facob%TYPE;   --    wsin_ipagfacob NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprovfacob reasiniaux.prov_facob%TYPE;   --    wsin_iprovfacob NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_facob reasiniaux.prov31d_facob%TYPE;   --    wsin_prv31d_facob NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagfacul_nliq reasiniaux.pag_facul_nliq%TYPE;   --    wsin_ipagfacul_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagfacul_liq reasiniaux.pag_facul_liq%TYPE;   --    wsin_ipagfacul_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_ipagfacul reasiniaux.pag_facul%TYPE;   --    wsin_ipagfacul NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprovfacul reasiniaux.prov_facul%TYPE;   --    wsin_iprovfacul NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_facul reasiniaux.prov31d_facul%TYPE;   --    wsin_prv31d_facul NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   wsin_ipagpropi_nliq reasiniaux.pag_propi_nliq%TYPE;   --number(13,2);
   wsin_ipagpropi_liq reasiniaux.pag_propi_liq%TYPE;   -- number(13,2);
   wsin_ipagpropi reasiniaux.pag_propi%TYPE;   --    wsin_ipagpropi NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprovpropi reasiniaux.prov_propi%TYPE;   --    wsin_iprovpropi NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_propi reasiniaux.prov31d_propi%TYPE;   --    wsin_prv31d_propi NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
     -- Explicació de les variables del propi:
     --   wsin_ipagpropi = wsin_ipag_rea + wsin_ipag_nrea
     --   wsin_ipag_rea = wsin_pag_xl + wsin_pag_prosinxl
     --   wsin_pag_nostre = wsin_ipag_nrea + wsin_pag_prosinxl
--
     -- el propi degut a garanties reasegurables (per tant va a xl)
   wsin_ipag_rea  reasiniaux.pag_prorea%TYPE;   --    wsin_ipag_rea  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprv_rea  reasiniaux.prov_prorea%TYPE;   --    wsin_iprv_rea  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_rea reasiniaux.prov31d_prorea%TYPE;   --    wsin_prv31d_rea NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_pag31d_rea reasiniaux.prov31d_prorea%TYPE;   --NUMBER(13, 2);
   -- el propi degut a garanties no reasegurables
   wsin_ipag_nrea reasiniaux.pag_pronrea%TYPE;   --    wsin_ipag_nrea NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_iprv_nrea reasiniaux.prov_pronrea%TYPE;   --    wsin_iprv_nrea NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_nrea reasiniaux.prov31d_pronrea%TYPE;   --    wsin_prv31d_nrea NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_pag31d_nrea reasiniaux.prov31d_pronrea%TYPE;   --NUMBER(13, 2);
   -- la nostra part (el propi degut a garanties no reasegurables +
   -- el propi que ha anat al XL però que ens hem quedat nosaltres)
   wsin_pag_nostre reasiniaux.pag_nostre%TYPE;   --    wsin_pag_nostre NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv_nostre reasiniaux.prov_nostre%TYPE;   --    wsin_prv_nostre NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_nostre reasiniaux.prov31d_nostre%TYPE;   --    wsin_prv31d_nostre NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   -- el propi que ha anat al XL però ens hem quedat nosaltres
   wsin_pag_prosinxl reasiniaux.pag_prosinxl%TYPE;   --    wsin_pag_prosinxl NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prov_prosinxl reasiniaux.prov_prosinxl%TYPE;   --    wsin_prov_prosinxl NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_prosinxl reasiniaux.prov31d_prosinxl%TYPE;   --    wsin_prv31d_prosinxl NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_pag31d_prosinxl reasiniaux.prov31d_prosinxl%TYPE;   --NUMBER(13, 2);
   -- el que asumeixen els contractes XL
   wsin_pag_xl    reasiniaux.pag_xl%TYPE;   --    wsin_pag_xl    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prov_xl   reasiniaux.prov_xl%TYPE;   --    wsin_prov_xl   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_prv31d_xl reasiniaux.prov31d_xl%TYPE;   --    wsin_prv31d_xl NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   wsin_pag31d_xl reasiniaux.prov31d_xl%TYPE;   --NUMBER(13, 2);

--
-- variables que guardan importes de reaseguro a nivel de garantias
   TYPE vect IS TABLE OF NUMBER(13, 2)
      INDEX BY BINARY_INTEGER;

   w_porce        vect;
   w_plocal       tramos.plocal%TYPE;   --    w_plocal       NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_plocpro      tramos.plocal%TYPE;   --    w_plocpro      NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nsegcon      tramos.nsegcon%TYPE;   --    w_nsegcon      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nsegver      tramos.nsegver%TYPE;   --    w_nsegver      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   primera_cesion BOOLEAN;
--
-- variables que guardan importes a nivel de garantias
   w_totpagany_nliq reasiniaux.ipagoany_nliq%TYPE;   --    w_totpagany_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totpagany_liq reasiniaux.ipagoany_liq%TYPE;   --    w_totpagany_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totpagany    reasiniaux.ipago_any%TYPE;   --    w_totpagany    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totrecobros  reasiniaux.ipago_any%TYPE;   --NUMBER(13, 2);
   w_valora31d    reasiniaux.valora31d%TYPE;   --    w_valora31d    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totpag_nliq  reasiniaux.ipago_nliq%TYPE;   --    w_totpag_nliq  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totpag_liq   reasiniaux.ipago_liq%TYPE;   --    w_totpag_liq   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_totpag       reasiniaux.ipago%TYPE;   --    w_totpag       NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_provisio     reasiniaux.provisio%TYPE;   --    w_provisio     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_provisio31d  reasiniaux.provisio31d%TYPE;   --    w_provisio31d  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   w_ipagoany_coa_nliq reasiniaux.ipagoany_coa_nliq%TYPE;   --    w_ipagoany_coa_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ipagoany_coa_liq reasiniaux.ipagoany_coa_liq%TYPE;   --    w_ipagoany_coa_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ipagoany_coa reasiniaux.ipagoany_coa%TYPE;   --    w_ipagoany_coa NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_coa     reasiniaux.prov_coa%TYPE;   --    w_prov_coa     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_coa   reasiniaux.prov31d_coa%TYPE;   --    w_prv31d_coa   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag31d_coa   reasiniaux.prov31d_coa%TYPE;   --NUMBER(13, 2);
--
   w_pag_cuop_nliq reasiniaux.pag_cuopart_nliq%TYPE;   --    w_pag_cuop_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_cuop_liq reasiniaux.pag_cuopart_liq%TYPE;   --    w_pag_cuop_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_cuop     reasiniaux.pag_cuopart%TYPE;   --    w_pag_cuop     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_cuop    reasiniaux.prov_cuopart%TYPE;   --    w_prov_cuop    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_cuopart reasiniaux.prov31d_cuopart%TYPE;   --    w_prv31d_cuopart NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   w_pag_exc_nliq reasiniaux.pag_exc_nliq%TYPE;   --    w_pag_exc_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_exc_liq  reasiniaux.pag_exc_liq%TYPE;   --    w_pag_exc_liq  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_exc      reasiniaux.pag_exc%TYPE;   --    w_pag_exc      NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_exc     reasiniaux.prov_exc%TYPE;   --    w_prov_exc     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_exc   reasiniaux.prov31d_exc%TYPE;   --    w_prv31d_exc   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   w_pag_facob_nliq reasiniaux.pag_facob_nliq%TYPE;   --    w_pag_facob_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_facob_liq reasiniaux.pag_facob_liq%TYPE;   --    w_pag_facob_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_facob    reasiniaux.pag_facob%TYPE;   --    w_pag_facob    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_facob   reasiniaux.prov_facob%TYPE;   --    w_prov_facob   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_facob reasiniaux.prov31d_facob%TYPE;   --    w_prv31d_facob NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   w_pag_facul_nliq reasiniaux.pag_facul_nliq%TYPE;   --    w_pag_facul_nliq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_facul_liq reasiniaux.pag_facul_liq%TYPE;   --    w_pag_facul_liq NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag_facul    reasiniaux.pag_facul%TYPE;   --    w_pag_facul    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_facul   reasiniaux.prov_facul%TYPE;   --    w_prov_facul   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_facul reasiniaux.prov31d_facul%TYPE;   --    w_prv31d_facul NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--
   w_pag_propi_nliq reasiniaux.pag_propi_nliq%TYPE;   --NUMBER(13, 2);
   w_pag_propi_liq reasiniaux.pag_propi_liq%TYPE;   -- NUMBER(13, 2);
   w_pag_propi    reasiniaux.pag_propi%TYPE;   --    w_pag_propi    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prov_propi   reasiniaux.prov_propi%TYPE;   --    w_prov_propi   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31d_propi reasiniaux.prov31d_propi%TYPE;   --    w_prv31d_propi NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag31d_propi reasiniaux.prov31d_propi%TYPE;   --NUMBER(13, 2);
   -- propi reasegurable
   w_pagp_rea     reasiniaux.pag_prorea%TYPE;   --    w_pagp_rea     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prvp_rea     reasiniaux.prov_prorea%TYPE;   --    w_prvp_rea     NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31dp_rea  reasiniaux.prov31d_prorea%TYPE;   --    w_prv31dp_rea  NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag31dp_rea  reasiniaux.prov31d_prorea%TYPE;   --NUMBER(13, 2);
   -- propi no reasegurable
   w_pagp_nrea    reasiniaux.pag_pronrea%TYPE;   --    w_pagp_nrea    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prvp_nrea    reasiniaux.prov_pronrea%TYPE;   --    w_prvp_nrea    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_prv31dp_nrea reasiniaux.prov31d_pronrea%TYPE;   --    w_prv31dp_nrea NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_pag31dp_nrea reasiniaux.prov31d_pronrea%TYPE;   --NUMBER(13, 2);
--
-- variable especificas de la tabla mensual
   w_fini_exer    DATE;
   w_ffin_exer    DATE;
   w_fminval      DATE;
   w_fvalmax      DATE;
   w_proviniper   reasiniaux.prov_pronrea%TYPE;   --NUMBER(13, 2);
   w_provfinper   reasiniaux.prov_pronrea%TYPE;   --NUMBER(13, 2);
   w_irecobro     reasiniaux.pag_prorea%TYPE;   --NUMBER(13, 2);
   wsin_irecobro  reasiniaux.pag_prorea%TYPE;   --NUMBER(13, 2);
   w_ivalini      reasiniaux.prov_pronrea%TYPE;   --NUMBER(13, 2);
   wsin_ivalini   reasiniaux.prov_pronrea%TYPE;   --NUMBER(13, 2);
--
--
   v_cursor       INTEGER;
   v_nsin         NUMBER(8);
   v_fsin         DATE;
   v_sseg         NUMBER;   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
   v_nrie         NUMBER(6);
   v_anyo         NUMBER(4);
   v_dele         NUMBER;   -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER
   v_agen         NUMBER;   -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER
   v_ramo         codiram.cramo%TYPE;
   v_moda         NUMBER(2);
   v_tips         NUMBER(2);
   v_cole         NUMBER(2);
   v_acti         NUMBER(4);
   v_npol         NUMBER(8);
   v_cert         NUMBER(6);
   v_ests         NUMBER(2);
   v_fest         DATE;
   v_fnot         DATE;
   v_ncua         NUMBER(2);
   v_agpr         NUMBER(2);
--
-- variable per fer xapuces
   per_error_imputem_a_no_reasegu BOOLEAN := FALSE;
--
-- variables per guardar a la taula dades del contracte
   v_scontra      reasiniaux.scontra%TYPE;   --    v_scontra      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_nversio      reasiniaux.nversio%TYPE;   --    v_nversio      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_ppropi       reasiniaux.ppropi%TYPE;   --    v_ppropi       NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_scontra_prot reasiniaux.scontra_prot%TYPE;   --    v_scontra_prot NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_nversio_prot reasiniaux.nversio_prot%TYPE;   --    v_nversio_prot NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_ppropi_prot  reasiniaux.ppropi_prot%TYPE;   --    v_ppropi_prot  NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   v_crenova      reasiniaux.crenova%TYPE;   --    v_crenova      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

--
--
------------------------------------------------
   PROCEDURE inivar_sin(SIN IN NUMBER, pmerr OUT VARCHAR2) IS
   BEGIN
      wsin_ipagoany_nliq := 0;
      wsin_ipagoany_liq := 0;
      wsin_ipagoany := 0;
      wsin_recobros := 0;
      wsin_ivalora := 0;
      wsin_ipago_nliq := 0;
      wsin_ipago_liq := 0;
      wsin_ipago := 0;
      wsin_provisio := 0;
      wsin_provisio31d := 0;
      wsin_ipagoany_coa_nliq := 0;
      wsin_ipagoany_coa_liq := 0;
      wsin_ipagoany_coa := 0;
      wsin_iprov_coa := 0;
      wsin_prv31d_coa := 0;
      wsin_ipagcuop_nliq := 0;
      wsin_ipagcuop_liq := 0;
      wsin_ipagcuop := 0;
      wsin_iprovcuop := 0;
      wsin_prv31d_cuopart := 0;
      wsin_ipagexc_nliq := 0;
      wsin_ipagexc_liq := 0;
      wsin_ipagexc := 0;
      wsin_iprovexc := 0;
      wsin_prv31d_exc := 0;
      wsin_ipagfacob_nliq := 0;
      wsin_ipagfacob_liq := 0;
      wsin_ipagfacob := 0;
      wsin_iprovfacob := 0;
      wsin_prv31d_facob := 0;
      wsin_ipagfacul_nliq := 0;
      wsin_ipagfacul_liq := 0;
      wsin_ipagfacul := 0;
      wsin_iprovfacul := 0;
      wsin_prv31d_facul := 0;
      wsin_ipagpropi_nliq := 0;
      wsin_ipagpropi_liq := 0;
      wsin_ipagpropi := 0;
      wsin_iprovpropi := 0;
      wsin_prv31d_propi := 0;
      wsin_ipag_rea := 0;
      wsin_iprv_rea := 0;
      wsin_prv31d_rea := 0;
      wsin_pag31d_rea := 0;
      wsin_ipag_nrea := 0;
      wsin_iprv_nrea := 0;
      wsin_prv31d_nrea := 0;
      wsin_pag31d_nrea := 0;
      wsin_pag_nostre := 0;
      wsin_prv_nostre := 0;
      wsin_prv31d_nostre := 0;
      wsin_pag_prosinxl := 0;
      wsin_prov_prosinxl := 0;
      wsin_prv31d_prosinxl := 0;
      wsin_pag31d_prosinxl := 0;
      wsin_pag_xl := 0;
      wsin_prov_xl := 0;
      wsin_prv31d_xl := 0;
      wsin_pag31d_xl := 0;
      pmerr := SIN;
      v_crenova := NULL;
   END inivar_sin;

------------------------------------------------
   FUNCTION datos_coa_sin(
      sseg IN NUMBER,
      ncua IN NUMBER,
      w_ctipcoa OUT NUMBER,
      w_ploc OUT NUMBER)
      RETURN NUMBER IS
      codi_error     NUMBER := 0;
   BEGIN
      SELECT ctipcoa
        INTO w_ctipcoa
        FROM seguros
       WHERE sseguro = sseg;

      IF w_ctipcoa IN(1, 2) THEN
         BEGIN
            SELECT ploccoa
              INTO w_ploc
              FROM coacuadro
             WHERE sseguro = sseg
               AND ncuacoa = ncua;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_ploc := 100;
            WHEN OTHERS THEN
               codi_error := 105726;
               RETURN(codi_error);
         END;
      ELSE
         w_ploc := 100;
      END IF;

      RETURN(codi_error);
   END datos_coa_sin;

------------------------------------------------
   FUNCTION valida_aplica_coa(
      w_ctipcoa IN NUMBER,
      nsin IN NUMBER,
      w_cpagcoa OUT NUMBER,
      apl_coa_prov OUT BOOLEAN,
      apl_coa_pag OUT BOOLEAN)
      RETURN NUMBER IS
/*  Si no hay coaseguro o el coaseguro es aceptado no debemos aplicar
  el % de coaseguro ya que en la base de datos tenemos los datos sólo
  por nuesta parte.
 si el coaseguro es cedido, debemos aplicar el % de coaseguro en la valoración
 (se guarda el total), y en el pago depende del campo cpagcoa, si es 1 lo
  aplicamos, sino no.
 Campos apl_coa_prov (se aplica o no a la provision)
   apl_coa_pag (se aplica o no a los pagos del año)
*/
      codi_error     NUMBER := 0;
   BEGIN
      IF w_ctipcoa IN(1, 2) THEN
         apl_coa_prov := TRUE;

         BEGIN
            /* para el caso de coaseguro cedido obtenemos el tipo de pago
            (por nuestra parte o por la totalidad) que deberá ser igual
            para todos los pagos del siniestro  */
            SELECT   cpagcoa
                INTO w_cpagcoa
                FROM pagosini
               WHERE nsinies = nsin
            GROUP BY cpagcoa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               /* no influye ya que no hay pagos: estamos en un coaseguro
               cedido sin pagos (lo distinguiremos por plocal <> 100
               and cpagcoa = null) */
               w_cpagcoa := NULL;
               apl_coa_pag := FALSE;
            WHEN OTHERS THEN
               codi_error := 105813;
               /* no todos los pagos son del mismo tipo */
               RETURN(codi_error);
         END;
      ELSE
         w_cpagcoa := 2;
         apl_coa_prov := FALSE;
         apl_coa_pag := FALSE;
      END IF;

      IF w_ctipcoa IN(1, 2) THEN
         IF w_cpagcoa = 1 THEN
            apl_coa_pag := TRUE;
         ELSE
            apl_coa_pag := FALSE;
         END IF;
      END IF;

      RETURN(codi_error);
   END valida_aplica_coa;

------------------------------------------------
   FUNCTION datos_rea_sin(
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      sseg IN NUMBER,
      w_ctiprea OUT NUMBER,
      pmerr IN OUT VARCHAR2)
      RETURN NUMBER IS
/* Se controlará si hay reaseguro o no a nivel de producto y poliza
  w_ctiprea = 3 no hay reaseguro a nivel de producto
              2 no hay reaseguro a nivel de poliza  */
      codi_error     NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(creaseg, 1)
           INTO w_ctiprea
           FROM productos
          WHERE cramo = ramo
            AND cmodali = moda
            AND ctipseg = tips
            AND ccolect = cole;
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 102705;
            pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
            RETURN(codi_error);
      END;

      IF w_ctiprea = 0 THEN
         w_ctiprea := 3;   /* este producto no se reasegura */
      ELSE
         BEGIN
            SELECT NVL(ctiprea, 1)
              INTO w_ctiprea
              FROM seguros
             WHERE sseguro = sseg;
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 101919;
               pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
               RETURN(codi_error);
         END;

         IF w_ctiprea = 2 THEN
            w_ctiprea := 2;   /* esta poliza no se reasegura */
         ELSE
            w_ctiprea := 0;
         END IF;
      END IF;

      RETURN(codi_error);
   END datos_rea_sin;

------------------------------------------------
   PROCEDURE inivar_gar(ww_porce IN OUT vect) IS
   BEGIN
      FOR i IN 0 .. 5 LOOP
         ww_porce(i) := 0;
      END LOOP;

      primera_cesion := FALSE;
      w_plocal := NULL;
      w_plocpro := 100;
      w_pagp_rea := 0;
      w_prvp_rea := 0;
      w_prv31dp_rea := 0;
      w_pagp_nrea := 0;
      w_prvp_nrea := 0;
      w_prv31dp_nrea := 0;
      per_error_imputem_a_no_reasegu := FALSE;
      v_scontra := NULL;
      v_nversio := NULL;
      v_ppropi := NULL;
      v_scontra_prot := NULL;
      v_nversio_prot := NULL;
      v_ppropi_prot := NULL;
   END inivar_gar;

------------------------------------------------
   FUNCTION datos_rea_gar(
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      cgar IN NUMBER,
      acti IN NUMBER,
      w_ctiprea OUT NUMBER,
      pmerr IN OUT VARCHAR2)
      RETURN NUMBER IS
/* Se mira el reaseguro a nivel de garantia
  w_ctiprea = 1 no hay reaseguro a nivel de garantia
              0 hay reaseguro a nivel de garantia  */
      codi_error     NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(creaseg, 1)
           INTO w_ctiprea
           FROM garanpro
          WHERE cramo = ramo
            AND cmodali = moda
            AND ctipseg = tips
            AND ccolect = cole
            AND cgarant = cgar
            AND cactivi = acti;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT NVL(creaseg, 1)
                 INTO w_ctiprea
                 FROM garanpro
                WHERE cramo = ramo
                  AND cmodali = moda
                  AND ctipseg = tips
                  AND ccolect = cole
                  AND cgarant = cgar
                  AND cactivi = 0;
            EXCEPTION
               WHEN OTHERS THEN
                  w_ctiprea := 0;
                  codi_error := 103503;
                  pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
                  RETURN(codi_error);
            END;
         WHEN OTHERS THEN
            w_ctiprea := 0;
            codi_error := 103503;
            pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
            RETURN(codi_error);
      END;

      IF w_ctiprea = 0 THEN
         w_ctiprea := 1;   /* esta garantia de este producto no se reasegura */
      ELSE
         w_ctiprea := 0;   /* esta garantia se reasegura */
      END IF;

      RETURN(codi_error);
   END datos_rea_gar;

------------------------------------------------
   FUNCTION busca_plocal(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      w_plocal OUT NUMBER,
      w_nsegcon OUT NUMBER,
      w_nsegver OUT NUMBER)
      RETURN NUMBER IS
      /* accedemos a tramos y codicontratos para obtener el plocal
         (ctramo = 1) segun el contrato y la versión, siempre y cuando
          el contrato sea de tipo 1 (ctiprea de codicontratos) que
          significa que se cede un porcentaje */
      codi_error     NUMBER := 0;
   BEGIN
      BEGIN
         SELECT t.plocal, t.nsegcon, t.nsegver
           INTO w_plocal, w_nsegcon, w_nsegver
           FROM tramos t, codicontratos c
          WHERE c.scontra = pscontra
            AND c.ctiprea = 1
            AND t.scontra = pscontra
            AND t.nversio = pnversio
            AND t.ctramo = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            codi_error := 105297;
            RETURN(codi_error);
      END;

      RETURN(codi_error);
   END busca_plocal;

------------------------------------------------
   FUNCTION busca_plocal_proteccio(
      w_nsegcon IN NUMBER,
      w_nsegver IN NUMBER,
      w_plocpro OUT NUMBER)
      RETURN NUMBER IS
      codi_error     NUMBER := 0;
      w_proteccio    NUMBER := 0;
   BEGIN
      BEGIN
         SELECT t.plocal
           INTO w_plocpro
           FROM contratos c, tramos t
          WHERE c.scontra = w_nsegcon
            AND c.nversio = w_nsegver
            AND c.scontra = t.scontra
            AND c.nversio = t.nversio
            AND t.ctramo = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_plocpro := 100;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 106205;
            RETURN(codi_error);
      END;

      RETURN(codi_error);
   END busca_plocal_proteccio;

------------------------------------------------
   FUNCTION reaseguro(
      cgar IN NUMBER,
      sseg IN NUMBER,
      nrie IN NUMBER,
      fsin IN DATE,
      scon IN NUMBER,
      nver IN NUMBER,
      ww_porce IN OUT vect,
      tip OUT NUMBER)
      RETURN NUMBER IS
/* cursor para reaseguros,
    tip = 1 a nivel de garantia
   = 2 a nivel de seguro
   = 3 para cgar in (9999,9998)
    (se queda con el primer registro del seguro) */
      CURSOR cur_ces(w_seg NUMBER, w_rie NUMBER, w_cgar NUMBER, w_fsin DATE, tip NUMBER) IS
         SELECT   scontra, nversio, ctramo, pcesion, cgarant
             FROM cesionesrea
            WHERE sseguro = w_seg
              AND nriesgo = w_rie
              AND((tip = 1
                   AND cgarant IS NOT NULL
                   AND cgarant = w_cgar)
                  OR(tip = 2
                     AND cgarant IS NULL)
                  OR(tip = 3))
              AND cgenera IN(01, 03, 04, 05, 09, 40)
              AND fefecto <= w_fsin
              AND fvencim > w_fsin
              AND(fanulac > w_fsin
                  OR fanulac IS NULL)
              AND(fregula > w_fsin
                  OR fregula IS NULL)
         ORDER BY ctramo, cgarant;

      codi_error     NUMBER := 0;
      con_garantia   BOOLEAN := FALSE;
      sense_garantia BOOLEAN := FALSE;
      wgar           NUMBER := NULL;
      v_scon         NUMBER;
      v_nver         NUMBER;
      w_nsegver      tramos.nsegver%TYPE;   --       w_nsegver      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF cgar <> '9999'
         AND cgar <> '9998' THEN
         tip := 1;

         FOR curces IN cur_ces(sseg, nrie, cgar, fsin, tip) LOOP
            /* hemos encontrado cesión para esta garantia en concreto */
            con_garantia := TRUE;

            IF scon IS NULL THEN
               /* no estamos corrigiendo: interesa el contrato de la cesión */
               v_scon := curces.scontra;
               v_nver := curces.nversio;
            ELSE
               /* estamos corrigiendo: interesa el contrato que hemos buscado */
               v_scon := scon;
               v_nver := nver;
            END IF;

            IF NOT primera_cesion THEN   --solo lo calculamos para la primera cesión
               primera_cesion := TRUE;
               codi_error := busca_plocal(v_scon, v_nver, w_plocal, w_nsegcon, w_nsegver);

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;

               IF w_nsegcon IS NOT NULL THEN   -- hay protección del propio
                  codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;
               END IF;
            END IF;

            ww_porce(curces.ctramo) := curces.pcesion;
         /* hemos recorrido todos los registros de cesionesrea para
            todos los tramos y los tenemos guardados en w_porce  */
         END LOOP;

         IF NOT con_garantia THEN
            /* no hemos encontrado cesión para la garantia que tratamos, buscamos una
                cesión general para el seguro (cgarant null) */
            tip := 2;

            FOR curces IN cur_ces(sseg, nrie, NULL, fsin, tip) LOOP
               IF scon IS NULL THEN   -- no corregimos
                  v_scon := curces.scontra;
                  v_nver := curces.nversio;
               ELSE   -- corregimos
                  v_scon := scon;
                  v_nver := nver;
               END IF;

               IF NOT primera_cesion THEN   --solo lo calculamos para la primera cesión
                  primera_cesion := TRUE;
                  codi_error := busca_plocal(v_scon, v_nver, w_plocal, w_nsegcon, w_nsegver);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;

                  IF w_nsegcon IS NOT NULL THEN   -- hi ha protecció del propi
                     codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

                     IF codi_error <> 0 THEN
                        RETURN(codi_error);
                     END IF;
                  END IF;
               END IF;

               ww_porce(curces.ctramo) := curces.pcesion;
            /* hemos recorrido todos los registros de cesionesrea para
              todos los tramos y los tenemos guardados en w_porce  */
            END LOOP;
         END IF;

         con_garantia := FALSE;
      ELSE
         /*  a partir d'ara ja no busquem la cessió pel seguro sense
          tenir en compte si es per la garantia o pel seguro (sense condició
          a cgarant (tip := 3)), ara buscarem sense garantia (cgarant is null),
          i si no trobem cessió buscarem per una garantia (per exemple la màxima,
          i per tots els trams farem servir aquesta garantia per trobar la
          cessió */
         tip := 2;

         FOR curces IN cur_ces(sseg, nrie, NULL, fsin, tip) LOOP
            sense_garantia := TRUE;

            IF scon IS NULL THEN   -- no corregimos
               v_scon := curces.scontra;
               v_nver := curces.nversio;
            ELSE   -- corregimos
               v_scon := scon;
               v_nver := nver;
            END IF;

            IF NOT primera_cesion THEN   --solo lo calculamos para la primera cesión
               primera_cesion := TRUE;
               codi_error := busca_plocal(v_scon, v_nver, w_plocal, w_nsegcon, w_nsegver);

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;

               IF w_nsegcon IS NOT NULL THEN   -- hi ha protecció del propi
                  codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;
               END IF;
            END IF;

            ww_porce(curces.ctramo) := curces.pcesion;
         /* hemos recorrido todos los registros de cesionesrea para
            todos los tramos y los tenemos guardados en w_porce  */
         END LOOP;

         IF NOT sense_garantia THEN
            tip := 3;

            FOR curces IN cur_ces(sseg, nrie, NULL, fsin, tip) LOOP
               IF wgar IS NULL
                  OR wgar = curces.cgarant THEN
                  -- si és null és la primera garantia que tractem i ens la quedem i la tractem
                  wgar := curces.cgarant;

                  IF scon IS NULL THEN   -- no corregimos
                     v_scon := curces.scontra;
                     v_nver := curces.nversio;
                  ELSE   -- corregimos
                     v_scon := scon;
                     v_nver := nver;
                  END IF;

                  IF NOT primera_cesion THEN   --solo lo calculamos para la primera cesión
                     primera_cesion := TRUE;
                     codi_error := busca_plocal(v_scon, v_nver, w_plocal, w_nsegcon,
                                                w_nsegver);

                     IF codi_error <> 0 THEN
                        RETURN(codi_error);
                     END IF;

                     IF w_nsegcon IS NOT NULL THEN   -- hi ha protecció del propi
                        codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

                        IF codi_error <> 0 THEN
                           RETURN(codi_error);
                        END IF;
                     END IF;
                  END IF;

                  ww_porce(curces.ctramo) := curces.pcesion;
               /* hemos recorrido todos los registros de cesionesrea para
                  todos los tramos y los tenemos guardados en w_porce  */
               END IF;
            END LOOP;
         END IF;

         sense_garantia := FALSE;
         wgar := NULL;
      END IF;

      v_scontra := v_scon;
      v_nversio := v_nver;
      v_ppropi := w_plocal;
      v_scontra_prot := w_nsegcon;
      v_nversio_prot := w_nsegver;
      v_ppropi_prot := w_plocpro;

      IF NVL(w_plocal, 0) <> 0 THEN
         /* si hi hagués segon contracte per tipus de contracte 2
          (els que tenen tram 0) aquest càlcul s'hauria de fer fora de
           aquest if */
         w_plocal := w_plocal * w_plocpro / 100;
         ww_porce(0) := (w_plocal * ww_porce(1)) / 100;
         ww_porce(1) := ww_porce(1) - ww_porce(0);
      END IF;

      RETURN(codi_error);
   END reaseguro;

------------------------------------------------
   FUNCTION control_cesion(
      npol IN NUMBER,
      sseg IN NUMBER,
      fsin IN DATE,
      nsin IN NUMBER,
      cgar IN NUMBER,
      ww_porce IN OUT vect,
      psproces IN NUMBER,
      nrie IN NUMBER,
      tip IN OUT NUMBER,
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      acti IN NUMBER,
      pmerr IN OUT VARCHAR2)
      RETURN NUMBER IS
/* si la suma de todos los tramos no suma 100 insertamos el siniestro
  en la tabla reasinierr para un control posterior. */
      codi_error     NUMBER := 0;
      cerror         NUMBER;
      merror         VARCHAR2(100);
      scon           codicontratos.scontra%TYPE;   --       scon           NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nver           contratos.nversio%TYPE;   --       nver           NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

------------------
      PROCEDURE borra_cesiones_erroneas(
         sseg IN NUMBER,
         fsin IN DATE,
         cgar IN NUMBER,
         nrie IN NUMBER,
         tip IN NUMBER) IS
      BEGIN
                  /*INSERT INTO cesionesrea2
                     SELECT cesionesrea.*, psproces
                       FROM cesionesrea
                      WHERE sseguro = sseg
                        AND nriesgo = nrie
                        AND (   (    tip = 1
                                 AND cgarant IS NOT NULL
                                 AND cgarant = cgar)
                             OR (    tip = 2
                                 AND cgarant IS NULL)
                             OR (tip = 3))
                        AND cgenera IN (01, 03, 04, 05, 09, 40)
                        AND fefecto <= fsin
                        AND fvencim > fsin
                        AND (   fanulac > fsin
                             OR fanulac IS NULL)
                        AND (   fregula > fsin
                             OR fregula IS NULL);
         */
         DELETE FROM cesionesrea
               WHERE sseguro = sseg
                 AND nriesgo = nrie
                 AND((tip = 1
                      AND cgarant IS NOT NULL
                      AND cgarant = cgar)
                     OR(tip = 2
                        AND cgarant IS NULL)
                     OR(tip = 3))
                 AND cgenera IN(01, 03, 04, 05, 09, 40)
                 AND fefecto <= fsin
                 AND fvencim > fsin
                 AND(fanulac > fsin
                     OR fanulac IS NULL)
                 AND(fregula > fsin
                     OR fregula IS NULL);
      END borra_cesiones_erroneas;

-- *****************************************************************************
-- F. crea_cesiones
------------------
      FUNCTION crea_cesiones(
         npol IN NUMBER,
         sseg IN NUMBER,
         fsin IN DATE,
         nsin IN NUMBER,
         cgar IN NUMBER,
         ww_porce IN vect,
         psproces IN NUMBER,
         ramo IN NUMBER,
         moda IN NUMBER,
         tips IN NUMBER,
         cole IN NUMBER,
         acti IN NUMBER,
         scon OUT NUMBER,
         nver OUT NUMBER,
         pmerr IN OUT VARCHAR2,
         merror OUT VARCHAR2)
         RETURN NUMBER IS
         CURSOR trams(ncon NUMBER, nver NUMBER) IS
            SELECT itottra, ctramo
              FROM tramos
             WHERE scontra = ncon
               AND nversio = nver;

         codi_error     NUMBER := 0;
         c_e            NUMBER;
         iret           cesionesrea.icomreg%TYPE;   --NUMBER(13, 2);
         cont_rea       NUMBER(2);
         nmov           NUMBER(4);
         tmov           cesionesrea.ccalif2%TYPE;   --          tmov           NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         num_mov        NUMBER(4);
         import_cap     cesionesrea.icapces%TYPE;   --NUMBER(15, 2);
         w_capital      cesionesrea.icapces%TYPE;   --NUMBER(15, 2);
         fvenc          cesionesrea.fvencim%TYPE;   --          fvenc          DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         acum_pces      NUMBER(5, 2);
         icap_pend      cesionesrea.icesion%TYPE;   --NUMBER(13, 2);
         pces           cesionesrea.pcesion%TYPE;   --          pces           NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         necesita_cap   BOOLEAN := TRUE;
         wcgar          cesionesrea.cgarant%TYPE;   --          wcgar          NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         wtram          NUMBER(2);
         wwctiprea      seguros.ctiprea%TYPE;   --          wwctiprea      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         wwcesrea       NUMBER(8);

---
         FUNCTION obtiene_capital_movim(
            sseg IN NUMBER,
            nries IN NUMBER,
            fsin IN DATE,
            ramo IN NUMBER,
            moda IN NUMBER,
            tips IN NUMBER,
            cole IN NUMBER,
            acti IN NUMBER,
            ww_capital IN OUT NUMBER,
            w_nmov IN OUT NUMBER,
            w_tmov IN OUT NUMBER,
            necesita_cap IN OUT BOOLEAN,
            merror OUT VARCHAR2)
            RETURN NUMBER IS
            codi_error     NUMBER := 0;
         BEGIN
            necesita_cap := TRUE;

            BEGIN
               SELECT MIN(nmovimi)   -- el mínimo no será una regularización
                 INTO w_nmov
                 FROM garanseg
                WHERE sseguro = sseg
                  AND nriesgo = nrie
                  AND finiefe <= fsin
                  AND(ffinefe > fsin
                      OR ffinefe IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105814;
                  merror := '5555 - no hi ha moviment a garanseg per la data';
                  RETURN(codi_error);
            END;

            BEGIN
               SELECT DECODE(cmovseg, 0, 3, 1, 4, 2, 5, 3, 4, 4, 9, 5, 4, 6, 10, 3)
                 INTO w_tmov
                 FROM movseguro
                WHERE sseguro = sseg
                  AND nmovimi = w_nmov;
            EXCEPTION
               WHEN OTHERS THEN
                  w_tmov := 3;
            END;

            /* sumamos el capital del movimiento que hemos encontrado,
               si el contrato de reaseguro que estamos tratando es contra una garantia
              (wcgar no nulo), solo interesa el capital de la garantia;
               sino (wcgar nulo), entonces debemos sumar el capital de todas las garantias
              que no tengan un contrato de reaseguro (en las mismas fechas,...) que las
              cubra individualmente
            */
            SELECT NVL(SUM(NVL(icapital, 0)), 0)
              INTO ww_capital
              FROM garanseg
             WHERE sseguro = sseg
               AND nriesgo = nrie
               AND cgarant IN(SELECT cgarant
                                FROM garanpro
                               WHERE cramo = ramo
                                 AND cmodali = moda
                                 AND ctipseg = tips
                                 AND ccolect = cole
                                 AND creaseg IN(1, 3)
                                 AND(cgarant = wcgar
                                     OR(wcgar IS NULL
                                        AND cgarant NOT IN(
                                              SELECT cgarant
                                                FROM cesionesrea
                                               WHERE sseguro = sseg
                                                 AND nriesgo = nrie
                                                 AND cgarant IS NOT NULL
                                                 AND cgenera IN(01, 03, 04, 05, 09, 40)
                                                 AND fefecto <= fsin
                                                 AND fvencim > fsin
                                                 AND(fanulac > fsin
                                                     OR fanulac IS NULL)
                                                 AND(fregula > fsin
                                                     OR fregula IS NULL)))))
               AND nmovimi = w_nmov;

            IF ww_capital = 0 THEN
               IF ramo IN(40, 41, 42, 43, 44, 45, 46, 50, 51) THEN
                  necesita_cap := FALSE;
               ELSE
                  codi_error := 107639;
                  merror := '4444 - no hi ha capital per fer cessio';
                  RETURN(codi_error);
               END IF;
            END IF;

            RETURN(codi_error);
         END obtiene_capital_movim;

---
         PROCEDURE obtiene_fvencim(sseg IN NUMBER, nrie IN NUMBER, fsin IN DATE, fvenc OUT DATE) IS
         BEGIN
            SELECT MIN(fefecto)
              INTO fvenc
              FROM cesionesrea
             WHERE sseguro = sseg
               AND nriesgo = nrie
               AND cgenera IN(01, 03, 04, 05, 09, 40)
               AND fefecto > fsin
               AND cgarant IS NULL
               AND(fanulac > fsin
                   OR fanulac IS NULL)
               AND(fregula > fsin
                   OR fregula IS NULL);

            IF fvenc IS NULL THEN
               SELECT NVL(DECODE(csituac, 0, fcaranu, 2, fanulac, 3, fvencim, fcaranu),
                          TO_DATE('31/12/' || TO_CHAR(fsin, 'yyyy'), 'dd/mm/yyyy'))
                 INTO fvenc
                 FROM seguros
                WHERE sseguro = sseg;
            END IF;

            IF TRUNC(fvenc) <= TRUNC(fsin) THEN
               fvenc := fsin + 1;
            END IF;
         END obtiene_fvencim;

-- ****************************************************************************
-- F. busca_contrato
--
         FUNCTION busca_contrato(
            fsin IN DATE,
            ramo IN NUMBER,
            scon OUT NUMBER,
            nver OUT NUMBER,
            iret OUT NUMBER,
            wcgar OUT NUMBER,
            wcont_rea OUT NUMBER,
            merror OUT VARCHAR2)
            RETURN NUMBER IS
            codi_error     NUMBER := 0;
         BEGIN
            BEGIN   -- buscamos contrato por producto, actividad, garantia
               SELECT cc.scontra, c.nversio, iretenc, ctiprea, cgarant
                 INTO scon, nver, iret, wcont_rea, wcgar
                 FROM codicontratos cc, contratos c, agr_contratos a
                WHERE cc.scontra = c.scontra
                  AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                  AND cc.ctiprea < 3
                  AND a.cramo = ramo
                  AND a.cactivi = acti
                  AND a.cgarant = cgar
                  AND a.cmodali = moda
                  AND a.ctipseg = tips
                  AND a.ccolect = cole
                  AND c.fconini <= fsin
                  AND(c.fconfin > fsin
                      OR c.fconfin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN   -- buscamos contrato por ramo, actividad, garantia
                     SELECT cc.scontra, c.nversio, iretenc, ctiprea, cgarant
                       INTO scon, nver, iret, wcont_rea, wcgar
                       FROM codicontratos cc, contratos c, agr_contratos a
                      WHERE cc.scontra = c.scontra
                        AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                        AND cc.ctiprea < 3
                        AND a.cramo = ramo
                        AND a.cactivi = acti
                        AND a.cgarant = cgar
                        AND a.cmodali IS NULL
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND c.fconini <= fsin
                        AND(c.fconfin > fsin
                            OR c.fconfin IS NULL);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN   -- buscamos contrato por producto, garantia
                           SELECT cc.scontra, c.nversio, iretenc, ctiprea, cgarant
                             INTO scon, nver, iret, wcont_rea, wcgar
                             FROM codicontratos cc, contratos c, agr_contratos a
                            WHERE cc.scontra = c.scontra
                              AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                              AND cc.ctiprea < 3
                              AND a.cramo = ramo
                              AND a.cactivi IS NULL
                              AND a.cgarant = cgar
                              AND a.cmodali = moda
                              AND a.ctipseg = tips
                              AND a.ccolect = cole
                              AND c.fconini <= fsin
                              AND(c.fconfin > fsin
                                  OR c.fconfin IS NULL);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              BEGIN   -- buscamos contrato por ramo, garantia
                                 SELECT cc.scontra, c.nversio, iretenc, ctiprea, cgarant
                                   INTO scon, nver, iret, wcont_rea, wcgar
                                   FROM codicontratos cc, contratos c, agr_contratos a
                                  WHERE cc.scontra = c.scontra
                                    AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                                    AND cc.ctiprea < 3
                                    AND a.cramo = ramo
                                    AND a.cactivi IS NULL
                                    AND a.cgarant = cgar
                                    AND a.cmodali IS NULL
                                    AND a.ctipseg IS NULL
                                    AND a.ccolect IS NULL
                                    AND c.fconini <= fsin
                                    AND(c.fconfin > fsin
                                        OR c.fconfin IS NULL);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    BEGIN   -- buscamos contrato por producto, actividad
                                       SELECT cc.scontra, c.nversio, iretenc, ctiprea, cgarant
                                         INTO scon, nver, iret, wcont_rea, wcgar
                                         FROM codicontratos cc, contratos c, agr_contratos a
                                        WHERE cc.scontra = c.scontra
                                          AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                                          AND cc.ctiprea < 3
                                          AND a.cramo = ramo
                                          AND a.cactivi = acti
                                          AND a.cgarant IS NULL
                                          AND a.cmodali = moda
                                          AND a.ctipseg = tips
                                          AND a.ccolect = cole
                                          AND c.fconini <= fsin
                                          AND(c.fconfin > fsin
                                              OR c.fconfin IS NULL);
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          BEGIN   -- buscamos contrato por ramo, actividad
                                             SELECT cc.scontra, c.nversio, iretenc, ctiprea,
                                                    cgarant
                                               INTO scon, nver, iret, wcont_rea,
                                                    wcgar
                                               FROM codicontratos cc, contratos c,
                                                    agr_contratos a
                                              WHERE cc.scontra = c.scontra
                                                AND c.scontra =
                                                               a.scontra   -- 14536 14-05-2010 AVT
                                                AND cc.ctiprea < 3
                                                AND a.cramo = ramo
                                                AND a.cactivi = acti
                                                AND a.cgarant IS NULL
                                                AND a.cmodali IS NULL
                                                AND a.ctipseg IS NULL
                                                AND a.ccolect IS NULL
                                                AND c.fconini <= fsin
                                                AND(c.fconfin > fsin
                                                    OR c.fconfin IS NULL);
                                          EXCEPTION
                                             WHEN NO_DATA_FOUND THEN
                                                BEGIN   -- buscamos contrato por producto
                                                   SELECT cc.scontra, c.nversio, iretenc,
                                                          ctiprea, cgarant
                                                     INTO scon, nver, iret,
                                                          wcont_rea, wcgar
                                                     FROM codicontratos cc, contratos c,
                                                          agr_contratos a
                                                    WHERE cc.scontra = c.scontra
                                                      AND c.scontra =
                                                               a.scontra   -- 14536 14-05-2010 AVT
                                                      AND cc.ctiprea < 3
                                                      AND a.cramo = ramo
                                                      AND a.cactivi IS NULL
                                                      AND a.cgarant IS NULL
                                                      AND a.cmodali = moda
                                                      AND a.ctipseg = tips
                                                      AND a.ccolect = cole
                                                      AND c.fconini <= fsin
                                                      AND(c.fconfin > fsin
                                                          OR c.fconfin IS NULL);
                                                EXCEPTION
                                                   WHEN NO_DATA_FOUND THEN
                                                      BEGIN   -- buscamos contrato por ramo
                                                         SELECT cc.scontra, c.nversio,
                                                                iretenc, ctiprea, cgarant
                                                           INTO scon, nver,
                                                                iret, wcont_rea, wcgar
                                                           FROM codicontratos cc, contratos c,
                                                                agr_contratos a
                                                          WHERE cc.scontra = c.scontra
                                                            AND c.scontra =
                                                                  a.scontra   -- 14536 14-05-2010 AVT
                                                            AND cc.ctiprea < 3
                                                            AND a.cramo = ramo
                                                            AND a.cactivi IS NULL
                                                            AND a.cgarant IS NULL
                                                            AND a.cmodali IS NULL
                                                            AND a.ctipseg IS NULL
                                                            AND a.ccolect IS NULL
                                                            AND c.fconini <= fsin
                                                            AND(c.fconfin > fsin
                                                                OR c.fconfin IS NULL);
                                                      EXCEPTION
                                                         WHEN OTHERS THEN
                                                            codi_error := 104485;
                                                            merror :=
                                                                   '3333 - no hi ha contracte';
                                                            RETURN(codi_error);
                                                      END;
                                                   WHEN OTHERS THEN
                                                      codi_error := 104485;
                                                      merror := '3333 - no hi ha contracte';
                                                      RETURN(codi_error);
                                                END;
                                             WHEN OTHERS THEN
                                                codi_error := 104485;
                                                merror := '3333 - no hi ha contracte';
                                                RETURN(codi_error);
                                          END;
                                       WHEN OTHERS THEN
                                          codi_error := 104485;
                                          merror := '3333 - no hi ha contracte';
                                          RETURN(codi_error);
                                    END;
                                 WHEN OTHERS THEN
                                    codi_error := 104485;
                                    merror := '3333 - no hi ha contracte';
                                    RETURN(codi_error);
                              END;
                           WHEN OTHERS THEN
                              codi_error := 104485;
                              merror := '3333 - no hi ha contracte';
                              RETURN(codi_error);
                        END;
                     WHEN OTHERS THEN
                        codi_error := 104485;
                        merror := '3333 - no hi ha contracte';
                        RETURN(codi_error);
                  END;
               WHEN OTHERS THEN
                  codi_error := 104485;
                  merror := '3333 - no hi ha contracte';
                  RETURN(codi_error);
            END;

            RETURN(codi_error);
         END busca_contrato;

-- ***********************************************************************
-- F. inserta_cesion ----------------------------------------------------
         FUNCTION inserta_cesion(
            sseg IN NUMBER,
            nrie IN NUMBER,
            nver IN NUMBER,
            scon IN NUMBER,
            fsin IN DATE,
            fvenc IN DATE,
            nmov IN NUMBER,
            tmov IN NUMBER,
            imp_tram IN NUMBER,
            icaptot IN NUMBER,
            icap_pend IN NUMBER,
            acum_pces IN NUMBER,
            tram IN NUMBER,
            wcgar IN NUMBER,
            pces OUT NUMBER,
            merror OUT VARCHAR2,
            w_scesrea OUT NUMBER)
            RETURN NUMBER IS
            codi_error     NUMBER := 0;
-- w_scesrea number;
            sfac           cesionesrea.sfacult%TYPE;   --             sfac           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

-- ***********************************************************************
-- F. graba_amb_facul ----------------------------------------------------
            FUNCTION graba_amb_facul(merror OUT VARCHAR2, sfac OUT NUMBER)
               RETURN NUMBER IS
/* L'usuari haurà d'informar els quadres manualment, i per això
  es treurà un llistat posteriorment  */
               codi_error     NUMBER := 0;
            BEGIN
               SELECT MAX(sfacult)
                 INTO sfac
                 FROM cuafacul
                WHERE sseguro = sseg
                  AND finicuf <= fsin
                  AND(ffincuf > fsin
                      OR ffincuf IS NULL);

               IF sfac IS NULL THEN
                  merror := '2222 - ha de gravar-se el quadre de facultatiu';
                  codi_error := 107638;
                  RETURN(codi_error);
               END IF;

               RETURN(codi_error);
            END graba_amb_facul;
         BEGIN
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            /* calculamos el porcentaje */
            IF tram = 5 THEN
               pces := 100 - acum_pces;
               codi_error := graba_amb_facul(merror, sfac);   -- avt
            /* guardamos el codigo de error, y si no falla la inserción en
             cesionesrea sera el que devolvamos */
            ELSE
               IF icap_pend > imp_tram THEN
                  pces := ROUND(imp_tram * 100 / icaptot, 2);
               ELSE
                  pces := 100 - acum_pces;
               END IF;
            END IF;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra,
                            ctramo, sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant,
                            spleno, ccalif1, ccalif2, nsinies, fefecto, fvencim,
                            fcontab, pcesion, sproces, cgenera,
                            fgenera, fregula, fanulac, nmovimi)
                    VALUES (w_scesrea, 1, 1, 1, sseg, nver, scon,
                            tram, sfac, nrie, NULL, NULL, NULL, wcgar,
                            NULL, NULL, NULL, NULL, fsin, fvenc,
                            TO_DATE('31/03/1999', 'dd/mm/yyyy'), pces, 21331, tmov,
                            f_sysdate, NULL, NULL, nmov);

               /* insertamos en la tabla de control */
               INSERT INTO cesionesrea1
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra,
                            ctramo, sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant,
                            spleno, ccalif1, ccalif2, nsinies, fefecto, fvencim,
                            fcontab, pcesion, sproces, cgenera,
                            fgenera, fregula, fanulac, nmovimi)
                    VALUES (w_scesrea, 1, 1, 1, sseg, nver, scon,
                            tram, sfac, nrie, NULL, NULL, NULL, wcgar,
                            NULL, NULL, NULL, NULL, fsin, fvenc,
                            TO_DATE('31/03/1999', 'dd/mm/yyyy'), pces, psproces, tmov,
                            f_sysdate, NULL, NULL, nmov);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105200;
                  merror := '1111 - no podem inserir a cesionesrea';
                  RETURN(codi_error);
            END;

            RETURN(codi_error);
         END inserta_cesion;

---
         PROCEDURE actualiza_capital(
            imp_tram IN NUMBER,
            pces IN NUMBER,
            imp_pend IN OUT NUMBER,
            acum_pces IN OUT NUMBER) IS
         BEGIN
            imp_pend := imp_pend - imp_tram;

            IF imp_pend < 0 THEN
               imp_pend := 0;
            END IF;

            acum_pces := acum_pces + pces;
         END actualiza_capital;
---
/* todos los errores que se transfieren entre esta función,
  sus funciones anidadas y las función que la llama no
  hacen parar la ejecución del libro */
      BEGIN
         acum_pces := 0;
         obtiene_fvencim(sseg, nrie, fsin, fvenc);
         codi_error := busca_contrato(fsin, ramo, scon, nver, iret, wcgar, cont_rea, merror);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         codi_error := obtiene_capital_movim(sseg, nrie, fsin, ramo, moda, tips, cole, acti,
                                             w_capital, nmov, tmov, necesita_cap, merror);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         icap_pend := w_capital;

         IF (ww_porce(0) + ww_porce(1) + ww_porce(2) + ww_porce(3) + ww_porce(4) + ww_porce(5)) <>
                                                                                              0 THEN
            borra_cesiones_erroneas(sseg, fsin, cgar, nrie, tip);
         END IF;

         IF necesita_cap THEN
            IF cont_rea = 2 THEN   -- se cede un importe, por lo tanto existe tramo 0
               codi_error := inserta_cesion(sseg, nrie, nver, scon, fsin, fvenc, nmov, tmov,
                                            iret, w_capital, icap_pend, acum_pces, 0, wcgar,
                                            pces, merror, wwcesrea);   -- avt

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;

               actualiza_capital(iret, pces, icap_pend, acum_pces);
            END IF;

            IF icap_pend > 0 THEN
               FOR t IN trams(scon, nver) LOOP
                  IF icap_pend > 0 THEN
                     codi_error := inserta_cesion(sseg, nrie, nver, scon, fsin, fvenc, nmov,
                                                  tmov, t.itottra, w_capital, icap_pend,
                                                  acum_pces, t.ctramo, wcgar, pces, merror,
                                                  wwcesrea);   -- avt

                     IF codi_error <> 0 THEN
                        RETURN(codi_error);
                     END IF;

                     actualiza_capital(t.itottra, pces, icap_pend, acum_pces);
                  END IF;
               END LOOP;

               IF icap_pend > 0 THEN
                  --  Les pólisses amb ctiprea = 1 no acumulen al facultatiu sino a l'últim
                  -- tram
                  BEGIN
                     SELECT ctiprea
                       INTO wwctiprea
                       FROM seguros
                      WHERE sseguro = sseg;
                  END;

                  IF wwctiprea = 1 THEN
                     pces := 100 - acum_pces;

                     UPDATE cesionesrea
                        SET pcesion = pcesion + pces
                      WHERE scesrea = wwcesrea;
                  ELSE
                     -- todo lo que queda va a facultativo
                     codi_error := inserta_cesion(sseg, nrie, nver, scon, fsin, fvenc, nmov,
                                                  tmov, 0, 0, 0, acum_pces, 5, wcgar, pces,
                                                  merror, wwcesrea);   --avt

                     IF codi_error <> 0 THEN
                        RETURN(codi_error);
                     END IF;
                  END IF;
               END IF;
            END IF;
         ELSE   --  no necesita capital, estem tractant un ram de salud i inserirem el 100%
            -- al tram 1, o al tram 0 depenent del tipus de contracte (ctiprea de
            -- codicontratos (que tenim a la variable cont_rea) valdrà 1 o 2 respectivament)
            IF cont_rea = 1 THEN
               wtram := 1;
            ELSE
               wtram := 0;
            END IF;

            codi_error := inserta_cesion(sseg, nrie, nver, scon, fsin, fvenc, nmov, tmov, 0, 0,
                                         0, 0, wtram, wcgar, pces, merror, wwcesrea);   -- avt

            IF codi_error <> 0 THEN
               RETURN(codi_error);
            END IF;
         END IF;

         RETURN(codi_error);
      END crea_cesiones;

------------------
      FUNCTION inserta_error(wcerror IN NUMBER, wmerror IN VARCHAR2)
         RETURN NUMBER IS
         codi_error     NUMBER := 0;
      BEGIN
         BEGIN
            INSERT INTO reasinierr
                        (npoliza, sseguro, fsinies, nsinies, cgarant, ptramo0, ptramo1,
                         ptramo2, ptramo3, ptramo4, ptramo5, sproces,
                         cerror, merror)
                 VALUES (npol, sseg, fsin, nsin, cgar, ww_porce(0), ww_porce(1),
                         ww_porce(2), ww_porce(3), ww_porce(4), ww_porce(5), psproces,
                         wcerror, wmerror);
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 105833;
               pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
               RETURN(codi_error);
         END;

         RETURN(codi_error);
      END inserta_error;
------------------
   BEGIN
-- NP només crearem els que no existeixen , els que no sumen 100 no
-- if round((ww_porce(0)+ww_porce(1)+ww_porce(2)+ww_porce(3)+ww_porce(4)+ww_porce(5)))<> 100 then
      IF ROUND((ww_porce(0) + ww_porce(1) + ww_porce(2) + ww_porce(3) + ww_porce(4)
                + ww_porce(5))) = 0 THEN
         cerror := crea_cesiones(npol, sseg, fsin, nsin, cgar, ww_porce, psproces, ramo, moda,
                                 tips, cole, acti, scon, nver, pmerr, merror);
         /* este error no hace que para la ejecución del libro, solo sirve
           que se inserte en la tabla de errores el motivo por el que no
           se ha corregido el error */
         codi_error := inserta_error(cerror, merror);   --avt

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         --  Si el error es 's'ha de grabar quadre de facultatiu', a pesar del error
         -- conseguimos correguir la cesion
         IF cerror = 0
            OR cerror = 107638 THEN
            /* hemos conseguido corregir la cesión, recalculamos el reaseguro
              para que el libro lo muestre */
            inivar_gar(ww_porce);
            codi_error := reaseguro(cgar, sseg, nrie, fsin, scon, nver, ww_porce, tip);

            IF codi_error <> 0 THEN
               RETURN(codi_error);
            END IF;
         ELSE
            -- Fem una xapuça: tot el que no s'ha pogut corretgir ho imputem al
            --   propi no reasegurable.
            per_error_imputem_a_no_reasegu := TRUE;
         END IF;
      END IF;

      RETURN(codi_error);
   END control_cesion;

------------------------------------------------
   PROCEDURE sumpag_any(nsin IN NUMBER, cgar IN NUMBER, pdata IN DATE) IS
   /* obtenemos la suma de los pagos realizados desde el inicio
    del año solicitado hasta el último día del mes solicitado */
   BEGIN
      /* No liquidados */
      SELECT NVL(SUM(DECODE(ps.ctippag, 2, pg.isinret, 3, 0 - pg.isinret, 0)), 0)
        INTO w_totpagany_nliq
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag IN(0, 1)   -- pendiente, acceptado
         AND fordpag <(LAST_DAY(pdata) + 1)
         AND fordpag > TO_DATE('31/12/'
                               || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy')) - 1)
                               || ' 23:59',
                               'dd/mm/yyyy hh24:mi');

      /* Liquidados */
      SELECT NVL(SUM(DECODE(ps.ctippag, 2, pg.isinret, 3, 0 - pg.isinret, 0)), 0)
        INTO w_totpagany_liq
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag = 2   -- pagado
         AND fordpag <(LAST_DAY(pdata) + 1)
         AND fordpag > TO_DATE('31/12/'
                               || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy')) - 1)
                               || ' 23:59',
                               'dd/mm/yyyy hh24:mi');

      w_totpagany := w_totpagany_nliq + w_totpagany_liq;
   END sumpag_any;

------------------------------------------------
   PROCEDURE sumrecobros(nsin IN NUMBER, cgar IN NUMBER, pdata IN DATE) IS
   /* obtenemos la suma de los recobros realizados desde el inicio
    del año solicitado hasta el último día del mes solicitado */
   BEGIN
      /* Liquidados */
      SELECT NVL(SUM(DECODE(ps.ctippag, 7, pg.isinret, 8, 0 - pg.isinret, 0)), 0)
        INTO w_totrecobros
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag = 2   -- pagado
         AND fordpag <(LAST_DAY(pdata) + 1)
         AND fordpag > TO_DATE('31/12/'
                               || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy')) - 1)
                               || ' 23:59',
                               'dd/mm/yyyy hh24:mi');
   END sumrecobros;

------------------------------------------------
   PROCEDURE sumpag(nsin IN NUMBER, cgar IN NUMBER, pdata IN DATE) IS
/* obtenemos la suma de todos los pagos para el siniestro */
   BEGIN
      /* No liquidados */
      SELECT NVL(SUM(DECODE(ps.ctippag, 2, pg.isinret, 3, 0 - pg.isinret, 0)), 0)
        INTO w_totpag_nliq
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag IN(0, 1)   -- pendiente, aceptado
         AND fordpag <(LAST_DAY(pdata) + 1);

      /* Liquidados */
      SELECT NVL(SUM(DECODE(ps.ctippag, 2, pg.isinret, 3, 0 - pg.isinret, 0)), 0)
        INTO w_totpag_liq
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag = 2   -- pagado
         AND fordpag <(LAST_DAY(pdata) + 1);

      w_totpag := w_totpag_nliq + w_totpag_liq;
   END sumpag;

------------------------------------------------
   PROCEDURE aplica_coaseguro(apl_coa_prov IN BOOLEAN, apl_coa_pag IN BOOLEAN, w_ploc IN NUMBER) IS
   BEGIN
  /* obtenemos los campos calculados */
-- Se añade el calculo para la provision a 31dic y nueva variable provision
      IF apl_coa_prov THEN
--    w_prov_coa := (ival -  w_totpag) * w_ploc/100;
         w_prov_coa := w_provisio * w_ploc / 100;
         w_prv31d_coa := w_provisio31d * w_ploc / 100;
      ELSE
--    w_prov_coa := (ival - w_totpag);
         w_prov_coa := w_provisio;
         w_prv31d_coa := w_provisio31d;
      END IF;

      IF apl_coa_pag THEN
         w_ipagoany_coa_nliq := w_totpagany_nliq * w_ploc / 100;
         w_ipagoany_coa_liq := w_totpagany_liq * w_ploc / 100;
--w_pag31d_coa := (w_totpag - (w_totpagany_nliq + w_totpagany_liq)) * w_ploc/100;
      ELSE
         w_ipagoany_coa_nliq := w_totpagany_nliq;
         w_ipagoany_coa_liq := w_totpagany_liq;
--w_pag31d_coa := w_totpag - (w_totpagany_nliq + w_totpagany_liq);
      END IF;

      w_ipagoany_coa := w_ipagoany_coa_nliq + w_ipagoany_coa_liq;
   END aplica_coaseguro;

------------------------------------------------
   PROCEDURE aplica_reaseguro(ival IN NUMBER, ww_porce IN vect, w_ctiprea IN NUMBER) IS
   BEGIN
      w_pag_cuop_nliq := w_ipagoany_coa_nliq * ww_porce(1) / 100;
      w_pag_cuop_liq := w_ipagoany_coa_liq * ww_porce(1) / 100;
      w_prov_cuop := w_prov_coa * ww_porce(1) / 100;
      w_prv31d_cuopart := w_prv31d_coa * ww_porce(1) / 100;
--
      w_pag_exc_nliq := w_ipagoany_coa_nliq *(ww_porce(2) + ww_porce(3)) / 100;
      w_pag_exc_liq := w_ipagoany_coa_liq *(ww_porce(2) + ww_porce(3)) / 100;
      w_prov_exc := w_prov_coa *(ww_porce(2) + ww_porce(3)) / 100;
      w_prv31d_exc := w_prv31d_coa *(ww_porce(2) + ww_porce(3)) / 100;
--
      w_pag_facob_nliq := w_ipagoany_coa_nliq * ww_porce(4) / 100;
      w_pag_facob_liq := w_ipagoany_coa_liq * ww_porce(4) / 100;
      w_prov_facob := w_prov_coa * ww_porce(4) / 100;
      w_prv31d_facob := w_prv31d_coa * ww_porce(4) / 100;
--
      w_pag_facul_nliq := w_ipagoany_coa_nliq * ww_porce(5) / 100;
      w_pag_facul_liq := w_ipagoany_coa_liq * ww_porce(5) / 100;
      w_prov_facul := w_prov_coa * ww_porce(5) / 100;
      w_prv31d_facul := w_prv31d_coa * ww_porce(5) / 100;
--
      w_pag_propi_nliq := w_ipagoany_coa_nliq * ww_porce(0) / 100;
      w_pag_propi_liq := w_ipagoany_coa_liq * ww_porce(0) / 100;
      w_prov_propi := w_prov_coa * ww_porce(0) / 100;
      w_prv31d_propi := w_prv31d_coa * ww_porce(0) / 100;
--w_pag31d_propi := w_pag31d_coa * ww_porce(0) / 100;
--
      w_pag_cuop := w_pag_cuop_nliq + w_pag_cuop_liq;
      w_pag_exc := w_pag_exc_nliq + w_pag_exc_liq;
      w_pag_facob := w_pag_facob_nliq + w_pag_facob_liq;
      w_pag_facul := w_pag_facul_nliq + w_pag_facul_liq;
      w_pag_propi := w_pag_propi_nliq + w_pag_propi_liq;

      IF w_ctiprea = 0
         AND NOT per_error_imputem_a_no_reasegu THEN
         w_pagp_rea := w_pag_propi;
         w_prvp_rea := w_prov_propi;
         w_prv31dp_rea := w_prv31d_propi;
--w_pag31dp_rea := w_pag31d_propi;
      ELSE
         w_pagp_nrea := w_ipagoany_coa;
         w_prvp_nrea := w_prov_coa;
         w_prv31dp_nrea := w_prv31d_coa;
--w_pag31dp_nrea := w_pag31d_coa;
      END IF;

      wsin_ipagoany_nliq := wsin_ipagoany_nliq + w_totpagany_nliq;
      wsin_ipagoany_liq := wsin_ipagoany_liq + w_totpagany_liq;
      wsin_ipagoany := wsin_ipagoany + w_totpagany;
      wsin_ivalora := wsin_ivalora + ival;
      wsin_valora31d := wsin_valora31d + w_valora31d;
      wsin_ipago_nliq := wsin_ipago_nliq + w_totpag_nliq;
      wsin_ipago_liq := wsin_ipago_liq + w_totpag_liq;
      wsin_ipago := wsin_ipago + w_totpag;
      wsin_provisio := wsin_provisio + w_provisio;
      wsin_provisio31d := wsin_provisio31d + w_provisio31d;
      wsin_recobros := wsin_recobros + w_totrecobros;
--
      wsin_ipagoany_coa_nliq := wsin_ipagoany_coa_nliq + w_ipagoany_coa_nliq;
      wsin_ipagoany_coa_liq := wsin_ipagoany_coa_liq + w_ipagoany_coa_liq;
      wsin_ipagoany_coa := wsin_ipagoany_coa + w_ipagoany_coa;
      wsin_iprov_coa := wsin_iprov_coa + w_prov_coa;
      wsin_prv31d_coa := wsin_prv31d_coa + w_prv31d_coa;
--
      wsin_ipagcuop_nliq := wsin_ipagcuop_nliq + w_pag_cuop_nliq;
      wsin_ipagcuop_liq := wsin_ipagcuop_liq + w_pag_cuop_liq;
      wsin_ipagcuop := wsin_ipagcuop + w_pag_cuop;
      wsin_iprovcuop := wsin_iprovcuop + w_prov_cuop;
      wsin_prv31d_cuopart := wsin_prv31d_cuopart + w_prv31d_cuopart;
--
      wsin_ipagexc_nliq := wsin_ipagexc_nliq + w_pag_exc_nliq;
      wsin_ipagexc_liq := wsin_ipagexc_liq + w_pag_exc_liq;
      wsin_ipagexc := wsin_ipagexc + w_pag_exc;
      wsin_iprovexc := wsin_iprovexc + w_prov_exc;
      wsin_prv31d_exc := wsin_prv31d_exc + w_prv31d_exc;
--
      wsin_ipagfacob_nliq := wsin_ipagfacob_nliq + w_pag_facob_nliq;
      wsin_ipagfacob_liq := wsin_ipagfacob_liq + w_pag_facob_liq;
      wsin_ipagfacob := wsin_ipagfacob + w_pag_facob;
      wsin_iprovfacob := wsin_iprovfacob + w_prov_facob;
      wsin_prv31d_facob := wsin_prv31d_facob + w_prv31d_facob;
--
      wsin_ipagfacul_nliq := wsin_ipagfacul_nliq + w_pag_facul_nliq;
      wsin_ipagfacul_liq := wsin_ipagfacul_liq + w_pag_facul_liq;
      wsin_ipagfacul := wsin_ipagfacul + w_pag_facul;
      wsin_iprovfacul := wsin_iprovfacul + w_prov_facul;
      wsin_prv31d_facul := wsin_prv31d_facul + w_prv31d_facul;
--
      wsin_ipagpropi_nliq := wsin_ipagpropi_nliq + w_pag_propi_nliq;
      wsin_ipagpropi_liq := wsin_ipagpropi_liq + w_pag_propi_liq;
      wsin_ipagpropi := wsin_ipagpropi + w_pag_propi;
      wsin_iprovpropi := wsin_iprovpropi + w_prov_propi;
      wsin_prv31d_propi := wsin_prv31d_propi + w_prv31d_propi;

      IF w_ctiprea = 0
         AND NOT per_error_imputem_a_no_reasegu THEN
         wsin_ipag_rea := wsin_ipag_rea + w_pag_propi;
         wsin_iprv_rea := wsin_iprv_rea + w_prov_propi;
         wsin_prv31d_rea := wsin_prv31d_rea + w_prv31d_propi;
--wsin_pag31d_rea := wsin_pag31d_rea + w_pag31d_propi;
      ELSE
         wsin_ipag_nrea := wsin_ipag_nrea + w_ipagoany_coa;
         wsin_iprv_nrea := wsin_iprv_nrea + w_prov_coa;
         wsin_prv31d_nrea := wsin_prv31d_nrea + w_prv31d_coa;
--wsin_pag31d_nrea := wsin_pag31d_nrea + w_pag31d_coa;
      END IF;
   END aplica_reaseguro;

------------------------------------------------
   FUNCTION busca_contrato_xl(
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      acti IN NUMBER,
      fsin IN DATE,
      w_iprioxl OUT NUMBER,
      w_icapacixl OUT NUMBER)
      RETURN NUMBER IS
/* de la busqueda de contrato excluimos los ramos
de vida (30,31,32,33) que tienen un contrato ficticio
por necesidades del programa de alta de cesiones */
/* recupera información del tramo */
      CURSOR cur_trams(scon NUMBER, nver NUMBER) IS
         SELECT ixlprio
           FROM tramos
          WHERE scontra = scon
            AND nversio = nver;

      codi_error     NUMBER := 0;
      w_scontra      contratos.scontra%TYPE;   --       w_scontra      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nversio      contratos.nversio%TYPE;   --       w_nversio      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      w_scontra := NULL;

      BEGIN   -- buscamos contrato para el producto y la actividad
         SELECT c.scontra, c.nversio, c.iprioxl
           INTO w_scontra, w_nversio, w_iprioxl
           FROM contratos c, codicontratos co, agr_contratos a
          WHERE co.ctiprea = 3
            AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
            AND a.cramo = ramo
            AND a.cramo NOT IN(30, 31, 32, 33)
            AND a.cmodali = moda
            AND a.ctipseg = tips
            AND a.ccolect = cole
            AND a.cactivi = acti
            AND c.scontra = co.scontra
            AND c.fconini <= fsin
            AND(c.fconfin > fsin
                OR c.fconfin IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN   -- buscamos contrato por ramo, actividad
               SELECT c.scontra, c.nversio, c.iprioxl
                 INTO w_scontra, w_nversio, w_iprioxl
                 FROM contratos c, codicontratos co, agr_contratos a
                WHERE co.ctiprea = 3
                  AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                  AND a.cramo = ramo
                  AND a.cramo NOT IN(30, 31, 32, 33)
                  AND a.cactivi = acti
                  AND a.cmodali IS NULL
                  AND a.ctipseg IS NULL
                  AND a.ccolect IS NULL
                  AND c.scontra = co.scontra
                  AND c.fconini <= fsin
                  AND(c.fconfin > fsin
                      OR c.fconfin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN   -- buscamos contrato por producto
                     SELECT c.scontra, c.nversio, c.iprioxl
                       INTO w_scontra, w_nversio, w_iprioxl
                       FROM contratos c, codicontratos co, agr_contratos a
                      WHERE co.ctiprea = 3
                        AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                        AND a.cramo = ramo
                        AND a.cramo NOT IN(30, 31, 32, 33)
                        AND a.cmodali = moda
                        AND a.ctipseg = tips
                        AND a.ccolect = cole
                        AND a.cactivi IS NULL
                        AND c.scontra = co.scontra
                        AND c.fconini <= fsin
                        AND(c.fconfin > fsin
                            OR c.fconfin IS NULL);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN   -- buscamos contrato por ramo
                           SELECT c.scontra, c.nversio, c.iprioxl
                             INTO w_scontra, w_nversio, w_iprioxl
                             FROM contratos c, codicontratos co, agr_contratos a
                            WHERE co.ctiprea = 3
                              AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                              AND a.cramo = ramo
                              AND a.cramo NOT IN(30, 31, 32, 33)
                              AND a.cmodali IS NULL
                              AND a.ctipseg IS NULL
                              AND a.ccolect IS NULL
                              AND a.cactivi IS NULL
                              AND c.scontra = co.scontra
                              AND c.fconini <= fsin
                              AND(c.fconfin > fsin
                                  OR c.fconfin IS NULL);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              NULL;
                           WHEN OTHERS THEN
                              codi_error := 104704;
                              RETURN(codi_error);
                        END;
                     WHEN OTHERS THEN
                        codi_error := 104704;
                        RETURN(codi_error);
                  END;
               WHEN OTHERS THEN
                  codi_error := 104704;
                  RETURN(codi_error);
            END;
         WHEN OTHERS THEN
            codi_error := 104704;
            RETURN(codi_error);
      END;

      w_icapacixl := 0;

      IF w_scontra IS NOT NULL THEN
         w_icapacixl := w_iprioxl;

         FOR regtram IN cur_trams(w_scontra, w_nversio) LOOP
            w_icapacixl := w_icapacixl + regtram.ixlprio;
         END LOOP;
      END IF;

      RETURN(codi_error);
   END busca_contrato_xl;

------------------------------------------------
   PROCEDURE aplica_xl(ramo IN NUMBER, w_iprioxl IN NUMBER) IS
/* Se calcula la parte propia sin xl */
   BEGIN
      IF ramo NOT IN(30, 31, 32, 33) THEN
         IF wsin_ipag_rea >= w_iprioxl THEN
            wsin_pag_prosinxl := w_iprioxl;
            wsin_pag_xl := wsin_ipag_rea - w_iprioxl;
         ELSE
            wsin_pag_prosinxl := wsin_ipag_rea;
            wsin_pag_xl := 0;
         END IF;

         IF wsin_pag_xl > 0 THEN
            wsin_prov_prosinxl := 0;
            wsin_prov_xl := wsin_iprv_rea;
         ELSIF wsin_iprv_rea -(w_iprioxl - wsin_ipag_rea) >= 0 THEN
            wsin_prov_prosinxl := w_iprioxl - wsin_ipag_rea;
            wsin_prov_xl := wsin_iprv_rea - wsin_prov_prosinxl;
         ELSE
            wsin_prov_prosinxl := wsin_iprv_rea;
            wsin_prov_xl := 0;
         END IF;

--
         IF wsin_pag31d_rea >= w_iprioxl THEN
            wsin_pag31d_prosinxl := w_iprioxl;
            wsin_pag31d_xl := wsin_pag31d_rea - w_iprioxl;
         ELSE
            wsin_pag31d_prosinxl := wsin_pag31d_rea;
            wsin_pag31d_xl := 0;
         END IF;

         IF wsin_pag31d_xl > 0 THEN
            wsin_prv31d_prosinxl := 0;
            wsin_prv31d_xl := wsin_prv31d_rea;
         ELSIF wsin_prv31d_rea -(w_iprioxl - wsin_pag31d_rea) >= 0 THEN
            wsin_prv31d_prosinxl := w_iprioxl - wsin_pag31d_rea;
            wsin_prv31d_xl := wsin_prv31d_rea - wsin_prv31d_prosinxl;
         ELSE
            wsin_prv31d_prosinxl := wsin_prv31d_rea;
            wsin_prv31d_xl := 0;
         END IF;
--
      ELSE
         wsin_pag_prosinxl := wsin_ipag_rea;
         wsin_prov_prosinxl := wsin_iprv_rea;
         wsin_prv31d_prosinxl := wsin_prv31d_rea;
         wsin_pag_xl := 0;
         wsin_prov_xl := 0;
         wsin_prv31d_xl := 0;
      END IF;
   END aplica_xl;

------------------------------------------------
   PROCEDURE obtiene_valora31d(w_nsini IN NUMBER, w_gar IN NUMBER, pdata IN DATE, w_fsin DATE) IS
-------------------------------------
/*
La valoració 31d es considera fins a 31/01, dels sinistres amb data
de sinistres(fsinies) anterior a 01/01 (declarats quan sigui)
 */
   BEGIN
      IF w_fsin < TO_DATE('31/12/' || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy')) - 1),
                          'dd/mm/yyyy')
                  + 1 THEN
         BEGIN
            SELECT ivalora
              INTO w_valora31d
              FROM valorasini v
             WHERE v.nsinies = w_nsini
               AND v.cgarant = w_gar
               AND v.fvalora =
                     (SELECT MAX(v1.fvalora)
                        FROM valorasini v1
                       WHERE v1.nsinies = v.nsinies
                         AND v1.cgarant = v.cgarant
                         AND v1.fvalora <
                               (TO_DATE('31/01/'
                                        || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy'))),
                                        'dd/mm/yyyy')
                                + 1));
         EXCEPTION
            WHEN OTHERS THEN
               w_valora31d := 0;
         END;
      ELSE
         w_valora31d := 0;
      END IF;
   END obtiene_valora31d;

/*********************************************
  FUNCIONES ESPECIFICAS DE LA TABLA MENSUAL
**********************************************/
------------------------------------------------
   PROCEDURE inivar_mens(pdata IN DATE) IS
   BEGIN
      w_fini_exer := TO_DATE(TO_CHAR(pdata, 'mmyyyy'), 'mmyyyy');
      w_ffin_exer := LAST_DAY(pdata);
   END inivar_mens;

------------------------------------------------
   PROCEDURE obtiene_provision_periodo(nsin IN NUMBER) IS
      err            NUMBER;
   BEGIN
      /* obtenemos la provisión al inicio del periodo solicitado */
      err := f_provisio(nsin, w_proviniper, w_fini_exer);
      /* obtenemos la provisión al final del periodo solicitado */
      err := f_provisio(nsin, w_provfinper, w_ffin_exer);
   END obtiene_provision_periodo;

------------------------
   PROCEDURE obt_fecha_valoracion_inicial(nsin IN NUMBER, fnot IN DATE) IS
      w_valnot       NUMBER;
   BEGIN
      /* Recuperamos la fecha de valoración el primer dia en que hubo  */
      SELECT MIN(fvalora)
        INTO w_fminval
        FROM valorasini
       WHERE nsinies = nsin;
   END obt_fecha_valoracion_inicial;

------------------------
   PROCEDURE obt_fecha_ultima_valoracion(nsin IN NUMBER) IS
   BEGIN
      /* obtenemos la fecha de la ultima valoración del siniestro */
      SELECT MAX(fvalora)
        INTO w_fvalmax
        FROM valorasini
       WHERE nsinies = nsin
         AND fvalora < w_ffin_exer + 1;
   END obt_fecha_ultima_valoracion;

------------------------
   PROCEDURE datsin_mens(nsin IN NUMBER, fnot IN DATE) IS
   BEGIN
      wsin_ivalini := 0;
      wsin_irecobro := 0;
      obtiene_provision_periodo(nsin);
      obt_fecha_valoracion_inicial(nsin, fnot);
      obt_fecha_ultima_valoracion(nsin);
   END datsin_mens;

------------------------------------------------
   PROCEDURE obtiene_valoracion_inicial(nsin IN NUMBER, cgar IN NUMBER) IS
   BEGIN
      /* miramos si la garantia pertenecia a la valoración inicial del
       siniestros y recuperamos el valor */
      BEGIN
         SELECT NVL(ivalora, 0)
           INTO w_ivalini
           FROM valorasini
          WHERE nsinies = nsin
            AND cgarant = cgar
            AND fvalora = w_fminval;
      EXCEPTION
         WHEN OTHERS THEN
            w_ivalini := 0;
      END;
   END obtiene_valoracion_inicial;

------------------------
   PROCEDURE sumrecob(nsin IN NUMBER, cgar IN NUMBER, pdata IN DATE) IS
   BEGIN
      /* obtenemos la suma de todos los recobros para el siniestro */
      SELECT NVL(SUM(DECODE(ps.ctippag, 7, pg.isinret, 8, 0 - pg.isinret, 0)), 0)
        INTO w_irecobro
        FROM pagogarantia pg, pagosini ps
       WHERE pg.sidepag = ps.sidepag
         AND ps.nsinies = nsin
         AND pg.cgarant = cgar
         AND ps.cestpag <> 8   -- (no anulado)
         AND fordpag <(LAST_DAY(pdata) + 1);
   END sumrecob;

------------------------
   PROCEDURE datgar_mens(nsin IN NUMBER, cgar IN NUMBER, ppdata IN DATE) IS
   BEGIN
      obtiene_valoracion_inicial(nsin, cgar);
      sumrecob(nsin, cgar, ppdata);
   END datgar_mens;

------------------------------------------------
   PROCEDURE aplica_datgarmens IS
   BEGIN
      wsin_ivalini := wsin_ivalini + w_ivalini;
      wsin_irecobro := wsin_irecobro + w_irecobro;
   END aplica_datgarmens;

------------------------------------------------
/**********************************************/
------------------------------------------------
   FUNCTION actualitza_provisions_mensuals(
      wempresa IN NUMBER,
      wdata_ini IN DATE,
      wdata_fin IN DATE)
      RETURN NUMBER IS
/***********************************************************************
    ACTUALITZA_PROVISIONS_MENSUALS: Esta función actualiza el campo ipromes de siniestros
    de los siniestros que se han tratado durante el último mes. Antes de reemplazar la in-
    formación de ipromes se guarda el valor en iproant. Se llama desde el cierre mensual de
    siniestros.

*************************************************************************/
      CURSOR sinistres_a_tractar IS
         SELECT si.nsinies, si.cestsin, si.festsin
           FROM siniestros si, seguros s, codiram cr
          WHERE NVL(si.fentrad, si.fnotifi) < wdata_fin + 1
            AND si.sseguro = s.sseguro
            AND s.cramo = cr.cramo
            AND cr.cempres = wempresa
            AND(   -- esta obert des del principi fins final de mes
                NOT EXISTS(SELECT ag.nsinies
                             FROM agensini ag
                            WHERE ag.nsinies = si.nsinies
                              AND ag.ctipreg = 5
                              AND ag.fapunte < wdata_fin + 1)
                OR   -- moviment durant el mes
                  EXISTS(SELECT ag.nsinies
                           FROM agensini ag
                          WHERE ag.nsinies = si.nsinies
                            AND ag.ctipreg = 5
                            AND ag.fapunte >= wdata_ini
                            AND ag.fapunte < wdata_fin + 1)
                OR   -- oberts i sense moviments des del principi de mes
                  (si.cestsin = 0
                   AND NOT EXISTS(SELECT ag.nsinies
                                    FROM agensini ag
                                   WHERE ag.nsinies = si.nsinies
                                     AND ag.ctipreg = 5
                                     AND ag.fapunte >= wdata_ini))
                OR   -- que l'ultim moviment abans del principi del mes era de reobertura.
                  (si.cestsin <> 0
                   AND EXISTS(SELECT ag.nsinies
                                FROM agensini ag
                               WHERE ag.nsinies = si.nsinies
                                 AND ag.ctipreg = 5
                                 AND ag.fapunte =
                                       (SELECT MAX(ag1.fapunte)
                                          FROM agensini ag1
                                         WHERE ag1.fapunte < wdata_fin + 1
                                           AND ag.nsinies = ag1.nsinies
                                           AND ag.ctipreg = 5)
                                 AND SUBSTR(ag.tagenda, 1, 2) = '04')));

      err            NUMBER;
      prov           siniestros.ipromes%TYPE;   --       prov           NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nerr           NUMBER := 0;
      wsproces       NUMBER;   -- Bug 28462 - 08/10/2013 - JMG - Modificacion campo sproces a NUMBER
      nlin           NUMBER(4);
      codi_error     NUMBER := 0;

      PROCEDURE guarda_provisions_anteriors(
         wempresa IN NUMBER,
         wdata_ini IN DATE,
         wdata_fin IN DATE) IS
         CURSOR sinistres_a_tractar IS
            SELECT si.nsinies, si.cestsin, si.festsin
              FROM siniestros si, seguros s, codiram cr
             WHERE NVL(si.fentrad, si.fnotifi) < wdata_fin + 1
               AND si.sseguro = s.sseguro
               AND s.cramo = cr.cramo
               AND cr.cempres = wempresa
               AND(   -- esta obert des del principi fins final de mes
                   NOT EXISTS(SELECT ag.nsinies
                                FROM agensini ag
                               WHERE ag.nsinies = si.nsinies
                                 AND ag.ctipreg = 5
                                 AND ag.fapunte < wdata_fin + 1)
                   OR   -- moviment durant el mes
                     EXISTS(SELECT ag.nsinies
                              FROM agensini ag
                             WHERE ag.nsinies = si.nsinies
                               AND ag.ctipreg = 5
                               AND ag.fapunte >= wdata_ini
                               AND ag.fapunte < wdata_fin + 1)
                   OR   -- oberts i sense moviments des del principi de mes
                     (si.cestsin = 0
                      AND NOT EXISTS(SELECT ag.nsinies
                                       FROM agensini ag
                                      WHERE ag.nsinies = si.nsinies
                                        AND ag.ctipreg = 5
                                        AND ag.fapunte >= wdata_ini))
                   OR   -- que l'ultim moviment abans del principi del mes era de reobertura.
                     (si.cestsin <> 0
                      AND EXISTS(SELECT ag.nsinies
                                   FROM agensini ag
                                  WHERE ag.nsinies = si.nsinies
                                    AND ag.ctipreg = 5
                                    AND ag.fapunte =
                                          (SELECT MAX(ag1.fapunte)
                                             FROM agensini ag1
                                            WHERE ag1.fapunte < wdata_fin + 1
                                              AND ag.nsinies = ag1.nsinies
                                              AND ag.ctipreg = 5)
                                    AND SUBSTR(ag.tagenda, 1, 2) = '04')));
      BEGIN
         FOR csin IN sinistres_a_tractar LOOP
            UPDATE siniestros
               SET iproant = ipromes
             WHERE nsinies = csin.nsinies;
         END LOOP;
      END guarda_provisions_anteriors;
   BEGIN
      guarda_provisions_anteriors(wempresa, ADD_MONTHS(wdata_ini, -1),
                                  ADD_MONTHS(wdata_fin, -1));

      FOR csin IN sinistres_a_tractar LOOP
         err := f_provisio(csin.nsinies, prov, wdata_fin);

         IF csin.cestsin = 1
            AND csin.festsin <= wdata_fin
            AND prov <> 0 THEN
            -- controlem una part dels errors: que estés tancat a data de fi de mes
            --   amb provisió <> 0 (s'escapen casos de reobertura,...)
            err := f_proceslin(wsproces,
                               'Sinistre: ' || csin.nsinies
                               || ' tancat amb provisio diferent de 0',
                               0, nlin);
            nerr := nerr + 1;
         END IF;

         UPDATE siniestros
            SET ipromes = prov
          WHERE nsinies = csin.nsinies;
      END LOOP;

      RETURN(codi_error);
   END actualitza_provisions_mensuals;

------------------------------------------------
/**********************************************/
------------------------------------------------
   FUNCTION actualitza_provisions_anuals(
      wempresa IN NUMBER,
      wdata_ini IN DATE,
      wdata_fin IN DATE)
      RETURN NUMBER IS
/***********************************************************************
    ACTUALITZA_PROVISIONS_ANUALS: Esta función actualiza el campo ipro31d de siniestros
    de los siniestros que se han tratado durante el año. Se llama desde el cierre de
    siniestros con fecha cierre 31/12 del año correspondiente.

*************************************************************************/
-- Creamos otro cursor para tratar los siniestros ocurridos durante el
--   año, pero declarados durante enero del año siguiente.
      CURSOR sinistres_a_tractar IS
         SELECT si.nsinies, si.cestsin, si.festsin
           FROM siniestros si, seguros s, codiram cr
          WHERE si.fnotifi < wdata_fin + 1
            AND si.sseguro = s.sseguro
            AND s.cramo = cr.cramo
            AND cr.cempres = wempresa
            AND(   -- esta obert des del principi fins final de mes
                NOT EXISTS(SELECT ag.nsinies
                             FROM agensini ag
                            WHERE ag.nsinies = si.nsinies
                              AND ag.ctipreg = 5
                              AND ag.fapunte < wdata_fin + 1)
                OR   -- moviment durant el mes
                  EXISTS(SELECT ag.nsinies
                           FROM agensini ag
                          WHERE ag.nsinies = si.nsinies
                            AND ag.ctipreg = 5
                            AND ag.fapunte >= wdata_ini
                            AND ag.fapunte < wdata_fin + 1)
                OR   -- oberts i sense moviments des del principi de mes
                  (si.cestsin = 0
                   AND NOT EXISTS(SELECT ag.nsinies
                                    FROM agensini ag
                                   WHERE ag.nsinies = si.nsinies
                                     AND ag.ctipreg = 5
                                     AND ag.fapunte >= wdata_ini))
                OR   -- que l'ultim moviment abans del principi del mes era de reobertura.
                  (si.cestsin <> 0
                   AND EXISTS(SELECT ag.nsinies
                                FROM agensini ag
                               WHERE ag.nsinies = si.nsinies
                                 AND ag.ctipreg = 5
                                 AND ag.fapunte =
                                       (SELECT MAX(ag1.fapunte)
                                          FROM agensini ag1
                                         WHERE ag1.fapunte < wdata_fin + 1
                                           AND ag.nsinies = ag1.nsinies
                                           AND ag.ctipreg = 5)
                                 AND SUBSTR(ag.tagenda, 1, 2) = '04')));

      CURSOR sin_declarats_gener_seguent IS
         SELECT si.nsinies, si.cestsin, si.festsin
           FROM siniestros si, seguros s, codiram cr
          WHERE si.fnotifi < ADD_MONTHS(wdata_fin, 1) + 1
            AND si.fnotifi > wdata_fin
            AND si.fsinies < wdata_fin + 1
            AND si.sseguro = s.sseguro
            AND s.cramo = cr.cramo
            AND cr.cempres = wempresa
            AND(   -- esta obert des del principi fins final de mes
                NOT EXISTS(SELECT ag.nsinies
                             FROM agensini ag
                            WHERE ag.nsinies = si.nsinies
                              AND ag.ctipreg = 5
                              AND ag.fapunte < wdata_fin + 1)
                OR   -- moviment durant el mes
                  EXISTS(SELECT ag.nsinies
                           FROM agensini ag
                          WHERE ag.nsinies = si.nsinies
                            AND ag.ctipreg = 5
                            AND ag.fapunte >= wdata_ini
                            AND ag.fapunte < wdata_fin + 1)
                OR   -- oberts i sense moviments des del principi de mes
                  (si.cestsin = 0
                   AND NOT EXISTS(SELECT ag.nsinies
                                    FROM agensini ag
                                   WHERE ag.nsinies = si.nsinies
                                     AND ag.ctipreg = 5
                                     AND ag.fapunte >= wdata_ini))
                OR   -- que l'ultim moviment abans del principi del mes era de reobertura.
                  (si.cestsin <> 0
                   AND EXISTS(SELECT ag.nsinies
                                FROM agensini ag
                               WHERE ag.nsinies = si.nsinies
                                 AND ag.ctipreg = 5
                                 AND ag.fapunte =
                                       (SELECT MAX(ag1.fapunte)
                                          FROM agensini ag1
                                         WHERE ag1.fapunte < wdata_fin + 1
                                           AND ag.nsinies = ag1.nsinies
                                           AND ag.ctipreg = 5)
                                 AND SUBSTR(ag.tagenda, 1, 2) = '04')));

      err            NUMBER;
      prov           siniestros.ipro31d%TYPE;   --       prov           NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nerr           NUMBER := 0;
      wsproces       NUMBER;   -- Bug 28462 - 08/10/2013 - JMG - Modificacion campo sproces a NUMBER
      nlin           NUMBER(4);
      codi_error     NUMBER := 0;
   BEGIN
      FOR csin IN sinistres_a_tractar LOOP
         -- tractem els sinistres de l'any del tancament
         err := f_provisio(csin.nsinies, prov, wdata_fin);

         IF csin.cestsin = 1
            AND csin.festsin <= wdata_fin
            AND prov <> 0 THEN
            -- controlem una part dels errors: que estés tancat a data de fi de mes
            --   amb provisió <> 0 (s'escapen casos de reobertura,...)
            err := f_proceslin(wsproces,
                               'Sinistre: ' || csin.nsinies
                               || ' tancat amb provisio diferent de 0',
                               0, nlin);
            nerr := nerr + 1;
         END IF;

         UPDATE siniestros
            SET ipro31d = prov
          WHERE nsinies = csin.nsinies;
      END LOOP;

      FOR csin IN sin_declarats_gener_seguent LOOP   -- tractem els sinistres declarats durant el gener de l'any següent al tancament.
         --   per calcular la provisió fem servir el mes de gener.
         err := f_provisio(csin.nsinies, prov, ADD_MONTHS(wdata_fin, 1));

         IF csin.cestsin = 1
            AND csin.festsin <= wdata_fin
            AND prov <> 0 THEN
            -- controlem una part dels errors: que estés tancat a data de fi de mes
            --   amb provisió <> 0 (s'escapen casos de reobertura,...)
            err := f_proceslin(wsproces,
                               'Sinistre: ' || csin.nsinies
                               || ' tancat amb provisio diferent de 0',
                               0, nlin);
            nerr := nerr + 1;
         END IF;

         UPDATE siniestros
            SET ipro31d = prov
          WHERE nsinies = csin.nsinies;
      END LOOP;

      RETURN(codi_error);
   END actualitza_provisions_anuals;

------------------------------------------------
--
--
--
--
--
--
--
--
--
--
--
/***********************************************************************************/
/***********************************************************************************/
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
   FUNCTION f_libsin(psproces IN NUMBER, pempres IN NUMBER, pdata IN DATE, pmerr OUT VARCHAR2)
      RETURN NUMBER IS
/************************************************************************************
    F_LIBSIN: Esta función escribe en la tabla reasiniaux los % de repartición
     del reaseguro de las garantias afectadas por un siniestro para su posterior trato.
     Informa del % por tramos, incluyendo la propia participación, y los posibles importes
     de prioridad de XL y capacidad máxima del XL. En la misma tabla se guardan los datos
     generales del siniestro y del seguro que después necesitarán en el libro de siniestros.
     Los siniestros tratados son todos aquellos que sean de la empresa pempres y que estén
     abiertos o hayan tenido pagos en el periodo comprendido desde el primer dia del año
     del parámetro pdata hasta el último dia del mes pdata.

**************************************************************************************/
      w_ctipcoa      reasiniaux.ctipcoa%TYPE;   --       w_ctipcoa      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_ploc         reasiniaux.plocal%TYPE;   --       w_ploc         NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_cpagcoa      reasiniaux.cpagcoa%TYPE;   --       w_cpagcoa      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      apl_coa_prov   BOOLEAN;
      apl_coa_pag    BOOLEAN;
      w_ctiprea      reasiniaux.ctiprea%TYPE;   --       w_ctiprea      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      tip            NUMBER(1);
      w_iprioxl      reasiniaux.iprioxl%TYPE;   --       w_iprioxl      NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_icapacixl    reasiniaux.icapaxl%TYPE;   --       w_icapacixl    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pany_ant       DATE;
      pmes_seg       DATE;
      codi_error     NUMBER(8) := 0;
      codifac        NUMBER(1) := 0;
      x_agent        seguredcom.cageseg%TYPE;
   BEGIN
      pany_ant := TO_DATE('31/12/' || TO_CHAR(TO_NUMBER(TO_CHAR(pdata, 'yyyy')) - 1)
                          || ' 23:59',
                          'dd/mm/yyyy hh24:mi');
      pmes_seg := LAST_DAY(pdata) + 1;

      FOR cursini IN cur_sini(pany_ant, pmes_seg, pempres) LOOP
         -- Calculem l'agent de la polissa a la data del sinistre a la taula SEGUREDCOM, no
         -- ens quedem amb el del seguro
         BEGIN
            SELECT cageseg
              INTO x_agent
              FROM seguredcom
             WHERE sseguro = cursini.sseg
               AND fmovini <= cursini.fsin
               AND(fmovfin > cursini.fsin
                   OR fmovfin IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_agent := cursini.agen;
            WHEN OTHERS THEN
               RETURN(-1);
         END;

         inivar_sin(cursini.nsin, pmerr);
         v_crenova := f_es_renova(cursini.sseg, cursini.fsin);
         codi_error := datos_coa_sin(cursini.sseg, cursini.ncua, w_ctipcoa, w_ploc);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         codi_error := valida_aplica_coa(w_ctipcoa, cursini.nsin, w_cpagcoa, apl_coa_prov,
                                         apl_coa_pag);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         codi_error := datos_rea_sin(cursini.ramo, cursini.moda, cursini.tips, cursini.cole,
                                     cursini.sseg, w_ctiprea, pmerr);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         FOR curval IN cur_val(cursini.nsin, pmes_seg) LOOP
            inivar_gar(w_porce);

            IF w_ctiprea = 0 THEN
                    -- solo miramos el reaseguro si la garantia se reasegura o si
               -- estamos tratando las garantias 9999 (gastos), o 9998 (reajuste
               -- por cierre a las que asignamos w_ctiprea 0 por defecto (a no ser que
               -- provengan de polizas o productos que no se reaseguran)
               IF curval.cgar IN(9999, 9998) THEN
                  w_ctiprea := 0;
               ELSE
                  codi_error := datos_rea_gar(cursini.ramo, cursini.moda, cursini.tips,
                                              cursini.cole, curval.cgar, cursini.acti,
                                              w_ctiprea, pmerr);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;
               END IF;

               IF w_ctiprea = 0 THEN
                  codi_error := reaseguro(curval.cgar, cursini.sseg, cursini.nrie,
                                          cursini.fsin, NULL, NULL, w_porce, tip);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;

                  --Si el seguro está a FACPENDIENTES no fem control_cesion
                  BEGIN
                     SELECT 1
                       INTO codifac
                       FROM DUAL
                      WHERE NOT EXISTS(SELECT f.sseguro
                                         FROM cuafacul f
                                        WHERE f.sseguro = cursini.sseg
                                          AND f.cestado = 1);                                              /* BUG 10462: ETM:16/06/2009:--AÑADIMOS-- CESTADO=1-*/
                                                                /* BUG 10462: ETM:16/06/2009:--ANTES
                                                                 facpendientes f
                                                                 WHERE f.sseguro = cursini.sseg);*/
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        codifac := 0;
                  END;

/***  ***********************************************
 *** Control de les cessions anul.lat al tractar-se d'un procés ***
 *** que tenia la finalitat de compensar les cessions que no    ***
 *** sumaven 100% que provenen de l'HP                          ***

 *** Es descomenta per haver pagaments anteriors que no         ***
 *** disposen de cessions                                       ***
 *****************************************************************/
                  IF cursini.ramo NOT IN(30, 31, 32, 33)
                     OR codifac = 0 THEN
                     codi_error := control_cesion(cursini.npol, cursini.sseg, cursini.fsin,
                                                  cursini.nsin, curval.cgar, w_porce,
                                                  psproces, cursini.nrie, tip, cursini.ramo,
                                                  cursini.moda, cursini.tips, cursini.cole,
                                                  cursini.acti, pmerr);

                     IF codi_error <> 0 THEN
                        RETURN(codi_error);
                     END IF;
                  END IF;
/******************************************************************/
               ELSE   -- no hay reaseguro a nivel de garantia
                  w_porce(0) := 0;
               END IF;
            ELSE   -- no hay reaseguro a nivel de póliza o reaseguro
               --asignamos al tramo0 un 100 %, ya que todos los importes (pagos,
               --reservas, ...) se consideran de propia retención.
               --ya no es verdad, tenemos otras variables para guardar los
               --pagos y reservas que no se llevan al reaseguro
               w_porce(0) := 0;
            END IF;

            sumpag_any(cursini.nsin, curval.cgar, pdata);
            sumpag(cursini.nsin, curval.cgar, pdata);
            -- Añadimos calculo de la provisión y la valoración
            --  y provisión a 31dic año anterior
            obtiene_valora31d(cursini.nsin, curval.cgar, pdata, cursini.fsin);

-- Si el sinistro está cerrado la reserva que aparezca en el informe debe ser cero,
-- aunque realmente la que es cero es la garantia total
            IF v_ests = 1 THEN
               IF v_fest < LAST_DAY(pdata) + 1 THEN
                  w_provisio := 0;
               ELSE
                  w_provisio := w_valora31d -(w_totpag - w_totpagany);
               END IF;

               IF v_fest <(TO_DATE('31/12/'
                                   || TO_CHAR(TO_NUMBER(TO_CHAR(LAST_DAY(pdata), 'yyyy')) - 1),
                                   'dd/mm/yyyy')
                           + 1) THEN
                  w_provisio31d := 0;
               ELSE
                  w_provisio31d := w_valora31d -(w_totpag - w_totpagany);
               END IF;
            ELSE
               w_provisio := curval.ival - w_totpag;
               w_provisio31d := w_valora31d -(w_totpag - w_totpagany);
            END IF;

            sumrecobros(cursini.nsin, curval.cgar, pdata);
            w_totpagany_liq := w_totpagany_liq - w_totrecobros;
            w_totpagany := w_totpagany - w_totrecobros;
--
            aplica_coaseguro(apl_coa_prov, apl_coa_pag, w_ploc);
            aplica_reaseguro(curval.ival, w_porce, w_ctiprea);

            BEGIN
               INSERT INTO reasiniaux
                           (nsinies, cgarant, ptramo0, ptramo1, ptramo2,
                            ptramo3, ptramo4, ptramo5, sproces, fcalcul, ipago_any,
                            ipago, valora, valora31d, provisio, provisio31d,
                            anyo, cagente, cramo, cmodali, ctipseg,
                            ccolect, cactivi, cagrpro, crenova, cempres,
                            sseguro, npoliza, ncertif, nriesgo,
                            cestsin, festsin, fsinies, fnotifi, plocal,
                            ctipcoa, cpagcoa, ctiprea, scontra, nversio, ppropi,
                            scontra_prot, nversio_prot, ppropi_prot, iprioxl, icapaxl,
                            ipagoany_coa, prov_coa, prov31d_coa, pag_cuopart,
                            prov_cuopart, prov31d_cuopart, pag_exc, prov_exc,
                            prov31d_exc, pag_facob, prov_facob, prov31d_facob,
                            pag_facul, prov_facul, prov31d_facul, pag_propi,
                            prov_propi, prov31d_propi, pag_prosinxl, prov_prosinxl,
                            prov31d_prosinxl, pag_xl, prov_xl, prov31d_xl, pag_prorea,
                            prov_prorea, prov31d_prorea, pag_pronrea, prov_pronrea,
                            prov31d_pronrea, pag_nostre, prov_nostre, prov31d_nostre,
                            ipago_nliq, ipago_liq, ipagoany_nliq, ipagoany_liq,
                            ipagoany_coa_nliq, ipagoany_coa_liq, pag_cuopart_nliq,
                            pag_cuopart_liq, pag_exc_nliq, pag_exc_liq, pag_facob_nliq,
                            pag_facob_liq, pag_facul_nliq, pag_facul_liq,
                            pag_propi_nliq, pag_propi_liq, irecobro)
                    VALUES (cursini.nsin, curval.cgar, w_porce(0), w_porce(1), w_porce(2),
                            w_porce(3), w_porce(4), w_porce(5), psproces, pdata, w_totpagany,
                            w_totpag, curval.ival, w_valora31d, w_provisio, w_provisio31d,
                            cursini.anyo,
         -- Calculem l'agent de la polissa a la data del sinistre a la taula SEGUREDCOM, no
         -- ens quedem amb el del seguro
--         cursini.agen,
                                         x_agent, cursini.ramo, cursini.moda, cursini.tips,
                            cursini.cole, cursini.acti, cursini.agpr, v_crenova, pempres,
                            cursini.sseg, cursini.npol, cursini.cert, cursini.nrie,
                            cursini.ests, cursini.fest, cursini.fsin, cursini.fnot, w_ploc,
                            w_ctipcoa, w_cpagcoa, w_ctiprea, v_scontra, v_nversio, v_ppropi,
                            v_scontra_prot, v_nversio_prot, v_ppropi_prot, NULL, NULL,
                            w_ipagoany_coa, w_prov_coa, w_prv31d_coa, w_pag_cuop,
                            w_prov_cuop, w_prv31d_cuopart, w_pag_exc, w_prov_exc,
                            w_prv31d_exc, w_pag_facob, w_prov_facob, w_prv31d_facob,
                            w_pag_facul, w_prov_facul, w_prv31d_facul, w_pag_propi,
                            w_prov_propi, w_prv31d_propi, NULL, NULL,
                            NULL, NULL, NULL, NULL, w_pagp_rea,
                            w_prvp_rea, w_prv31dp_rea, w_pagp_nrea, w_prvp_nrea,
                            w_prv31dp_nrea, NULL, NULL, NULL,
                            w_totpag_nliq, w_totpag_liq, w_totpagany_nliq, w_totpagany_liq,
                            w_ipagoany_coa_nliq, w_ipagoany_coa_liq, w_pag_cuop_nliq,
                            w_pag_cuop_liq, w_pag_exc_nliq, w_pag_exc_liq, w_pag_facob_nliq,
                            w_pag_facob_liq, w_pag_facul_nliq, w_pag_facul_liq,
                            w_pag_propi_nliq, w_pag_propi_liq, w_totrecobros);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105298;
                  pmerr := pmerr || SQLERRM || TO_CHAR(SQLCODE);
                  RETURN(codi_error);
            END;

            IF w_ctiprea = 1 THEN
               w_ctiprea := 0;
            END IF;
         END LOOP;   -- acabamos el bucle para todas las garantias valoradas

              -- del siniestro.
         --  La provision del siniestro ahora se acumula de las garantias
         --    wsin_provisio  := wsin_ivalora - wsin_ipago;
         IF w_ctiprea = 1 THEN
            w_ctiprea := 0;
         END IF;

         codi_error := busca_contrato_xl(cursini.ramo, cursini.moda, cursini.tips,
                                         cursini.cole, cursini.acti, cursini.fsin, w_iprioxl,
                                         w_icapacixl);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         aplica_xl(cursini.ramo, w_iprioxl);
         wsin_pag_nostre := wsin_pag_prosinxl + wsin_ipag_nrea;
         wsin_prv_nostre := wsin_prov_prosinxl + wsin_iprv_nrea;
         wsin_prv31d_nostre := wsin_prv31d_prosinxl + wsin_prv31d_nrea;

         BEGIN
            INSERT INTO reasiniaux
                        (nsinies, cgarant, ptramo0, ptramo1, ptramo2, ptramo3, ptramo4,
                         ptramo5, sproces, fcalcul, ipago_any, ipago, valora,
                         valora31d, provisio, provisio31d, anyo,
                         cagente, cramo, cmodali, ctipseg, ccolect,
                         cactivi, cagrpro, crenova, cempres, sseguro,
                         npoliza, ncertif, nriesgo, cestsin,
                         festsin, fsinies, fnotifi, plocal, ctipcoa,
                         cpagcoa, ctiprea, scontra, nversio, ppropi, scontra_prot,
                         nversio_prot, ppropi_prot, iprioxl, icapaxl, ipagoany_coa,
                         prov_coa, prov31d_coa, pag_cuopart, prov_cuopart,
                         prov31d_cuopart, pag_exc, prov_exc, prov31d_exc,
                         pag_facob, prov_facob, prov31d_facob, pag_facul,
                         prov_facul, prov31d_facul, pag_propi, prov_propi,
                         prov31d_propi, pag_prosinxl, prov_prosinxl,
                         prov31d_prosinxl, pag_xl, prov_xl, prov31d_xl,
                         pag_prorea, prov_prorea, prov31d_prorea, pag_pronrea,
                         prov_pronrea, prov31d_pronrea, pag_nostre, prov_nostre,
                         prov31d_nostre, ipago_nliq, ipago_liq,
                         ipagoany_nliq, ipagoany_liq, ipagoany_coa_nliq,
                         ipagoany_coa_liq, pag_cuopart_nliq, pag_cuopart_liq,
                         pag_exc_nliq, pag_exc_liq, pag_facob_nliq,
                         pag_facob_liq, pag_facul_nliq, pag_facul_liq,
                         pag_propi_nliq, pag_propi_liq, irecobro)
                 VALUES (cursini.nsin, 0, NULL, NULL, NULL, NULL, NULL,
                         NULL, psproces, pdata, wsin_ipagoany, wsin_ipago, wsin_ivalora,
                         wsin_valora31d, wsin_provisio, wsin_provisio31d, cursini.anyo,
         -- Calculem l'agent de la polissa a la data del sinistre a la taula SEGUREDCOM, no
         -- ens quedem amb el del seguro
--         cursini.agen,
                         x_agent, cursini.ramo, cursini.moda, cursini.tips, cursini.cole,
                         cursini.acti, cursini.agpr, v_crenova, pempres, cursini.sseg,
                         cursini.npol, cursini.cert, cursini.nrie, cursini.ests,
                         cursini.fest, cursini.fsin, cursini.fnot, w_ploc, w_ctipcoa,
                         w_cpagcoa, w_ctiprea, NULL, NULL, NULL, NULL,
                         NULL, NULL, w_iprioxl, w_icapacixl, wsin_ipagoany_coa,
                         wsin_iprov_coa, wsin_prv31d_coa, wsin_ipagcuop, wsin_iprovcuop,
                         wsin_prv31d_cuopart, wsin_ipagexc, wsin_iprovexc, wsin_prv31d_exc,
                         wsin_ipagfacob, wsin_iprovfacob, wsin_prv31d_facob, wsin_ipagfacul,
                         wsin_iprovfacul, wsin_prv31d_facul, wsin_ipagpropi, wsin_iprovpropi,
                         wsin_prv31d_propi, wsin_pag_prosinxl, wsin_prov_prosinxl,
                         wsin_prv31d_prosinxl, wsin_pag_xl, wsin_prov_xl, wsin_prv31d_xl,
                         wsin_ipag_rea, wsin_iprv_rea, wsin_prv31d_rea, wsin_ipag_nrea,
                         wsin_iprv_nrea, wsin_prv31d_nrea, wsin_pag_nostre, wsin_prv_nostre,
                         wsin_prv31d_nostre, wsin_ipago_nliq, wsin_ipago_liq,
                         wsin_ipagoany_nliq, wsin_ipagoany_liq, wsin_ipagoany_coa_nliq,
                         wsin_ipagoany_coa_liq, wsin_ipagcuop_nliq, wsin_ipagcuop_liq,
                         wsin_ipagexc_nliq, wsin_ipagexc_liq, wsin_ipagfacob_nliq,
                         wsin_ipagfacob_liq, wsin_ipagfacul_nliq, wsin_ipagfacul_liq,
                         wsin_ipagpropi_nliq, wsin_ipagpropi_liq, wsin_recobros);
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 105298;
               pmerr := cursini.nsin || SQLERRM || TO_CHAR(SQLCODE);
               RETURN(codi_error);
         END;
      END LOOP;

      RETURN(codi_error);
   END f_libsin;

------------------------------------------------
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
--
--    Proceso que lanzará el proceso de cierre de siniestros
--
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER;
      v_titulo       VARCHAR2(50);
      -- variables per a tancar provisions
      wdata_ini      DATE;
      wdata_fin      DATE;
      wdataanu_ini   DATE;
      wdataanu_fin   DATE;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Diario (empresa ' || pcempres || ')';
      ELSE
         v_titulo := 'Proceso Cierre Mensual';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, 1, 'SINIESTROS', v_titulo, psproces);
      COMMIT;
      SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Siniestros ' || texto || ' ' || text_error, 1, 120),
                                0, pnnumlin);
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      ELSE
         -- Borrado de los registros que se corresponden al mes y empresa que vamos a tratar
         IF pmodo = 1 THEN
            DELETE FROM reasiniaux r
                  WHERE r.fcalcul = pfcierre
                    AND r.cempres = pcempres
                    AND NOT EXISTS(SELECT c.sproces
                                     FROM cierres c
                                    WHERE c.sproces = r.sproces);

            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         ELSIF pmodo = 2 THEN
            DELETE FROM reasiniaux r
                  WHERE r.fcalcul = pfcierre
                    AND r.cempres = pcempres
                    AND NOT EXISTS(SELECT sproces
                                     FROM cierres c
                                    WHERE c.sproces = r.sproces);

            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         END IF;

         num_err := f_libsin(psproces, pcempres, pfcierre, text_error);

         IF num_err <> 0 THEN   -- hay errores
            v_estado := 1;
         ELSE
            v_estado := 0;
         END IF;

         IF num_err <> 0 THEN
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            num_err := f_proceslin(psproces,
                                   SUBSTR('Siniestros ' || texto || ' ' || text_error, 1, 120),
                                   0, pnnumlin);
            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         ELSE
            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            pcerror := 0;
         END IF;

         IF pmodo = 2 THEN   -- si són tancaments tanquem provisions
            wdata_ini := TO_DATE('01/' || TO_CHAR(pfcierre, 'MM/YYYY'), 'DD/MM/YYYY');
            wdata_fin := TO_DATE(TO_CHAR(LAST_DAY(pfcierre), 'DD/MM/YYYY') || ' 23:59',
                                 'DD/MM/YYYY hh24:mi');
            num_err := actualitza_provisions_mensuals(pcempres, wdata_ini, wdata_fin);

            /** Les provisions es calculen al desembre, i es recalculen al gener ,
                pels sinistres declarats al gener amb data de sinistre de l'any anterior **/
            IF TO_CHAR(pfcierre, 'MM') = 12 THEN   -- tanquem provisions anuals
               wdataanu_ini := TO_DATE('01/01/' || TO_CHAR(pfcierre, 'YYYY'), 'DD/MM/YYYY');
               wdataanu_fin := TO_DATE('31/12/' || TO_CHAR(pfcierre, 'YYYY') || ' 23:59',
                                       'DD/MM/YYYY hh24:mi');
               num_err := actualitza_provisions_anuals(pcempres, wdataanu_ini, wdataanu_fin);
            END IF;

            -- tornem a recalcular tanquem provisions anuals
            IF TO_CHAR(pfcierre, 'MM') = 1 THEN
               wdataanu_ini := TO_DATE('01/01/' ||(TO_CHAR(pfcierre, 'YYYY') - 1),
                                       'DD/MM/YYYY');
               wdataanu_fin := TO_DATE('31/12/' ||(TO_CHAR(pfcierre, 'YYYY') - 1) || ' 23:59',
                                       'DD/MM/YYYY hh24:mi');
               num_err := actualitza_provisions_anuals(pcempres, wdataanu_ini, wdataanu_fin);
            END IF;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, pcerror);
      pfproces := f_sysdate;

      IF num_err = 0 THEN
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      END IF;
   END proceso_batch_cierre;

------------------------------------------------
/**********************************************/
------------------------------------------------
   FUNCTION busca_pcedido(scon IN NUMBER, nver IN NUMBER, wpcedido OUT NUMBER)
      RETURN NUMBER IS
/***********************************************************************
    BUSCA_PCEDIDO: Esta función devuelve el porcentaje de la prima que va
   al reaseguro. Si el campo pcedido es nulo devolvemos un 100, ya que
        se reasegura toda la prima.

*************************************************************************/
      codi_error     NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(pcedido, 100)
           INTO wpcedido
           FROM contratos
          WHERE scontra = scon
            AND nversio = nver;
      EXCEPTION
         WHEN OTHERS THEN
--            DBMS_OUTPUT.put_line(SQLERRM);
            codi_error := 104704;   --error al obtener pcedido de contratos
            RETURN(codi_error);
      END;

      RETURN(codi_error);
   END busca_pcedido;

------------------------------------------------
/**********************************************/
------------------------------------------------
   FUNCTION f_pnoreaseguro(
      sseg IN NUMBER,
      nrie IN NUMBER,
      cgar IN NUMBER,
      fecha IN DATE,
      pnostre OUT NUMBER,
      ppcedido OUT NUMBER)
      RETURN NUMBER IS
/***********************************************************************
    F_PNOREASEGURO: Esta función devuelve en el parametro pnostre el porcentaje
   que no va a reaseguro, siendo el parámetro de entrada fecha, la fecha
   en que se buscará la cesión.

*************************************************************************/
      CURSOR cur_ces(
         w_seg IN NUMBER,
         w_rie IN NUMBER,
         w_cgar IN NUMBER,
         w_fecha IN DATE,
         tip IN NUMBER) IS
         SELECT   scontra, nversio, ctramo, pcesion
             FROM cesionesrea
            WHERE sseguro = w_seg
              AND nriesgo = w_rie
              AND((tip = 1
                   AND cgarant IS NOT NULL
                   AND cgarant = w_cgar)
                  OR(tip = 2
                     AND cgarant IS NULL))
              AND ctramo IN(0, 1)
              AND cgenera IN(01, 03, 04, 05, 09, 40)
              AND fefecto <= w_fecha
              AND fvencim > w_fecha
              AND(fanulac > w_fecha
                  OR fanulac IS NULL)
              AND(fregula > w_fecha
                  OR fregula IS NULL)
         ORDER BY ctramo;

      tip            NUMBER;
      con_garantia   BOOLEAN := FALSE;
      w_plocal       tramos.plocal%TYPE;   --       w_plocal       NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nsegcon      tramos.nsegcon%TYPE;   --       w_nsegcon      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_plocpro      tramos.plocal%TYPE := 100;   --       w_plocpro      NUMBER(5, 2) := 100; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tramo        NUMBER(2);
      codi_error     NUMBER := 0;
      w_scontra      contratos.scontra%TYPE;   --       w_scontra      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nversio      contratos.nversio%TYPE;   --       w_nversio      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nsegver      tramos.nsegver%TYPE;   --       w_nsegver      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      tip := 1;

      FOR curces IN cur_ces(sseg, nrie, cgar, fecha, tip) LOOP
         /* hemos encontrado cesión para esta garantia en concreto */
         con_garantia := TRUE;
         w_plocpro := 100;

         IF curces.ctramo = 1 THEN   --solo lo calculamos para el tramo 1
            codi_error := busca_plocal(curces.scontra, curces.nversio, w_plocal, w_nsegcon,
                                       w_nsegver);

            IF codi_error <> 0 THEN
               RETURN(codi_error);
            END IF;

            IF w_nsegcon IS NOT NULL THEN   -- hay protección del propio
               codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;
            END IF;
         END IF;

         w_tramo := curces.ctramo;
         pnostre := curces.pcesion;
         w_scontra := curces.scontra;
         w_nversio := curces.nversio;
      END LOOP;

      IF NOT con_garantia THEN
         /* no hemos encontrado cesión para la garantia que tratamos, buscamos una
             cesión general para el seguro (cgarant null) */
         tip := 2;

         FOR curces IN cur_ces(sseg, nrie, NULL, fecha, tip) LOOP
            IF curces.ctramo = 1 THEN   --solo lo calculamos para el tramo 1
               codi_error := busca_plocal(curces.scontra, curces.nversio, w_plocal, w_nsegcon,
                                          w_nsegver);

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;

               IF w_nsegcon IS NOT NULL THEN   -- hi ha protecció del propi
                  codi_error := busca_plocal_proteccio(w_nsegcon, w_nsegver, w_plocpro);

                  IF codi_error <> 0 THEN
                     RETURN(codi_error);
                  END IF;
               END IF;
            END IF;

            w_tramo := curces.ctramo;
            pnostre := curces.pcesion;
            w_scontra := curces.scontra;
            w_nversio := curces.nversio;
         END LOOP;
      END IF;

      con_garantia := FALSE;

      IF w_scontra IS NOT NULL THEN
         IF w_tramo = 1 THEN
            /* modifiquem el plocal amb la protecció del propi (si s'escau), i
               apliquem el plocal modificat al propi */
            w_plocal := w_plocal * w_plocpro / 100;
            pnostre := (w_plocal * pnostre) / 100;
         END IF;

         codi_error := busca_pcedido(w_scontra, w_nversio, ppcedido);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         IF pnostre IS NULL THEN
            codi_error := 105297;
         END IF;
      ELSE
         pnostre := 100;
         ppcedido := 0;
      END IF;

      RETURN(codi_error);
   END f_pnoreaseguro;

------------------------------------------------
   PROCEDURE p_ajusta_reservas31d(pcempres IN NUMBER, pperfin IN DATE) IS
      tancament      BOOLEAN := FALSE;
      procene        cierres.sproces%TYPE;   --       procene        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      procmes        cierres.sproces%TYPE;   --       procmes        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      datacalcul     DATE;
      error          NUMBER;
      nprolin        NUMBER;
      conta_act      NUMBER := 0;
      conta_no       NUMBER := 0;
      conta_nocal    NUMBER := 0;
      xvalora31d     reasiniaux.valora31d%TYPE;   --       xvalora31d     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprovisio31d   reasiniaux.provisio31d%TYPE;   --       xprovisio31d   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_coa   reasiniaux.prov31d_coa%TYPE;   --       xprov31d_coa   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_cuopart reasiniaux.prov31d_cuopart%TYPE;   --       xprov31d_cuopart NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_exc   reasiniaux.prov31d_exc%TYPE;   --       xprov31d_exc   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_facob reasiniaux.prov31d_facob%TYPE;   --       xprov31d_facob NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_facul reasiniaux.prov31d_facul%TYPE;   --       xprov31d_facul NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_propi reasiniaux.prov31d_propi%TYPE;   --       xprov31d_propi NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_prosinxl reasiniaux.prov31d_prosinxl%TYPE;   --       xprov31d_prosinxl NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_xl    reasiniaux.prov31d_xl%TYPE;   --       xprov31d_xl    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_prorea reasiniaux.prov31d_prorea%TYPE;   --       xprov31d_prorea NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_pronrea reasiniaux.prov31d_pronrea%TYPE;   --       xprov31d_pronrea NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprov31d_nostre reasiniaux.prov31d_nostre%TYPE;   --       xprov31d_nostre NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      CURSOR SIN(c_procmes IN NUMBER, c_procene IN NUMBER) IS
         SELECT nsinies, prov31d_coa
           FROM reasiniaux
          WHERE cgarant = 0
            AND sproces = c_procmes
         MINUS
         SELECT nsinies, prov31d_coa
           FROM reasiniaux
          WHERE cgarant = 0
            AND sproces = c_procene;
   BEGIN
      -- busquem el procés
      BEGIN   -- Si està tancat
         SELECT sproces
           INTO procmes
           FROM cierres
          WHERE ctipo = 2
            AND cestado = 1
            AND cempres = pcempres
            AND fperfin = pperfin;

         tancament := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   -- es el diari
            BEGIN
               SELECT MAX(sproces)
                 INTO procmes
                 FROM reasiniaux
                WHERE cempres = pcempres
                  AND fcalcul = pperfin;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         SELECT sproces
           INTO procene
           FROM cierres
          WHERE ctipo = 2
            AND cestado = 1
            AND cempres = pcempres
            AND fperini = TO_DATE('0101' || TO_CHAR(pperfin, 'yyyy'), 'ddmmyyyy');
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      FOR a IN SIN(procmes, procene) LOOP
         xvalora31d := 0;
         xprovisio31d := 0;
         xprov31d_coa := 0;
         xprov31d_cuopart := 0;
         xprov31d_exc := 0;
         xprov31d_facob := 0;
         xprov31d_facul := 0;
         xprov31d_propi := 0;
         xprov31d_prosinxl := 0;
         xprov31d_xl := 0;
         xprov31d_prorea := 0;
         xprov31d_pronrea := 0;
         xprov31d_nostre := 0;

         BEGIN
            SELECT NVL(valora31d, 0), NVL(provisio31d, 0), NVL(prov31d_coa, 0),
                   NVL(prov31d_cuopart, 0), NVL(prov31d_exc, 0), NVL(prov31d_facob, 0),
                   NVL(prov31d_facul, 0), NVL(prov31d_propi, 0), NVL(prov31d_prosinxl, 0),
                   NVL(prov31d_xl, 0), NVL(prov31d_prorea, 0), NVL(prov31d_pronrea, 0),
                   NVL(prov31d_nostre, 0)
              INTO xvalora31d, xprovisio31d, xprov31d_coa,
                   xprov31d_cuopart, xprov31d_exc, xprov31d_facob,
                   xprov31d_facul, xprov31d_propi, xprov31d_prosinxl,
                   xprov31d_xl, xprov31d_prorea, xprov31d_pronrea,
                   xprov31d_nostre
              FROM reasiniaux
             WHERE cgarant = 0
               AND sproces = procene
               AND nsinies = a.nsinies;

            IF tancament THEN
               INSERT INTO reasiniaux_bak
                  (SELECT *
                     FROM reasiniaux
                    WHERE sproces = procmes
                      AND nsinies = a.nsinies
                      AND cgarant = 0);
            END IF;

            UPDATE reasiniaux
               SET valora31d = xvalora31d,
                   provisio31d = xprovisio31d,
                   prov31d_coa = xprov31d_coa,
                   prov31d_cuopart = xprov31d_cuopart,
                   prov31d_exc = xprov31d_exc,
                   prov31d_facob = xprov31d_facob,
                   prov31d_facul = xprov31d_facul,
                   prov31d_propi = xprov31d_propi,
                   prov31d_prosinxl = xprov31d_prosinxl,
                   prov31d_xl = xprov31d_xl,
                   prov31d_prorea = xprov31d_prorea,
                   prov31d_pronrea = xprov31d_pronrea,
                   prov31d_nostre = xprov31d_nostre
             WHERE cgarant = 0
               AND sproces = procmes
               AND nsinies = a.nsinies;

            conta_act := conta_act + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT NVL(valora31d, 0), NVL(provisio31d, 0), NVL(prov31d_coa, 0),
                      NVL(prov31d_cuopart, 0), NVL(prov31d_exc, 0), NVL(prov31d_facob, 0),
                      NVL(prov31d_facul, 0), NVL(prov31d_propi, 0), NVL(prov31d_prosinxl, 0),
                      NVL(prov31d_xl, 0), NVL(prov31d_prorea, 0), NVL(prov31d_pronrea, 0),
                      NVL(prov31d_nostre, 0)
                 INTO xvalora31d, xprovisio31d, xprov31d_coa,
                      xprov31d_cuopart, xprov31d_exc, xprov31d_facob,
                      xprov31d_facul, xprov31d_propi, xprov31d_prosinxl,
                      xprov31d_xl, xprov31d_prorea, xprov31d_pronrea,
                      xprov31d_nostre
                 FROM reasiniaux
                WHERE cgarant = 0
                  AND sproces = procmes
                  AND nsinies = a.nsinies;

               IF xvalora31d = 0
                  AND xprovisio31d = 0
                  AND xprov31d_coa = 0
                  AND xprov31d_cuopart = 0
                  AND xprov31d_exc = 0
                  AND xprov31d_facob = 0
                  AND xprov31d_facul = 0
                  AND xprov31d_propi = 0
                  AND xprov31d_prosinxl = 0
                  AND xprov31d_xl = 0
                  AND xprov31d_prorea = 0
                  AND xprov31d_pronrea = 0
                  AND xprov31d_nostre = 0 THEN
                  conta_nocal := conta_nocal + 1;
               ELSE
                  IF tancament THEN
                     INSERT INTO reasiniaux_bak
                        (SELECT *
                           FROM reasiniaux
                          WHERE sproces = procmes
                            AND nsinies = a.nsinies
                            AND cgarant = 0);
                  END IF;

                  UPDATE reasiniaux
                     SET valora31d = 0,
                         provisio31d = 0,
                         prov31d_coa = 0,
                         prov31d_cuopart = 0,
                         prov31d_exc = 0,
                         prov31d_facob = 0,
                         prov31d_facul = 0,
                         prov31d_propi = 0,
                         prov31d_prosinxl = 0,
                         prov31d_xl = 0,
                         prov31d_prorea = 0,
                         prov31d_pronrea = 0,
                         prov31d_nostre = 0
                   WHERE nsinies = a.nsinies
                     AND cgarant = 0
                     AND sproces = procmes;

                  conta_no := conta_no + 1;
               END IF;
            WHEN OTHERS THEN
               error := f_proceslin(procmes, 'Error a reserves31d. Sinistre =' || a.nsinies,
                                    0, nprolin);
         END;
      END LOOP;

      error := f_proceslin(procmes,
                           'Reserves31d ajustades = ' || TO_CHAR(conta_act + conta_no), 0,
                           nprolin);
   END p_ajusta_reservas31d;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "CONF_DWH";
