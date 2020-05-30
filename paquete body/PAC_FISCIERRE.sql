--------------------------------------------------------
--  DDL for Package Body PAC_FISCIERRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FISCIERRE" AS
/******************************************************************************
   NOMBRE:    PAC_FISCIERRE

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        08/10/2008  SBG              1. Creación F_GENERAR
                                           2. Creación F_GET_MODELOS
                                           3. Creación F_GETDETVALORES
                                           4. Creación F_GETLINEAPARAM
   3.0        17/02/2010  FAL              6. Creación FF_PENALIZACION
   4.0        27/09/2010  RSC              7. Bug 15702 - Models Fiscals: 347
   5.0        12/09/2012  APD              8. 0022996: MDP_F001-Fiscalidad - crear el modelo 7
   6.0        20/10/2012  DCG              9. 0023887: AGM800-Modelo 347. Contemplar (operaciones con terceros)
******************************************************************************/

   /******************************************************************
     28/01/2005 CPM
     Package que contiene la función para realizar el cierre fiscal
   ******************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      --
      --    Proceso que lanzará el proceso de cierre fiscal
      --
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      -- RSC 10/04/2008
      vsfiscab       NUMBER;
      -- RSC 17/04/2088
      verror         NUMBER;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Fiscal - Previo';
      ELSE
         v_titulo := 'Proceso Cierre Fiscal';
      END IF;

--dbms_output.put_line('llamamos a procesini');
   --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'CIERRE_FISCAL', v_titulo, psproces);
      COMMIT;

--dbms_output.put_line('sproces ='||psproces);
      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Cierre fiscal: ' || texto || ' ' || text_error, 1,
                                       120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         pcerror := 0;

         -- Borrado de los registros que se corresponden al año y empresa que vamos a tratar
         BEGIN
            DELETE FROM fis_irpfpp
                  WHERE sfiscab IN(SELECT sfiscab
                                     FROM fis_cabcierre
                                    WHERE nanyo = TO_CHAR(pfperfin, 'yyyy')
                                      AND cempres = pcempres);

            DELETE FROM fis_detcierrecobro
                  WHERE sfiscab IN(SELECT sfiscab
                                     FROM fis_cabcierre
                                    WHERE nanyo = TO_CHAR(pfperfin, 'yyyy')
                                      AND cempres = pcempres);

            DELETE FROM fis_detcierrepago
                  WHERE sfiscab IN(SELECT sfiscab
                                     FROM fis_cabcierre
                                    WHERE nanyo = TO_CHAR(pfperfin, 'yyyy')
                                      AND cempres = pcempres);

            DELETE FROM fis_cabcierre
                  WHERE nanyo = TO_CHAR(pfperfin, 'yyyy')
                    AND cempres = pcempres;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL =' || psproces, NULL,
                           'when others del delete del cierre =' || pfperfin, SQLERRM);
         END;

         -- RSC 10/04/2008
         /***********************************************************************
           Desde aqui vamos a lanzar todos los cierres fiscales.
           Inicialmente solo existia el cirre fiscal de planes de pensiones.
           Ahora añadiremos el de ahorro. En un futuro se añadirá el de rentas.
         ***********************************************************************/
         --Inserción de la tabla FIS_CABCIERRE
         SELECT sfiscab.NEXTVAL
           INTO vsfiscab
           FROM DUAL;

         INSERT INTO fis_cabcierre
                     (sfiscab, cempres, nanyo, nnumpet, mesini,
                      mesfin, cpagcob, ccierre, fpeticion, sproces)
              VALUES (vsfiscab, pcempres, TO_NUMBER(TO_CHAR(pfperfin, 'yyyy')), pcempres, 0,
                      0, 0, 0, f_sysdate, psproces);

         -- Borramos el PlanFiscal del año que se cálcula
         DELETE FROM planfiscal
               WHERE nano = TO_CHAR(pfperfin, 'yyyy');

         -- Cierre de Planes de Pensiones
         verror := pac_cierrefiscal_pp.cierre_pp(TO_CHAR(pfperfin, 'yyyy'), pcempres, vsfiscab,
                                                 pfperfin);

         IF verror = 0 THEN
            -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
            verror := pac_cierrefiscal_aru.cierre_fis_riesgo(TO_CHAR(pfperfin, 'yyyy'),
                                                             pcempres, vsfiscab, psproces,
                                                             pfperfin);

            -- Bug 15702
            IF verror = 0 THEN
               -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
               verror := pac_cierrefiscal_aru.cierre_fis_aho(TO_CHAR(pfperfin, 'yyyy'),
                                                             pcempres, vsfiscab, psproces,
                                                             pfperfin);

               IF verror = 0 THEN
                  -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                  verror := pac_cierrefiscal_aru.cierre_fis_ren_ulk(TO_CHAR(pfperfin, 'yyyy'),
                                                                    pcempres, vsfiscab,
                                                                    psproces, pfperfin);

