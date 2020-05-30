
CREATE OR REPLACE PACKAGE BODY "PAC_SIN_IMP_SAP" AS
/******************************************************************************
   NOMBRE:    pac_sin_imp_sap
   PROP¿SITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
    2.0       18/01/2019   WAJ             Insertar codigo impuesto segun tipo de vinculacion
	3.0		  25/06/2019   SWAPNIL	       Cambios de Iaxis-4521
******************************************************************************/
   FUNCTION f_get_lstimpuestos(pcempres IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_imp_sap.f_get_lstimpuestos';
      vparam         VARCHAR2(200)
         := 'par¿metros - pcempres=' || pcempres || ' pcidioma: ' || pcidioma || ' ptselect: '
            || ptselect;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT c.ccodimp, d.tdesimp
                      FROM sin_imp_codimpuesto c, sin_imp_desimpuesto d
                     WHERE c.ccodimp = d.ccodimp
					    and c.ccodimp not in (1)
                       AND d.cidioma = '
         || pcidioma || ' ORDER by c.nordcal';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_lstimpuestos;

   /*************************************************************************
    Devuelve los tipos de indicador para el impuesto indicado
   *************************************************************************/
   FUNCTION f_get_tipos_indicador(pccodimp IN NUMBER, pcarea IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_imp_sap.f_get_tipos_indicador';
      vparam         VARCHAR2(200) := 'par¿metros - pccodimp=' || pccodimp;
   BEGIN
      IF pccodimp = 4 THEN
         ptselect :=
     'SELECT p.tpoblac || '' - '' || i.tindica tindica, i.ctipind
        FROM   tipos_indicadores i, tipos_indicadores_det d, poblaciones p WHERE d.ctipind = i.ctipind
        AND cimpret = 4 AND carea = ' || pcarea || ' AND p.cprovin = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),1,2))
        AND p.cpoblac = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),3,3))
        order by p.tpoblac';
      ELSE
         vtraza := 1;
          ptselect :=
            'SELECT t.tindica, t.ctipind,  d.porcent
                       FROM   tipos_indicadores t, tipos_indicadores_det d
                       WHERE  t.cimpret = '
            || pccodimp || ' AND t.carea = ' || pcarea || ' AND t.CTIPIND =  d.CTIPIND
            order by t.tindica';

	END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_tipos_indicador;
