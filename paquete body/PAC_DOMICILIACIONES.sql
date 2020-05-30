--------------------------------------------------------
--  DDL for Package Body PAC_DOMICILIACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DOMICILIACIONES" 
AS
/******************************************************************************
   NOMBRE:       PAC_DOMICILIACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones capa lógica

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/02/2009   XCG                1. Creación del package.
   2.0        08/10/2009   JGM                2. Llamada a nueva función de PAC_DOMIS -> f_retorna_select
   3.0        29/06/2010   PFA                3. Error selección domiciliación por productos
   4.0        27/08/2010   FAL                4. 0015750: CRE998 - Modificacions mòdul domiciliacions
   5.0        13/12/2010   ICV                5. 0016383: AGA003 - recargo por devolución de recibo (renegociación de recibos)
   6.0        19/07/2011   JMP                6. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
   7.0        04/11/2011   APD                7. 0019986: LCOL_A001-Referencias agrupadas o consecutivas
   8.0        03/04/2012   JGR                8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
   9.0        17/07/2012   JGR                9. 0022753: MDP_A001-Cierre de remesa
   10.0       22/02/2012   JGR               10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818
   11.0       03/07/2013   JDS               11. 0027150: LCOL_A003-Corregir lista de incidencia reportadas en QT-6200
   12.0       07/10/2013   JGR               12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones no tiene en cuenta los recibos agrupados - QT-9258
   13.0       11/03/2015   KJSC              13. 35103-200056 Eliminar la condición del parámetro “DIASGEST_DIRECTO” y la línea que calcula los días con la función del tramo
 ******************************************************************************/
   FUNCTION f_domiciliar (
      psproces    IN       NUMBER,
      pcempres    IN       NUMBER,
      pfefecto    IN       DATE,
      pffeccob    IN       DATE,
      pcramo      IN       NUMBER,
      psproduc    IN       NUMBER,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom    IN       NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban    IN       NUMBER,
      pcbanco     IN       NUMBER,
      pctipcta    IN       NUMBER,
      pfvtotar    IN       VARCHAR2,
      pcreferen   IN       VARCHAR2,
      pdfefecto   IN       DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente    IN       NUMBER,
      ptagente    IN       VARCHAR2,
      pnnumide    IN       VARCHAR2,
      pttomador   IN       VARCHAR2,
      pnrecibo    IN       NUMBER,
      --FI BUG 23645
      pidioma     IN       NUMBER,
      pnok        OUT      NUMBER,
      pnko        OUT      NUMBER,
      ppath       OUT      VARCHAR2,
      nommap1     OUT      VARCHAR2,      --Path Completo Fichero de map 318,
      nommap2     OUT      VARCHAR2,      --Path Completo Fichero de map 347,
      nomdr       OUT      VARCHAR2,           --Path Completo Fichero de DR,
      vsproces    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      ttexto      VARCHAR2 (20)            := 'pac_dom.f_domiciliar';
      ttexto2     VARCHAR2 (400);
      tprocesc    VARCHAR2 (120);
      vnumerr     NUMBER (10)              := 0;
      vcempres    empresas.cempres%TYPE;
      vcmodali    productos.cmodali%TYPE;
      vctipseg    productos.ctipseg%TYPE;
      vccolect    productos.ccolect%TYPE;
      vcramo      productos.cramo%TYPE;
      -- BUG 15146 - PFA- Error selección domiciliación por productos
      vctipemp    empresas.ctipemp%TYPE;
      smapead     NUMBER;
      vtparpath   VARCHAR2 (20);
      vpasexec    NUMBER                   := 0;
   -- 8. 0021718 / 0111176 (y también las asignaciones, pero no las comentamos)
   BEGIN
      vpasexec := 10;

      IF psproces IS NULL
      THEN
         vpasexec := 20;
         ttexto2 := f_axis_literales (102253, pidioma);       -- ' Cartera: '
         tprocesc :=
               TO_CHAR (f_sysdate, 'dd-mm-yyyy hh24:mi')
            || '  '
            || ttexto2
            || '  '
            || pcempres
            || '  '
            || TO_CHAR (pfefecto, 'yyyy mm');
         vnumerr := f_procesini (f_user, pcempres, ttexto, tprocesc, vsproces);
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMICILIACIONES.f_domiciliar',
                      1,
                      'sproces' || vsproces,
                      SQLERRM || ' ' || SQLCODE
                     );

         IF vnumerr <> 0
         THEN
            RETURN vnumerr;
         END IF;

         vpasexec := 50;

         IF psproduc IS NOT NULL
         THEN
            vpasexec := 60;

            BEGIN
               SELECT cmodali, ctipseg, ccolect, cramo
                 INTO vcmodali, vctipseg, vccolect, vcramo
                 -- BUG 15146 - PFA- Error selección domiciliación por productos
               FROM   productos
                WHERE sproduc = psproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Producto inexistente',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 100503;                        --Producto inexistente
               WHEN OTHERS
               THEN
                  p_tab_error
                        (f_sysdate,
                         f_user,
                         'PAC_DOMICILIACIONES.f_domiciliar',
                         2,
                         'Error al leer la
                tabla PRODUCTOS',
                         SQLERRM || ' ' || SQLCODE
                        );
                  RETURN 102705;            --Error al leer la tabla PRODUCTOS
            END;
         END IF;

         vpasexec := 80;

         -- BUG 15146 - PFA- Error selección domiciliación por productos
         IF pcramo IS NOT NULL
         THEN
            vcramo := pcramo;
         END IF;

         vpasexec := 100;

         -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
         IF psprodom IS NOT NULL
         THEN
            vpasexec := 120;

            INSERT INTO domisaux
                        (sproces, cramo, cmodali, ctipseg, ccolect)
               SELECT vsproces, p.cramo, p.cmodali, p.ctipseg, p.ccolect
                 FROM productos p, tmp_domisaux t
                WHERE p.sproduc = t.sproduc
                  AND t.sproces = psprodom
                  AND t.cestado = 1;
         ELSE
            vpasexec := 140;

            INSERT INTO domisaux
                        (sproces, cramo, cmodali, ctipseg, ccolect)
               SELECT vsproces, p.cramo, p.cmodali, p.ctipseg, p.ccolect
                 FROM productos p
                WHERE p.sproduc = NVL (psproduc, p.sproduc)
                  AND p.cramo = NVL (vcramo, p.cramo)
                  AND p.cmodali = NVL (vcmodali, p.cmodali)
                  AND p.ctipseg = NVL (vctipseg, p.ctipseg)
                  AND p.ccolect = NVL (vccolect, p.ccolect);
         END IF;

         -- FI Bug 15750 - FAL - 27/08/2010

         -- Fi BUG 15146 - PFA- Error selección domiciliación por productos
         vpasexec := 160;
         vnumerr :=
            pac_domis.f_domiciliar (vsproces,
                                    pcempres,
                                    pfefecto,
                                    pffeccob,
                                    vcramo,
                                    vcmodali,
                                    vctipseg,
                                    vccolect,
                                    pccobban,
                                    pcbanco,
                                    pctipcta,
                                    pfvtotar,
                                    pcreferen,
                                    pdfefecto,
                                    pcagente,
                                    ptagente,
                                    pnnumide,
                                    pttomador,
                                    pnrecibo,
                                    pidioma,
                                    nomdr,
                                    pnok,
                                    pnko
                                   );

         IF vnumerr <> 0
         THEN
            RETURN vnumerr;
         END IF;

         vpasexec := 180;
      --El procés està informat
      ELSE
         vpasexec := 200;

         --comprobar si existeix el proces
         BEGIN
            SELECT DISTINCT (sproces)
                       INTO vsproces
                       FROM domiciliaciones
                      WHERE sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_DOMICILIACIONES.f_domiciliar',
                            1,
                            'Proceso inexistente',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN 103778;                            --proceso inexistente
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_DOMICILIACIONES.f_domiciliar',
                            1,
                            'Error al leer en la tabla DOMICILIACIONES',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN 112318;     --Error al leer en la tabla DOMICILIACIONES;
         END;

         vpasexec := 220;

         IF pcempres IS NOT NULL
         THEN
            vpasexec := 240;

            BEGIN
               SELECT ctipemp
                 INTO vctipemp
                 FROM empresas
                WHERE cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Empresa inexistente',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 100501;                         --Empresa inexistente
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Error al leer en la tabla EMPRESAS',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 103290;         --Error al leer en la tabla EMPRESAS;
            END;
         ELSE
            vpasexec := 260;

            BEGIN
               SELECT DISTINCT (cempres)
                          INTO vcempres
                          FROM domiciliaciones
                         WHERE sproces = psproces;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Empresa inexistente',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 100501;                         --Empresa inexistente
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Error al leer en la tabla DOMICILIACIONES',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 112318;  --Error al leer en la tabla DOMICILIACIONES;
            END;

            vpasexec := 280;

            BEGIN
               SELECT ctipemp
                 INTO vctipemp
                 FROM empresas
                WHERE cempres = vcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Empresa inexistente',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 100501;                         --Empresa inexistente
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_domiciliar',
                               1,
                               'Error al leer en la tabla EMPRESAS',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 103290;         --Error al leer en la tabla EMPRESAS;
            END;
         END IF;

         vpasexec := 300;
         vnumerr :=
                   pac_domis.f_domrecibos (vctipemp, pidioma, psproces, nomdr);

         IF vnumerr <> 0
         THEN
            RETURN vnumerr;
         END IF;
      END IF;

      vpasexec := 340;
      --Bug23498 - JTS - 27/08/2012
      /*BEGIN
         --buscar el path del fitxers
         SELECT tparpath
           INTO vtparpath
           FROM map_cabecera
          WHERE cmapead = '318';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_DOMICILIACIONES.f_domiciliar', 1,
                        'Dato de cabecera inexistente', SQLERRM || ' ' || SQLCODE);
            RETURN 151539;
         --Error al buscar la información de la cabecera del fichero
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_DOMICILIACIONES.f_domiciliar', 1,
                        'Error al leer en la tabla MAP_CABECERA', SQLERRM || ' ' || SQLCODE);
            RETURN 151539;
      --Error al buscar la información de la cabecera del fichero
      END;

      vpasexec := 360;
      ppath := f_parinstalacion_t(vtparpath);*/
      ppath := f_parempresa_t ('PATH_DOMIS_C', pcempres);
      --Fi Bug23498 - JTS - 27/08/2012
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- 8. 0021718 / 0111176 - Inicio
         --p_tab_error(f_sysdate, f_user, 'PAC_DOMICILIACIONES.f_domiciliar', 1,
         --            'Error generic', SQLERRM || ' ' || SQLCODE);
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMICILIACIONES.f_domiciliar',
                      vpasexec,
                      'Error generic',
                      SQLERRM || ' ' || SQLCODE
                     );
         -- 8. 0021718 / 0111176 - Fin
         RETURN -1;
   END f_domiciliar;

   FUNCTION f_get_domiciliacion (
      psproces    IN       NUMBER,
      pcempres    IN       NUMBER,
      pcramo      IN       NUMBER,
      psproduc    IN       NUMBER,
      pfefecto    IN       DATE,
      pidioma     IN       NUMBER,
      psquery     OUT      VARCHAR2,
      psprodom    IN       NUMBER DEFAULT NULL,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban    IN       NUMBER DEFAULT NULL,
      pcbanco     IN       NUMBER DEFAULT NULL,
      pctipcta    IN       NUMBER DEFAULT NULL,
      pfvtotar    IN       VARCHAR2 DEFAULT NULL,
      pcreferen   IN       VARCHAR2 DEFAULT NULL,
      pdfefecto   IN       DATE DEFAULT NULL,
      pcagente    IN       NUMBER DEFAULT NULL,
      -- Código Mediador -- 8. 0021718 / 0111176 - Inicio
      ptagente    IN       VARCHAR2 DEFAULT NULL,           -- Nombre Mediador
      pnnumide    IN       VARCHAR2 DEFAULT NULL,               -- Nif Tomador
      pttomador   IN       VARCHAR2 DEFAULT NULL,            -- Nombre Tomador
      pnrecibo    IN       NUMBER
            DEFAULT NULL               -- Recibo -- 8. 0021718 / 0111176 - Fin
   )
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN NUMBER
   IS
      vcramo      productos.cramo%TYPE;
      vcmodali    productos.cmodali%TYPE;
      vctipseg    productos.ctipseg%TYPE;
      vccolect    productos.ccolect%TYPE;
      vsproces    domiciliaciones.sproces%TYPE;
      v_max_reg   parinstalacion.nvalpar%TYPE;
      xsproces    domiciliaciones.sproces%TYPE;
      vtabla      VARCHAR2 (50);
   BEGIN
      v_max_reg := f_parinstalacion_n ('N_MAX_REG');

      IF psproces IS NULL
      THEN
         IF pcramo IS NOT NULL
         THEN
            vcramo := pcramo;
         END IF;

         IF psproduc IS NOT NULL
         THEN
            BEGIN
               SELECT cramo, cmodali, ctipseg, ccolect
                 INTO vcramo, vcmodali, vctipseg, vccolect
                 FROM productos
                WHERE sproduc = psproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_DOMICILIACIONES.f_get_domiciliar',
                               1,
                               'Producto inexistente',
                               SQLERRM || ' ' || SQLCODE
                              );
                  RETURN 100503;                        --Producto inexistente
               WHEN OTHERS
               THEN
                  p_tab_error
                     (f_sysdate,
                      f_user,
                      'PAC_DOMICILIACIONES.f_get_domiciliar',
                      2,
                      'Error al leer la
                            tabla PRODUCTOS',
                      SQLERRM || ' ' || SQLCODE
                     );
                  RETURN 102705;            --Error al leer la tabla PRODUCTOS
            END;
         END IF;

         psquery :=
            pac_domis.f_retorna_query (TO_CHAR (pfefecto, 'ddmmyyyy'),
                                       vcramo,
                                       psproduc,
                                       pcempres,
                                       psprodom,
                                       TRUE,
                                       -- BUG 18825 - 19/07/2011 - JMP
                                       pccobban,
                                       pcbanco,
                                       pctipcta,
                                       pfvtotar,
                                       pcreferen,
                                       TO_CHAR (pdfefecto, 'ddmmyyyy'),
                                       pcagente,
                                       -- Código Mediador -- 8. 0021718 / 0111176 - Inicio
                                       ptagente,
                                       pnnumide,
                                       pttomador,
                                       pnrecibo
                                      -- Código Mediador -- 8. 0021718 / 0111176 - Fin
                                      );   -- FIN BUG 18825 - 19/07/2011 - JMP
      ELSE
         IF NVL (pac_parametros.f_parempresa_n (pcempres, 'MONEDA_POL'), 0) =
                                                                            1
         THEN
            vtabla := 'vdetrecibos_monpol';
         ELSE
            vtabla := 'vdetrecibos';
         END IF;

         -- Bug 19986 - APD - 07/11/2011 - se añade la condicion AND ar.nrecunif <> ar.nrecibo
         psquery :=
               'select S.sseguro, D.cempres empresa, f_desproducto_T(D.cramo,D.cmodali,D.ctipseg,D.ccolect,1,'
            || pidioma
            || ') producto, null CODBANCAR, C.ncuenta cobrador, D.nrecibo, S.npoliza,  '
            || 'DV.tatribu tipo_recibo, null TOMADOR, R.fefecto, R.fvencim, R.cbancar, '
            -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
            /*
            || 'DR.itotalr  +  (decode(pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc),2, (SELECT NVL(SUM(v2.itotalr), 0)
                   FROM adm_recunif ar, vdetrecibos v2
                   WHERE ar.nrecunif = r.nrecibo
                     AND ar.nrecibo = v2.nrecibo
                     AND ar.nrecunif <> ar.nrecibo) ,0)) itotalr, '
            */
            || 'DR.itotalr  +  (SELECT NVL(SUM(v2.itotalr), 0)
                   FROM adm_recunif ar, vdetrecibos v2
                   WHERE ar.nrecunif = r.nrecibo
                     AND ar.nrecibo = v2.nrecibo
                     AND ar.nrecunif <> ar.nrecibo
                     AND pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (2,4) '
            -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Inicio
            || '  AND ar.sdomunif = d.sproces )
               +  (SELECT NVL(SUM(v2.itotalr), 0)
                   FROM adm_recunif_his ar, vdetrecibos v2
                   WHERE ar.nrecunif = r.nrecibo
                     AND ar.nrecibo = v2.nrecibo
                     AND ar.nrecunif <> ar.nrecibo
                     AND pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (2,4)
                     AND ar.sdomunif = d.sproces '
            ||
               -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Inicio
               ')  itotalr, '
            -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin
            || ' c.ctipban ctipban_cobra, r.ctipban ctipban_cban,  D.sproces proceso, '
--            || '''DR''||lpad(D.sproces, 6, ''0'')||''.''||lpad(D.cempres, 2, ''0'')||''.''||lpad(D.cdoment, 4, ''0'')||''.''||lpad(D.cdomsuc, 4, ''0'') fichero '
            || 'LTRIM(PAC_NOMBRES_FICHEROS.f_nom_domici(d.sproces,d.cempres,d.cdoment,d.cdomsuc),''_'') fichero, '
-- FAL - bug 0014328 - 03/05/2010 - CEM - Nombre fichero Domiciliaciones por pantalla
            -- BUG 18825 - 19/07/2011 - JMP
            || 'ff_desvalorfijo(383, '
            || pidioma
            || ', f_cestrec_mv(r.nrecibo, '
            || pidioma
            || ', null)) estado, '
            || 'ff_desvalorfijo(75, '
            || pidioma
            || ', r.cestimp) testimp, '
            || 'ff_desvalorfijo(800079, '
            || pidioma
            || ', dd.cestdom) est_domi, d.fdebito festado '
            -- FIN BUG 18825 - 19/07/2011 - JMP
            || ', r.cagente, F_DESAGENTE_T(r.cagente) tagente, r.nanuali, r.nfracci '
            -- 8. 0021718 / 0111176
            || ', to_date(decode(d.cdomest,0,d.fdebito,null)) frecaudo, '
            --22080
            || '  to_date(decode(d.cdomest,1,d.fdebito,null)) frechazo, '
            || ' (select de.CDEVREC from devbanrecibos de where dd.sdevolu = de.sdevolu and d.nrecibo = de.nrecibo) cdevrec '
            || 'from domiciliaciones D, seguros S, '
            || 'detvalores DV, recibos R, cobbancario C, '
            || vtabla
            || ' DR, domiciliaciones_cab dd '
            || 'where D.sproces = '
            || psproces
            || ' and D.sseguro = S.sseguro and '
            || 'DV.cvalor = 8 and DV.catribu = R.ctiprec and DV.cidioma = '
            || pidioma
            || ' and R.nrecibo = D.nrecibo and '
            || 'R.sseguro = S.sseguro and D.ccobban = C.ccobban and '
            || 'Dr.nrecibo = R.nrecibo  '
            -- BUG 18825 - 19/07/2011 - JMP
            || 'and dd.sproces(+) = d.sproces '
            -- FIN BUG 18825 - 19/07/2011 - JMP
            || 'order by D.cempres, S.npoliza, R.nrecibo ';

         IF v_max_reg IS NOT NULL
         THEN
            IF INSTR (psquery, 'order by', -1, 1) > 0
            THEN
               -- se hace de esta manera para mantener el orden de los registros
               psquery :=
                     'select * from ('
                  || psquery
                  || ') where rownum <= '
                  || v_max_reg;
            ELSE
               psquery := psquery || ' and rownum <= ' || v_max_reg;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 9001250;           --Error al recuperar les dades dels rebuts
   END f_get_domiciliacion;

   FUNCTION ff_nombre_entidad (pcbancar VARCHAR2, pctipban NUMBER)
      RETURN VARCHAR
   IS
      vnombanc   VARCHAR2 (50);
      vini       NUMBER;
      vlong      NUMBER;
   BEGIN
      SELECT pos_entidad, long_entidad
        INTO vini, vlong
        FROM tipos_cuenta
       WHERE ctipban = pctipban;

      SELECT tbanco
        INTO vnombanc
        FROM bancos
       WHERE cbanco = TO_NUMBER (SUBSTR (pcbancar, vini, vlong));

      RETURN vnombanc;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMICILIACIONES.ff_nombre_entidad',
                      1,
                      'Error generic',
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN NULL;
   END ff_nombre_entidad;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para obtener los datos de la cabecera de domiciliaciones
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pccobban   : Código de cobrador bancario
       param in pidioma    : Código de idioma
       param in pfinirem   : Fecha inicio remesa
       param in pffinrem   : Fecha fin remesa
       param out psquery   : Query
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_get_domiciliacion_cab (
      pcempres   IN       NUMBER,
      psproces   IN       NUMBER,
      pccobban   IN       NUMBER,
      pidioma    IN       NUMBER,
      pfinirem   IN       DATE,
      pffinrem   IN       DATE,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vcramo      productos.cramo%TYPE;
      vcmodali    productos.cmodali%TYPE;
      vctipseg    productos.ctipseg%TYPE;
      vccolect    productos.ccolect%TYPE;
      vsproces    domiciliaciones.sproces%TYPE;
      v_max_reg   parinstalacion.nvalpar%TYPE;
      xsproces    domiciliaciones.sproces%TYPE;
      vtabla      VARCHAR2 (50);
   BEGIN
      v_max_reg := f_parinstalacion_n ('N_MAX_REG');

      IF NVL (pac_parametros.f_parempresa_n (pcempres, 'MONEDA_POL'), 0) = 1
      THEN
         vtabla := 'vdetrecibos_monpol';
      ELSE
         vtabla := 'vdetrecibos';
      END IF;

      psquery :=
            'SELECT dc.cempres, dc.sproces, dc.ccobban, dc.fefecto fcreacion, '
         || '    dc.TFILEENV, dc.TFILEDEV, dc.CREMBAN, dc.CUSUMOD, dc.FUSUMOD, dc.SDEVOLU, '
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Inicio
         -- || '    COUNT(d.nrecibo) remesados, '
         || '    COUNT(distinct d.nrecibo) remesados, '
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Final
         || '    SUM(v.itotalr) iremesados,       '
         --|| '    COUNT(DECODE(f_cestrec(d.nrecibo, NULL), 1, d.nrecibo, NULL)) cobrados, ' --> (-)
         --|| '    NVL(SUM(DECODE(f_cestrec(d.nrecibo, NULL), 1, v.itotalr, NULL)), 0) icobrados, ' --> (-)
         --|| '    COUNT(DECODE(f_cestrec(d.nrecibo, NULL), 2, d.nrecibo, NULL)) anulados, ' --> (-)
         --|| '    NVL(SUM(DECODE(f_cestrec(d.nrecibo, NULL), 2, v.itotalr, NULL)), 0) ianulados, '--> (-)
         --|| '    MAX((SELECT dv.tatribu ' || '                FROM detvalores dv '--> (-)  --> 12. Añadir "distinct
         || '    COUNT(distinct DECODE(m.cestrec, 1, d.nrecibo, NULL)) cobrados, '
         --> (+) --> 12. Añadir "distinct
         || '    NVL(SUM(DECODE(m.cestrec, 1, v.itotalr, NULL)), 0) icobrados, '
         --> (+)   --> 12. Añadir "distinct
         || '    COUNT(distinct DECODE(m.cestrec, 2, d.nrecibo, NULL)) anulados, '
         --> (+) --> 12. Añadir "distinct
         || '    NVL(SUM(DECODE(m.cestrec, 2, v.itotalr, NULL)), 0) ianulados, '
         --> (+)   --> 12. Añadir "distinct
         || '    COUNT(distinct DECODE(m.cestrec, 0, DECODE(m.cestant, 1, d.nrecibo, NULL), NULL)) impagados, '
         --> (+)
         || '    NVL(SUM(DECODE(m.cestrec, 0, DECODE(m.cestant, 1, v.itotalr, NULL))), 0) iimpagados, '
         --> (+)
         || '    MAX((SELECT dv.tatribu '
         || '                FROM detvalores dv '
         || '          WHERE dv.cvalor = 800079 '
         || '            AND dv.cidioma = '
         || pidioma
         || '            AND dv.catribu = dc.cestdom)) cestado, dc.cestdom, ff_desvalorfijo (800090,'
         || pidioma
         || ',cb.nprisel) tcompani, max(d.fdebito) frecaudo, cb.descripcion tcobban '
         || '    FROM '
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Inicio
         || '          adm_recunif_his arh, adm_recunif ar, '
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Final
         || vtabla
         || '   v, domiciliaciones_cab dc, domiciliaciones d, cobbancario cb '
         || ' , movrecibo m '                                          --> (+)
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Inicio
         --|| '   WHERE v.nrecibo = d.nrecibo '
         || '   WHERE v.nrecibo = m.nrecibo '
         || '   and arh.nrecunif(+) = d.nrecibo '
         || '   and arh.sdomunif(+) = d.sproces '
         || '   and ar.nrecunif(+) = d.nrecibo  '
         || '   and ar.sdomunif(+) = d.sproces  '
         || '   and dc.sproces(+) = d.sproces   '
         || '   and v.nrecibo = NVL(NVL(ar.nrecibo, arh.nrecibo), d.nrecibo) '
         -- || ' and m.nrecibo = d.nrecibo and m.fmovfin is null '   --> (+)
         || '   and m.fmovfin is null '                                --> (+)
         -- 12. 0028449: LCOL_A003-En pantallas y listados de domiciliaciones - QT-9258 - Final
         || '   AND dc.sproces(+) = d.sproces '
         || '   and cb.ccobban = dc.ccobban ';

      IF psproces IS NOT NULL
      THEN
         psquery := psquery || '   AND dc.sproces = ' || psproces || ' ';
      END IF;

      IF pccobban IS NOT NULL
      THEN
         psquery := psquery || '   AND dc.ccobban = ' || pccobban || ' ';
      END IF;

      IF pfinirem IS NOT NULL
      THEN
         psquery :=
               psquery
            || '   AND TRUNC(dc.fefecto) >= to_date('
            || CHR (39)
            || TO_CHAR (pfinirem, 'ddmmyyyy')
            || CHR (39)
            || ',''ddmmyyyy'') ';
      END IF;

      IF pffinrem IS NOT NULL
      THEN
         psquery :=
               psquery
            || '   AND TRUNC(dc.fefecto) <= to_date('
            || CHR (39)
            || TO_CHAR (pffinrem, 'ddmmyyyy')
            || CHR (39)
            || ',''ddmmyyyy'') ';
      END IF;

      IF v_max_reg IS NOT NULL
      THEN
         IF INSTR (psquery, 'order by', -1, 1) > 0
         THEN
            -- se hace de esta manera para mantener el orden de los registros
            psquery :=
               'select * from (' || psquery || ') where rownum <= '
               || v_max_reg;
         ELSE
            psquery := psquery || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      psquery :=
            psquery
         || ' GROUP BY dc.cempres, dc.sproces, dc.ccobban, dc.fefecto, '
         || '          dc.TFILEENV, dc.TFILEDEV, dc.CREMBAN, dc.CUSUMOD, dc.FUSUMOD, dc.SDEVOLU, dc.cestdom, cb.nprisel, cb.descripcion '
         || 'ORDER BY dc.sproces ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 9001250;           --Error al recuperar les dades dels rebuts
   END f_get_domiciliacion_cab;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para modificar el cabecera de domiciliaciones
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pccobban   : Código de cobrador bancario
       param in pfefecto   : Fecha de efecto de la remesa
       param in ptfileenv  : Nombre del fichero de envío
       param in ptfiledev  : Nombre del fichero de devolución
       param in pcestdom   : Estado de la remesa
       param in pcremban   : Número de remesa interna de la entidad bancaria
       param in pidioma    : Código de idioma
       return              : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_set_domiciliacion_cab (
      pcempres    IN   NUMBER,
      psproces    IN   NUMBER,
      pccobban    IN   NUMBER,
      pfefecto    IN   DATE,
      ptfileenv   IN   VARCHAR2,
      ptfiledev   IN   VARCHAR2,
      pcestdom    IN   NUMBER,
      pcremban    IN   VARCHAR2,
      psdevolu    IN   NUMBER,
      psprocie    IN   NUMBER,    -- 9. 0022753: MDP_A001-Cierre de remesa (+)
      pcidioma    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vdomcab       domiciliaciones_cab%ROWTYPE;
      vnerror       NUMBER                             := 0;
      vobjectname   VARCHAR2 (500)
                             := 'pac_domiciliaciones.f_set_domiciliacion_cab';
      vtexto        VARCHAR2 (2000);
      vcidioma      NUMBER   := NVL (pcidioma, pac_md_common.f_get_cxtidioma);
      vcusumod      domiciliaciones_cab.cusumod%TYPE   := f_user;
      vfusumod      domiciliaciones_cab.fusumod%TYPE   := f_sysdate;
   BEGIN
      SELECT 0
        INTO vnerror
        FROM domiciliaciones_cab
       WHERE sproces = psproces;

      BEGIN
         UPDATE domiciliaciones_cab c
            SET c.ccobban = NVL (pccobban, ccobban),
                c.cempres = NVL (pcempres, c.cempres),
                c.fefecto = NVL (pfefecto, c.fefecto),
                c.tfileenv = NVL (ptfileenv, c.tfileenv),
                c.tfiledev = NVL (ptfiledev, c.tfiledev),
                c.cestdom = NVL (pcestdom, c.cestdom),
                c.cremban = NVL (pcremban, c.cremban),
                c.cusumod = vcusumod,
                c.fusumod = vfusumod,
                c.sdevolu = NVL (psdevolu, c.sdevolu),
                c.sprocie = NVL (psprocie, sprocie)
          -- 9. 0022753: MDP_A001-Cierre de remesa (+)
         WHERE  sproces = psproces;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- 'Error al modificar la taula domiciliaciones_cab.
            vnerror := 9903561;
            vtexto := f_axis_literales (vnerror, vcidioma);
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         1,
                         vtexto,
                         SQLERRM || ' ' || SQLCODE
                        );
      END;

      RETURN vnerror;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            INSERT INTO domiciliaciones_cab
                        (sproces, ccobban, cempres, fefecto, tfileenv,
                         tfiledev, cestdom, cremban, cusumod, fusumod,
                         sdevolu, sprocie
                        )
                 VALUES (psproces, pccobban, pcempres, pfefecto, ptfileenv,
                         ptfiledev, pcestdom, pcremban, vcusumod, vfusumod,
                         psdevolu, psprocie
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Error de duplicados al insertar en la tabla domiciliaciones_cab
               vnerror := 9903551;
               vtexto := f_axis_literales (vnerror, vcidioma);
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            1,
                            vtexto,
                            SQLERRM || ' ' || SQLCODE
                           );
            WHEN OTHERS
            THEN
               -- Error al insertar en la tabla domiciliaciones_cab
               vnerror := 9903549;
               vtexto := f_axis_literales (vnerror, vcidioma);
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            1,
                            vtexto,
                            SQLERRM || ' ' || SQLCODE
                           );
         END;

         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 9001250;           --Error al recuperar les dades dels rebuts
   END f_set_domiciliacion_cab;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para retroceder una domiciliación
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pfecha     : Fecha de la retrocesión
       param in pidioma    : Código de idioma
       return              : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_retro_domiciliacion (
      pcempres   IN   NUMBER,
      psproces   IN   NUMBER,
      pfecha     IN   DATE DEFAULT NULL,
      pcidioma   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vdomcab       domiciliaciones_cab%ROWTYPE;
      vnerror       NUMBER                             := 0;
      vobjectname   VARCHAR2 (500)
                               := 'pac_domiciliaciones.f_retro_domiciliacion';
      vtexto        VARCHAR2 (2000);
      vcidioma      NUMBER                   := pac_md_common.f_get_cxtidioma;
      vcestdom      domiciliaciones_cab.cestdom%TYPE;
      vfecha        DATE;
      vpasexec      NUMBER                             := 0;
      vsdevolu      domiciliaciones_cab.sdevolu%TYPE;
      vcremban      domiciliaciones_cab.cremban%TYPE;

      FUNCTION f_retro_acciones (
         pcempres   IN   NUMBER,
         psproces   IN   NUMBER,
         pnrecibo   IN   NUMBER,
         pccobban   IN   NUMBER,
         pfecha     IN   DATE,
         pcidima    IN   NUMBER
      )
         RETURN NUMBER
      IS
         vnerror       NUMBER;
         vsmovagr      movrecibo.smovagr%TYPE   := 0;
         vnliqmen      NUMBER;
         vnliqlin      NUMBER;
         vidobs        NUMBER;
         vtexto        VARCHAR2 (2000);
         vtextobs      VARCHAR2 (2000);
         vpasexec      NUMBER                   := 0;
         vobjectname   VARCHAR2 (500)
              := 'pac_domiciliaciones.f_retro_domiciliacion.f_retro_acciones';
      BEGIN
         vpasexec := 10;
         --Deixa el rebut a pendent
         vnerror :=
            f_movrecibo (pnrecibo,
                         0,
                         pfecha,
                         NULL,
                         vsmovagr,
                         vnliqmen,
                         vnliqlin,
                         pfecha,
                         pccobban,
                         NULL,
                         248,           --> Retrocesión domiciliación bancaria
                         NULL
                        );

         IF vnerror = 0
         THEN
            vpasexec := 30;

            UPDATE recibos
               SET cestimp = 4                      -- Pendiente domiciliación
             WHERE nrecibo = pnrecibo AND cestimp = 5;

            -- Grabar apunte automático en la agenda del recibo
            -- El recibo estuvo incluida en remesa bancaria "retrocedida" #1#
            vpasexec := 40;
            vtextobs := f_axis_literales (9903524, pcidioma);
            vtextobs := REPLACE (vtextobs, '#1#', psproces);
            vpasexec := 50;

            -- Grabar en la agenda OBS
            BEGIN
               SELECT NVL (MAX (idobs), 0) + 1
                 INTO vidobs
                 FROM agd_observaciones
                WHERE cempres = pcempres;
            EXCEPTION
               WHEN OTHERS
               THEN
                  vidobs := 1;
            END;

            vpasexec := 60;
            -- 9903524 - El recibo estuvo incluida en remesa bancaria "retrocedida" #1#
            vnerror :=
               pac_agenda.f_set_obs (pcempres,
                                     vidobs,
                                     1,
                                     0,
                                     SUBSTR (vtextobs, 1, 100),
                                     vtextobs,
                                     f_sysdate,
                                     NULL,
                                     2,
                                     NULL,
                                     NULL,
                                     NULL,
                                     1,
                                     1,
                                     f_sysdate,
                                     vidobs
                                    );

            IF vnerror = 0
            THEN
               vpasexec := 70;

               UPDATE agd_observaciones
                  SET nrecibo = pnrecibo
                WHERE cempres = pcempres AND idobs = vidobs;
            ELSE
               vtexto := f_axis_literales (vnerror, vcidioma);
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            vpasexec,
                            vtexto,
                            'pac_agenda.f_set_obs'
                           );
            END IF;
         END IF;

         vpasexec := 80;
         RETURN vnerror;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- 9903525 - Error en retrocesión de remesa bancaria #1#
            vnerror := 9903525;
            vtexto := f_axis_literales (vnerror, vcidioma);
            vtexto := REPLACE (vtexto, '#1#', psproces);
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         vpasexec,
                         vtexto,
                         SQLERRM || ' ' || SQLCODE
                        );
            RETURN vnerror;
      END;
   BEGIN
      vpasexec := 10;

      SELECT cestdom, cremban
        INTO vcestdom, vcremban
        FROM domiciliaciones_cab
       WHERE sproces = psproces;

      vpasexec := 20;
      vfecha := NVL (vfecha, f_sysdate);

      IF vcestdom = 0
      THEN
         vpasexec := 30;
         -- El estado de la remesa bancaria no permite su retrocesión
         vnerror := 9904180;
         vtexto := f_axis_literales (vnerror, vcidioma);
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      1,
                      vtexto,
                      psproces || ' - ' || vcestdom
                     );
      ELSIF vcremban IS NOT NULL
      THEN
         vpasexec := 35;
         -- Remesa con respuesta bancaria, no se permite su retrocesión.
         vnerror := 9903715;
         vtexto := f_axis_literales (vnerror, vcidioma);
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      1,
                      vtexto,
                      psproces || ' - ' || vcremban
                     );
      ELSE
         vpasexec := 40;

         -- Retroceder la remesa
         FOR r1 IN (SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                           r.nrecibo, r.cestimp, r.ccobban, r.cempres,
                           s.sproduc                -- 10 - 0026169 - 0138818
                      FROM seguros s, recibos r, domiciliaciones d
                     WHERE s.sseguro = r.sseguro
                       AND r.nrecibo = d.nrecibo
                       AND d.sproces = psproces)
         LOOP
            vpasexec := 50;

            -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
                  /*
               IF NVL(f_parproductos_v(f_sproduc_ret(r1.cramo, r1.cmodali, r1.ctipseg,
                                                     r1.ccolect),
                                       'RECUNIF'),
                      0) IN(1, 2) THEN
                      */
            IF pac_domis.f_agrupa_rec_tipo (r1.ccobban,
                                            r1.cempres,
                                            r1.sproduc
                                           ) IN (1, 2, 4)
            THEN
               -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin

               -- Si se devuelve un recibo agrupado entrará en LOOP
               vpasexec := 60;

               FOR v_recind IN (SELECT nrecibo
                                  FROM adm_recunif a
                                 WHERE nrecunif = r1.nrecibo
                                   AND nrecibo != r1.nrecibo
                                   -- 12. 0028449 - QT-9258 - Inicio
                                   AND sdomunif = psproces
                                UNION
                                SELECT nrecibo
                                  FROM adm_recunif_his a
                                 WHERE nrecunif = r1.nrecibo
                                   AND nrecibo != r1.nrecibo
                                   AND sdomunif = psproces
                                                          -- 12. 0028449 - QT-9258 - Final
                              )
               LOOP
                  vpasexec := 70;
                  vnerror :=
                     f_retro_acciones (pcempres,
                                       psproces,
                                       v_recind.nrecibo,
                                       r1.ccobban,
                                       vfecha,
                                       vcidioma
                                      );

                  IF vnerror <> 0
                  THEN
                     vtexto := f_axis_literales (vnerror, vcidioma);
                     p_tab_error (f_sysdate,
                                  f_user,
                                  vobjectname,
                                  vpasexec,
                                  vtexto,
                                     '(recibos unificados) - recibo:'
                                  || v_recind.nrecibo
                                  || ' error:'
                                  || vnerror
                                 );
                  END IF;
               END LOOP;
            END IF;

            vpasexec := 80;
            vnerror :=
               f_retro_acciones (pcempres,
                                 psproces,
                                 r1.nrecibo,
                                 r1.ccobban,
                                 vfecha,
                                 vcidioma
                                );

            IF vnerror <> 0
            THEN
               vtexto := f_axis_literales (vnerror, vcidioma);
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            vpasexec,
                            vtexto,
                            'recibo:' || r1.nrecibo || ' error:' || vnerror
                           );
            END IF;
         END LOOP;

         vpasexec := 90;

         IF vnerror = 0
         THEN
            BEGIN
               vpasexec := 100;

               UPDATE domiciliaciones_cab
                  SET cestdom = 2                               -- Retrocedida
                WHERE sproces = psproces;
            EXCEPTION
               WHEN OTHERS
               THEN
                  -- Error al modificar la tabla domiciliaciones_cab
                  vnerror := 9903561;
                  vtexto := f_axis_literales (vnerror, vcidioma);
                  p_tab_error (f_sysdate,
                               f_user,
                               vobjectname,
                               1,
                               vtexto,
                               SQLERRM || ' ' || SQLCODE
                              );
            END;
         END IF;
      END IF;

      vpasexec := 110;
      RETURN vnerror;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- 9903525 - Error en retrocesión de remesa bancaria #1#
         vnerror := 9903525;
         vtexto := f_axis_literales (vnerror, vcidioma);
         vtexto := REPLACE (vtexto, '#1#', psproces);
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vtexto,
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN vnerror;
   END f_retro_domiciliacion;

   -- 9. 0022753: MDP_A001-Cierre de remesa - Inicio

   /*******************************************************************************
    FUNCION f_cierre_remesa
    Función que cierra las remesa y el estado de los sus recibos.
    Parámetros:
     Entrada :
        Psproces NUMBER

     Retorna: un NUMBER con el id del error.
    ********************************************************************************/
   FUNCTION f_cierre_remesa (
      pcempres    IN       NUMBER DEFAULT pac_md_common.f_get_cxtempresa,
      psproces    IN       NUMBER,                 --> DOMICILIACIONES.SPROCES
      psproces2   IN       NUMBER,                      --> PROCESOCAB.SPROCES
      pnum_ok     OUT      NUMBER,
      pnum_ko     OUT      NUMBER,
      psmovagr    IN OUT   NUMBER,
      pfdebito    IN       DATE DEFAULT NULL,
      pfproces    IN       DATE DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)                  := 1;
      vparam      VARCHAR2 (200)
         :=    'pcempres='
            || pcempres
            || ' psproces='
            || psproces
            || ' psproces2='
            || psproces2
            || ' pnum_ok='
            || pnum_ok
            || ' pnum_ko='
            || pnum_ko
            || ' pfdebito='
            || pfdebito;
      vobject     VARCHAR2 (200)      := 'PAC_DOMICILIACIONES.f_cierre_remesa';

      CURSOR c_dom (ppsproces NUMBER)
      IS
         SELECT *
           FROM domiciliaciones
          WHERE f_cestrec (nrecibo, pfproces) = 3
            AND sproces = ppsproces
            AND cempres = pcempres
            AND (cerror = 0 OR cerror IS NULL);

      vcestrec    NUMBER                      := 1;
      num_err     NUMBER                      := 0;
      lnliqlin    NUMBER;
      lnliqmen    NUMBER;
      vnprolin    NUMBER;
      vtexto      VARCHAR2 (400);
      vtexto2     VARCHAR2 (400);
      vsproces2   NUMBER                      := psproces2;
      vfdia       DATE                        := TRUNC (f_sysdate);
      vcidioma    NUMBER                      := pac_md_common.f_get_cxtidioma;
      vcaccret    recibos_comp.caccret%TYPE;
      salir       EXCEPTION;
   BEGIN
      IF NVL (pac_parametros.f_parempresa_n (pcempres, 'COBRA_RECDOM'), 1) =
                                                                            3
      THEN
         -- Control parametros entrada
         IF psproces IS NULL
         THEN
            num_err := 140974;               --Faltan parametros por informar
            RAISE salir;
         END IF;

         vpasexec := 2;
         pnum_ok := 0;
         pnum_ko := 0;
         vpasexec := 3;
         vpasexec := 4;
         psmovagr := NVL (psmovagr, 0);

         BEGIN
            SELECT tvalor
              INTO vtexto2
              FROM valores
             WHERE cvalor = 800089 AND cidioma = vcidioma;
         EXCEPTION
            WHEN OTHERS
            THEN
               vtexto2 := NULL;
         END;

         FOR v_dom IN c_dom (psproces)
         LOOP
            -- Cobrem el rebut
            lnliqmen := NULL;
            lnliqlin := NULL;
            num_err := 0;

            BEGIN
               SELECT caccret
                 INTO vcaccret
                 FROM recibos_comp
                WHERE nrecibo = v_dom.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  vcaccret := NULL;
            END;

            -- Antes de cobrar el recibo miramos que tiene acciones retenidas que deban impedirlo
            IF vcaccret IN (2,                                        -- Cobro
                              5)                            -- Todas retenidas
            THEN
               pnum_ok := pnum_ok + 1;
               vnprolin := NULL;
               vtexto :=
                     vtexto2
                  || ' '
                  || ff_desvalorfijo (800089, vcidioma, vcaccret);
               num_err :=
                      f_proceslin (vsproces2, vtexto, v_dom.nrecibo, vnprolin);
               COMMIT;
            ELSE
               -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
                     /*
                  IF NVL(f_parproductos_v(f_sproduc_ret(v_dom.cramo, v_dom.cmodali,
                                                        v_dom.ctipseg, v_dom.ccolect),
                                          'RECUNIF'),
                         0) IN(1, 2, 3) THEN
                         */
               IF pac_domis.f_agrupa_rec_tipo (v_dom.ccobban,
                                               v_dom.cempres,
                                               f_sproduc_ret (v_dom.cramo,
                                                              v_dom.cmodali,
                                                              v_dom.ctipseg,
                                                              v_dom.ccolect
                                                             )
                                              ) IN (1, 2, 4)
               THEN
                  -- 10. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin

                  -- Si es un recibo agrupado entrará en LOOP
                  FOR v_recind IN (SELECT nrecibo
                                     FROM adm_recunif a
                                    WHERE nrecunif = v_dom.nrecibo
                                      AND nrecunif <> nrecibo)
                  LOOP
                     num_err :=
                        f_movrecibo (v_recind.nrecibo,
                                     vcestrec,
                                     NULL,
                                     NULL,
                                     psmovagr,
                                     lnliqmen,
                                     lnliqlin,
                                     NVL (pfdebito, pfproces),
                                     v_dom.ccobban,
                                     NULL,
                                     NULL,
                                     v_dom.cagente,
                                     v_dom.cagrpro,
                                     v_dom.ccompani,
                                     v_dom.cempres,
                                     v_dom.ctipemp,
                                     v_dom.sseguro,
                                     v_dom.ctiprec,
                                     v_dom.cbancar,
                                     v_dom.nmovimi,
                                     v_dom.cramo,
                                     v_dom.cmodali,
                                     v_dom.ctipseg,
                                     v_dom.ccolect,
                                     NULL,                          --nomovrec
                                     NULL,                            --usucob
                                     v_dom.fefecrec,
                                     v_dom.pgasint,
                                     v_dom.pgasext,
                                     v_dom.cfeccob
                                    );
                  END LOOP;
               END IF;

               IF num_err = 0
               THEN
                  vpasexec := 5;
                  num_err :=
                     f_movrecibo (v_dom.nrecibo,
                                  vcestrec,
                                  NULL,
                                  NULL,
                                  psmovagr,
                                  lnliqmen,
                                  lnliqlin,
                                  NVL (pfdebito, pfproces),
                                  v_dom.ccobban,
                                  NULL,
                                  NULL,
                                  v_dom.cagente,
                                  v_dom.cagrpro,
                                  v_dom.ccompani,
                                  v_dom.cempres,
                                  v_dom.ctipemp,
                                  v_dom.sseguro,
                                  v_dom.ctiprec,
                                  v_dom.cbancar,
                                  v_dom.nmovimi,
                                  v_dom.cramo,
                                  v_dom.cmodali,
                                  v_dom.ctipseg,
                                  v_dom.ccolect,
                                  NULL,
                                  NULL,
                                  v_dom.fefecrec,
                                  v_dom.pgasint,
                                  v_dom.pgasext,
                                  v_dom.cfeccob
                                 );
               END IF;

               -- Si ha ido bien hace commit, sino rollback
               IF num_err = 0
               THEN
                  pnum_ok := pnum_ok + 1;
                  vnprolin := NULL;
                  vtexto :=
                        ff_desvalorfijo (383, vcidioma, vcestrec)
                        || ' --> OK';
                  num_err :=
                     f_proceslin (vsproces2, vtexto, v_dom.nrecibo, vnprolin);
                  COMMIT;
               ELSE
                  pnum_ko := pnum_ko + 1;
                  ROLLBACK;
                  vnprolin := NULL;
                  vtexto := f_axis_literales (num_err, vcidioma);
                  num_err :=
                     f_proceslin (vsproces2, vtexto, v_dom.nrecibo, vnprolin);
                  COMMIT;
               END IF;
            END IF;

            vpasexec := 6;
         END LOOP;

         IF num_err = 0
         THEN
            vpasexec := 7;
            num_err :=
               pac_domiciliaciones.f_set_domiciliacion_cab
                          (pcempres,
                           psproces,
                           NULL,                                   -- pccobban
                           NULL,                                   -- pfefecto
                           NULL,                                  -- ptfileenv
                           NULL,                                  -- ptfiledev
                           0,                                      -- pcestdom
                           NULL,                                   -- pcremban
                           NULL,                                   -- psdevolu
                           vsproces2, -- 9. 0022753: MDP_A001-Cierre de remesa
                           vcidioma                                -- pcidioma
                          );
            COMMIT;
         END IF;
      END IF;

      vpasexec := 8;
      RETURN num_err;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_cierre_remesa;

   /*******************************************************************************
   FUNCION f_cierre_automatico_remesas
   Función que busca las remesas que se han de cerrar automáticamente.
   Existen dos parámetros por empresa
     DIASGEST_DIRECTO = 0; -- (0-No, 1-Sí)
     DIASGEST := Nº tramo creado en el punto anterior.

   Sí DIASGEST_DIRECTO = 1 (Sí), los días son los que hay directamente en DIASGEST,
   Sino DIASGEST contiene el tramo donde se guardan los días de gestión por meses

   Parámetros:
    Entrada :
       Pcempres
       Psproces
       Pnmes
       Pfproces

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_cierre_automatico_remesas (
      pcempres   IN   NUMBER,
      pfcierre   IN   DATE,
      pfdebito   IN   DATE DEFAULT NULL,
      pfproces   IN   DATE DEFAULT NULL
   )
      RETURN NUMBER
   IS
      CURSOR c_liq (ppsprocie NUMBER)
      IS
         SELECT DISTINCT b.cagente
                    FROM domiciliaciones_cab a, domiciliaciones b
                   WHERE a.sprocie = ppsprocie AND a.sproces = b.sproces
                ORDER BY b.cagente;

      verror         NUMBER;
      vnum_ok        NUMBER;
      vnum_ko        NUMBER;
      vnum_lin       NUMBER;
      vdias          NUMBER;
      vfdebito       DATE;
      vfproces       DATE;
      vobjectname    VARCHAR2 (500)
                         := 'pac_domiciliaciones.f_cierre_automatico_remesas';
      vparam         VARCHAR2 (500)
         :=    'parámetros - pcempres: '
            || pcempres
            || ' pfcierre:'
            || pfcierre
            || ' pfproces:'
            || TO_CHAR (pfproces, 'dd/mm/yyyy');
      vpasexec       NUMBER (5)      := 0;
      vcidioma       NUMBER          := pac_md_common.f_get_cxtidioma;
      vnomfichero    VARCHAR2 (1000);
      vsproces2      NUMBER;
      vnprolin       NUMBER;
      vsmovagr       NUMBER          := 0;
      vcerradas_ok   NUMBER          := 0;
      vcerradas_ko   NUMBER          := 0;
      vtexto         VARCHAR2 (9000);
      vtextot        VARCHAR2 (9000);
      vnmes          NUMBER          := TO_CHAR (pfcierre, 'MM');
      vnmesany       VARCHAR2 (10)   := TO_CHAR (pfcierre, 'MM/YYYY');
      vcempres       NUMBER
                          := NVL (pcempres, f_parinstalacion_n ('EMPRESADEF'));
      v_mail         VARCHAR2 (9000);
      v_asunto       VARCHAR2 (9000);
      v_from         VARCHAR2 (9000);
      v_to           VARCHAR2 (9000);
      v_to2          VARCHAR2 (9000);
      v_error        VARCHAR2 (9000);
      v_saltolin     VARCHAR2 (2)    := CHR (10) || CHR (13);
   BEGIN
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      vpasexec := 5;
      vtexto := f_axis_literales (9903996, vcidioma) || ' ' || vnmesany;
      vtextot := vtexto || v_saltolin;
      vpasexec := 10;
      verror :=
         f_procesini (f_user,
                      vcempres,
                      'CIERRE AUTO.REM.BCO',
                      vtexto,
                      vsproces2
                     );
      vpasexec := 15;
      COMMIT;
      vpasexec := 20;
      --5103-200056 11/03/2015   KJSC eliminaremos la línea que calcula los días con el parámetro “DIASGEST” y en su lugar, llamaremos a la función PAC_ADM.F_GEST_DIASGEST con el parámetro recibo vacio y el parámetro fecha con la fecha de cierre (pfcierre).
      --vdias := NVL(pac_parametros.f_parempresa_n(vcempres, 'DIASGEST'), 0);
      vdias := NVL (pac_adm.f_get_diasgest (NULL, pfcierre), 0);
      vfdebito := NVL (pfdebito, f_sysdate);
      vfproces := NVL (pfproces, f_sysdate);
      vpasexec := 25;
      --35103-200056 11/03/2015   KJSC Eliminar la condición del parámetro “DIASGEST_DIRECTO” y la línea que calcula los días con la función del tramo
      /*IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DIASGEST_DIRECTO'), 0) = 0 THEN
         vdias := vtramo(-1, vdias, vnmes);
      END IF;*/
      vpasexec := 30;

      FOR r1 IN (SELECT sproces
                   FROM domiciliaciones_cab
                  WHERE cestdom = 1                               --> abiertas
                    AND cempres = vcempres
                    AND fefecto + vdias <= vfproces)
      LOOP
         vpasexec := 35;
         verror :=
            f_cierre_remesa (vcempres,
                             r1.sproces,
                             vsproces2,
                             vnum_ok,
                             vnum_ko,
                             vsmovagr,
                             vfdebito,
                             vfproces
                            );

         IF verror = 0
         THEN
            vpasexec := 40;
            vtexto :=
                  'Cerrada Remesa '
               || r1.sproces
               || ' recibos-OK: '
               || vnum_ok
               || ' recibo-KO: '
               || vnum_ko;
            vcerradas_ok := vcerradas_ok + 1;
         ELSE
            vpasexec := 50;
            vtexto := 'Cierre Remesa ' || r1.sproces || ' error: ' || verror;
            vcerradas_ko := vcerradas_ko + 1;
         END IF;

         verror := f_proceslin (vsproces2, vtexto, 1, vnum_lin);
         vtextot := vtextot || v_saltolin || vtexto || v_saltolin;
      END LOOP;

      -- El listado y la liquidación solo se efectuará solo cuando se haya cerrado
      -- correctamente alguna remesa.
      IF vcerradas_ok > 0
      THEN
         vpasexec := 60;
         verror :=
               f_get_listado_cierre_remesa (vsproces2, vcidioma, vnomfichero);

         IF verror = 0
         THEN
            vpasexec := 70;
            verror :=
               f_proceslin (vsproces2,
                            'Listado Cierre Remesas: ' || vnomfichero,
                            1,
                            vnum_lin
                           );
         ELSE
            verror :=
               f_proceslin (vsproces2,
                            'Listado Cierre Remesas - error: ' || verror,
                            1,
                            vnum_lin
                           );
         END IF;

         IF NVL (pac_parametros.f_parempresa_n (pcempres,
                                                'CIERRE_REM_LIQ_AGE'),
                 0
                ) = 1
         THEN
            FOR v_liq IN c_liq (vsproces2)
            LOOP
               verror :=
                  pac_liquida.f_liquidaliq_age
                                              (v_liq.cagente,
                                               pcempres,
                                               0,                 -- Modo real
                                               vfproces,
                                               vcidioma,
                                               pac_md_common.f_get_cxtagente,
                                               vsproces2,
                                               vsmovagr
                                              );

               IF verror = 0
               THEN
                  -- 9001776 - Liquidación de comisiones
                  vtexto :=
                        f_axis_literales (9001776, vcidioma)
                     || ' '
                     || v_liq.cagente;
               ELSE
                  vtexto :=
                        f_axis_literales (9001776, vcidioma)
                     || ' '
                     || v_liq.cagente
                     || ' Error: '
                     || f_axis_literales (verror, vcidioma);
               END IF;

               vnprolin := NULL;
               verror :=
                      f_proceslin (vsproces2, vtexto, v_liq.cagente, vnprolin);
            END LOOP;
         END IF;
      END IF;

      verror :=
         pac_correo.f_mail (49,                                    -- pscorreo
                            NULL,                                 -- psseguro,
                            NULL,                                 -- pnriesgo,
                            vcidioma,
                            NULL,                                  -- pcaccion
                            v_mail,
                            v_asunto,
                            v_from,
                            v_to,
                            v_to2,
                            v_error,
                            NULL,                                  -- pnsinies
                            NULL,                                  -- pcmotmov
                            NULL,                                    -- paviso
                            vnmesany,                              -- ptasunto
                            vtextot                                -- ptcuerpo
                           );
      vpasexec := 80;
      RETURN verror;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'Error no controlat. Vparam.: ' || vparam,
                      SQLERRM
                     );
         RETURN 103847;
   END f_cierre_automatico_remesas;

   /*************************************************************************
   Función que se encargará gde generar el listado de acciones de los recibos
   de una remesa por cierre

   Este listado se generará automáticamente al cerrar la remesa y mostrará las
   acciones relacionadas con los recibos que cambian de estado de ‘remesado’ a ‘cobrado’.
   Quedará en el directorio parametrizado para este listado.

   No se le han generado capas MD ni IAX porque no se ha previsto ejecutarlo
   desde ningún formulario.

        param in psproces     : nº proceso de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1

   *************************************************************************/
   FUNCTION f_get_listado_cierre_remesa (
      psproces      IN       NUMBER,
      pidioma       IN       NUMBER,
      pnomfichero   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                            := 'PAC_devoluciones.f_get_listado_cierre_remesa';
      vparam        VARCHAR2 (500)
         := 'parámetros - psproces : ' || psproces || ', pidioma : '
            || pidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vsmapead      NUMBER;
      vtparpath     VARCHAR2 (1000);
      vpath         VARCHAR2 (1000);
      vfichero      VARCHAR2 (1000);
   BEGIN
      SELECT psproces || '_' || tdesmap, tparpath || '_C'
        INTO vfichero, vtparpath
        FROM map_cabecera
       WHERE cmapead = '611';

      vpath := f_parinstalacion_t (vtparpath);
      pac_map.p_genera_parametros_fichero ('611',
                                           psproces || '|' || pidioma,
                                           vfichero,
                                           0
                                          );
      vnumerr := pac_map.genera_map ('611', vsmapead);
      pnomfichero := vpath || '/' || vfichero;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001653;
   END f_get_listado_cierre_remesa;
-- 9. 0022753: MDP_A001-Cierre de remesa - Fin
END pac_domiciliaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "PROGRAMADORESCSI";
