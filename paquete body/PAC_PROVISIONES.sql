CREATE OR REPLACE PACKAGE BODY pac_provisiones IS
/******************************************************************************
   NOMBRE:     pac_provisiones
   PROP¿SITO:  C¿lculo de provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creaci¿n del package.
   2.0        15/09/2010   JRH                2. 0012278: Proceso de PB para el producto PEA.
   3.0        22/11/2010   JRH                3. 0012278: Proceso de PB para el producto PEA.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_provision_vigente(pcprovis IN NUMBER, pfcierre IN DATE, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_vigente      NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_vigente
        FROM codprovi_emp
       WHERE cprovis = pcprovis
         AND cempres = pcempres
         AND(fbaja IS NULL
             OR fbaja > pfcierre);

      RETURN v_vigente;
   END f_provision_vigente;

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
--    Proceso que lanzar¿ el proceso de cierre de provisiones
--
-- 15/9/04 CPM: Se a¿aden par¿metros a la llamada, aunque no son necesarios
--      para que sea compatible con el resto de cierres programados.
      CURSOR c1 IS
         SELECT   cp.tfunc, cp.cprovis, cp.ttabla
             FROM codprovi_emp ce, codprovisiones cp
            WHERE ce.cempres = pcempres
              AND(ce.fbaja IS NULL
                  OR ce.fbaja > pfcierre)
              AND ce.cprovis = cp.cprovis
              AND cp.tfunc IS NOT NULL
         ORDER BY cp.norden ASC;

      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      xmodo          VARCHAR2(1);
      v_func         VARCHAR2(4000);
      v_aux          VARCHAR2(40);
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Diario (empresa ' || pcempres || ')';
         xmodo := 'P';
      ELSE
         v_titulo := 'Proceso Cierre Mensual';
         xmodo := 'R';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'PROVISIONES', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Provisiones ' || texto || ' ' || text_error, 1, 120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         pcerror := 0;

         -- Ejecutamos provisiones t¿cnicas.
         -- La funciones en num_err, nos devuelven el n¿mero de errores que se han producido en el
         -- c¿lculo. Grabamos este n¿mero en el campo CERROR de CTRL_PROVIS.
         -- Ahora el c¿lculo de las provisiones PPNC y LDG se ejecuta a la vez, con lo cual s¿lo
         -- tenemos un registro de CTRL_PROVIS de control con el c¿digo 1

         --Bug.: 21715 - 21/03/2012 - ICV
         FOR rc IN c1 LOOP
            IF rc.ttabla IS NOT NULL THEN
               BEGIN
                  IF pmodo = 1 THEN   --Previo
                     v_aux := '_PREVIO';
                  ELSE
                     v_aux := NULL;
                  END IF;

                  v_func := 'DELETE FROM ' || rc.ttabla || v_aux
                            || ' r WHERE r.fcalcul = to_date(' || CHR(39) || pfperfin
                            || CHR(39) || ') AND r.cempres = ' || pcempres;

                  EXECUTE IMMEDIATE v_func;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'CIERRE PROVISIONES MAT PROCESO =' || psproces, NULL,
                                 'when others del delete del cierre =' || pfperfin, SQLERRM);
               END;
            END IF;

            v_func := ' BEGIN ' || CHR(10) || ':num_err := ' || rc.tfunc || '(' || pcempres
                      || ',to_date(' || CHR(39) || pfperfin || CHR(39) || '),' || psproces
                      || ',' || pcidioma || ',' || pmoneda || ',' || CHR(39) || xmodo
                      || CHR(39) || ');' || CHR(10) || ' END;';

            EXECUTE IMMEDIATE v_func
                        USING OUT num_err;

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, rc.cprovis, psproces, f_user, pcerror);

            COMMIT;
         END LOOP;
      END IF;

      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      pcerror := 0;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE PROVISIONES MAT PROCESO =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

   FUNCTION f_sproces(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      ptprovis IN VARCHAR2,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN VARCHAR2 IS
      vsproces       NUMBER;
      texto1         VARCHAR2(200);
      texto2         VARCHAR2(200);
      texto          VARCHAR2(200);
   BEGIN
      -- Si se ha pedido el listado Real se ha de buscar el sproces de la tabla CTRL_PROVIS
      IF NVL(pprevio, 1) = 2 THEN
         BEGIN
            SELECT MAX(sproces)
              INTO vsproces
              FROM ctrl_provis
             WHERE cempres = pempresa
               AND cprovis = pprovis
               AND fcalcul = pfecha;
         EXCEPTION
            WHEN OTHERS THEN
               vsproces := 0;
         END;
      END IF;

      IF (vsproces <> 0
          AND NVL(pprevio, 1) = 2)
         OR NVL(pprevio, 1) = 1 THEN
         -- si se ha pedido el listado Real
         IF NVL(pprevio, 1) = 2 THEN
            psproces := vsproces;
         ELSE   -- si se ha pedido el listado Previo
            IF pprovis = 1 THEN   -- Si la provisi¿n es PPNC
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM ppnc_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 99 THEN   -- Si la provisi¿n es PM
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM provmat_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 8 THEN   -- Si la provisi¿n es PTPPLP
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM ptpplp_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 9 THEN   -- Si la provisi¿n es PTIBNR
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM ibnr_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 10 THEN   -- Si la provisi¿n es PESTAB
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM pestab_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 11 THEN   -- Si la provisi¿n es PTPBEX
               -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.--Nueva tabla
                  -- El sproces es el mismo que si se ha pedido el listado Real
                  /*BEGIN
                     SELECT MAX(sproces)
                       INTO vsproces
                       FROM ctrl_provis
                      WHERE cempres = pempresa
                        AND cprovis = pprovis
                        AND fcalcul = pfecha;
                  EXCEPTION
                     WHEN OTHERS THEN
                        vsproces := 0;
                  END;*/
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM pbex_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            -- Fi BUG 12278 -  09/2010 - JRH
            ELSIF pprovis = 12 THEN   -- Si la provisi¿n es PPPC
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM pppc_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            ELSIF pprovis = 13 THEN   -- Si la provisi¿n es LDG
               BEGIN
                  SELECT MAX(sproces)
                    INTO vsproces
                    FROM ppnc_previo
                   WHERE cempres = pempresa
                     AND fcalcul = pfecha;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsproces := 0;
               END;
            END IF;

            psproces := vsproces;
         END IF;

         texto := NULL;
      ELSE
         texto1 := f_axis_literales(pcidioma, 107238);   -- No existe informaci¿n de la provisi¿n
         texto2 := f_axis_literales(pcidioma, 107239);   -- para la fecha
         texto := texto1 || ' ' || ptprovis || ' ' || texto2 || ' '
                  || TO_CHAR(pfecha, 'dd/mm/yyyy');
      END IF;

      RETURN texto;
   END f_sproces;

   /*************************************************************************
      Recupera todas las provisiones existentes seg¿n la empresa seleccionada
      param in pempresa  : c¿digo de empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_emp(pempresa IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pempresa: ' || pempresa || ';pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Get_Provisiones_Emp';
      squery         VARCHAR2(1000);
   BEGIN
      --Bug 21715 - APD - 02/07/2012 - primero se mira si hay alg¿n map especifico por empresa
      -- (codprovi_emp.cmapead), sino existe ning¿n map, se busca el map definido de forma
      -- general (codprovisiones.cmapead)
      squery :=
         'SELECT c.cprovis cprovis, NVL(ce.cmapead,c.cmapead) cmapead, '
         || 'd.tcprovis tcprovis, d.tlprovis tlprovis, d.cidioma cidioma, trunc(ce.falta) falta, '
         || 'max(fcalcul) fcalculo, max(trunc(fmodifi)) flanzamiento '
         || ' FROM codprovi_emp ce, codprovisiones c, desprovisiones d, ctrl_provis cp '
         || ' WHERE c.cprovis = ce.cprovis ' || ' AND c.cprovis = d.cprovis '
         || ' AND cp.cempres(+) = ce.cempres ' || ' AND cp.cprovis(+) = ce.cprovis '
         || ' AND ce.cempres = ' || pempresa || ' AND ce.fbaja IS NULL ' || ' AND cidioma =  '
         || pcidioma
         || ' GROUP BY c.cprovis, ce.cmapead, c.cmapead, d.tcprovis, d.tlprovis, d.cidioma, ce.falta '
         || ' ORDER BY cprovis';
      --fin Bug 21715 - APD - 02/07/2012
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_provisiones_emp;

   /*************************************************************************
      Recupera todas las provisiones existentes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones(pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Get_Provisiones';
      squery         VARCHAR2(1000);
   BEGIN
      squery :=
         'SELECT c.cprovis cprovis, c.tipoprov tipoprov, d.tcprovis tcprovis, d.tlprovis tlprovis, d.cidioma cidioma, c.creport creport '
         || 'FROM codprovisiones c, desprovisiones d ' || 'WHERE c.cprovis = d.cprovis '
         || 'AND cidioma = ' || pcidioma || 'ORDER BY cprovis';
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_provisiones;

   /*************************************************************************
      Recupera todas las provisiones existentes y muestra el c¿digo de la nueva provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_nueva(pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Get_Provisiones_Nueva';
      squery         VARCHAR2(1000);
   BEGIN
      squery :=
         'SELECT c.cprovis cprovis, c.tipoprov tipoprov, d.tcprovis tcprovis, d.tlprovis tlprovis, d.cidioma cidioma, c.creport creport '
         || 'FROM codprovisiones c, desprovisiones d ' || 'WHERE c.cprovis = d.cprovis '
         || 'AND cidioma = ' || pcidioma || ' UNION '
         || 'SELECT decode(max(c.cprovis)+1,99,100,max(c.cprovis)+1) cprovis, null tipoprov, null tcprovis, null tlprovis, null cidioma, null creport '
         || 'FROM codprovisiones c ' || 'WHERE cprovis <> 99 ' || 'ORDER BY cprovis';
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_provisiones_nueva;

   /*************************************************************************
      Recupera todas las descripciones de una provisi¿n en los diferentes idiomas que exista
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desprovisiones(pprovis IN NUMBER)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Get_DesProvisiones';
      squery         VARCHAR2(1000);
   BEGIN
      squery :=
         'SELECT d.cidioma cidioma, i.tidioma tidioma, d.tcprovis tcprovis, d.tlprovis tlprovis'
         || ' FROM desprovisiones d, idiomas i' || ' WHERE d.cidioma = i.cidioma'
         || '  AND d.cprovis = ' || pprovis || ' UNION'
         || ' SELECT i.cidioma, i.tidioma, null, null' || ' FROM idiomas i'
         || ' WHERE i.cidioma not in (select cidioma from desprovisiones where cprovis = '
         || pprovis || ')' || ' ORDER BY cidioma';
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_desprovisiones;

   /*************************************************************************
      Actualiza o inserta una provisi¿n
      param in pempresa  : c¿digo de empresa
      param in pprovis   : c¿digo de la provision
      param in pfbaja    : fecha de baja de la provisi¿n
      param in ptipoprov : c¿digo del tipo de provisi¿n
      param in pcreport  : Nombre del listado de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_provisiones(
      pempresa IN NUMBER,
      pprovis IN NUMBER,
      pfbaja IN DATE,
      ptipoprov IN NUMBER,
      pcreport IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ';pprovis: ' || pprovis || ';pfbaja: ' || pfbaja
            || ';ptipoprov: ' || ptipoprov || ';pcreport: ' || pcreport;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Grabar_Provisiones';
      vcount         NUMBER;
   BEGIN
      --Se busca si la provisi¿n ya existe para la empresa seleccionada
      SELECT COUNT(1)
        INTO vcount
        FROM codprovi_emp ce
       WHERE ce.cempres = pempresa
         AND ce.cprovis = pprovis;

      IF vcount <> 0 THEN   -- existe la provisi¿n para la empresa seleccionada
         -- Se est¿ modificando una provisi¿n
         UPDATE codprovi_emp
            SET fbaja = pfbaja
          WHERE cempres = pempresa
            AND cprovis = pprovis;

         UPDATE codprovisiones
            SET tipoprov = ptipoprov,
                creport = LOWER(pcreport)
          WHERE cprovis = pprovis;

         COMMIT;
      ELSE   -- no existe la provisi¿n para la empresa seleccionada
         -- Se est¿ dando de alta una provisi¿n
         INSERT INTO codprovi_emp
                     (cempres, cprovis, falta, fbaja)
              VALUES (pempresa, pprovis, TRUNC(f_sysdate), pfbaja);

         BEGIN
            -- La provisi¿n no existe
            INSERT INTO codprovisiones
                        (cprovis, tipoprov, creport, cmapead)
                 VALUES (pprovis, ptipoprov, LOWER(pcreport), NULL);
         EXCEPTION
            WHEN OTHERS THEN
               -- La provisi¿n ya exist¿a
               UPDATE codprovisiones
                  SET tipoprov = ptipoprov,
                      creport = LOWER(pcreport)
                WHERE cprovis = pprovis;
         END;

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RETURN 1;
   END f_grabar_provisiones;

   /*************************************************************************
      Actualiza o inserta una descripci¿n de provisi¿n
      param in pprovis   : c¿digo de la provision
      param in pcidioma  : idioma de la descripci¿n de la provisi¿n
      param in ptcprovis : descripci¿n corta de la provisi¿n
      param in ptlprovis : descripci¿n larga de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_desprovisiones(
      pprovis IN NUMBER,
      pcidioma IN NUMBER,
      ptcprovis IN VARCHAR2,
      ptlprovis IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pprovis: ' || pprovis || ';pcidioma: ' || pcidioma || ';ptcprovis: ' || ptcprovis
            || ';ptlprovis: ' || ptlprovis;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Grabar_DesProvisiones';
      vcount         NUMBER;
   BEGIN
      --Se busca si la descripci¿n de la provisi¿n ya existe
      SELECT COUNT(1)
        INTO vcount
        FROM desprovisiones d
       WHERE d.cprovis = pprovis
         AND d.cidioma = pcidioma;

      IF vcount <> 0 THEN   -- existe la provisi¿n para la empresa seleccionada
         -- Se est¿ modificando una descripci¿n de provisi¿n
         UPDATE desprovisiones
            SET tcprovis = ptcprovis,
                tlprovis = ptlprovis
          WHERE cprovis = pprovis
            AND cidioma = pcidioma;

         COMMIT;
      ELSE   -- no existe la provisi¿n para la empresa seleccionada
         -- Se est¿ dando de alta una descripci¿n de provisi¿n
         INSERT INTO desprovisiones
              VALUES (pcidioma, pprovis, ptcprovis, ptlprovis);

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RETURN 1;
   END f_grabar_desprovisiones;

   /*************************************************************************
      Valida si una provisi¿n ya existe para la empresa seleccionada
      param in pempresa  : c¿digo de la empresa
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_validar_provision(pprovis IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_PROVISIONES.F_Validar_Provision';
      vcount         NUMBER;
   BEGIN
      --Se busca si la provisi¿n ya existe
      SELECT COUNT(1)
        INTO vcount
        FROM codprovisiones
       WHERE cprovis = pprovis;

      IF vcount <> 0 THEN   -- existe la provisi¿n para la empresa seleccionada
         RETURN 1;
      ELSE   -- no existe la provisi¿n para la empresa seleccionada
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_validar_provision;

       /**********************************************************************
      FUNCTION F_GRABAR_EXCLUSIONES
      Funci¿n que almacena los datos de la exclusion.
      Firma (Specification)
      Param IN pnpoliza    : npoliza
      Param IN pnrecibo    : nrecibo
	    Param IN pcobservexc : cobservexc
	    Param IN pcprovisi   : cprovisi
	    Param IN pcobservp   : pcobservp
	    Param IN pcnprovisi  : pcnprovisi
	    Param IN pcobservnp  : pcobservnp
	    Param IN pfalta      : pfalta
	    Param IN pfbaja      : pfbaja
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
    **********************************************************************/
    FUNCTION f_grabar_exclusiones(
         pnpoliza IN NUMBER,
         pnrecibo IN NUMBER,
	    pcobservexc IN VARCHAR2,
	      pcprovisi IN NUMBER,
	      pcobservp IN VARCHAR2,
	     pcnprovisi IN NUMBER,
	     pcobservnp IN VARCHAR2,
	         pfalta IN DATE,
	         pfbaja IN DATE,
         mensajes IN OUT T_IAX_MENSAJES )
         RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vnumerr    NUMBER;

       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM EXCLUS_PROVISIONES
         WHERE npoliza = pnpoliza
           AND nrecibo = pnrecibo;

        IF v_existe = 0 THEN
          INSERT INTO EXCLUS_PROVISIONES
                      (npoliza, nrecibo, cobservexc, cprovisi, cobservp,
                       cnprovisi, cobservnp, falta, fbaja)
               VALUES (pnpoliza, pnrecibo, pcobservexc, pcprovisi, pcobservp,
                       pcnprovisi, pcobservnp, pfalta, pfbaja);

          INSERT INTO HIS_EXCLUS_PROVISIONES
                      (npoliza, nrecibo, cobservexc, cprovisi, cobservp,
                      cnprovisi, cobservnp, falta, fbaja, cusualt,
                      cusumod, fusumod)
               VALUES (pnpoliza, pnrecibo, pcobservexc, pcprovisi, pcobservp,
                      pcnprovisi, pcobservnp, pfalta, pfbaja, f_user,
                      f_user, f_sysdate);

        END IF;


        IF v_existe = 1 THEN
         UPDATE EXCLUS_PROVISIONES
            SET cobservexc = pcobservexc,
                  cprovisi = pcprovisi,
                  cobservp = pcobservp,
                 cnprovisi = pcnprovisi,
                 cobservnp = pcobservnp,
                     falta = pfalta,
                     fbaja = pfbaja
          WHERE    npoliza = pnpoliza
            AND    nrecibo = pnrecibo;

          UPDATE HIS_EXCLUS_PROVISIONES
            SET cobservexc = pcobservexc,
                  cprovisi = pcprovisi,
                  cobservp = pcobservp,
                 cnprovisi = pcnprovisi,
                 cobservnp = pcobservnp,
                     falta = pfalta,
                     fbaja = pfbaja,
                   cusualt = f_user,
                   cusumod = f_user,
                   fusumod = f_sysdate
          WHERE    npoliza = pnpoliza
            AND    nrecibo = pnrecibo;
        END IF;
        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
           RETURN 1;
      END f_grabar_exclusiones;


   /**********************************************************************
      FUNCTION F_DEL_EXCLUSIONES
      Funci¿n que elimina de la exclusion por numero de poliza
      Param IN pnpoliza : npoliza
      Param IN pnrecibo : nrecibo
     **********************************************************************/
      FUNCTION f_del_exclusiones(
        pnpoliza IN exclus_provisiones.npoliza%TYPE,
        pnrecibo IN exclus_provisiones.nrecibo%TYPE)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'pnpoliza = ' || pnpoliza;
        terror         VARCHAR2(2000);
        vobject        VARCHAR2(200) := 'PAC_PROVISIONES.f_del_exclusiones';
        num_err        axis_literales.slitera%TYPE := 0;
         BEGIN
            DELETE FROM exclus_provisiones
                  WHERE  npoliza = pnpoliza
                    AND  nrecibo = pnrecibo;

          --  DELETE FROM his_exclus_provisiones
          --        WHERE  npoliza = pnpoliza
          --          AND  nrecibo = pnrecibo;

            --COMMIT;
            RETURN num_err;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
      END f_del_exclusiones;


   /**********************************************************************
      FUNCTION F_GET_EXCLUSIONES
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pcsucursal  : csucursal
      Param IN  pfdesde     : fdesde
      Param IN  pfhasta     : fhasta
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param IN  pnit        : nit
      Param IN  pnnumide    : nnumide
      Param IN  pcagente    : cagente
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
    FUNCTION f_get_exclusiones(
        pcsucursal IN NUMBER,
           pfdesde IN DATE,
           pfhasta IN DATE,
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
              pnit IN NUMBER,
          pnnumide IN VARCHAR2,
          pcagente IN NUMBER)
          RETURN VARCHAR2 IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(200) := 'pcsucursal: ' || pcsucursal || ' pfdesde: ' || pfdesde || ' pfhasta: ' || pfhasta
                                           || ' pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo || ' pnit: ' || pnit
                                           || ' pnnumide: ' || pnnumide || ' pcagente: ' || pcagente;
          vobject        VARCHAR2(200) := 'PAC_PROVISIONES.f_get_exclusiones';
          squery         VARCHAR2(1000);
       BEGIN

          squery :=
                ' SELECT ep.npoliza, ep.nrecibo, ep.cobservexc, ff_desvalorfijo(8001174, 8,ep.cprovisi) AS CPROVISI, ep.cobservp, '
             || ' ff_desvalorfijo(8001175, 8,ep.cnprovisi) AS CNPROVISI, ep.COBSERVNP, ep.falta, ep.fbaja, s.npoliza, '
             || ' r.nrecibo,r.cdelega ||'' - '' ||f_desagente_T(r.cdelega) tdelega,r.cagente ||'' - ''||f_desagente_T(r.cagente) tagente, '
             || ' f_nombre(t.sperson, 1,s.cagente) ntomador '
             || ' FROM exclus_provisiones ep, recibos r, seguros s,per_personas pp ,tomadores t,vdetrecibos v,agentes aa '
             || ' WHERE r.sseguro = s.sseguro '
             || ' and pp.sperson = t.sperson '
             || ' and t.sseguro = s.sseguro '
             || ' and ep.npoliza= s.npoliza '
             || ' and ep.nrecibo= r.nrecibo '
             || ' and t.nordtom in (select min(tt.nordtom) from tomadores tt where tt.sseguro = t.sseguro) '
             || ' and r.nrecibo = v.nrecibo '
             || ' and s.cagente = aa.cagente '
             || ' and s.cempres = 24 ';
            
			 -- INI - AXIS 3951 - ML - 10/5/2019 - EL FILTRO DE FECHAS TOMA DESDE: FALTA Y HASTA: FBAJA
             IF pfdesde IS NOT NULL THEN 
               squery := squery || ' and ep.falta >= ''' || pfdesde || '''';
             END IF;
             IF pfhasta IS NOT NULL THEN 
               squery := squery || ' and ep.fbaja <= ''' || pfhasta || '''';
             END IF;
            -- FIN - AXIS 3951 - ML - 10/5/2019 - EL FILTRO DE FECHAS TOMA DESDE: FALTA Y HASTA: FBAJA
                          
             IF pnpoliza IS NOT NULL THEN
               squery := squery || ' and ep.npoliza = ' || pnpoliza;
             END IF;

             IF pnrecibo IS NOT NULL THEN
               squery := squery  || ' and ep.nrecibo = ' || pnrecibo;
             END IF;

            -- INI BUG - AXIS 3951 - ML - 10/5/2019 - nnumide debe estar entre comillas
             IF pnnumide IS NOT NULL THEN
               squery := squery  || ' and pp.nnumide = ''' || pnnumide || '''';
             END IF;
            -- FIN BUG - AXIS 3951 - ML - 10/5/2019 - nnumide debe estar entre comillas

             IF pcagente IS NOT NULL THEN
               squery := squery  || ' and aa.cagente = ' || pcagente;
             END IF;

             IF pcsucursal IS NOT NULL THEN
               squery := squery  || ' and pac_agentes.f_get_cageliq(24, 2, aa.cagente) = ' || pcsucursal;
             END IF;

          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;
       END f_get_exclusiones;


    /**********************************************************************
      FUNCTION F_GET_EXCLUSIONESBYPK
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
       FUNCTION f_get_exclusionesbypk(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER)
          RETURN VARCHAR2 IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
          vobject        VARCHAR2(200) := 'PAC_PROVISIONES.f_get_exclusionesbypk';
          squery         VARCHAR2(1000);
       BEGIN



          squery :=
                ' SELECT ep.npoliza, ep.nrecibo, ep.cobservexc, ep.cprovisi, ep.cobservp, '
             || ' ep.cnprovisi, ep.COBSERVNP, ep.falta, ep.fbaja,'
             || '(select SSEGURO from recibos where nrecibo = ep.nrecibo and rownum = 1) as SSEGURO, '
             || '(select NMOVIMI from recibos where nrecibo = ep.nrecibo and rownum = 1) as NMOVIMI '
             || ' FROM exclus_provisiones ep '
             || ' WHERE ep.npoliza = ' || pnpoliza
             || ' and ep.nrecibo = ' || pnrecibo;


          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;
       END f_get_exclusionesbypk;

     /**********************************************************************
      FUNCTION F_GET_EXISTEPOLIZARECIBO
      Funci¿n que retorna si existe o no poliza y recibo
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_existepolizarecibo(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER)
          RETURN VARCHAR2 IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
          vobject        VARCHAR2(200) := 'PAC_PROVISIONES.f_get_existepolizarecibo';
          squery         VARCHAR2(1000);
       BEGIN

          squery :=
                ' SELECT count(*) as EXISTE '
             || ' FROM recibos r, seguros s,per_personas pp ,tomadores t,vdetrecibos v,agentes aa '
             || ' WHERE r.sseguro= s.sseguro '
             || ' and pp.sperson = t.sperson '
             || ' and t.sseguro = s.sseguro '
             || ' and t.nordtom in (select min(tt.nordtom) from tomadores tt where tt.sseguro = t.sseguro) '
             || ' and r.nrecibo = v.nrecibo '
             || ' and s.cagente = aa.cagente '
             || ' and s.cempres = 24 '
             || ' and s.npoliza = ' || pnpoliza
             || ' and r.nrecibo = ' || pnrecibo;


          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;
       END f_get_existepolizarecibo;
END;