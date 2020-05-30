--------------------------------------------------------
--  DDL for Package Body PAC_MD_ESC_RIESGO
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "PAC_MD_ESC_RIESGO" AS
/******************************************************************************
   NOMBRE:     pac_md_esc_riesgo
   PROP¿SITO:  Funciones para realizar una conexi¿n
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/03/2017   ERH               1. Creaci¿n del package.
   2.0        11/03/2019   DFR               2. IAXIS-2016: Scoring
******************************************************************************/
   e_object_error_n EXCEPTION;
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
   e_param_info     EXCEPTION;
   v_idioma         NUMBER := pac_md_common.f_get_cxtidioma();

     /**********************************************************************
	  FUNCTION F_GRABAR_ESCALA_RIESGO
      Funci¿n que almacena los datos de la escala de riesgo.
      Firma (Specification)
      Param IN pcescrie: cescrie
      Param IN  pndesde: ndesde
	    Param IN  pnhasta: nhasta
      Param IN pindicad: indicad
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
	  FUNCTION f_grabar_escala_riesgo(
        pcescrie IN NUMBER,
         pndesde IN NUMBER,
		     pnhasta IN NUMBER,
        pindicad IN VARCHAR2,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_MD_ESC_RIESGO.f_grabar_escala_riesgo';
      vobjectnamen   VARCHAR2(500) := 'Registro Nuevo';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'par¿metros - ';
      verrores       t_ob_error;

       BEGIN

          IF pcescrie IS NULL THEN
             vparam := vparam || ' pcescrie =' || pcescrie;
             RAISE e_param_error;
          END IF;

          IF pndesde IS NULL THEN
             vparam := vparam || ' pndesde =' || pndesde;
             RAISE e_param_error;
          END IF;

          IF pnhasta IS NULL THEN
             vparam := vparam || ' pnhasta =' || pnhasta;
             RAISE e_param_error;
          END IF;

          IF pindicad IS NULL THEN
             vparam := vparam || ' pindicad =' || pindicad;
             RAISE e_param_error;
          END IF;

            vnumerr := pac_esc_riesgo.f_grabar_escala_riesgo(pcescrie, pndesde, pnhasta,  pindicad, mensajes);

           mensajes := f_traspasar_errores_mensajes(verrores);

          IF vnumerr = 1 AND (pindicad = 'E') THEN
             RAISE e_object_error;
          END IF;

          IF vnumerr = 1 AND (pindicad = 'N') THEN
             RAISE e_object_error_n;
          END IF;


          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error_n THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectnamen, 9910627, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_escala_riesgo;


	 /**********************************************************************
      FUNCTION F_GET_ESCALA_RIESGO
      Funci¿n que retorna los datos de la escala de riesgo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_escala_riesgo(
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_ESC_RIESGO.f_get_escala_riesgo';
      cur            sys_refcursor;

       BEGIN

          cur := pac_esc_riesgo.f_get_escala_riesgo();

          RETURN cur;
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

             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;

             RETURN cur;
       END f_get_escala_riesgo;

    -- Inicio IAXIS-2016: Scoring 11/03/2019
   /**********************************************************************
     FUNCTION F_CALCULA_MODELO
     Funci¿n que genera el calculo modelo de SCORING
     Firma (Specification):
     Param IN  psperson: sperson
     Param IN  psproduc: sproduc
     Param IN   pccanal: ccanal
    **********************************************************************/
   FUNCTION f_calcula_modelo (
      psperson   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcagente   IN       NUMBER,
      pcdomici   IN       NUMBER, 
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr            NUMBER;
      vobjectname        VARCHAR2 (500)
                                   := 'PAC_MD_ESCALA_RIESGO.f_calcula_modelo';
      vpasexec           NUMBER (5)      := 1;
      vparam             VARCHAR2 (1000) := 'par¿metros - ';
      vmensaje           VARCHAR2 (1000) := 'par¿metros sin informar - ';
      v_tipopersona      NUMBER          := 0;
      v_tipop            NUMBER          := 0;
      v_calrieclatiper   NUMBER          := 0;
      v_calrieciiu       NUMBER          := 0;
      v_cpais            NUMBER          := 0;
      v_cprovin          NUMBER          := 0;
      v_cpoblac          NUMBER          := 0;
      v_npundep          NUMBER          := 0;
      v_calpro           NUMBER          := 0;
      v_calriecanal      NUMBER          := 0;
      v_return           NUMBER          := 0;
      v_factorcliente    NUMBER          := 0;
      v_factorjurisdi    NUMBER          := 0;
      v_factorproduct    NUMBER          := 0;
      v_factorcanal      NUMBER          := 0;
      v_opera_factores   NUMBER          := 0;
      v_scoring_total    NUMBER          := 0;
      v_cactippal        NUMBER          := 0;
      v_datsarlatf       NUMBER          := 0;
      v_ctipoemp         NUMBER          := 0;
      fecha_calculo      DATE;
      nerror             NUMBER;
      v_conta            NUMBER;
      v_cantidad         NUMBER;
      vempres            VARCHAR2 (20);
      vusu_context       VARCHAR2 (100);
      vobjage        ob_iax_agentes;
      vctipage       NUMBER;
      tfactor        VARCHAR2(20);
   BEGIN
      vusu_context := f_parinstalacion_t ('CONTEXT_USER');
      vempres := pac_contexto.f_contextovalorparametro (vusu_context, 'empresa');

      IF psperson IS NULL
      THEN
         vparam := vparam || ' psperson =' || psperson;
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL
      THEN
         vparam := vparam || ' psproduc =' || psproduc;
         RAISE e_param_error;
      END IF;

      BEGIN
        SELECT cciiu
          INTO v_datsarlatf
          FROM fin_general
         WHERE sperson = psperson
           AND sfinanci = (SELECT MAX(sfinanci) 
                             FROM fin_general 
                            WHERE sperson = psperson); 
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           BEGIN
             SELECT cciiu
               INTO v_datsarlatf
               FROM datsarlatf
              WHERE sperson = psperson
                AND ssarlaft = (SELECT MAX(ssarlaft) 
                                 FROM datsarlatf 
                                WHERE sperson = psperson)  ;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_datsarlatf := 81;
            END;
      END;

      IF v_datsarlatf IS NOT NULL
      THEN
        BEGIN
         -- CIIU
         SELECT NVL(ncalrie,0)
           INTO v_calrieciiu
           FROM per_ciiu
          WHERE cciiu = v_datsarlatf
            AND cidioma = v_idioma;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_calrieciiu := 0;
        END;     
      END IF;

      IF v_calrieciiu IS NOT NULL
      THEN
         v_factorcliente := v_calrieciiu;
      END IF;

      IF v_opera_factores < v_factorcliente
      THEN
         v_opera_factores := v_factorcliente;
         tfactor          := 'Actividad económica';
      END IF;

      -- FACTOR JURIDICCION
      BEGIN
         SELECT cprovin, cpoblac
           INTO v_cprovin, v_cpoblac
           FROM per_direcciones
          WHERE sperson = psperson
            AND cdomici = pcdomici;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cprovin := 11;
            v_cpoblac := 1;
      END;

      BEGIN
         SELECT cpais
           INTO v_cpais
           FROM per_detper
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cpais := 170;
      END;

      -- 170 nacional colombia.
      IF v_cpais IS NOT NULL AND v_cprovin IS NOT NULL
         AND v_cpoblac IS NOT NULL
      THEN
         IF (v_cpais = 170)
         THEN
            BEGIN
               SELECT NVL(npundep,0)
                 INTO v_npundep
                 FROM poblaciones
                WHERE cprovin = v_cprovin 
                  AND cpoblac = v_cpoblac;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_npundep := 0;
            END;
         ELSE
            BEGIN
               SELECT NVL(ncalparcial,0)
                 INTO v_npundep
                 FROM score_paises
                WHERE cpais = v_cpais;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_npundep := 0;
            END;
         END IF;
      END IF;

      IF v_npundep IS NOT NULL
      THEN
         v_factorjurisdi := v_npundep;
      END IF;

      IF v_opera_factores < v_factorjurisdi
      THEN
         v_opera_factores := v_factorjurisdi;
         tfactor          := 'Jurisdicción';
      END IF;

      -- FACTOR PRODUCTO
      BEGIN
         SELECT NVL(cvalpar,0)
           INTO v_calpro
           FROM parproductos
          WHERE cparpro = 'CALIFICACION_RIESDGO' 
            AND sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_calpro := 0;
      END;

      IF v_calpro IS NOT NULL
      THEN
         v_factorproduct := (v_calpro * 1);
      END IF;

      IF v_opera_factores < v_factorproduct
      THEN
         v_opera_factores := v_factorproduct;
         tfactor          := 'Producto';
      END IF;
      --
      vobjage := pac_md_redcomercial.f_get_agente(pcagente, mensajes);
			vctipage := vobjage.ctipage;
      --
      -- FACTOR CANAL
      BEGIN
         SELECT NVL(ncalrie,0)
           INTO v_calriecanal
           FROM score_canales
          WHERE ccanal = vctipage;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_calriecanal := 0;
      END;

      IF v_calriecanal IS NOT NULL
      THEN
         v_factorcanal := (v_calriecanal * 1);
      END IF;

      IF v_opera_factores < v_factorcanal
      THEN
         v_opera_factores := v_factorcanal;
         tfactor          := 'Canal';
      END IF;

      v_scoring_total := v_opera_factores;

      BEGIN
         SELECT COUNT (*)
           INTO v_cantidad
           FROM score_general
          WHERE TO_CHAR (fcalcul, 'DD/MM/YYYY HH24') =
                                        TO_CHAR (f_sysdate, 'DD/MM/YYYY HH24')
            AND sperson = psperson;
         IF v_cantidad = 0
         THEN
            -- INSERT
            INSERT INTO score_general
                        (sperson, fcalcul, nfaccli,
                         nfacjur, nfacpro, nfaccal,
                         nscotot
                        )
                 VALUES (psperson, f_sysdate, v_factorcliente,
                         v_factorjurisdi, v_factorproduct, v_factorcanal,
                         v_scoring_total
                        );         
         ELSE
            UPDATE score_general
               SET nfaccli = v_factorcliente,
                   nfacjur = v_factorjurisdi,
                   nfacpro = v_factorproduct,
                   nfaccal = v_factorcanal,
                   nscotot = v_scoring_total
             WHERE sperson = psperson
               AND TO_CHAR (fcalcul, 'DD/MM/YYYY HH24') =
                                        TO_CHAR (f_sysdate, 'DD/MM/YYYY HH24');
                                        
         END IF;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE score_general
               SET nfaccli = v_factorcliente,
                   nfacjur = v_factorjurisdi,
                   nfacpro = v_factorproduct,
                   nfaccal = v_factorcanal,
                   nscotot = v_scoring_total
             WHERE sperson = psperson
               AND TO_CHAR (fcalcul, 'DD/MM/YYYY HH24') =
                                        TO_CHAR (f_sysdate, 'DD/MM/YYYY HH24');                 
      END;
    
      IF v_scoring_total = 5 THEN
        --
        nerror := pac_iax_marcas.f_set_marca_automatica(f_empres,psperson,'0300',mensajes);  -- CJMR
        nerror := pac_md_marcas.f_del_marca_automatica(f_empres,psperson,'0301',mensajes);   -- CJMR
        --
        pac_iobj_mensajes.Crea_Nuevo_Mensaje(mensajes,2,NULL,'Tomador con riesgo extremo: '||tfactor);   
        --                                         
      ELSIF v_scoring_total >= 4 AND v_scoring_total < 5 THEN
        --
        nerror := pac_iax_marcas.f_set_marca_automatica(f_empres,psperson,'0301',mensajes);  -- CJMR
        nerror := pac_md_marcas.f_del_marca_automatica(f_empres,psperson,'0300',mensajes);   -- CJMR
        --
        pac_iobj_mensajes.Crea_Nuevo_Mensaje(mensajes,2,NULL,'Tomador con riesgo alto: '||tfactor);  
        --
      ELSE
        --
        nerror := pac_md_marcas.f_del_marca_automatica(f_empres,psperson,'0300',mensajes);  -- CJMR
        nerror := pac_md_marcas.f_del_marca_automatica(f_empres,psperson,'0301',mensajes);  -- CJMR
        --  
      END IF;
      /*
      IF v_scoring_total >= 4.9 AND v_scoring_total <= 5
      THEN
         nerror :=
            pac_iax_marcas.f_set_marca_automatica (vempres,
                                                   psperson,
                                                   '0200',
                                                   mensajes
                                                  );
         nerror :=
            pac_md_marcas.f_del_marca_automatica (vempres,
                                                  psperson,
                                                  '0201',
                                                  mensajes
                                                 );
      ELSIF v_scoring_total >= 4 AND v_scoring_total < 4.9
      THEN
         nerror :=
            pac_iax_marcas.f_set_marca_automatica (vempres,
                                                   psperson,
                                                   '0201',
                                                   mensajes
                                                  );
         nerror :=
            pac_md_marcas.f_del_marca_automatica (vempres,
                                                  psperson,
                                                  '0200',
                                                  mensajes
                                                 );
      ELSE
         nerror :=
            pac_md_marcas.f_del_marca_automatica (vempres,
                                                  psperson,
                                                  '0200',
                                                  mensajes
                                                 );
         nerror :=
            pac_md_marcas.f_del_marca_automatica (vempres,
                                                  psperson,
                                                  '0201',
                                                  mensajes
                                                 );
      END IF;
      */
      IF nerror <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN v_return;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vmensaje
                                           );
         RETURN 1;
      WHEN e_param_info
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vmensaje
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN 1;
   END f_calcula_modelo;
   -- Fin IAXIS-2016: Scoring 11/03/2019

     /**********************************************************************
      FUNCTION F_GET_SCORING_GENERAL
      Funci¿n que retorna los datos de scoring por persona.
      Param IN    psperson : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_scoring_general(
          psperson IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson = ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_ESC_RIESGO.f_get_scoring_general';
      cur            sys_refcursor;

       BEGIN

          IF psperson IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_esc_riesgo.f_get_scoring_general(psperson);

          RETURN cur;
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

             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;

             RETURN cur;
       END f_get_scoring_general;


       /*************************************************************************
         Traspasa a las EST si es necesario desde las tablas reales
         param out mensajes  : mensajes de error
         return              : Nulo si hay un error
      *************************************************************************/
       FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
          RETURN t_iax_mensajes IS
          vnumerr        NUMBER(8) := 0;
          mensajesdst    t_iax_mensajes;
          errind         ob_error;
          msg            ob_iax_mensajes;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := ' ';
          vobject        VARCHAR2(200) := 'PAC_MD_FINANCIERA.f_traspasar_errores_mensajes';
       BEGIN
          mensajesdst := t_iax_mensajes();

          IF errores IS NOT NULL THEN
             IF errores.COUNT > 0 THEN
                FOR vmj IN errores.FIRST .. errores.LAST LOOP
                   IF errores.EXISTS(vmj) THEN
                      errind := errores(vmj);
                      mensajesdst.EXTEND;
                      mensajesdst(mensajesdst.LAST) := ob_iax_mensajes();
                      mensajesdst(mensajesdst.LAST).tiperror := 1;
                      mensajesdst(mensajesdst.LAST).cerror := errind.cerror;
                      mensajesdst(mensajesdst.LAST).terror := errind.terror;
                   END IF;
                END LOOP;
             END IF;
          END IF;

          RETURN mensajesdst;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000005, vpasexec, vparam);
             RETURN mensajesdst;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000006, vpasexec, vparam);
             RETURN mensajesdst;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN mensajesdst;
       END f_traspasar_errores_mensajes;

END pac_md_esc_riesgo;

/