--IAXIS 7655 AABC Conceptos tiquetes aereos
   /*************************************************************************
    Devuelve los tipos de conceptos de tiquetes aereos
   *************************************************************************/
   FUNCTION f_get_concep_pago(pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_imp_sap.f_get_concep_pago';
      vparam         VARCHAR2(200) := 'par¿metros - pcidioma=' || pcidioma;
   BEGIN
      ptselect :=
        'SELECT catribu,tatribu 
           FROM detvalores  
          WHERE cvalor = 8002028 
            AND cidioma = ' || pcidioma || '
          ORDER BY tatribu ASC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_concep_pago;
--IAXIS 7655 AABC Conceptos tiquetes aereos   
     /*************************************************************************
            Relaciona al profesional con el impuesto indicado
   *************************************************************************/
   FUNCTION f_set_impuesto_prof(psprofes IN NUMBER, pccodimp IN NUMBER, pctipind IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_imp_sap.f_set_impuesto_prof';
      vparam         VARCHAR2(500)
                       := 'par¿metros - psprofes: ' || psprofes || ' - pctipind: ' || pctipind;
      vpasexec       NUMBER := 0;
      vcregfiscal    per_regimenfiscal.cregfiscal%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      v_host         VARCHAR2(10);
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
      v_nerror       NUMBER;
      vsperson       per_personas.sperson%TYPE;
	  
	  /* Cambios de Iaxis-4521 : start */
      VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	  /* Cambios de Iaxis-4521 : end */	
	  
   BEGIN
      SELECT sperson
        INTO vsperson
        FROM sin_prof_profesionales
       WHERE sprofes = psprofes;

      vpasexec := 1;

      BEGIN
         SELECT cregfiscal
           INTO vcregfiscal
           FROM per_regimenfiscal r
          WHERE r.sperson = vsperson
            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9906614;
      END;

   /* Cambios de Iaxis-4521 : start */	
      BEGIN
        SELECT PP.NNUMIDE,PP.TDIGITOIDE
          INTO VPERSON_NUM_ID,VDIGITOIDE
          FROM PER_PERSONAS PP
         WHERE PP.SPERSON = VSPERSON
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT PP.CTIPIDE
            INTO VCTIPIDE
            FROM PER_PERSONAS PP
           WHERE PP.SPERSON = VSPERSON;
          VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                         UPPER(VPERSON_NUM_ID));
      END;
   /* Cambios de Iaxis-4521 : end */    	  
	  
      vpasexec := 2;
      vcregfiscal := NULL;

      IF pccodimp = 2   --RETEFUENTE
                     THEN
         BEGIN
            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = vsperson
               AND r.cregfiscal = 5
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL THEN
            RETURN 9906613;
         END IF;
      END IF;

      vpasexec := 3;

      IF pccodimp = 3   --RETEIVA
                     THEN
         BEGIN
            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = vsperson
               AND r.cregfiscal IN(4, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL THEN
            RETURN 9906613;
         END IF;
      END IF;

      vpasexec := 4;

      INSERT INTO sin_prof_indicadores
                  (sprofes, ctipind)
           VALUES (psprofes, pctipind);

      COMMIT;
      vpasexec := 5;
      v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'ALTA_PROV_HOST');
      vpasexec := 6;

      IF v_host IS NOT NULL THEN
         IF pac_persona.f_gubernamental(vsperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_ACREEDOR_HOST');
         END IF;

         vpasexec := 7;
         v_nerror := pac_user.f_get_terminal(f_user, vcterminal);
         vpasexec := 8;
   /* Cambios de Iaxis-4521 : start */		 
         v_nerror := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, vsperson,
                                            vcterminal, vsinterf, vterror,
                                            pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                            v_host);
   /* Cambios de Iaxis-4521 : end */											
         vpasexec := 9;

         IF v_nerror <> 0 THEN
            RETURN v_nerror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_impuesto_prof;

/*************************************************************************
         Elimina la relaci¿n del profesional con el impuesto indicado
*************************************************************************/
   FUNCTION f_del_impuesto_prof(psprofes IN NUMBER, pctipind IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_imp_sap.f_del_impuesto_prof';
      vparam         VARCHAR2(500)
                       := 'par¿metros - psprofes: ' || psprofes || ' - pctipind: ' || pctipind;
      vpasexec       NUMBER := 0;
   BEGIN
      DELETE FROM sin_prof_indicadores
            WHERE sprofes = psprofes
              AND ctipind = pctipind;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_impuesto_prof;

/*************************************************************************
      Recupera los impuestos/retenciones para un profesional dado
*************************************************************************/
   FUNCTION f_get_indicador_prof(
      pcconpag IN NUMBER,
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pfordpag IN DATE,
      pnsinies IN sin_tramita_localiza.nsinies%TYPE,
      pntramit IN sin_tramita_localiza.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_imp_sap.f_get_indicador_prof';
      vparam         VARCHAR2(200)
         := 'par¿metros -  pcconpag=' || pcconpag || ' psprofes=' || psprofes || ' pfordpag='
            || pfordpag || ' pccodimp=' || pccodimp || ' pnlocali=' || pnlocali;
      vcpostal       NUMBER;
      vcuenta        NUMBER;
      vfordpag       VARCHAR2(10);
      vcregfiscal    per_regimenfiscal.cregfiscal%TYPE;
      vcprovin       sin_tramita_localiza.cprovin%TYPE;
      vcpoblac       sin_tramita_localiza.cpoblac%TYPE;
   BEGIN
      IF pcconpag <> -1 THEN
         SELECT COUNT(*)
           INTO vcuenta
           FROM sin_imp_conceptos
          WHERE cconpag = pcconpag;

         IF vcuenta = 0 THEN   -- Este concepto de pago no tiene que cobrar impuestos
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind FROM dual';
            RETURN 0;
         END IF;
      END IF;

      vfordpag := TO_CHAR(pfordpag, 'DD/MM/YYYY');

      -- Bug 24637 - 15/07/2014 - JTT: En funcion de la fiscalidad no hay que cargar porcentajes de RETEIVA ni RETEFUENTE
      IF pccodimp = 2 THEN   --RETEFUENTE
         BEGIN
            vtraza := 1;

            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = (SELECT sperson
                                  FROM sin_prof_profesionales
                                 WHERE sprofes = psprofes)
               AND r.cregfiscal = 5
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL THEN
            ptselect :=
               'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind
                         FROM dual';
            RETURN 0;
         END IF;
      END IF;

      IF pccodimp = 3 THEN   --RETEIVA
         BEGIN
            vtraza := 2;

            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = (SELECT sperson
                                  FROM sin_prof_profesionales
                                 WHERE sprofes = psprofes)
               AND r.cregfiscal IN(4, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL THEN
            ptselect :=
               'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind
                         FROM dual';
            RETURN 0;
         END IF;
      END IF;

      -- Fi Bug 24637
      IF pccodimp = 4 THEN   -- RETEICA
         vtraza := 3;

         SELECT cpostal, cprovin, cpoblac
           INTO vcpostal, vcprovin, vcpoblac
           FROM sin_tramita_localiza
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nlocali = pnlocali;

         vtraza := 4;

         --INICIO - BUG38575 - DCT - 11/11/2015
         --Si el campo cpostal de la tabla sin_tramita_localiza esta NULL debemos obtener su valor a traves de la provincia y la poblaci¿n.
         IF vcpostal IS NULL THEN
            SELECT cpostal
              INTO vcpostal
              FROM codpostal
             WHERE cprovin = vcprovin
               AND cpoblac = vcpoblac;
         END IF;

         --FIN - BUG38575 - DCT - 11/11/2015
         SELECT COUNT(*)
           INTO vcuenta
           FROM tipos_indicadores_det
          WHERE cpostal = vcpostal;

         IF vcuenta = 0 THEN   -- Es una ciudad que no cobra ICA
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind FROM dual';
            RETURN 0;   -- Bug 24637 - 19/08/2014 - JTT
         END IF;

         vtraza := 5;

         SELECT COUNT(*)
           INTO vcuenta
           FROM tipos_indicadores i, sin_prof_indicadores p
          WHERE cimpret = 4
            AND p.ctipind = i.ctipind
            AND sprofes = psprofes;

         IF vcuenta = 0 THEN
            RETURN 9906572;   -- Falta definir retenciones/impuestos para el profesional
         END IF;

         vtraza := 6;
         -- Bug 24637 - 15/07/2014 - JTT: Se a¿ade en la consulta la tabla SIN_TRAMITA_LOCALIZA
         ptselect :=
            'SELECT p.tpoblac || '' - '' || i.tindica tindica, d.porcent, i.ctipind
        FROM   tipos_indicadores i, tipos_indicadores_det d, poblaciones p, sin_tramita_localiza l, codpostal cp
        WHERE d.ctipind = i.ctipind
        AND d.fvigor = (SELECT MAX(fvigor) FROM tipos_indicadores_det d1 WHERE d1.ctipind = d.ctipind AND d1.fvigor <= TO_DATE(
        '''
            || vfordpag || ''' , ''DD/MM/YYYY''))'
            || ' AND cimpret = 4 AND carea = 3
        AND p.cprovin = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),1,2))
        AND p.cpoblac = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),3,3))
        AND i.ctipind IN (SELECT ctipind FROM sin_prof_indicadores WHERE sprofes = '
            || psprofes || ')
        AND l.nsinies = ' || pnsinies || '
        AND l.ntramit = ' || pntramit || '
        AND l.nlocali = ' || pnlocali
            || '
        AND d.cpostal = cp.cpostal
        AND l.cprovin = cp.cprovin
        AND l.cpoblac = cp.cpoblac';
      ELSE
         vtraza := 7;

         SELECT COUNT(*)
           INTO vcuenta
           FROM tipos_indicadores i, sin_prof_indicadores p
          WHERE cimpret = pccodimp
            AND p.ctipind = i.ctipind
            AND sprofes = psprofes;

         IF vcuenta = 0 THEN
            RETURN 9906572;   -- Falta definir retenciones/impuestos para el profesional
         END IF;

         vtraza := 8;
         ptselect :=
            'SELECT tindica, porcent, i.ctipind
                       FROM   tipos_indicadores i, tipos_indicadores_det d
                       WHERE  cimpret = '
            || pccodimp
            || ' and d.ctipind = i.ctipind
             AND d.fvigor = (SELECT MAX(fvigor) FROM tipos_indicadores_det d1 WHERE d1.ctipind = d.ctipind AND d1.fvigor <= '
            || 'TO_DATE( ''' || vfordpag || ''' , ''DD/MM/YYYY''))'
            || ' AND  carea = 3 AND i.ctipind IN (SELECT ctipind FROM sin_prof_indicadores WHERE sprofes = '
            || psprofes || ')';
      END IF;

      -- Bug 24637 - 19/08/2014 - JTT: Para ReteIVA y ReteICA se a¿ade la opci¿n de 0% - SIN RETENCION a la
      -- lista recuperada.
      IF pccodimp IN(3, 4) THEN   -- RETEIVA, RETEICA
         ptselect :=
            ptselect
            || '
                UNION
                SELECT ''0% Sin retenci¿n'' tindica, 0 porcent, -1 ctipind
                  FROM DUAL
                ORDER BY porcent';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam || 'ptselect = ' || ptselect,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_indicador_prof;

/*************************************************************************
         Elimina la relaci¿n del profesional con el impuesto indicado
*************************************************************************/
   FUNCTION f_graba_log(psprofes IN NUMBER, pctipind IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_imp_sap.f_graba_log';
      vparam         VARCHAR2(500)
                       := 'par¿metros - psprofes: ' || psprofes || ' - pctipind: ' || pctipind;
      vpasexec       NUMBER := 0;
   BEGIN
--      INSERT INTO sin_imp_log
--      VALUES (psidepag, );
--
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_graba_log;
     --INI--WAJ
    /*************************************************************************
            Relaciona el vinculo de la persona con el impuesto indicado
   *************************************************************************/
   FUNCTION f_set_impuesto_per(pccodvin IN NUMBER, pccatribu IN NUMBER, pctipind IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS

      vparam         VARCHAR2(500)
                       := 'par¿metros - pccodvin: ' || pccodvin || ' - pctipind: ' || pctipind;
      vobjectname    VARCHAR2(500) := 'pac_sin_imp_sap.f_set_impuesto_per';
      vpasexec       NUMBER := 0;
      vcregfiscal    per_regimenfiscal.cregfiscal%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      v_host         VARCHAR2(10);
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
      v_nerror       NUMBER;
      vsperson       per_personas.sperson%TYPE;
      usuario number;
	  x_sprofes number;
	  x_ccompani number;
	  num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
	  
	  /* Cambios de Iaxis-4521 : start */
      VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	  /* Cambios de Iaxis-4521 : end */		  

   BEGIN

   usuario := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'));

    insert into per_indicadores (CODVINCULO, CODSUBVINCULO, SPERSON, CTIPIND, FALTA, CUSUALTA)
          values (pccodvin, pccatribu, psperson, pctipind, sysdate, pac_md_common.f_get_cxtusuario);
          commit;
		  
  /* Cambios de Iaxis-4521 : start */	
      BEGIN
        SELECT PP.NNUMIDE,PP.TDIGITOIDE
          INTO VPERSON_NUM_ID,VDIGITOIDE
          FROM PER_PERSONAS PP
         WHERE PP.SPERSON = psperson
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT PP.CTIPIDE
            INTO VCTIPIDE
            FROM PER_PERSONAS PP
           WHERE PP.SPERSON = psperson;
          VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                         UPPER(VPERSON_NUM_ID));
      END;
   /* Cambios de Iaxis-4521 : end */  		  

	 if pccodvin in (2,7) then
            begin
                select sprofes
                      into x_sprofes
                from sin_prof_profesionales
                where sperson = psperson;
                exception when no_data_found then
                   x_sprofes := 0;
            end;

            if x_sprofes > 0 then
              insert into sin_prof_indicadores (sprofes,ctipind, falta, cusualta, cusumod)
                 values (x_sprofes, pctipind, sysdate, pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtusuario);
                 commit;
            end if;
         end if;

         if pccodvin = 4 then
            begin
                select ccompani
                      into x_ccompani
                from companias
                where sperson = psperson;
                exception when no_data_found then
                   x_ccompani := 0;
            end;

             if x_ccompani > 0 then
              insert into indicadores_cias(ccompani,ctipind, nvalor, finivig, ffinvig, cenviosap, caplica, ffalta, fbaja, cusualta, cusumod)
                 values (x_ccompani, pctipind, 0, sysdate, null, 0, null, sysdate, null, pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtusuario);
                 commit;
            end if;
         end if;

				 IF 1 = 1 THEN
               /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
               v_host := NULL;

               /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_DEUDOR_HOST');
               END IF;
			/* Cambios de Iaxis-4521 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson, vcterminal, psinterf,
                                                 terror, pac_md_common.f_get_cxtusuario, 1,
                                                 'ALTA', VDIGITOIDE, v_host);
			/* Cambios de Iaxis-4521 : end */												 
            END IF;


            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
			/* Cambios de Iaxis-4521 : start */			   
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
			/* Cambios de Iaxis-4521 : end */												 
            END IF;

    RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;

end    f_set_impuesto_per;
  --FIN--WAJ
END pac_sin_imp_sap;

/