-- Bug 0023887 - DCG - 20/10/2012 -  AGM800-Modelo 347. Contemplar (operaciones con terceros)
-- Por el momento se queda asteriscado el reaseguro y el coaseguro a la espera que se suban los cambios a producción.
-- También se deberá controlar el estado de los accesos a estas tablas ya que no están perfilados.
                  IF verror = 0 THEN
                     verror := cierre_fis_pag_com(TO_CHAR(pfperfin, 'yyyy'), pcempres,
                                                  vsfiscab, psproces, pfperfin);

                     IF verror = 0 THEN
--Pdte de habilitar                        verror := cierre_fis_reaseg(TO_CHAR(pfperfin, 'yyyy'), pcempres,
--Pdte de habilitar                                                    vsfiscab, psproces, pfperfin);
                        IF verror = 0 THEN
--Pdte de habilitar                           verror := cierre_fis_coaseg(TO_CHAR(pfperfin, 'yyyy'), pcempres,
--Pdte de habilitar                                                       vsfiscab, psproces, pfperfin);

                           -- Fin Bug 0023887
                           IF verror = 0 THEN
                              UPDATE fis_cabcierre
                                 SET ccierre = 1
                               WHERE sfiscab = vsfiscab;
                           ELSE
                              -- Apuntem linea de error a PROCESOSLIN
                              conta_err := conta_err + 1;
                              pnnumlin := NULL;
                              num_err :=
                                 f_proceslin
                                    (psproces,
                                     SUBSTR
                                        ('Cierre fiscal: Proceso no finalizado correctamente',
                                         1, 120),
                                     0, pnnumlin);
                           END IF;
-- Bug 0023887 - DCG - 20/10/2012 -  AGM800-Modelo 347. Contemplar (operaciones con terceros)
                        ELSE
                           -- Apuntem linea de error a PROCESOSLIN
                           conta_err := conta_err + 1;
                           pnnumlin := NULL;
                           num_err :=
                              f_proceslin
                                 (psproces,
                                  SUBSTR
                                        ('Cierre fiscal: Proceso no finalizado correctamente',
                                         1, 120),
                                  0, pnnumlin);
                        END IF;
                     ELSE
                        -- Apuntem linea de error a PROCESOSLIN
                        conta_err := conta_err + 1;
                        pnnumlin := NULL;
                        num_err :=
                           f_proceslin
                               (psproces,
                                SUBSTR('Cierre fiscal: Proceso no finalizado correctamente',
                                       1, 120),
                                0, pnnumlin);
                     END IF;

                     -- Apuntem linea de error a PROCESOSLIN
                     conta_err := conta_err + 1;
                     pnnumlin := NULL;
                     num_err :=
                        f_proceslin
                                (psproces,
                                 SUBSTR('Cierre fiscal: Proceso no finalizado correctamente',
                                        1, 120),
                                 0, pnnumlin);
                  END IF;
-- Fin Bug 0023887
               ELSE
                  -- Apuntem linea de error a PROCESOSLIN
                  conta_err := conta_err + 1;
                  pnnumlin := NULL;
                  num_err :=
                     f_proceslin
                               (psproces,
                                SUBSTR('Cierre fiscal: Proceso no finalizado correctamente',
                                       1, 120),
                                0, pnnumlin);
               END IF;
            ELSE
               conta_err := conta_err + 1;
               pnnumlin := NULL;
               num_err :=
                  f_proceslin(psproces,
                              SUBSTR('Cierre fiscal: Proceso no finalizado correctamente', 1,
                                     120),
                              0, pnnumlin);
            END IF;
         ELSE
            conta_err := conta_err + 1;
            pnnumlin := NULL;
            num_err :=
               f_proceslin(psproces,
                           SUBSTR('Cierre fiscal: Proceso no finalizado correctamente', 1,
                                  120),
                           0, pnnumlin);
         END IF;
