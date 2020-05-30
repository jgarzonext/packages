
CREATE OR REPLACE PACKAGE BODY "PAC_SIN_IMP_SAP_CONF" AS
   /******************************************************************************
      NOMBRE:    PAC_SIN_IMP_SAP_CONF
      PROPÓSITO: Funciones para calculo de impuestos en siniestros

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  --------------------------------
      1.0       12/05/2017   JAEG             Creacion
      2.0       30/01/2017   ACL              2. 000743: Se realiza modificacion en la función f_get_indicador_prof.
	  3.0       02/02/2018   ACL              3. 000768: En la función f_get_indicador_prof, se agrega otra condición para que no pida los impuestos si va solo el IVA.
	4.0	19/07/2019	  PK	4.0 Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
   ******************************************************************************/

   /*************************************************************************
            Relaciona al profesional con el impuesto indicado
   *************************************************************************/
   FUNCTION f_set_impuesto_prof(psprofes IN NUMBER,
                                pccodimp IN NUMBER,
                                pctipind IN NUMBER) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'PAC_SIN_IMP_SAP_CONF.f_set_impuesto_prof';
      vparam      VARCHAR2(500) := 'parámetros - psprofes: ' || psprofes ||
                                   ' - pctipind: ' || pctipind;
      vpasexec    NUMBER := 0;
      vcregfiscal per_regimenfiscal.cregfiscal%TYPE;
      vcterminal  usuarios.cterminal%TYPE;
      v_host      VARCHAR2(10);
      vsinterf    NUMBER;
      vterror     VARCHAR(2000);
      v_nerror    NUMBER;
      vsperson    per_personas.sperson%TYPE;
	  /* Cambio de IAXIS-4844 start */
	  VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	  /* Cambio de IAXIS-4844 end */
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

      vpasexec    := 2;
      vcregfiscal := NULL;

      IF pccodimp = 2 --RETEFUENTE
      THEN
         BEGIN
            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = vsperson
               AND r.cregfiscal IN (6, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL
         THEN
            RETURN 9906613;
         END IF;
      END IF;

      vpasexec := 3;

      IF pccodimp = 3 --RETEIVA
      THEN
         /*         BEGIN
            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = vsperson
               AND r.cregfiscal IN (4, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;*/

         IF vcregfiscal IS NOT NULL
         THEN
            RETURN 9906613;
         END IF;
      END IF;

      vpasexec := 4;

      INSERT INTO sin_prof_indicadores
         (sprofes, ctipind)
      VALUES
         (psprofes, pctipind);

      COMMIT;
      vpasexec := 5;
      v_host   := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                'ALTA_PROV_HOST');
      vpasexec := 6;
		
      /* Cambios de IAXIS-4844 : start */
        BEGIN
		SELECT PP.NNUMIDE,PP.TDIGITOIDE
		  INTO VPERSON_NUM_ID,VDIGITOIDE
		  FROM PER_PERSONAS PP
		 WHERE PP.SPERSON = vsperson
		   AND ROWNUM = 1;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  SELECT PP.CTIPIDE, PP.NNUMIDE
			INTO VCTIPIDE, VPERSON_NUM_ID
			FROM PER_PERSONAS PP
		   WHERE PP.SPERSON = vsperson;
		  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
														 UPPER(VPERSON_NUM_ID));
	END;
        /* Cambios de IAXIS-4844 : end */

      IF v_host IS NOT NULL
      THEN
         IF pac_persona.f_gubernamental(vsperson) = 1
         THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_ACREEDOR_HOST');
         END IF;

         vpasexec := 7;
         v_nerror := pac_user.f_get_terminal(f_user, vcterminal);
         vpasexec := 8;
		/* Cambios de IAXIS-4844 : start */
         v_nerror := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa,
                                            vsperson,
                                            vcterminal,
                                            vsinterf,
                                            vterror,
                                            pac_md_common.f_get_cxtusuario,
                                            1,
                                            'ALTA',
                                            VDIGITOIDE,
                                            v_host);
		/* Cambios de IAXIS-4844 : end */
         vpasexec := 9;

         IF v_nerror <> 0
         THEN
            RETURN v_nerror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_impuesto_prof;

   /*************************************************************************
         Recupera los impuestos/retenciones para un profesional dado
   *************************************************************************/
   FUNCTION f_get_indicador_prof(pcconpag IN NUMBER,
                                 psprofes IN NUMBER,
                                 pccodimp IN NUMBER,
                                 pfordpag IN DATE,
                                 pnsinies IN sin_tramita_localiza.nsinies%TYPE,
                                 pntramit IN sin_tramita_localiza.ntramit%TYPE,
                                 pnlocali IN sin_tramita_localiza.nlocali%TYPE,
                                 ptselect OUT VARCHAR2) RETURN NUMBER IS
      vtraza      NUMBER := 0;
      vobject     VARCHAR2(200) := 'PAC_SIN_IMP_SAP_CONF.f_get_indicador_prof';
      vparam      VARCHAR2(200) := 'parámetros -  pcconpag=' || pcconpag ||
                                   ' psprofes=' || psprofes || ' pfordpag=' ||
                                   pfordpag || ' pccodimp=' || pccodimp ||
                                   ' pnlocali=' || pnlocali;
      vcpostal    NUMBER;
      vcuenta     NUMBER;
      vfordpag    VARCHAR2(10);
      vcregfiscal per_regimenfiscal.cregfiscal%TYPE;
      vcprovin    sin_tramita_localiza.cprovin%TYPE;
      vcpoblac    sin_tramita_localiza.cpoblac%TYPE;
      --iaxis 5373 ust Andres Betancourt
      VTIPIVA NUMBER;
   BEGIN
      IF pcconpag <> -1
      THEN
         SELECT COUNT(*)
           INTO vcuenta
           FROM sin_imp_conceptos
          WHERE cconpag = pcconpag;

         IF vcuenta = 0
         THEN
            -- Este concepto de pago no tiene que cobrar impuestos
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind FROM dual';
            RETURN 0;
         END IF;
      END IF;

      vfordpag := TO_CHAR(pfordpag, 'DD/MM/YYYY');

      IF pccodimp = 2
      THEN
         --RETEFUENTE
         BEGIN
            vtraza := 1;

            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = (SELECT sperson
                                  FROM sin_prof_profesionales
                                 WHERE sprofes = psprofes)
               AND r.cregfiscal IN (6, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         IF vcregfiscal IS NOT NULL
         THEN
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind
                         FROM dual';
            RETURN 0;
         END IF;
      END IF;

      IF pccodimp = 3
      THEN
         --RETEIVA
         /*         BEGIN
            vtraza := 2;

            SELECT cregfiscal
              INTO vcregfiscal
              FROM per_regimenfiscal r
             WHERE r.sperson = (SELECT sperson
                                  FROM sin_prof_profesionales
                                 WHERE sprofes = psprofes)
               AND r.cregfiscal IN (4, 8)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;*/

         IF vcregfiscal IS NOT NULL
         THEN
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind
                         FROM dual';
            RETURN 0;
         END IF;
      END IF;

      IF pccodimp = 4
      THEN
         -- RETEICA
         vtraza := 3;

         SELECT cpostal,
                cprovin,
                cpoblac
           INTO vcpostal,
                vcprovin,
                vcpoblac
           FROM sin_tramita_localiza
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nlocali = pnlocali;

         vtraza := 4;

         IF vcpostal IS NULL
         THEN
            SELECT cpostal
              INTO vcpostal
              FROM codpostal
             WHERE cprovin = vcprovin
               AND cpoblac = vcpoblac;
         END IF;

         SELECT COUNT(*)
           INTO vcuenta
           FROM tipos_indicadores_det
          WHERE cpostal = vcpostal;

         IF vcuenta = 0
         THEN
            -- Es una ciudad que no cobra ICA
            ptselect := 'SELECT ''No aplica'' tindica, 0 porcen, '' '' cipind FROM dual';
            RETURN 0;
         END IF;
       -- INI BUG 768 - ACL - 02/02/2018
       --  vtraza := 5;

        /* SELECT COUNT(*)
           INTO vcuenta
           FROM tipos_indicadores    i,
                sin_prof_indicadores p
          WHERE cimpret = 4
            AND p.ctipind = i.ctipind
            AND sprofes = psprofes;

         IF vcuenta = 0
         THEN
            RETURN 9906572; -- Falta definir retenciones/impuestos para el profesional
         END IF;
         */
		 -- FIN BUG 768 - ACL - 02/02/2018
         vtraza := 6;
         --
         ptselect := 'SELECT p.tpoblac || '' - '' || i.tindica tindica, d.porcent, i.ctipind
        FROM   tipos_indicadores i, tipos_indicadores_det d, poblaciones p, sin_tramita_localiza l, codpostal cp
        WHERE d.ctipind = i.ctipind
        AND d.fvigor = (SELECT MAX(fvigor) FROM tipos_indicadores_det d1 WHERE d1.ctipind = d.ctipind AND d1.fvigor <= TO_DATE(
        ''' || vfordpag || ''' , ''DD/MM/YYYY''))' ||
                     ' AND cimpret = 4 AND carea = 3
        AND p.cprovin = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),1,2))
        AND p.cpoblac = to_number(substr(ltrim(to_char(d.cpostal, ''00000'')),3,3))
        AND i.ctipind IN (SELECT ctipind FROM PER_INDICADORES WHERE sperson = (SELECT s.sperson FROM sin_prof_profesionales s WHERE sprofes = ' ||
                     psprofes || '))
        AND l.nsinies = ' || pnsinies || '
        AND l.ntramit = ' || pntramit || '
        AND l.nlocali = ' || pnlocali || '
        AND d.cpostal = cp.cpostal
        AND l.cprovin = cp.cprovin
        AND l.cpoblac = cp.cpoblac';
         --
      ELSE
         vtraza := 7;
         -- IAXIS 5373 UST ANDRES BETANCOURT
         BEGIN 
              SELECT CTIPIVA 
                INTO VTIPIVA 
                FROM per_regimenfiscal pf
               WHERE pf.sperson=(SELECT sperson 
                                FROM sin_prof_profesionales 
                               WHERE SPROFES=psprofes)
                 AND pf.fefecto =  (SELECT MAX (pf2.fefecto)
                                   FROM per_regimenfiscal pf2
                                  WHERE pf2.sperson = pf.sperson);           
              -- REGIMEN FISCAL TIENE IVA. 
              EXCEPTION
          WHEN OTHERS
            THEN
            -- SIGNIFICA QUE ES EXENTO DE IVA
             VTIPIVA :=1;
        END;

      IF VTIPIVA =0  THEN 
        -- 9000019 SUB TABLA CON CONSEPTOS  ctipind PARA DETERMINAR EL TIPO DE IVA QUE TIENE
         SELECT COUNT(*) INTO VCUENTA
           FROM sgt_subtabs_det sd
          WHERE sd.csubtabla = 9000019 and  CCLA1=pcconpag;
      ELSE
           VCUENTA:=0;
     END IF;
     -- IAXIS 5373 UST ANDRES BETANCOURT

         IF vcuenta = 0 AND
		 -- INI BUG 743 - ACL - 30/01/2018
            --pccodimp != 5
			-- INI BUG 768 - ACL - 02/02/2018
			pccodimp not in (1, 2, 3, 5)
			-- FIN BUG 768 - ACL - 02/02/2018
		 -- FIN BUG 743 - ACL - 30/01/2018
         THEN
            RETURN 9906572; -- Falta definir retenciones/impuestos para el profesional
         END IF;
         --IAXIS 4504 AABC 02/10/2019 validacion de iva y demas impuestos
         IF VCUENTA <> 0 AND pccodimp = 1 THEN
           vtraza   := 8;
         ptselect := 'SELECT tindica, porcent, i.ctipind
                       FROM   tipos_indicadores i, tipos_indicadores_det d
                       WHERE  cimpret = ' || pccodimp ||
                     ' and d.ctipind = i.ctipind
             AND d.fvigor = (SELECT MAX(fvigor) FROM tipos_indicadores_det d1 WHERE d1.ctipind = d.ctipind AND d1.fvigor <= ' ||
                     'TO_DATE( ''' || vfordpag || ''' , ''DD/MM/YYYY''))' ||
                     ' AND  carea = 3 AND i.ctipind IN (SELECT CCLA3 FROM sgt_subtabs_det WHERE csubtabla = 9000019 AND  CCLA1 = ' || pcconpag ||
                     ' AND CCLA3 IS NOT NULL )';           
            -- 
         ELSE 
         vtraza   := 8;
         ptselect := 'SELECT tindica, porcent, i.ctipind
                       FROM   tipos_indicadores i, tipos_indicadores_det d
                       WHERE  cimpret = ' || pccodimp ||
                     ' and d.ctipind = i.ctipind
             AND d.fvigor = (SELECT MAX(fvigor) FROM tipos_indicadores_det d1 WHERE d1.ctipind = d.ctipind AND d1.fvigor <= ' ||
                     'TO_DATE( ''' || vfordpag || ''' , ''DD/MM/YYYY''))' ||
                     ' AND  carea = 3 AND i.ctipind IN (SELECT ctipind FROM PER_INDICADORES WHERE sperson = (SELECT s.sperson FROM sin_prof_profesionales s WHERE sprofes =  ' ||
                     psprofes || '))';
        END IF;
         --IAXIS 4504 AABC 02/10/2019 validacion de iva y demas impuestos
      --CCLA1 ES EL CONCEPTO DE PAGO Y  CCLA3 ES EL INDICADOR - AB - 2019/30/09
      -- IAXIS 5373 UST ANDRES BETANCOURT
      END IF;
      --
	  -- INI BUG 743 - ACL - 30/01/2018
      --IF pccodimp IN (3, 4, 5)
	   -- INI BUG 768 - ACL - 02/02/2018
	   IF pccodimp IN (1, 2, 3, 4, 5)
	   -- FIN BUG 768 - ACL - 02/02/2018
	  -- FIN BUG 743 - ACL - 30/01/2018
      THEN
         -- RETEIVA, RETEICA, IPOCONSUMO
         ptselect := ptselect || '
                UNION
                SELECT ''0% Sin retención'' tindica, 0 porcent, -1 ctipind
                  FROM DUAL
                ORDER BY porcent';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobject,
                     vtraza,
                     vparam || 'ptselect = ' || ptselect,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_indicador_prof; 
   --
END pac_sin_imp_sap_conf;

/
