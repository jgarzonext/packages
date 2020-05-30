CREATE OR REPLACE PACKAGE BODY "PAC_IAX_FINANCIERA" AS
/******************************************************************************
   NOMBRE:       pac_iax_financiera
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2016   ERH              1. Creación del package.
   2.0        24/02/2019   JLTS             2. TCS_9998 IAXIS-2490 Se adicionan campos PNCONTPOL y PNANIOSVINC en la
                                               funcion F_CALCULA_MODELO
   3.0        10/03/2019   JLTS             3.0 TCS_11;IAXIS-2119 - Creación de las funciones F_GRABAR_GENERAL_DET, F_GET_GENERAL_PERSONA_DET
	                                         y F_DEL_FIN_GENERAL_DET.
   4.0        31/05/2019  Krishnakant       4.0 IAXIS-3674:AMPLIACIóN DE LOS CAMPOS DE CONCEPTOS                      
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /**********************************************************************
      FUNCTION F_GRABAR_GENERAL
      Función que almacena los datos generales de la ficha financiera.
      Firma (Specification)
      Param IN psperson: sperson
      Param IN pcmodo: cmodo
      Param IN psfinanci: sfinanci
      Param IN ptdescrip: tdescrip
      Param IN pfccomer: fccomer
      Param IN pcfotorut: cfotorut
      Param IN pfrut: frut
      Param IN pttitulo: ttitulo
      Param IN pcfotoced: cfotoced
      Param IN pfexpiced: fexpiced
      Param IN pcpais: cpais
      Param IN pcprovin: cprovin
      Param IN pcpoblac: cpoblac
      Param IN ptinfoad: tinfoad
      Param IN pcciiu: cciiu
      Param IN pctipsoci: ctipsoci
      Param IN cestsoc: estsoc
      Param IN tobjsoc: objsoc
      Param IN texperi: experi
      Param IN fconsti: consti
      Param IN tvigenc: vigenc
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
      FUNCTION f_grabar_general(
        psperson IN NUMBER,
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
       ptdescrip IN VARCHAR2,
        pfccomer IN DATE,
       pcfotorut IN NUMBER,
           pfrut IN DATE,
        pttitulo IN VARCHAR2,
       pcfotoced IN NUMBER,
       pfexpiced IN DATE,
          pcpais IN NUMBER,
        pcprovin IN NUMBER,
        pcpoblac IN NUMBER,
        ptinfoad IN VARCHAR2,
          pcciiu IN NUMBER,
       pctipsoci IN NUMBER,
        pcestsoc IN NUMBER,
        ptobjsoc IN VARCHAR2,
        ptexperi IN VARCHAR2,
        pfconsti IN DATE,
        ptvigenc IN VARCHAR2,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_general';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_grabar_general(psperson, psfinanci, pcmodo, ptdescrip, pfccomer,
	                                                   pcfotorut, pfrut, pttitulo, pcfotoced, pfexpiced,
                                                     pcpais, pcprovin, pcpoblac, ptinfoad, pcciiu,
                                                     pctipsoci, pcestsoc, ptobjsoc, ptexperi, pfconsti,
                                                     ptvigenc, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_general;
 -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
/**********************************************************************
      FUNCTION F_GRABAR_GENERAL_DET
      Función que almacena los datos generales de la ficha financiera.
      Firma (Specification)
      Param IN pnmovimi: nmovimi
      Param IN pcmodo: cmodo
      Param IN psfinanci: sfinanci
      Param IN ptdescrip: tdescrip
      Param IN pfccomer: fccomer
      Param IN pcfotorut: cfotorut
      Param IN pfrut: frut
      Param IN pttitulo: ttitulo
      Param IN pcfotoced: cfotoced
      Param IN pfexpiced: fexpiced
      Param IN pcpais: cpais
      Param IN pcprovin: cprovin
      Param IN pcpoblac: cpoblac
      Param IN ptinfoad: tinfoad
      Param IN pcciiu: cciiu
      Param IN pctipsoci: ctipsoci
      Param IN cestsoc: estsoc
      Param IN tobjsoc: objsoc
      Param IN texperi: experi
      Param IN fconsti: consti
      Param IN tvigenc: vigenc
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
      FUNCTION f_grabar_general_det(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
          pcmodo IN VARCHAR2,
       ptdescrip IN VARCHAR2,
        pfccomer IN DATE,
       pcfotorut IN NUMBER,
           pfrut IN DATE,
        pttitulo IN VARCHAR2,
       pcfotoced IN NUMBER,
       pfexpiced IN DATE,
          pcpais IN NUMBER,
        pcprovin IN NUMBER,
        pcpoblac IN NUMBER,
        ptinfoad IN VARCHAR2,
          pcciiu IN NUMBER,
       pctipsoci IN NUMBER,
        pcestsoc IN NUMBER,
        ptobjsoc IN VARCHAR2,
        ptexperi IN VARCHAR2,
        pfconsti IN DATE,
        ptvigenc IN VARCHAR2,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_general_det';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_grabar_general_det(psfinanci, pnmovimi, pcmodo, ptdescrip, pfccomer,
                                                            pcfotorut, pfrut, pttitulo, pcfotoced, pfexpiced,
                                                            pcpais, pcprovin, pcpoblac, ptinfoad, pcciiu,
                                                            pctipsoci, pcestsoc, ptobjsoc, ptexperi, pfconsti,
                                                            ptvigenc, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_general_det;
     -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION F_GRABAR_RENTA
      Función que almacena los datos de la declaración de renta de la ficha financiera por persona.
      Firma (Specification):
      Param IN  psfinanci: sfinanci
      Param IN  pcmodo: cmodo
      Param IN  pfcorte: fcorte
      Param IN  pcesvalor: cesvalor
      Param IN  pipatriliq: ipatriliq
      Param IN  pirenta: irenta
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
       FUNCTION f_grabar_renta(
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
         pfcorte IN DATE,
       pcesvalor IN NUMBER,
      pipatriliq IN NUMBER,
         pirenta IN NUMBER,
        mensajes IN OUT t_iax_mensajes )
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_renta';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN


          vnumerr := pac_md_financiera.f_grabar_renta(psfinanci, pcmodo, pfcorte, pcesvalor, pipatriliq, pirenta, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_renta;


       /**********************************************************************
      FUNCTION F_GRABAR_ENDEUDA
      Función que almacena los datos del endeudamiento financiero de la central de riesgos por persona.
      Firma (Specification):
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcmodo: cmodo
      Param IN pcfuente: cfuente
      Param IN piminimo: iminimo
      Param IN picappag: icappag
      Param IN picapend: icapend
      Param IN piendtot: iendtot
      Param IN pncalifa: ncalifa
      Param IN pncalifb: ncalifb
      Param IN pncalifc: ncalifc
      Param IN pncalifd: ncalifd
      Param IN pncalife: ncalife
      Param IN pnconsul: nconsul
      Param IN pnscore: nscore
      Param IN pnmora: nmora
      Param IN picupog: icupog
      Param IN picupos: icupos
      Param IN pfcupo: fcupo
      Param IN ptcupor: tcupor
      Param IN pcrestric: crestric
      Param IN ptconcepc: tconcepc
      Param IN ptconceps: tconceps
      Param IN ptcburea: tcburea
      Param IN ptcotros: tcotros
      Param OUT mensajes : mesajes de error
      Return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
     FUNCTION f_grabar_endeuda(
        psfinanci IN NUMBER,
       pfconsulta IN DATE,
           pcmodo IN VARCHAR2,
         pcfuente IN NUMBER,
         piminimo IN NUMBER,
         picappag IN NUMBER,
         picapend IN NUMBER,
         piendtot IN NUMBER,
         pncalifa IN NUMBER,
         pncalifb IN NUMBER,
         pncalifc IN NUMBER,
         pncalifd IN NUMBER,
         pncalife IN NUMBER,
         pnconsul IN NUMBER,
          pnscore IN NUMBER,
           pnmora IN NUMBER,
          picupog IN NUMBER,
          picupos IN NUMBER,
           pfcupo IN DATE,
          ptcupor IN VARCHAR2,
        pcrestric IN NUMBER,
     ptconcepc IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptconceps IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptcburea IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         ptcotros IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_endeuda';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_grabar_endeuda(psfinanci, pfconsulta, pcmodo, pcfuente, piminimo,
                                                        picappag, picapend, piendtot, pncalifa, pncalifb,
                                                        pncalifc, pncalifd, pncalife, pnconsul, pnscore,
                                                        pnmora, picupog, picupos, pfcupo, ptcupor,
                                                        pcrestric, ptconcepc, ptconceps, ptcburea, ptcotros,
                                                        mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_endeuda;


        /**********************************************************************
      FUNCTION F_GRABAR_INDICADOR
      Función que almacena los datos de indicadores financieros por persona.
      Firma (Specification):
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
      Param IN pcmodo: cmodo
      Param IN pimargen: imargen
      Param IN picaptrab: icaptrab
      Param IN ptrazcor: trazcor
      Param IN ptprbaci: tprbaci
      Param IN pienduada: ienduada
      Param IN pndiacar: ndiacar
      Param IN pnrotpro: nrotpro
      Param IN pnrotinv: nrotinv
      Param IN pndiacicl: ndiacicl
      Param IN pirentab: irentab
      Param IN pioblcp: ioblcp
      Param IN piobllp: iobllp
      Param IN pigastfin: igastfin
      Param IN pivalpt: ivalpt
      Param IN pcesvalor: cesvalor
      Param IN pcmoneda: cmoneda
      Param IN pfcupo: fcupo
      Param IN picupog: icupog
      Param IN picupos: icupos
      Param IN pfcupos: fcupos
      Param IN ptcupor: tcupor
      Param IN ptconcepc: tconcepc
      Param IN ptconceps: tconceps
      Param IN ptcburea: tcburea
      Param IN ptcotros: tcotros
      Param IN pcmoncam: cmoncam
      Return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
       FUNCTION f_grabar_indicador(
        psfinanci IN NUMBER,
         pnmovimi IN NUMBER,
           pcmodo IN VARCHAR2,
         pimargen IN NUMBER,
        picaptrab IN NUMBER,
         ptrazcor IN VARCHAR2,
         ptprbaci IN VARCHAR2,
        pienduada IN NUMBER,
         pndiacar IN NUMBER,
         pnrotpro IN NUMBER,
         pnrotinv IN NUMBER,
        pndiacicl IN NUMBER,
         pirentab IN NUMBER,
          pioblcp IN NUMBER,
          piobllp IN NUMBER,
        pigastfin IN NUMBER,
          pivalpt IN NUMBER,
        pcesvalor IN NUMBER,
         pcmoneda IN VARCHAR2,
           pfcupo IN DATE,
          picupog IN NUMBER,
          picupos IN NUMBER,
          pfcupos IN DATE,
          ptcupor IN VARCHAR2,
      ptconcepc IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptconceps IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptcburea IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         ptcotros IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         pcmoncam IN VARCHAR2,
         pncapfin IN NUMBER,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_indicador';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_grabar_indicador(psfinanci, pnmovimi, pcmodo, pimargen, picaptrab,
                                                       ptrazcor, ptprbaci, pienduada, pndiacar, pnrotpro,
                                                       pnrotinv, pndiacicl, pirentab, pioblcp, piobllp,
                                                       pigastfin, pivalpt, pcesvalor, pcmoneda, pfcupo,
                                                       picupog, picupos, pfcupos, ptcupor, ptconcepc,
                                                       ptconceps, ptcburea, ptcotros, pcmoncam, pncapfin,
                                                       mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_indicador;


    /**********************************************************************
      FUNCTION F_GRABAR_DOC
      Función que almacena los documentos asociados a la ficha financiera.
      Firma (Specification):
      Param IN psfinanci: sfinanci
      Param IN pcmodo: cmodo
      Param IN pnmovimi: nmovimi
      Param IN piddocgdx: iddocgdx
      Param IN ptobser: tobser
      Return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
      FUNCTION f_grabar_doc(
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
        pnmovimi IN NUMBER,
       piddocgdx IN NUMBER,
         ptobser IN VARCHAR2,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_grabar_doc';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_grabar_doc(psfinanci, pcmodo, pnmovimi, piddocgdx,
	                                               ptobser, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_grabar_doc;

       -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
     /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA_DET
      Función que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general_persona_det(
         psperson IN NUMBER,
         pnmovimi IN NUMBER DEFAULT NULL,
         mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson = ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_general_persona_det';
      cur            sys_refcursor;

       BEGIN

          IF psperson IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_general_persona_det(psperson,pnmovimi, mensajes);

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
       END f_get_general_persona_det;
       -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019


     /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA
      Función que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general_persona(
         psperson IN NUMBER,
         mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson = ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_general_persona';
      cur            sys_refcursor;

       BEGIN

          IF psperson IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_general_persona(psperson, mensajes);

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
       END f_get_general_persona;




    /**********************************************************************
      FUNCTION F_GET_GENERAL
      Función que retorna los datos generales de la ficha financiera
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general(
         psfinanci IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_general';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_general(psfinanci, mensajes);

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
       END f_get_general;


        /**********************************************************************
      FUNCTION F_GET_RENTA
      Función que retorna los datos de la declaración de renta de la ficha financiera.
      Param IN  psfinanci: sfinanci
      Param IN DATE DEFAULT NULL pfrenta: frenta  fcorte
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_renta(
         psfinanci IN NUMBER,
           pfrenta IN DATE DEFAULT NULL,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_renta';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_renta(psfinanci, pfrenta, mensajes);

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
       END f_get_renta;

    /**********************************************************************
      FUNCTION F_GET_ENDEUDA
      Función que retorna los datos de endeudamiento financiero de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN VARCHAR2 DEFAULT NULL pfconsulta: fconsulta
      Param IN VARCHAR2 DEFAULT NULL pcfuente: cfuente
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_endeuda(
         psfinanci IN NUMBER,
      pfconsulta IN DATE DEFAULT NULL,
        pcfuente IN NUMBER DEFAULT NULL,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_endeuda';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_endeuda(psfinanci, pfconsulta, pcfuente, mensajes);

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
       END f_get_endeuda;


    /**********************************************************************
      FUNCTION F_GET_INDICADOR
      Función que retorna los datos de indicadores financieros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
       FUNCTION f_get_indicador(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_indicador';
      cur            sys_refcursor;

       BEGIN

          cur := pac_md_financiera.f_get_indicador(psfinanci, pnmovimi, mensajes);

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
       END f_get_indicador;


       /**********************************************************************
      FUNCTION F_GET_DOC
      Función que retorna los datos de los documentos asociados de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_doc(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_doc';
      cur            sys_refcursor;

       BEGIN


          cur := pac_md_financiera.f_get_doc(psfinanci, pnmovimi, mensajes);

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
       END f_get_doc;
      -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION f_del_fin_general_det
      Función elimina los datos de la tabla FIN_GENERAL_DET
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_del_fin_general_det(
        psfinanci IN fin_general_det.sfinanci%TYPE,
         pnmovimi IN fin_general_det.nmovimi%TYPE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_fin_general_det';
       BEGIN

          vnumerr := pac_md_financiera.f_del_fin_general_det(psfinanci, pnmovimi, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_del_fin_general_det;
       -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

    /**********************************************************************
      FUNCTION F_DEL_RENTA
      Función que elimina los datos de la declaración de renta de la ficha financiera por persona
      Param IN psfinanci: sfinanci
      Param IN pfcorte: fcorte
      Param IN pcesvalor: cesvalor
      Param IN pipatriliq: ipatriliq
      Param IN pirenta: irenta
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_del_renta(
       psfinanci IN fin_d_renta.sfinanci%TYPE,
         pfcorte IN fin_d_renta.fcorte%TYPE,
       pcesvalor IN fin_d_renta.cesvalor%TYPE,
      pipatriliq IN fin_d_renta.ipatriliq%TYPE,
         pirenta IN fin_d_renta.irenta%TYPE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_renta';
       BEGIN

          vnumerr := pac_md_financiera.f_del_renta(psfinanci, pfcorte, pcesvalor, pipatriliq, pirenta, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_del_renta;


       /**********************************************************************
      FUNCTION F_DEL_ENDEUDA
      Función que elimina los datos de endeudamiento financiero de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcfuente: cfuente
     **********************************************************************/
      FUNCTION f_del_endeuda(
        psfinanci IN fin_endeudamiento.sfinanci%TYPE,
       pfconsulta IN fin_endeudamiento.fconsulta%TYPE,
         pcfuente IN fin_endeudamiento.cfuente%TYPE,
         mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_endeuda';
       BEGIN

          vnumerr := pac_md_financiera.f_del_endeuda(psfinanci, pfconsulta, pcfuente, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_del_endeuda;


      /**********************************************************************
      FUNCTION F_DEL_INDICADOR
      Función que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
       FUNCTION f_del_indicador(
         psfinanci IN fin_indicadores.sfinanci%TYPE,
          pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_indicador';
       BEGIN

          vnumerr := pac_md_financiera.f_del_indicador(psfinanci, pnmovimi, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_del_indicador;


      -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
      /**********************************************************************
      FUNCTION F_DEL_PARAMETRO
      Función que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
       FUNCTION f_del_parametro(
         psfinanci IN fin_indicadores.sfinanci%TYPE,
          pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_indicador';
       BEGIN

          vnumerr := pac_md_financiera.f_del_parametro(psfinanci, pnmovimi, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;

          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_del_parametro;
       -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_GET_PARCUENTA
      Función que retorna los datos de parametros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_parcuenta(
       psfinanci IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_parcuenta';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_parcuenta(psfinanci, mensajes);

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
       END f_get_parcuenta;


    /**********************************************************************
      FUNCTION F_INS_PARCUENTA
      Función que almacena los datos de los parametros de la ficha financiera.
      Firma (Specification):
      Param IN  psfinanci: sfinanci
      Param IN  pcparam: cparam
      Param IN  pnvalpar: nvalpar
      Param IN  ptvalpar: tvalpar
      Param IN  pfvalpar: pfvalpar
     **********************************************************************/
      FUNCTION f_ins_parcuenta(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
         pcparam IN VARCHAR2,
        pnvalpar IN NUMBER,
        ptvalpar IN VARCHAR2,
        pfvalpar IN DATE,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_ins_parcuenta';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_ins_parcuenta(psfinanci, pnmovimi, pcparam, pnvalpar, ptvalpar, pfvalpar, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_ins_parcuenta;


     /**********************************************************************
      FUNCTION F_CALCULA_MODELO
      Función que genera el calculo modelo de la ficha financiera
      Firma (Specification):
      Param IN  psfinanci: sfinanci
      Param IN  pcesvalor: cesvalor
      Param IN  pcuposug: cuposug
      Param IN  pcupogar: cupogar
     **********************************************************************/
        FUNCTION f_calcula_modelo(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
       pcesvalor IN NUMBER,
        pcuposug OUT NUMBER,
        pcupogar OUT NUMBER,
        pcapafin OUT NUMBER,
        pcuposugv1 OUT NUMBER,
        pcupogarv1 OUT NUMBER,
        pcapafinv1 OUT NUMBER,
        pncontpol OUT NUMBER, -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
        pnaniosvinc OUT NUMBER, -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
		pcmonori IN VARCHAR2,
        pcmondes IN VARCHAR2,
        mensajes IN OUT T_IAX_MENSAJES )
        RETURN NUMBER IS
        vnumerr        NUMBER;
        vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_calcula_modelo';
        vpasexec       NUMBER(5) := 1;
        vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_calcula_modelo(psfinanci, pnmovimi, pcesvalor, pcuposug, pcupogar, pcapafin, pcuposugv1, pcupogarv1, pcapafinv1, pncontpol,pnaniosvinc,pcmonori, pcmondes, mensajes);


          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          --COMMIT
          RETURN vnumerr;

       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_calcula_modelo;


    /**********************************************************************
      FUNCTION f_get_cifin_intermedio
      Función que retorna los datos de cifin intermenio.
      Param IN  pctipide  : ctipide
      Param IN  pnnumide  : snnumide
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_cifin_intermedio(
          pctipide IN NUMBER,
          pnnumide IN VARCHAR2,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pctipide = ' || pctipide || 'pnnumide = ' || pnnumide;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_cifin_intermedio';
      cur            sys_refcursor;

       BEGIN

          IF pctipide IS NULL THEN
             RAISE e_object_error;
          END IF;

          IF pnnumide IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_cifin_intermedio(pctipide, pnnumide, mensajes);

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
       END f_get_cifin_intermedio;


     /**********************************************************************
      FUNCTION f_get_int_carga_informacol
      Función que retorna los datos de informa colombia.
      Param IN  pnit  : nit
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_int_carga_informacol(
        pnit IN VARCHAR2,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnit = ' || pnit;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_int_carga_informacol';
      cur            sys_refcursor;

       BEGIN

          IF pnit IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_int_carga_informacol(pnit, mensajes);

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
       END f_get_int_carga_informacol;


     /**********************************************************************
      FUNCTION F_INDICADORES_CLIENTE
      Función que consulta el margen operacional.
      Param IN psfinanci: sfinanci
      Param OUT pmaropecl: maropecl
      Param OUT pcaptracl: captracl
      Param OUT prazcorcl: razcorcl
      Param OUT ppruacicl: pruacicl
      Param OUT pendtotcl: endtotcl
      Param OUT protcarcl: rotcarcl
      Param OUT protprocl: rotprocl
      Param OUT protinvcl: rotinvcl
      Param OUT pcicefecl: cicefecl
      Param OUT prentabcl: rentabcl
      Param OUT pobficpcl: obficpcl
      Param OUT pobfilpcl: obfilpcl
      Param OUT pgasfincl: gasfincl
     **********************************************************************/
      FUNCTION f_indicadores_cliente(
         psfinanci IN NUMBER,
          pnmovimi IN NUMBER,
          pcmonori IN VARCHAR2,
          pcmondes IN VARCHAR2,
         pmaropecl OUT NUMBER,
         pcaptracl OUT NUMBER,
         prazcorcl OUT NUMBER,
         ppruacicl OUT NUMBER,
         pendtotcl OUT NUMBER,
         protcarcl OUT NUMBER,
         protprocl OUT NUMBER,
         protinvcl OUT NUMBER,
         pcicefecl OUT NUMBER,
         prentabcl OUT NUMBER,
         pobficpcl OUT NUMBER,
         pobfilpcl OUT NUMBER,
         pgasfincl OUT NUMBER,
         mensajes IN OUT T_IAX_MENSAJES)
        RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_indicadores_cliente';
       BEGIN

           IF psfinanci IS NULL THEN
             RAISE e_object_error;
           END IF;

           vnumerr := pac_md_financiera.f_indicadores_cliente(psfinanci, pnmovimi,   pcmonori,  pcmondes, pmaropecl,  pcaptracl,
                                                              prazcorcl, ppruacicl, pendtotcl, protcarcl, protprocl,
                                                              protinvcl, pcicefecl, prentabcl, pobficpcl, pobfilpcl,
                                                              pgasfincl, mensajes);

           IF vnumerr = 1 THEN
             RAISE e_object_error;
           END IF;

           RETURN vnumerr;

       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_indicadores_cliente;


     /**********************************************************************
      FUNCTION F_INDICADORES_SECTOR
      Función que consulta los indicadores del cliente.
      Param  IN psfinanci: sfinanci
      Param OUT pmaropese: maropese
      Param OUT pcaptrase: captrase
      Param OUT prazcorse: razcorse
      Param OUT ppruacise: pruacise
      Param OUT pendtotse: endtotse
      Param OUT protcarse: rotcarse
      Param OUT protprose: rotprose
      Param OUT protinvse: rotinvse
      Param OUT pcicefese: cicefese
      Param OUT prentabse: rentabse
      Param OUT pobficpse: obficpse
      Param OUT pobfilpse: obfilpse
      Param OUT pgasfinse: gasfinse
     **********************************************************************/
      FUNCTION f_indicadores_sector(
         psfinanci IN NUMBER,
          pnmovimi IN NUMBER,
          pcmonori IN VARCHAR2,
          pcmondes IN VARCHAR2,
         pmaropese OUT NUMBER,
         pcaptrase OUT NUMBER,
         prazcorse OUT NUMBER,
         ppruacise OUT NUMBER,
         pendtotse OUT NUMBER,
         protcarse OUT NUMBER,
         protprose OUT NUMBER,
         protinvse OUT NUMBER,
         pcicefese OUT NUMBER,
         prentabse OUT NUMBER,
         pobficpse OUT NUMBER,
         pobfilpse OUT NUMBER,
         pgasfinse OUT NUMBER,
         mensajes IN OUT T_IAX_MENSAJES)
        RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_indicadores_sector';
       BEGIN

           IF psfinanci IS NULL THEN
             RAISE e_object_error;
           END IF;

           vnumerr := pac_md_financiera.f_indicadores_sector(psfinanci, pnmovimi,   pcmonori, pcmondes, pmaropese, pcaptrase,
                                                             prazcorse, ppruacise, pendtotse, protcarse, protprose,
                                                             protinvse, pcicefese, prentabse, pobficpse, pobfilpse,
                                                             pgasfinse, mensajes);

           IF vnumerr = 1 THEN
             RAISE e_object_error;
           END IF;

           RETURN vnumerr;

       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_indicadores_sector;
    -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_VPATRIMONIAL
      Función que valida la ecuación patrimonial.
      Param  IN psfinanci: sfinanci
      Param  IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_vpatrimonial(
         psfinanci IN NUMBER,
          pnmovimi IN NUMBER,
         mensajes IN OUT T_IAX_MENSAJES)
        RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_vpatrimonial';
       BEGIN

           IF psfinanci IS NULL THEN
             RAISE e_object_error;
           END IF;

           vnumerr := pac_md_financiera.f_vpatrimonial(psfinanci, pnmovimi, mensajes);


           IF vnumerr <> 0 THEN
             --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
             RAISE e_object_error;
           END IF;


           RETURN vnumerr;

       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_vpatrimonial;
       -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
     /**********************************************************************
      FUNCTION F_GET_FIN_INDICA_SECTOR
      Función que retorna los datos de los indicadores del sector.
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_fin_indica_sector(
        psfinanci IN NUMBER,
         pcmonori IN VARCHAR2,
         pcmondes IN VARCHAR2,
         mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_fin_indica_sector';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_fin_indica_sector(psfinanci, pcmonori, pcmondes, mensajes);

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
       END f_get_fin_indica_sector;



        -- ===========================================================================
        --  P A R A M E T R O S  C O N E X I O N
        -- ===========================================================================
            /*************************************************************************
               Devuelve la lista de parámetros de CONEXION
               param out mensajes : mensajes de error
               return             : descripción del parámetro -> Si ha ido bién
                                    NULL -> Si ha ido mal
            *************************************************************************/
           FUNCTION f_get_conparam(
              psfinanci IN NUMBER,
               pnmovimi IN NUMBER,
               pcmonori IN VARCHAR2,
               pcmondes IN VARCHAR2,
              mensajes OUT t_iax_mensajes)
              RETURN sys_refcursor IS
              vcursor        sys_refcursor;
              vnumerr        NUMBER(8);
              vpasexec       NUMBER(8) := 1;
              vparam         VARCHAR2(2000) := NULL;
              vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.F_get_conparam';
           BEGIN
              vpasexec := 3;
              --Recuperació dels paràmetres del producte.
              vcursor := pac_md_financiera.f_get_conparam(psfinanci, pnmovimi, pcmonori, pcmondes, mensajes);
              --Tot ok
              RETURN vcursor;
           EXCEPTION
              WHEN e_param_error THEN
                 IF vcursor%ISOPEN THEN
                    CLOSE vcursor;
                 END IF;

                 pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
                 RETURN vcursor;
              WHEN OTHERS THEN
                 IF vcursor%ISOPEN THEN
                    CLOSE vcursor;
                 END IF;

                 pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                                   SQLCODE, SQLERRM);
                 RETURN vcursor;
           END f_get_conparam;

      FUNCTION f_modificar_cciiu(
         psfinanci IN NUMBER,
            pcciiu IN NUMBER,
          mensajes OUT t_iax_mensajes)
        RETURN NUMBER IS
        vnumerr        NUMBER;
        vobjectname    VARCHAR2(500) := 'PAC_IAX_FINANCIERA.f_modificar_cciiu';
        vpasexec       NUMBER(5) := 1;
        vparam         VARCHAR2(1000) := 'parámetros - ';

       BEGIN

          vnumerr := pac_md_financiera.f_modificar_cciiu(psfinanci, pcciiu, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                               NULL, SQLCODE, SQLERRM);
             RETURN 1;
       END f_modificar_cciiu;


     /**********************************************************************
      FUNCTION F_GET_PERSONA_FIN
      Función que retorna los datos deL tipo de persona.
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_persona_fin(
         psfinanci IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
      vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_get_persona_fin';
      cur            sys_refcursor;

       BEGIN

          IF psfinanci IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_financiera.f_get_persona_fin(psfinanci, mensajes);

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
       END f_get_persona_fin;

END pac_iax_financiera;
/