/***********************************************************************/
      END IF;

      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
--dbms_output.put_line(SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

   /*************************************************************************
      Genera el fichero
      param in  P_EMPRESA : código empresa
      param in  P_CMODELO : modelo fiscal
      param in  P_LINEA   : línea de parámetros
      param in  P_FICH_IN : nombre fichero deseado (opcional)
      param in  P_FICH_OUT: path + nombre fichero salida
   *************************************************************************/
   FUNCTION f_generar(
      p_empresa IN NUMBER,
      p_cmodelo IN VARCHAR2,
      p_linea IN VARCHAR2,
      p_fich_in IN VARCHAR2 DEFAULT NULL,
      p_fich_out OUT VARCHAR2)
      RETURN NUMBER IS
      v_cmap         VARCHAR2(5);
      v_tfich        VARCHAR2(100);
      v_error        NUMBER;
   BEGIN
      SELECT cmap, tfichero
        INTO v_cmap, v_tfich
        FROM fis_modelosdet
       WHERE cempresa = p_empresa
         AND cmodelo = p_cmodelo;

      -- Bug 22996 - APD - 12/09/2012
      -- tener en cuenta ficheros que se quieran con formato yyyymmddhh24miss
      v_tfich := REPLACE(v_tfich, 'yyyymmddhh24miss', TO_CHAR(f_sysdate, 'yyyymmddhh24miss'));
      -- fin Bug 22996 - APD - 12/09/2012
      v_error := pac_map.f_extraccion(v_cmap, p_linea, NVL(p_fich_in, v_tfich), p_fich_out);
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_generar;

   /*************************************************************************
      Retorna un cursor a los modelos fiscales ACTIVOS para la empresa
      param in  P_EMPRESA : código empresa
      param in  P_IDIOMA  : idioma
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_get_modelos(p_empresa IN NUMBER, p_idioma IN NUMBER, p_error OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_query        VARCHAR2(200);
   BEGIN
      IF p_empresa IS NULL
         OR p_idioma IS NULL THEN
         p_error := -2;
         RETURN NULL;
      END IF;

      v_query := 'SELECT M.CMODELO, M.TMODELO FROM FIS_MODELOS M, FIS_MODELOSDET D '
                 || 'WHERE M.CMODELO = D.CMODELO AND D.CEMPRESA = ' || p_empresa
                 || ' AND M.CIDIOMA = ' || p_idioma || ' AND LACTIVO = ''S''';

      OPEN cur FOR v_query;

      p_error := 0;
      RETURN(cur);
   EXCEPTION
      WHEN OTHERS THEN
         p_error := -1;

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN(cur);
   END f_get_modelos;

   /*************************************************************************
      Retorna un cursor con los diferentes valores y descripciones
      param in  P_EMPRESA : código empresa
      param in  P_CVALOR  : valor
      param in  P_IDIOMA  : idioma
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_getdetvalores(
      p_empresa IN NUMBER,
      p_cvalor IN VARCHAR2,
      p_idioma IN NUMBER,
      p_error OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_query        VARCHAR2(200);
   BEGIN
      IF p_empresa IS NULL
         OR p_cvalor IS NULL
         OR p_idioma IS NULL THEN
         p_error := -2;
         RETURN NULL;
      END IF;

      v_query := 'SELECT CATRIBU CODI_' || p_cvalor || ', TATRIBU VALOR_' || p_cvalor || ' '
                 || 'FROM FIS_MODELOSDETVALORES ' || 'WHERE CEMPRESA = ' || p_empresa
                 || ' AND CVALOR = ''' || p_cvalor || ''' AND CIDIOMA = ' || p_idioma;

      OPEN cur FOR v_query;

      p_error := 0;
      RETURN(cur);
   EXCEPTION
      WHEN OTHERS THEN
         p_error := -1;

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN(cur);
   END f_getdetvalores;

   /*************************************************************************
      Retorna el LPARAME de la tabla FIS_MODELOSDET
      param in  P_EMPRESA : código empresa
      param in  P_CMODELO : modelo fiscal
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_getlineaparam(p_empresa IN NUMBER, p_cmodelo IN VARCHAR2, p_error OUT NUMBER)
      RETURN VARCHAR2 IS
      v_lparame      VARCHAR2(1000);
   BEGIN
      SELECT lparame, 0
        INTO v_lparame, p_error
        FROM fis_modelosdet
       WHERE cempresa = p_empresa
         AND cmodelo = p_cmodelo;

      RETURN v_lparame;
   EXCEPTION
      WHEN OTHERS THEN
         p_error := -1;
         RETURN NULL;
   END f_getlineaparam;

   /*************************************************************************
      Retorna la penalizacion de la poliza/producto. Tipo mov. penal: rescate total. Se usa en el map 310. Modelo fiscal 189
      param in  P_SPRODUC : código producto
      param in  P_SSEGURO : código del seguro
      param out P_FECHA   : fecha del rescate
   *************************************************************************/
   FUNCTION ff_penalizacion(
      psproduc IN parproductos.sproduc%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pfecha IN DATE,
      picaprisc IN NUMBER)   -- se añade el parametro que en la llamada (en la select del map 310) se informará con provmat.ipromat
      RETURN NUMBER IS
      vsproces       NUMBER;
      perror         NUMBER;
      wfefecto       DATE;
      nanyos         NUMBER;
      err            NUMBER;
      wipenali       NUMBER;
      wwippenali     NUMBER;
   BEGIN
      SELECT fefecto
        INTO wfefecto
        FROM seguros
       WHERE sseguro = psseguro;

      nanyos := MONTHS_BETWEEN(pfecha, wfefecto) / 12;
      err := f_penalizacion(3, nanyos, psproduc, psseguro, pfecha, wipenali, wwippenali, 'SEG',
                            1);

      IF err <> 0 THEN
         RETURN NULL;
      END IF;

      IF wwippenali = 1 THEN
         wipenali := wipenali;
      ELSIF wwippenali = 2 THEN
         wipenali := picaprisc * wipenali / 100;
      END IF;

      RETURN ROUND(wipenali, 2);
   END ff_penalizacion;

-- Bug 0023887 - DCG - 20/10/2012 -  AGM800-Modelo 347. Contemplar (operaciones con terceros)
   FUNCTION cierre_fis_pag_com(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      vtidenti       NUMBER;
      vsperson       NUMBER;
      vnumnif        VARCHAR2(14);
      vpais          NUMBER;
      vfnacimi       DATE;
      vfpeticion     DATE;
      vresul         NUMBER;
      vcontaerr      NUMBER := 0;
      vsproces       NUMBER;
      perror         NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      xsigno         CHAR(1);

      CURSOR comisiones IS
         SELECT   spago, cempres, cagente, iimporte, cestado, fliquida, falta, cforpag,
                  ctipopag, nremesa, ftrans, nnumlin, ctipban, cbancar
             FROM pagoscomisiones
            WHERE TO_CHAR(fliquida, 'YYYY') = pany
              AND cempres = NVL(pempres, 1)
         ORDER BY spago;
   BEGIN
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL COMISIONES', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      --Inserción de la tabla fis_detcierrepago
      FOR comi IN comisiones LOOP
         BEGIN
            SELECT sperson
              INTO vsperson
              FROM agentes
             WHERE cagente = comi.cagente;

            BEGIN
               SELECT pr.ctipseg, pr.ccolect, pr.cramo, pr.cmodali
                 INTO vctipseg, vccolect, vcramo, vcmodali
                 FROM ctactes c, productos pr
                WHERE c.cagente = comi.cagente
                  AND c.nnumlin = comi.nnumlin
                  AND c.sproduc = pr.sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vctipseg := NULL;
                  vccolect := NULL;
                  vcramo := NULL;
                  vcmodali := NULL;
               WHEN OTHERS THEN
                  vcontaerr := vcontaerr + 1;
            END;

            vresult := pac_persona.f_get_dadespersona(vsperson, comi.cagente, vpersona);
            vnumnif := vpersona.nnumide;
            vfnacimi := vpersona.fnacimi;
            vpais := vpersona.cpais;
            vtidenti := vpersona.ctipide;

            IF comi.iimporte < 0 THEN
               xsigno := 'N';
            ELSE
               xsigno := 'P';
            END IF;

            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali, ctipseg, ccolect,   --nnumpet,
                         pfiscal, sseguro, spersonp, nnumnifp,   --tidentip, cdomicip, sperson1,
                                                              --nnumnif1, tidenti1, cdomici1,ctipo, ndocum, cestrec,
                                                              fpago, ibruto,
                         iresrcm, iresred,   --ibase,
                                          pretenc, iretenc, ineto, cpaisret, csubtipo,
                         csigbase,
--                               cprovin,
                                  ctipcap, sidepag)
                 VALUES (psfiscab, sfisdpa.NEXTVAL, vcramo, vcmodali, vctipseg, vccolect,   --pnumpet,
                         pany, NULL, vsperson, vnumnif,   --xtidentip, xcdomicip, xspersonr,
                                                       --xnnumnifr, xtidentir, xcdomicir,'REN', ren.srecren, 1,
                                                       comi.fliquida, comi.iimporte,
                         comi.iimporte, 0,   --ren.ibase,
                                          0, 0, comi.iimporte, vpais, 347,
                         xsigno,
--                               REPLACE(LPAD(xcprovinp, 2), ' ', '0'),
                         1, comi.spago);
         EXCEPTION
            WHEN OTHERS THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      RETURN 0;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL cierre_fis_pag_com', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
   END cierre_fis_pag_com;

   FUNCTION cierre_fis_reaseg(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      vtidenti       NUMBER;
      vsperson       NUMBER;
      vnumnif        VARCHAR2(14);
      vpais          NUMBER;
      vfnacimi       DATE;
      vfpeticion     DATE;
      vresul         NUMBER;
      vcontaerr      NUMBER := 0;
      vsproces       NUMBER;
      perror         NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      xsigno         CHAR(1);
/* Se comenta a la espera de que suban los cambios de reaseguro
      CURSOR movreaseguro IS
         SELECT   spagrea, ccompani, ccorred, sproduc, iimporte, cestado, fliquida, falta,
                  cforpag, nremesa, ftrans, ctipban, cbancar, sproces, iimporte_moncon,
                  fcambio
             FROM pagos_ctatec_rea
            WHERE TO_CHAR(fliquida, 'YYYY') = pany
              AND cempres = NVL(pempres, 1)
              AND cestado = 1   -- pagado
         ORDER BY spagrea;
*/
   BEGIN
/* Se comenta a la espera de subir los cambios de coaseguro
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL REASEGURO', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      --Inserción de la tabla fis_detcierrepago
      FOR reas IN movreaseguro LOOP
         BEGIN
            SELECT sperson
              INTO vsperson
              FROM companias
             WHERE ccompani = reas.ccompani;

            BEGIN
               SELECT pr.ctipseg, pr.ccolect, pr.cramo, pr.cmodali
                 INTO vctipseg, vccolect, vcramo, vcmodali
                 FROM productos pr
                WHERE pr.sproduc = reas.sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vctipseg := NULL;
                  vccolect := NULL;
                  vcramo := NULL;
                  vcmodali := NULL;
               WHEN OTHERS THEN
                  vcontaerr := vcontaerr + 1;
            END;

            vresult := pac_persona.f_get_dadespersona(vsperson, reas.ccompani, vpersona);
            vnumnif := vpersona.nnumide;
            vfnacimi := vpersona.fnacimi;
            vpais := vpersona.cpais;
            vtidenti := vpersona.ctipide;

            IF reas.iimporte < 0 THEN
               xsigno := 'N';
            ELSE
               xsigno := 'P';
            END IF;

            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali, ctipseg, ccolect,   --nnumpet,
                         pfiscal, sseguro, spersonp, nnumnifp,   --tidentip, cdomicip, sperson1,
                                                              --nnumnif1, tidenti1, cdomici1,ctipo, ndocum, cestrec,
                                                              fpago, ibruto,
                         iresrcm, iresred,   --ibase,
                                          pretenc, iretenc, ineto, cpaisret, csubtipo,
                         csigbase,
--                               cprovin,
                                  ctipcap, sidepag)
                 VALUES (psfiscab, sfisdpa.NEXTVAL, vcramo, vcmodali, vctipseg, vccolect,   --pnumpet,
                         pany, NULL, vsperson, vnumnif,   --xtidentip, xcdomicip, xspersonr,
                                                       --xnnumnifr, xtidentir, xcdomicir,'REN', ren.srecren, 1,
                                                       reas.fliquida, reas.iimporte,
                         reas.iimporte, 0,   --ren.ibase,
                                          0, 0, reas.iimporte, vpais, 347,
                         xsigno,
--                               REPLACE(LPAD(xcprovinp, 2), ' ', '0'),
                         1, reas.spagrea);
         EXCEPTION
            WHEN OTHERS THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      RETURN 0;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL cierre_fis_reaseg', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
*/
      RETURN 0;
   END cierre_fis_reaseg;

   FUNCTION cierre_fis_coaseg(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      vtidenti       NUMBER;
      vsperson       NUMBER;
      vnumnif        VARCHAR2(14);
      vpais          NUMBER;
      vfnacimi       DATE;
      vfpeticion     DATE;
      vresul         NUMBER;
      vcontaerr      NUMBER := 0;
      vsproces       NUMBER;
      perror         NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      xsigno         CHAR(1);
/* Se comenta a la espera de subir los cambios de coaseguro
      CURSOR movcoaseguro IS
         SELECT   spagcoa, ccompani, sproduc, iimporte, cestado, fliquida, falta, cforpag,
                  ctipopag, nremesa, ftrans, ctipban, cbancar, sproces, iimporte_moncon,
                  fcambio
             FROM pagos_ctatec_coa
            WHERE TO_CHAR(fliquida, 'YYYY') = pany
              AND cempres = NVL(pempres, 1)
              AND cestado = 1   -- pagado
         ORDER BY spagcoa;
*/
   BEGIN
/* Se comenta a la espera de subir los cambios de coaseguro
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL COASEGURO', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      --Inserción de la tabla fis_detcierrepago
      FOR coas IN movcoaseguro LOOP
         BEGIN
            SELECT sperson
              INTO vsperson
              FROM companias
             WHERE ccompani = coas.ccompani;

            BEGIN
               SELECT pr.ctipseg, pr.ccolect, pr.cramo, pr.cmodali
                 INTO vctipseg, vccolect, vcramo, vcmodali
                 FROM productos pr
                WHERE pr.sproduc = coas.sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vctipseg := NULL;
                  vccolect := NULL;
                  vcramo := NULL;
                  vcmodali := NULL;
               WHEN OTHERS THEN
                  vcontaerr := vcontaerr + 1;
            END;

            vresult := pac_persona.f_get_dadespersona(vsperson, coas.ccompani, vpersona);
            vnumnif := vpersona.nnumide;
            vfnacimi := vpersona.fnacimi;
            vpais := vpersona.cpais;
            vtidenti := vpersona.ctipide;

            IF coas.iimporte < 0 THEN
               xsigno := 'N';
            ELSE
               xsigno := 'P';
            END IF;

            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali, ctipseg, ccolect,   --nnumpet,
                         pfiscal, sseguro, spersonp, nnumnifp,   --tidentip, cdomicip, sperson1,
                                                              --nnumnif1, tidenti1, cdomici1,ctipo, ndocum, cestrec,
                                                              fpago, ibruto,
                         iresrcm, iresred,   --ibase,
                                          pretenc, iretenc, ineto, cpaisret, csubtipo,
                         csigbase,
--                               cprovin,
                                  ctipcap, sidepag)
                 VALUES (psfiscab, sfisdpa.NEXTVAL, vcramo, vcmodali, vctipseg, vccolect,   --pnumpet,
                         pany, NULL, vsperson, vnumnif,   --xtidentip, xcdomicip, xspersonr,
                                                       --xnnumnifr, xtidentir, xcdomicir,'REN', ren.srecren, 1,
                                                       coas.fliquida, coas.iimporte,
                         coas.iimporte, 0,   --ren.ibase,
                                          0, 0, coas.iimporte, vpais, 347,
                         xsigno,
--                               REPLACE(LPAD(xcprovinp, 2), ' ', '0'),
                         1, coas.spagcoa);
         EXCEPTION
            WHEN OTHERS THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      RETURN 0;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL cierre_fis_coaseg', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
*/
      RETURN 0;
   END cierre_fis_coaseg;
-- Fin Bug 0023887
END pac_fiscierre;

/

  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "PROGRAMADORESCSI";
