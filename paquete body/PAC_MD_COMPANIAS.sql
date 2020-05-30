--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COMPANIAS" AS
      /******************************************************************************
        NOMBRE:       PAC_MD_COMPANIAS
        COMPANIAS
      PROPÃ“SITO: Funciones para gestionar compañias

      REVISIONES:
      Ver        Fecha        Autor       DescripciÃ³n
      ---------  ----------  ---------  ------------------------------------
      1.0        09/07/2012  JRB        1. CreaciÃ³n del package.
      2.0        08/08/2012  AVT        2. 22076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
      3.0        24/01/2013  JDS        3. 0025832: LCOL_A004-Errores y tama?o de campos en el mantenimiento de compa?ias
      4.0        08/02/2013  JDS        4. 0025832: LCOL_A004-Errores y tama?o de campos en el mantenimiento de compa?ias
      5.0        20/03/2013  KBR        5. 0025822: RSA003 - Gestion de compa?ias reaseguradoras (Modificamos INSERT sobre tabla COMPANIAS)
      6.0        03/05/2013  KBR        6. 0025822: RSA003 - Gestion de compa?ias reaseguradoras (Nota: 143771)
      7.0        07/05/2013  KBR        7. 0025822: RSA003 - Gestion de compa?ias reaseguradoras (Nota: 143961)
      8.0        05/10/2013  MMS        8. 0026318: POSS038-(POSIN011)-Interfaces:IAXIS-SAP: Interfaz de Personas
      9.0        06/11/2013  RCL        9. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
      10.0       05/02/2014  AGG
      11.0       31/01/2019  ACL        11. TCS_1569B: Se agregan las funciones f_set_indicador_comp y f_get_indicador_comp. Se modifica la f_set_compania y f_get_indicadores_cias.
      12.0	19/07/2019    PK	12. Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
   ******************************************************************************/

   /*************************************************************************
      Nueva funciÃ³n que se encarga de borrar un registro de compañias
      return              : 0 Ok. 1 Error
     *************************************************************************/
   FUNCTION f_del_compania(
      pccompani IN companias.ccompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.f_del_compania';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      IF pccompani IS NULL THEN
         RETURN -1;
      ELSE
         DELETE      companias
               WHERE ccompani = pccompani;

         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_compania;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_compania(
      psperson IN companias.sperson%TYPE,
      pccompani IN OUT companias.ccompani%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      pcpais IN companias.cpais%TYPE,
      pctipiva IN companias.ctipiva%TYPE,
      pccomisi IN companias.ccomisi%TYPE,
      pcunespa IN companias.cunespa%TYPE,
      pffalta IN companias.ffalta%TYPE,
      pfbaja IN companias.fbaja%TYPE,
      pccontable IN companias.ccontable%TYPE,
      pctipcom IN companias.ctipcom%TYPE,
      pcafili IN companias.cafili%TYPE,
      pccasamat IN companias.ccasamat%TYPE,
      pcsuperfinan IN companias.csuperfinan%TYPE,
      pcdian IN companias.cdian%TYPE,
      pccalifi IN companias.ccalifi%TYPE,
      pcenticalifi IN companias.centicalifi%TYPE,
      pnanycalif IN companias.nanycalif%TYPE,
      pnpatrimonio IN companias.npatrimonio%TYPE,
      ppimpint IN companias.pimpint%TYPE,
      pctramtax IN companias.ctramtax%TYPE,   --25822 KBR Se agrega el parámetro CTRAMTAX 03052013
      pcinverfas IN companias.cinverfas%TYPE,   -- Bug 32034 - SHA - 11/08/2014
	  pcresidfisc IN par_companias_rea.cvalpar%TYPE,   --CONFCC-5
      pfresfini IN par_companias_rea.ffini%TYPE,   --CONFCC-5
      pfresffin IN par_companias_rea.ffini%TYPE,   --CONFCC-5
	  pctiprea IN companias.ctiprea%TYPE,   --IAXIS-4823
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parÃ¡metros - psperson:' || psperson || 'pccompani:' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_SET_COMPANIA';
      v_nerror       NUMBER;
      v_ctipcom      companias.ctipcom%TYPE;
      v_host         VARCHAR2(10);
      vcterminal     usuarios.cterminal%TYPE;
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
	  v_cont_ex      NUMBER; --CONFCC-5
	/* Cambios de IAXIS-4844 : start */
	VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	/* Cambios de IAXIS-4844 : end */
	  
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF pccompani IS NULL THEN
         SELECT COUNT(1)
           INTO v_nerror
           FROM companias
          WHERE sperson = psperson
            AND(ctipcom = pctipcom
                OR(ctipcom IS NULL
                   AND pctipcom IS NULL))
            AND NVL(pcafili, 0) = 0;

         IF v_nerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9904945);
            RETURN 1;
         END IF;

         SELECT ctipper
           INTO v_nerror
           FROM per_personas
          WHERE sperson = psperson;

         IF v_nerror <> 2 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9903971);
            RETURN 1;
         END IF;

         SELECT sccompani.NEXTVAL
           INTO pccompani
           FROM DUAL;

         -- 25822 KBR 20/03/2013 Modificamos el INSERT para que si se agrega un nuevo campo no falle el INSERT
         -- 25822 KBR 03/05/2013 Agregamos el campo CTRAMTAX en el INSERT
        INSERT INTO companias
                     (sperson, ccompani, tcompani, cpais, ctipiva, ccomisi,
                      cunespa, ffalta, fbaja, cusuari, fmovimi, ccontable, ctipcom,
                      cafili, ccasamat, csuperfinan, cdian, ccalifi, centicalifi,
                      nanycalif, npatrimonio, pimpint, gastdef, ctramtax, cinverfas,ctiprea)
              VALUES (psperson, pccompani, ptcompani, pcpais, NVL(pctipiva, 0), pccomisi,
                      pcunespa, pffalta, pfbaja, f_user, f_sysdate, pccontable, pctipcom,
                      pcafili, pccasamat, pcsuperfinan, pcdian, pccalifi, pcenticalifi,
                      pnanycalif, pnpatrimonio, ppimpint, NULL, pctramtax, NVL(pcinverfas, 0),pctiprea);    -- 22076 AVT 08/08/2012 s'afegeix el % impostos sobre interessos

	      -- Ini TCS_1569B - ACL - 31/01/2019
	      COMMIT;
	      v_nerror := f_set_indicador_comp(pccompani, pctipcom, mensajes);
	      -- Fin TCS_1569B - ACL - 31/01/2019
		--CONFCC-5 Inicio
         IF pcresidfisc = 1
           AND pfresfini IS NOT NULL
           AND pfresffin IS NOT NULL
         THEN
           DELETE par_companias_rea
            WHERE ccompani = pccompani
              AND cparcomp = 'EXENTA_RETENCION';

           INSERT INTO par_companias_rea
                       (ccompani, ffini, fffin, cparcomp, cvalpar, mcainh, fmodifi, cusumod)
                VALUES (pccompani, pfresfini, pfresffin, 'EXENTA_RETENCION', pcresidfisc, 'N', SYSDATE, USER);
         END IF;
         --CONFCC-5 Fin

      -- Bug 32034 - SHA - 11/08/2014
      ELSE
         --se comprueba si actualiza los datos sin haber modificar 'tipo de empresa', para que no lo
         --detecte como duplicado (error 9904945), pero sí se debe comprobar si se cambia el tipo
         SELECT ctipcom
           INTO v_ctipcom
           FROM companias
          WHERE ccompani = pccompani;

         IF (NVL(v_ctipcom, -1) <> NVL(pctipcom, -1)) THEN
            SELECT COUNT(1)
              INTO v_nerror
              FROM companias
             WHERE sperson = psperson
               AND(ctipcom = pctipcom
                   OR(ctipcom IS NULL
                      AND pctipcom IS NULL))
               AND NVL(pcafili, 0) = 0;

            IF v_nerror <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9904945);
               RETURN 1;
            END IF;
         END IF;

         UPDATE companias
            SET sperson = psperson,
                tcompani = ptcompani,
                cpais = pcpais,
                ctipiva = NVL(pctipiva, 0),
                ccomisi = pccomisi,
                cunespa = pcunespa,
                ffalta = pffalta,
                fbaja = pfbaja,
                cusuari = f_user,
                fmovimi = f_sysdate,
                ccontable = pccontable,
                ctipcom = pctipcom,
                cafili = pcafili,
                ccasamat = pccasamat,
                csuperfinan = pcsuperfinan,
                cdian = pcdian,
                ccalifi = pccalifi,
                centicalifi = pcenticalifi,
                nanycalif = pnanycalif,
                npatrimonio = pnpatrimonio,
                pimpint = NVL(ppimpint, pimpint),   -- BUG 25832 JDS 24/01/2013
                ctramtax = pctramtax,   --25822 KBR Se agrega el parámetro CTRAMTAX 03052013
                cinverfas = NVL(pcinverfas, 0),   -- Bug 32034 - SHA - 11/08/2014
                ctiprea=pctiprea
          WHERE ccompani = pccompani;

		  --CONFCC-5 Inicio
         SELECT COUNT(*)
           INTO v_cont_ex
           FROM par_companias_rea
          WHERE ccompani = pccompani
            AND cparcomp = 'EXENTA_RETENCION'
            AND cvalpar  = pcresidfisc
            AND ffini    = pfresfini
            AND fffin    = pfresffin
            AND mcainh   = 'N';

         IF v_cont_ex = 0
         THEN
           UPDATE par_companias_rea
              SET mcainh = 'S'
            WHERE ccompani = pccompani
              AND cparcomp = 'EXENTA_RETENCION';

           INSERT INTO par_companias_rea
                       (ccompani, ffini, fffin, cparcomp, cvalpar, mcainh, fmodifi, cusumod)
                VALUES (pccompani, pfresfini, pfresffin, 'EXENTA_RETENCION', NVL(pcresidfisc, 0), 'N', SYSDATE, USER);
         END IF;
         --CONFCC-5 Fin

      END IF;

        /* Cambios de IAXIS-4844 : start */
	  BEGIN
		SELECT PP.NNUMIDE,PP.TDIGITOIDE
		  INTO VPERSON_NUM_ID,VDIGITOIDE
		  FROM PER_PERSONAS PP
		 WHERE PP.SPERSON = psperson
		   AND ROWNUM = 1;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  SELECT PP.CTIPIDE, PP.NNUMIDE
			INTO VCTIPIDE, VPERSON_NUM_ID
			FROM PER_PERSONAS PP
		   WHERE PP.SPERSON = psperson;
		  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
														 UPPER(VPERSON_NUM_ID));
	  END;
	/* Cambios de IAXIS-4844 : end */
        
      --Bug 29166/160004 - 29/11/2013 - AMC
      -- Se convierte la persona a pública
      v_nerror := pac_persona.f_convertir_apublica(psperson);

      -- Bug 0026318: MMS 20131005
      IF NVL(v_ctipcom, 0) = 0 THEN
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_C_REASEG_HOST');
      ELSIF NVL(v_ctipcom, -1) = 3 THEN
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_C_COASEG_HOST');
      ELSE
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_PROV_HOST');
      END IF;

      IF v_host IS NOT NULL THEN
         --En LCOL la condición es IF pac_persona.f_persona_duplicada_nnumide(psperson) = 1 THEN
         --No se debe modificar
         IF pac_persona.f_gubernamental(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_ACREEDOR_HOST');
         END IF;

         v_nerror := pac_user.f_get_terminal(f_user, vcterminal);
		/* Cambios de IAXIS-4844 : start */
         v_nerror := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                            vcterminal, vsinterf, vterror,
                                            pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                            v_host);
		/* Cambios de IAXIS-4844 : end */
		
         IF v_nerror <> 0 THEN
            RAISE e_param_error;
         END IF;
      END IF;

      -- Fin Bug 0026318: MMS 20131005
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
	-- Ini TCS_1569B - ACL - 31/01/2019
	COMMIT;
	-- Fin TCS_1569B - ACL - 31/01/2019
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_compania;

    /*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar la compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_compania(
      pccompani IN companias.ccompani%TYPE,
      psperson IN companias.sperson%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_companias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parÃ¡metros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_get_compania';
      v_fich         VARCHAR2(400);
      vcompania      sys_refcursor;
      compania       ob_iax_companias := ob_iax_companias();
      v_numerr       NUMBER;
      v_tnombre      VARCHAR2(100);

      CURSOR ccompania IS
         SELECT d.*
           FROM companias d
          WHERE d.ccompani = pccompani;

      CURSOR ccompania2 IS
         SELECT d.*
           FROM companias d
          WHERE d.sperson = psperson;
   BEGIN
      vpasexec := 1;

      IF pccompani IS NULL
         AND psperson IS NULL THEN
         RETURN NULL;
      END IF;

      IF pccompani IS NULL THEN
         FOR comp IN ccompania2 LOOP
            compania.sperson := NVL(psperson, comp.sperson);
            compania.ccompani := comp.ccompani;
            compania.tcompani := comp.tcompani;
            compania.cpais := comp.cpais;
            compania.ctipiva := comp.ctipiva;
            compania.ccomisi := comp.ccomisi;
            compania.cunespa := comp.cunespa;
            compania.ffalta := comp.ffalta;
            compania.fbaja := comp.fbaja;
            compania.cusuari := comp.cusuari;
            compania.fmovimi := comp.fmovimi;
            compania.ccontable := comp.ccontable;
            compania.ctipcom := comp.ctipcom;
            compania.cafili := comp.cafili;
            compania.ccasamat := comp.ccasamat;
            compania.csuperfinan := comp.csuperfinan;
            compania.cdian := comp.cdian;
            compania.ccalifi := comp.ccalifi;
            compania.centicalifi := comp.centicalifi;
            compania.nanycalif := comp.nanycalif;
            compania.npatrimonio := comp.npatrimonio;
            compania.gastdef := comp.gastdef;
            compania.pimpint := comp.pimpint;
            compania.ctramtax := comp.ctramtax;   --25822 KBR Se agrega el parámetro CTRAMTAX 03052013
            compania.cinverfas := comp.cinverfas;   -- Bug 32034 - SHA - 11/08/2014
			compania.ctiprea := comp.ctiprea;   -- IAXIS-4823
            vpasexec := 3;

            IF compania.cpais IS NOT NULL THEN
               compania.tpais := pac_md_descvalores.f_get_descpais(compania.cpais, mensajes);
            END IF;

            vpasexec := 5;

            IF compania.ccalifi IS NOT NULL THEN
               compania.tcalifi := pac_md_listvalores.f_getdescripvalores(800100,
                                                                          compania.ccalifi,
                                                                          mensajes);
            END IF;

            vpasexec := 6;

            IF compania.centicalifi IS NOT NULL THEN
               compania.tenticalifi :=
                  pac_md_listvalores.f_getdescripvalores(800101, compania.centicalifi,
                                                         mensajes);
            END IF;

            vpasexec := 7;

            --BUG 25502/158166 - RCL - 06/11/2013 - Valor por defecto de tipo de compañia
            IF compania.ctipcom IS NULL THEN
               compania.ctipcom := 0;
            END IF;

            IF compania.ctipcom IS NOT NULL THEN
               compania.ttipcom := pac_md_listvalores.f_getdescripvalores(800102,
                                                                          compania.ctipcom,
                                                                          mensajes);
            END IF;

            vpasexec := 8;

            IF compania.sperson IS NOT NULL THEN
               compania.nnumide := pac_isqlfor.f_dni(NULL, NULL, compania.sperson);
               compania.tnombre := pac_isqlfor.f_persona(NULL, NULL, compania.sperson);
            END IF;

			--CONFCC-5 Inicio
            BEGIN

              SELECT p.cvalpar, p.ffini, p.fffin
                INTO compania.cresidfisc, compania.fresfini, compania.fresffin
                FROM par_companias_rea p
               WHERE p.ccompani = pccompani
                 AND p.cparcomp = 'EXENTA_RETENCION'
                 AND p.mcainh = 'N';

            EXCEPTION WHEN OTHERS THEN
              compania.cresidfisc := NULL;
              compania.fresfini := NULL;
              compania.fresffin := NULL;
            END;
            --CONFCC-5 Fin

         END LOOP;
      ELSE
         FOR comp IN ccompania LOOP
            compania.sperson := NVL(psperson, comp.sperson);
            compania.ccompani := comp.ccompani;
            compania.tcompani := comp.tcompani;
            compania.cpais := comp.cpais;
            compania.ctipiva := comp.ctipiva;
            compania.ccomisi := comp.ccomisi;
            compania.cunespa := comp.cunespa;
            compania.ffalta := comp.ffalta;
            compania.fbaja := comp.fbaja;
            compania.cusuari := comp.cusuari;
            compania.fmovimi := comp.fmovimi;
            compania.ccontable := comp.ccontable;
            compania.ctipcom := comp.ctipcom;
            compania.cafili := comp.cafili;
            compania.ccasamat := comp.ccasamat;
            compania.csuperfinan := comp.csuperfinan;
            compania.cdian := comp.cdian;
            compania.ccalifi := comp.ccalifi;
            compania.centicalifi := comp.centicalifi;
            compania.nanycalif := comp.nanycalif;
            compania.npatrimonio := comp.npatrimonio;
            compania.gastdef := comp.gastdef;
            compania.pimpint := comp.pimpint;
            compania.ctramtax := comp.ctramtax;   --25822 KBR Se agrega el parámetro CTRAMTAX 03052013
            compania.cinverfas := comp.cinverfas;   -- Bug 32034 - SHA - 11/08/2014
			compania.ctiprea := comp.ctiprea;   -- IAXIS-4823
            vpasexec := 3;

            IF compania.cpais IS NOT NULL THEN
               compania.tpais := pac_md_descvalores.f_get_descpais(compania.cpais, mensajes);
            END IF;

            vpasexec := 5;

            IF compania.ccalifi IS NOT NULL THEN
               compania.tcalifi := pac_md_listvalores.f_getdescripvalores(800100,
                                                                          compania.ccalifi,
                                                                          mensajes);
            END IF;

            vpasexec := 6;

            IF compania.centicalifi IS NOT NULL THEN
               compania.tenticalifi :=
                  pac_md_listvalores.f_getdescripvalores(800101, compania.centicalifi,
                                                         mensajes);
            END IF;

            vpasexec := 7;

            --BUG 25502/158166 - RCL - 06/11/2013 - Valor por defecto de tipo de compañia
            IF compania.ctipcom IS NULL THEN
               compania.ctipcom := 0;
            END IF;

            IF compania.ctipcom IS NOT NULL THEN
               compania.ttipcom := pac_md_listvalores.f_getdescripvalores(800102,
                                                                          compania.ctipcom,
                                                                          mensajes);
            END IF;

            vpasexec := 8;

            IF compania.sperson IS NOT NULL THEN
               compania.nnumide := pac_isqlfor.f_dni(NULL, NULL, compania.sperson);
               compania.tnombre := pac_isqlfor.f_persona(NULL, NULL, compania.sperson);
            END IF;

			--CONFCC-5 Inicio
            BEGIN

              SELECT p.cvalpar, p.ffini, p.fffin
                INTO compania.cresidfisc, compania.fresfini, compania.fresffin
                FROM par_companias_rea p
               WHERE p.ccompani = pccompani
                 AND p.cparcomp = 'EXENTA_RETENCION'
                 AND p.mcainh = 'N';

            EXCEPTION WHEN OTHERS THEN
              compania.cresidfisc := NULL;
              compania.fresfini := NULL;
              compania.fresffin := NULL;
            END;
            --CONFCC-5 Fin

         END LOOP;
      END IF;

      RETURN compania;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN compania;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN compania;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN compania;
   END f_get_compania;

   /*************************************************************************
     Nueva funciÃ³n que se encarga de recuperar las compañias
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_companias(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_companias IS
      CURSOR companias IS
         SELECT   d.*
             FROM companias d
         ORDER BY d.ccompani;

      vtcompania     t_iax_companias := t_iax_companias();
      vobcompania    ob_iax_companias := ob_iax_companias();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_get_companias';
   BEGIN
      vpasexec := 2;

      FOR comp IN companias LOOP
         vobcompania := pac_md_companias.f_get_compania(comp.ccompani, NULL, NULL, mensajes);
         vtcompania.EXTEND;
         vtcompania(vtcompania.LAST) := vobcompania;
         vobcompania := ob_iax_companias();
      END LOOP;

      RETURN vtcompania;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_companias;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_set_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pccompani IN compcalificacion.ccompani%TYPE,
      pccalifi IN compcalificacion.ccalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      pfvenci IN compcalificacion.fvenci%TYPE,
      pprecargo IN compcalificacion.precargo%TYPE,
      pfalta IN compcalificacion.falta%TYPE,
      pcusualta IN compcalificacion.cusualta%TYPE,
      pfultmod IN compcalificacion.fultmod%TYPE,
      pcusumod in compcalificacion.cusumod%type,
      pofc_repres in compcalificacion.ofc_repres%type,
      pcestado_califi in compcalificacion.cestado_califi%type,
      pfinscrip in compcalificacion.finscrip%type,
      panyoactualiz in compcalificacion.anyoactualiz%type,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                   := 'parÃ¡metros - psperson:' || psperson || 'pcenticalifi:' || pcenticalifi;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_SET_COMPANIA_CALIF';
      v_nerror       NUMBER;
      v_fin_calif    NUMBER;
      v_fecha        DATE;
      v_fecha_venci  DATE;
   BEGIN
      v_fecha := f_sysdate;
      vpasexec := 1;
      p_control_error('pac_md_companias', 'f_set_compania_calif','paso 1. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz
      );


      --Comprobamos los parámetros de entrada.
      IF psperson IS NULL
         OR pcenticalifi IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Update de los datos para el mismo día de fecha de efecto (MODIF)
      UPDATE compcalificacion
         SET ccalifi = pccalifi,
             precargo = pprecargo,
             ofc_repres = pofc_repres,
             cestado_califi = pcestado_califi,
             finscrip = pfinscrip,
             anyoactualiz = panyoactualiz,
             fultmod = pfultmod,
             cusumod = pcusumod
       WHERE sperson = psperson
         AND centicalifi = pcenticalifi
         AND TRUNC(fefecto) = TRUNC(pfefecto)
         AND fvenci IS NULL;

      vpasexec := 3;
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 2. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz
      );

      --El Update anterior no modificó nada, se debe finalizar la
      --calificación anterior y generar una nueva (ALTA)
      IF SQL%ROWCOUNT = 0 THEN
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 3. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz
      );

         UPDATE compcalificacion
            SET fvenci = NVL(pfvenci, pfefecto),
                fultmod = pfultmod,
                cusumod = pcusumod
          WHERE sperson = psperson
            AND centicalifi = pcenticalifi
            AND fvenci IS NULL
            AND TRUNC(fefecto) <= TRUNC(NVL(pfvenci, pfefecto));

         vpasexec := 4;
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 4. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );
         IF NVL(pfefecto, v_fecha) < TRUNC(v_fecha) THEN
            RETURN -100;
         END IF;

         vpasexec := 5;

p_control_error('pac_md_companias', 'f_set_compania_calif','paso 5. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );
         --Buscar si existe una calificación a futuro y se asigna a la fecha de vencimiento
         BEGIN
            SELECT MIN(fefecto)
              INTO v_fecha_venci
              FROM compcalificacion
             WHERE sperson = psperson
               AND centicalifi = pcenticalifi
               AND fefecto > f_sysdate
               AND TRUNC(fefecto) >= TRUNC(NVL(fvenci, fefecto));
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 6. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fecha_venci := pfvenci;
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 7. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );
         END;

         vpasexec := 5;
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 8. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );
         INSERT INTO compcalificacion
                     (sperson, centicalifi, ccompani, ccalifi, fefecto, fvenci,
                      precargo, falta, cusualta, fultmod, cusumod, ofc_repres, cestado_califi, finscrip, anyoactualiz)
              values (psperson, pcenticalifi, pccompani, pccalifi, pfefecto, v_fecha_venci,
                      pprecargo, pfalta, pcusualta, pfultmod, pcusumod, pofc_repres, pcestado_califi, pfinscrip, panyoactualiz);
      END IF;
p_control_error('pac_md_companias', 'f_set_compania_calif','paso 9. psperson:' || psperson ||
      ' pcenticalifi:' || pcenticalifi||' pccompani:'||pccompani||' pccalifi:'||pccalifi||
      ' pfefecto:'||pfefecto||' pfvenci:'||pfvenci||' pprecargo:'||pprecargo||' pfalta:'||pfalta||
      ' pofc_repres:'||pofc_repres||' pcestado_califi:'||pcestado_califi||' pfinscrip:'||pfinscrip||
      ' panyoactualiz:'||panyoactualiz||' v_fecha:'||v_fecha
      );
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 0;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar las compañias calificadoras
    o solo una
    return              : Referencia al cursor con las compañías
   *************************************************************************/
   FUNCTION f_get_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_es_cia       NUMBER(2) := 0;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_get_companias_calif';
      v_tsquery      VARCHAR2(2500);
      v_tabla        VARCHAR2(50);
      v_where        VARCHAR2(1500);
      v_order        VARCHAR2(500);
      v_identif      VARCHAR2(200);
   BEGIN
      v_npasexec := 2;
      p_control_error('pac_md_companias', 'f_get_companias_calif','paso 1');
      IF psperson IS NULL THEN
         p_control_error('pac_md_companias', 'f_get_companias_calif','paso 2');
         RETURN NULL;
      END IF;
      p_control_error('pac_md_companias', 'f_get_companias_calif','paso 3');

      v_npasexec := 2;

      SELECT COUNT(*)
        INTO v_es_cia
        FROM companias
       WHERE sperson = psperson;

      v_npasexec := 3;

      --Si la persona está asociada a una compañía
      IF v_es_cia > 0 THEN
         v_identif := 'co.tcompani';
         v_tabla := 'companias co';
         v_where := 'co.sperson = ' || psperson || ' and cc.sperson = co.sperson';
      ELSE
         v_npasexec := 4;
         v_identif := 'trim(pp.tnombre||' || CHR(39) || ' ' || CHR(39) || '||pp.tapelli||'
                      || CHR(39) || ' ' || CHR(39) || '||nvl2(pp.tapelli, ' || CHR(39)
                      || CHR(39) || ', pp.tapelli1)||' || CHR(39) || ' ' || CHR(39)
                      || '||nvl2(pp.tapelli1, ' || CHR(39) || CHR(39) || ', pp.tapelli2))';
         v_tabla := 'personas pp';
         v_where := 'pp.sperson = ' || psperson || ' and cc.sperson = pp.sperson';
      END IF;

      v_npasexec := 5;

      IF pcenticalifi IS NOT NULL THEN
         v_npasexec := 6;
         v_where := v_where || ' and cc.centicalifi = ' || pcenticalifi;
      ELSE
         v_npasexec := 7;
         v_where :=
            v_where
            || ' and ((trunc(cc.fefecto) <= trunc(f_sysdate)
                     and trunc(cc.fvenci) = (select min(trunc(cc3.fvenci))
                                              from compcalificacion cc3
                                              where cc3.sperson = cc.sperson
                                                and cc3.centicalifi = cc.centicalifi
                                                and trunc(cc3.fefecto) <= trunc(f_sysdate)
                                                and cc3.fvenci is not null
                                                and cc3.fvenci >= trunc(f_sysdate)))
                    or (trunc(cc.fefecto) <= trunc(f_sysdate)
                    and trunc(cc.fvenci) is null
                    and not exists(select 1
                                   from compcalificacion cc4
                                   where cc4.sperson = cc.sperson
                                     and cc4.centicalifi = cc.centicalifi
                                     and trunc(cc4.fvenci) >= trunc(f_sysdate))))';
      END IF;

      v_order := ' order by fefecto desc ';
      v_npasexec := 8;
      v_tsquery :=
         'SELECT cc.sperson, cc.ccompani, cc.CCALIFI, cc.centicalifi, ' || v_identif
         || ', cc.CESTADO_CALIFI, cc.FINSCRIP, cc.ANYOACTUALIZ,
                                    (select dv.tatribu
                                     from detvalores dv
                                     where dv.cvalor = 8001034
                                       and dv.cidioma = '
         || pac_md_common.f_get_cxtidioma()
         || '
                                       and dv.catribu = cc.CESTADO_CALIFI) CESTADO_CALIFI,
                                    (select dv.tatribu
                                     from detvalores dv
                                     where dv.cvalor = 800101
                                       and dv.cidioma = '
         || pac_md_common.f_get_cxtidioma()
         || '
                                       and dv.catribu = cc.centicalifi) entidadcalifi,
                                    (select dv.tatribu
                                     from detvalores dv
                                     where dv.cvalor = 800100
                                       and dv.cidioma = '
         || pac_md_common.f_get_cxtidioma()
         || ' and dv.catribu = cc.ccalifi) califi,
              fefecto, fvenci, precargo
            FROM compcalificacion cc, '
         || v_tabla || '
           WHERE ' || v_where || v_order;
      v_npasexec := 9;
      p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||substr(v_tsquery, 1, 1000));
      p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||substr(v_tsquery, 1001, 1000));
      p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||substr(v_tsquery, 2001, 1000));
      p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||substr(v_tsquery, 3001, 1000));
      --p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||v_tsquery);
      --p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||v_tsquery);
      --p_control_error('pac_md_companias', 'f_get_companias_calif','v_tsquery:'||v_tsquery);
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*************************************************************************
      Nueva funciÃ³n que se encarga de borrar un registro de compañia calificadora
      return              : 0 Ok. -1 Error
     *************************************************************************/
   FUNCTION f_del_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parÃ¡metros - psperson = ' || psperson || ' - pcenticalifi = ' || pcenticalifi
            || ' - pfefecto = ' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_del_compania_calif';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      IF psperson IS NULL
         OR pcenticalifi IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      ELSE
         UPDATE compcalificacion
            SET fvenci = f_sysdate,
                fultmod = f_sysdate,
                cusumod = f_user
          WHERE sperson = psperson
            AND centicalifi = pcenticalifi
            AND fefecto = pfefecto;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_compania_calif;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de validar si existen al menos dos calificaciones
    para la compañía
    return              : X nro de calificaciones. -1 Error
   *************************************************************************/
   FUNCTION f_val_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parÃ¡metros - psperson = ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_del_compania_calif';
      v_ctdad_calif  NUMBER(2) := 0;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(*)
        INTO v_ctdad_calif
        FROM compcalificacion
       WHERE sperson = psperson
         AND ccalifi IS NOT NULL
         AND TRUNC(fefecto) <= TRUNC(f_sysdate)
         AND(fvenci IS NULL
             OR TRUNC(fvenci) >= TRUNC(f_sysdate));

      RETURN v_ctdad_calif;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END;

    /*************************************************************************
    Función que se encarga de recuperar el indicador de la compañía
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_get_indicador_cia';
      v_fich         VARCHAR2(400);
      vindicadorcia  sys_refcursor;
      indicador_cia  ob_iax_indicadores_cias := ob_iax_indicadores_cias();
      v_numerr       NUMBER;
      v_tnombre      VARCHAR2(100);

      CURSOR cindicadorcia IS
         SELECT i.*, ti.tindica AS tindicador, dv.tatribu AS taplica, ti.carea, ti.ctipreg,
                ti.cimpret, ti.cindsap
           FROM indicadores_cias i, tipos_indicadores ti, detvalores dv
          WHERE ti.ctipind = i.ctipind
            AND i.ccompani = pccompani
            AND dv.cvalor = 17001
            AND dv.catribu = i.caplica
            AND dv.cidioma = pac_md_common.f_get_cxtidioma()
            AND i.ctipind = pctipind
            AND i.finivig = pffinivig
            AND ti.carea = 1;   --Area reaseguro
   BEGIN
      vpasexec := 1;

      IF pccompani IS NULL
         AND pctipind IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      FOR ind IN cindicadorcia LOOP
         indicador_cia.ccompani := ind.ccompani;
         indicador_cia.ctipind := ind.ctipind;
         indicador_cia.tindicador := ind.tindicador;
         indicador_cia.nvalor := ind.nvalor;
         indicador_cia.caplica := ind.caplica;
         indicador_cia.taplica := ind.taplica;
         indicador_cia.finivig := ind.finivig;
         indicador_cia.ffinvig := ind.ffinvig;
         indicador_cia.cenviosap := ind.cenviosap;
         indicador_cia.carea := ind.carea;
         indicador_cia.ctipreg := ind.ctipreg;
         indicador_cia.cimpret := ind.cimpret;
         indicador_cia.cindsap := ind.cindsap;
         vpasexec := 3;
      END LOOP;

      RETURN indicador_cia;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN indicador_cia;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN indicador_cia;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN indicador_cia;
   END f_get_indicador_cia;

   /*************************************************************************
     Función que se encarga de recuperar los indicadores de las compañias
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_indicadores_cias(
      pccompani IN indicadores_cias.ccompani%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_indicadores_cias IS
      CURSOR indicadorescias IS
         SELECT   i.*
             FROM indicadores_cias i
            WHERE i.ccompani = pccompani
         ORDER BY i.ctipind;

      vtindicadorcia t_iax_indicadores_cias := t_iax_indicadores_cias();
      vobindicadorcia ob_iax_indicadores_cias := ob_iax_indicadores_cias();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_get_indicadores_cias';
   BEGIN
      vpasexec := 2;

      FOR ind IN indicadorescias LOOP
      -- Ini TCS_1569B - ACL - 31/01/2019
         /* vobindicadorcia := pac_md_companias.f_get_indicador_cia(ind.ccompani, ind.ctipind,
                                                                 ind.finivig, mensajes);*/
        vobindicadorcia := pac_md_companias.f_get_indicador_comp(ind.ccompani, ind.ctipind,
                                                                 ind.finivig, mensajes);
      -- Fin TCS_1569B - ACL - 31/01/2019
         vtindicadorcia.EXTEND;
         vtindicadorcia(vtindicadorcia.LAST) := vobindicadorcia;
         vobindicadorcia := ob_iax_indicadores_cias();
      END LOOP;

      RETURN vtindicadorcia;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_indicadores_cias;

   /*************************************************************************
    Función que se encarga de insertar un registro en indicadores de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pnvalor IN indicadores_cias.nvalor%TYPE,
      pfinivig IN indicadores_cias.finivig%TYPE,
      pffinvig IN indicadores_cias.ffinvig%TYPE,
      pcenviosap IN indicadores_cias.cenviosap%TYPE,
      pcaplica IN indicadores_cias.caplica%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parÃ¡metros - pccompani:' || pccompani || 'pctipind:' || pctipind;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_SET_INDICADOR_CIA';
      v_reg          NUMBER;
      v_host         VARCHAR2(10);
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
      v_nerror       NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      vsperson       companias.sperson%TYPE;
      v_ctipcom      companias.ctipcom%TYPE;
      v_numindi      NUMBER := 0;
	/* Cambios de IAXIS-4844 : start */
	VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	/* Cambios de IAXIS-4844 : end */
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF pffinvig IS NOT NULL THEN   --estamos dando de baja el tipo de indicador
         vpasexec := 3;

         UPDATE indicadores_cias
            SET ffinvig = pffinvig,
                fbaja = f_sysdate
          WHERE ccompani = pccompani
            AND ctipind = pctipind
            AND TRUNC(finivig) = pfinivig;
      ELSE
         vpasexec := 4;

         SELECT COUNT(1)
           INTO v_reg
           FROM indicadores_cias
          WHERE ccompani = pccompani
            AND ctipind = pctipind
            AND finivig = pfinivig;

         IF v_reg > 0 THEN
            vpasexec := 5;

            --Estamos modificando
            UPDATE indicadores_cias
               SET cenviosap = pcenviosap,
                   cusumod = f_user
             WHERE ccompani = pccompani
               AND ctipind = pctipind
               AND TRUNC(finivig) = pfinivig;
         ELSE
            vpasexec := 6;

            SELECT COUNT(1)
              INTO v_numindi
              FROM indicadores_cias
             WHERE ccompani = pccompani
               AND ctipind = pctipind;

            IF v_numindi > 0 THEN
               --en este caso anulamos la anterior que hubiera
               --Como fecha de anulación indicamos un dia anterior a la fecha de inicio de vigencia de la siguiente
               UPDATE indicadores_cias
                  SET ffinvig = pfinivig - 1
                WHERE ccompani = pccompani
                  AND ctipind = pctipind;
            END IF;

            --Estamos insertando
            INSERT INTO indicadores_cias
                        (ccompani, ctipind, nvalor, finivig, ffinvig, cenviosap,
                         caplica, ffalta, cusualta)
                 VALUES (pccompani, pctipind, pnvalor, pfinivig, pffinvig, pcenviosap,
                         pcaplica, f_sysdate, f_user);
         END IF;

         vpasexec := 7;

         SELECT ctipcom
           INTO v_ctipcom
           FROM companias
          WHERE ccompani = pccompani;

         IF NVL(v_ctipcom, 0) = 0 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_C_REASEG_HOST');
         ELSIF NVL(v_ctipcom, -1) = 3 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_C_COASEG_HOST');
         ELSE
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');
         END IF;

         IF v_host IS NOT NULL THEN
            BEGIN
               SELECT sperson
                 INTO vsperson
                 FROM companias
                WHERE ccompani = pccompani;
            END;
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
            vpasexec := 8;
            v_nerror := pac_user.f_get_terminal(f_user, vcterminal);
            vpasexec := 9;
			/* Cambios de IAXIS-4844 : start */	
            v_nerror := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, vsperson,
                                               vcterminal, vsinterf, vterror,
                                               pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                               v_host);
			/* Cambios de IAXIS-4844 : end */	
            vpasexec := 10;

            IF v_nerror <> 0 THEN
               RAISE e_param_error;
            END IF;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_indicador_cia;

    /*************************************************************************
      FUNCTION f_get_tindicadorescia
      Recupera los tipos de indicadores para las compañias
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tindicadorescia(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres:';
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_Get_tindicadorescia';
   BEGIN
      vpasexec := 2;
      cur :=
         pac_md_listvalores.f_opencursor('SELECT CTIPIND, TINDICA '
                                         || ' FROM tipos_indicadores '
                                         || ' WHERE (fbaja IS NULL OR fbaja > f_sysdate) '
                                         || 'ORDER BY ctipind',
                                         mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tindicadorescia;

-- Ini TCS_1569B - ACL - 31/01/2019
   /*************************************************************************
    Función que se encarga de insertar un registro en indicadores de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipcom IN companias.ctipcom%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parÃ¡metros - pccompani:' || pccompani || 'pctipcom:' || pctipcom;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_SET_INDICADOR_COMP';

      CURSOR cur_comp_imp IS
            select p.*
            from per_indicadores p, companias c
            where c.ccompani = pccompani
            AND p.sperson = c.sperson
            AND p.codvinculo = 4;
            --AND p.codsubvinculo = pctipcom;

   BEGIN
      vpasexec := 1;
             for cur_comp_imp_r in cur_comp_imp loop
                    INSERT INTO indicadores_cias (ccompani, ctipind, nvalor, finivig, ffinvig, cenviosap,
                         caplica, ffalta, cusualta)
                    VALUES (pccompani, cur_comp_imp_r.ctipind, null, cur_comp_imp_r.falta, null, 0,
                         null, f_sysdate, f_user);
             END LOOP;
        COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_indicador_comp;

    /*************************************************************************
      FUNCTION f_get_tindicadorescomp
      Recupera los tipos de indicadores para las compañias
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
      FUNCTION f_get_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.f_get_indicador_cia';
      v_fich         VARCHAR2(400);
      vindicadorcia  sys_refcursor;
      indicador_comp  ob_iax_indicadores_cias := ob_iax_indicadores_cias();
      v_numerr       NUMBER;
      v_tnombre      VARCHAR2(100);

      CURSOR cindicadorcomp IS
      SELECT i.*, ti.tindica AS tindicador, ti.carea, ti.ctipreg,
                ti.cimpret, ti.cindsap
           FROM indicadores_cias i, tipos_indicadores ti
          WHERE ti.ctipind = i.ctipind
            AND i.ccompani = pccompani
            AND i.ctipind = pctipind
            AND I.finivig = pffinivig;

   BEGIN
      vpasexec := 1;

      IF pccompani IS NULL
         AND pctipind IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      FOR ind IN cindicadorcomp LOOP
         indicador_comp.ccompani := ind.ccompani;
         indicador_comp.ctipind := ind.ctipind;
         indicador_comp.tindicador := ind.tindicador;
         indicador_comp.nvalor := ind.nvalor;
         indicador_comp.caplica := ind.caplica;
        -- indicador_comp.taplica := ind.taplica;
         indicador_comp.finivig := ind.finivig;
         indicador_comp.ffinvig := ind.ffinvig;
         indicador_comp.cenviosap := ind.cenviosap;
         indicador_comp.carea := ind.carea;
         indicador_comp.ctipreg := ind.ctipreg;
         indicador_comp.cimpret := ind.cimpret;
         indicador_comp.cindsap := ind.cindsap;
         vpasexec := 3;
      END LOOP;

      RETURN indicador_comp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN indicador_comp;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN indicador_comp;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN indicador_comp;
   END f_get_indicador_comp;
-- Fin TCS_1569B - ACL - 31/01/2019
END pac_md_companias;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMPANIAS" TO "PROGRAMADORESCSI";
