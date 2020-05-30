CREATE OR REPLACE PACKAGE "PAC_MD_FINANCIERA" AS
/******************************************************************************
   NOMBRE:     pac_md_financiera
   PROPÃ“SITO:  Funciones para realizar una conexiÃ³n
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/06/2016   ERH               1. CreaciÃ³n del package.
   2.0        10/03/2019   JLTS              2.0 TCS_11;IAXIS-2119 - Creación de las funciones F_GRABAR_GENERAL_DET, F_GET_GENERAL_PERSONA_DET
	                                         y F_DEL_FIN_GENERAL_DET.
   3.0      31/05/2019  Krishnakant    3.0 IAXIS-3674:AMPLIACIN DE LOS CAMPOS DE CONCEPTOS

******************************************************************************/
    /**********************************************************************
      FUNCTION F_GRABAR_GENERAL
      FunciÃ³n que almacena los datos generales de la ficha financiera.
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
      Return             : 0 todo ha sido correcto
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
        mensajes IN OUT T_IAX_MENSAJES )
        RETURN NUMBER;
	-- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
 /**********************************************************************
      FUNCTION F_GRABAR_GENERAL_DET
      FunciÃ³n que almacena los datos generales de la ficha financiera.
      Firma (Specification)
      Param IN nmovimi: sperson
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
      Return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
     -- AABC 07/03/2019 Validacion Fin_general_det
      FUNCTION f_grabar_general_det(
        psfinanci IN NUMBER,
        pnmovimi  IN NUMBER,
          pcmodo  IN VARCHAR2,
       ptdescrip  IN VARCHAR2,
        pfccomer  IN DATE,
       pcfotorut  IN NUMBER,
           pfrut  IN DATE,
        pttitulo  IN VARCHAR2,
       pcfotoced  IN NUMBER,
       pfexpiced  IN DATE,
          pcpais  IN NUMBER,
        pcprovin  IN NUMBER,
        pcpoblac  IN NUMBER,
        ptinfoad  IN VARCHAR2,
          pcciiu  IN NUMBER,
       pctipsoci  IN NUMBER,
        pcestsoc  IN NUMBER,
        ptobjsoc  IN VARCHAR2,
        ptexperi  IN VARCHAR2,
        pfconsti  IN DATE,
        ptvigenc  IN VARCHAR2,
        mensajes  IN OUT T_IAX_MENSAJES )
        RETURN NUMBER;
     -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION F_GRABAR_RENTA
      FunciÃ³n que almacena los datos de la declaraciÃ³n de renta de la ficha financiera por persona.
      Firma (Specification):
      Param IN  psfinanci: sfinanci
      Param IN  pcmodo: cmodo
      Param IN  pfcorte: fcorte
      Param IN  pcesvalor: cesvalor
      Param IN  pipatriliq: ipatriliq
      Param IN  pirenta: irenta
      Param OUT mensajes : mesajes de error
      Return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
     FUNCTION f_grabar_renta(
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
         pfcorte IN DATE,
       pcesvalor IN NUMBER,
      pipatriliq IN NUMBER,
         pirenta IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GRABAR_ENDEUDA
      FunciÃ³n que almacena los datos del endeudamiento financiero de la central de riesgos por persona.
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
         mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GRABAR_INDICADOR
      FunciÃ³n que almacena los datos de indicadores financieros por persona.
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
         mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION F_GRABAR_DOC
      FunciÃ³n que almacena los documentos asociados a la ficha financiera.
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
        mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;

     -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
     /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA_DET
      Funci?n que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general_persona_det(
          psperson IN NUMBER,
          pnmovimi IN NUMBER DEFAULT NULL,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;
     -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

    /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA
      FunciÃ³n que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general_persona(
         psperson IN NUMBER,
         mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_GENERAL
      FunciÃ³n que retorna los datos generales de la ficha financiera
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general(
         psfinanci IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_RENTA
      FunciÃ³n que retorna los datos de la declaraciÃ³n de renta de la ficha financiera.
      Param IN  psfinanci: sfinanci
      Param IN DATE DEFAULT NULL pfrenta: frenta  fcorte
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_renta(
      psfinanci IN NUMBER,
        pfrenta IN DATE DEFAULT NULL,
       mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_ENDEUDA
      FunciÃ³n que retorna los datos de endeudamiento financiero de la ficha financiera
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
       RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION F_GET_INDICADOR
      FunciÃ³n que retorna los datos de indicadores financieros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_indicador(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL,
        mensajes IN OUT T_IAX_MENSAJES)
       RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_DOC
      FunciÃ³n que retorna los datos de los documentos asociados de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_doc(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL,
        mensajes IN OUT T_IAX_MENSAJES)
       RETURN sys_refcursor;

    -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION F_DEL_FIN_GENERL_DET
      Función que elimina los datos de la fin_general_det
      Param IN psfinanci: sfinanci
      Param IN pfcorte: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_del_fin_general_det(
        psfinanci IN fin_general_det.sfinanci%TYPE,
         pnmovimi IN fin_general_det.nmovimi%TYPE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER;
     -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019


    /**********************************************************************
      FUNCTION F_DEL_RENTA
      FunciÃ³n que elimina los datos de la declaraciÃ³n de renta de la ficha financiera por persona
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
        mensajes IN OUT T_IAX_MENSAJES)
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION F_DEL_ENDEUDA
      FunciÃ³n que elimina los datos de endeudamiento financiero de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcfuente: cfuente
     **********************************************************************/
      FUNCTION f_del_endeuda(
        psfinanci IN fin_endeudamiento.sfinanci%TYPE,
       pfconsulta IN fin_endeudamiento.fconsulta%TYPE,
         pcfuente IN fin_endeudamiento.cfuente%TYPE,
         mensajes IN OUT T_IAX_MENSAJES)
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION F_DEL_INDICADOR
      FunciÃ³n que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_del_indicador(
        psfinanci IN fin_indicadores.sfinanci%TYPE,
         pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL,
         mensajes IN OUT T_IAX_MENSAJES)
       RETURN NUMBER;
    -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_DEL_PARAMETRO
      Funci?n que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
       FUNCTION f_del_parametro(
         psfinanci IN fin_indicadores.sfinanci%TYPE,
          pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER;
     -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_GET_PARCUENTA
      FunciÃ³n que retorna los datos de parametros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_parcuenta(
       psfinanci IN NUMBER,
       mensajes IN OUT T_IAX_MENSAJES)
       RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_INS_PARCUENTA
      FunciÃ³n que almacena los datos de los parametros de la ficha financiera.
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
        mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_CALCULA_MODELO
      FunciÃ³n que genera el calculo modelo de la ficha financiera
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
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION f_get_cifin_intermedio
      FunciÃ³n que retorna los datos de cifin intermenio.
      Param IN  pctipide  : ctipide
      Param IN  pnnumide  : snnumide
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_cifin_intermedio(
         pctipide IN NUMBER,
         pnnumide IN VARCHAR2,
         mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;

     /**********************************************************************
      FUNCTION f_get_int_carga_informacol
      FunciÃ³n que retorna los datos de informa colombia.
      Param IN  pnit  : nit
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_int_carga_informacol(
        pnit IN VARCHAR2,
        mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;


    -- Pasa de t_ob_errores a T_IAX_MENSAJES
   FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
      RETURN t_iax_mensajes;


     /**********************************************************************
      FUNCTION F_INDICADORES_CLIENTE
      FunciÃ³n que consulta los indicadores del cliente.
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
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_INDICADORES_SECTOR
      FunciÃ³n que consulta los indicadores del cliente.
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
       RETURN NUMBER;

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
        RETURN NUMBER;
    -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
				

     /**********************************************************************
      FUNCTION F_GET_FIN_INDICA_SECTOR
      FunciÃ³n que retorna los datos de los indicadores del sector.
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_fin_indica_sector(
         psfinanci IN NUMBER,
          pcmonori IN VARCHAR2,
          pcmondes IN VARCHAR2,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;


    -- ===========================================================================
    --  P A R A M E T R O S  C O N E X I O N
    -- ===========================================================================
       FUNCTION f_get_conparam(
        psfinanci IN NUMBER,
         pnmovimi IN NUMBER,
         pcmonori IN VARCHAR2,
         pcmondes IN VARCHAR2,
        mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor;

      PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser);

       FUNCTION f_modificar_cciiu(
         psfinanci IN NUMBER,
            pcciiu IN NUMBER,
          mensajes OUT T_IAX_MENSAJES )
        RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_PERSONA_FIN
      FunciÃ³n que retorna los datos deL tipo de persona.
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_persona_fin(
      psfinanci IN NUMBER,
       mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor;

END pac_md_financiera;
/