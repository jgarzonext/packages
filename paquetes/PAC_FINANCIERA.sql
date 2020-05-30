CREATE OR REPLACE PACKAGE "PAC_FINANCIERA" AS

  	/******************************************************************************
	  NOMBRE:     PAC_FINANCIERA
	  PROPÓSITO:  Package que contiene las funciones de Cross - ficha financiera

	  REVISIONES:
	  Ver        Fecha        Autor             Descripción
	  ---------  ----------  ---------------  ------------------------------------
	  1.0        08/06/2016   ERH              1.0 0018790: CONF001 - Creación.
          2.0        10/03/2019   JLTS             2.0 TCS_11;IAXIS-2119 - Creación de las funciones F_GRABAR_GENERAL_DET, F_GET_GENERAL_PERSONA_DET
	                                               y F_DEL_FIN_GENERAL_DET.
          3.0      31/05/2019  Krishnakant    3.0 IAXIS-3674:AMPLIACIN DE LOS CAMPOS DE CONCEPTOS                    
          4.0        19/02/2020   JLTS             4.0 IAXIS-2099: Se crea la función f_grab_agenda_no_inf_fin
 	******************************************************************************/


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
      Función que almacena los datos generales DET de la ficha financiera.
      Firma (Specification)
      Param IN psfinanci: sfinanci
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
     **********************************************************************/
     -- AABC 07/03/2019 Validacion fin_geneneral_det
     FUNCTION f_grabar_general_det(
     psfinanci IN NUMBER,
     pnmovimi  IN NUMBER,
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
      Función que almacena los documentos asociados a la ficha financiera.
      Firma (Specification):
      Param IN psfinanci: sfinanci
      Param IN pcmodo: cmodo
      Param IN pnmovimi: nmovimi
      Param IN piddocgdx: iddocgdx
      Param IN ptobser: tobser
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
      Funci¿¿¿¿n que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_general_persona_det(
        psperson IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL
          )
      RETURN sys_refcursor;
     -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

    /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA
      Función que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general_persona(
         psperson IN NUMBER)
      RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_GENERAL
      Función que retorna los datos generales de la ficha financiera
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_general(
        psfinanci IN NUMBER)
      RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION F_GET_RENTA
      Función que retorna los datos de la declaración de renta de la ficha financiera.
      Param IN  psfinanci: sfinanci
      Param IN DATE DEFAULT NULL pfrenta: frenta  fcorte
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_renta(
      psfinanci IN NUMBER,
        pfrenta IN DATE DEFAULT NULL)
      RETURN sys_refcursor;


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
        pcfuente IN NUMBER DEFAULT NULL)
       RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_INDICADOR
      Función que retorna los datos de indicadores financieros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_indicador(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL)
       RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_GET_DOC
      Función que retorna los datos de los documentos asociados de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_doc(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL)
       RETURN sys_refcursor;


    /**********************************************************************
      FUNCTION F_DEL_RENTA
      Función que elimina los datos de la declaración de renta de la ficha financiera por persona
      Param IN psfinanci: sfinanci
      Param IN pfcorte: fcorte
      Param IN pcesvalor: cesvalor
      Param IN pipatriliq: ipatriliq
      Param IN pirenta: irenta
     **********************************************************************/
      FUNCTION f_del_renta(
       psfinanci IN fin_d_renta.sfinanci%TYPE,
         pfcorte IN fin_d_renta.fcorte%TYPE,
       pcesvalor IN fin_d_renta.cesvalor%TYPE,
      pipatriliq IN fin_d_renta.ipatriliq%TYPE,
         pirenta IN fin_d_renta.irenta%TYPE
        )
       RETURN NUMBER;

     -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
         /**********************************************************************
      FUNCTION F_DEL_FIN_GENERAL_DET
      Funciónn que elimina los datos de endeudamiento financiero de la ficha financiera det
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcfuente: cfuente
     **********************************************************************/
      FUNCTION f_del_fin_general_det(
        psfinanci IN fin_general_det.sfinanci%TYPE,
         pnmovimi IN fin_general_det.nmovimi%TYPE,
        mensajes IN OUT T_IAX_MENSAJES)
       RETURN NUMBER;

      -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019


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
         pcfuente IN fin_endeudamiento.cfuente%TYPE)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_DEL_INDICADOR
      Función que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_del_indicador(
        psfinanci IN fin_indicadores.sfinanci%TYPE,
         pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL)
       RETURN NUMBER;
    -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_DEL_PARAMETRO
      Funci¿¿¿¿n que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_del_parametro(
        psfinanci IN fin_indicadores.sfinanci%TYPE,
         pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL )
       RETURN NUMBER;
     -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_GET_PARCUENTA
      Función que retorna los datos de parametros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_parcuenta(
       psfinanci IN NUMBER )
       RETURN sys_refcursor;


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
        mensajes IN OUT T_IAX_MENSAJES )
       RETURN NUMBER;

    /**********************************************************************
      FUNCTION F_CONECTAR_CIFIN
      Función que realiza la conexión con cifin
      Firma (Specification):
      Param IN  psperson: psperson
     **********************************************************************/



    /**********************************************************************
      FUNCTION F_EXTRAER_XML_CIFIN
      Función que realiza la extracción de la información que nos dio como
      respuesta el WebService de la CIFIN
      Firma (Specification):
      Param IN  psfinanci: psfinanci
      Param IN  pnsinterf: pnsinterf
     **********************************************************************/
       FUNCTION f_extraer_xml_cifin(
       psfinanci IN NUMBER,
       pnsinterf IN NUMBER )
       RETURN NUMBER;

    /**********************************************************************
      FUNCTION F_FACTOR_S
      Función que realiza el cálculo del factor S de modelo Zeus, esto como
      parte del cálculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_s(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;

    /**********************************************************************
      FUNCTION f_factor_r
      Función que realiza el cálculo del factor Riesgo del Pais para
      extranjeros del modelo Zeus, esto como parte del cálculo del cupo
      sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_r(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;

     /**********************************************************************
      FUNCTION f_factor_f
      Función que realiza el cálculo del factor Financiero para extranjeros,
      esto como parte del cálculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_f(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;

     /**********************************************************************
      FUNCTION f_factor_z
      Función que realiza el cálculo del factor Z Altman, esto como parte
      del cálculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_z(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;

    /**********************************************************************
      FUNCTION f_factor_c
      Función que realiza el cálculo del factor de Caja Personas Juridicas,
      esto como parte del cálculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_c(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;

     /**********************************************************************
      FUNCTION f_factor_n
      Función que realiza el cálculo para personas naturales, esto como parte
      del cálculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_n(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION f_factor_p
      Función que realiza el cálculo de pólizas asociadas a la persona y su
      calificación correspondiente, esto como parte del cálculo del cupo
      sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_p(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;


    /**********************************************************************
      FUNCTION f_factor_a
      Función que realiza el cálculo de años e experiencia de la persona dentro
      de la compañía aseguradora y su calificación correspondiente, esto como
      parte del cálculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_a(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;



     /**********************************************************************
      FUNCTION f_get_fin_param
      Función que consulta el valor de un parametro
      Firma (Specification):
      Param IN  psfinanci: psfinanci
      Param IN    pcparam: pcparam
     **********************************************************************/
       FUNCTION f_get_fin_param(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
         pcparam IN VARCHAR2)
       RETURN NUMBER;



     /**********************************************************************
      FUNCTION f_get_fin_rango
      Función que consulta el valor de la calificacion propia
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_get_fin_rango(
       pcvariable IN VARCHAR2,
       pnvalor IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION f_get_fin_rango_fijo
      Función que consulta el valor de la calificacion propia
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_get_fin_rango_fijo(
       pcvariable IN VARCHAR2,
       ptvalor IN VARCHAR2)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION f_get_cifin_intermedio
      Función que retorna los datos de cifin intermenio.
      Param IN  pctipide  : ctipide
      Param IN  pnnumide  : snnumide
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_cifin_intermedio(
        pctipide IN NUMBER,
        pnnumide IN VARCHAR2)
      RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION f_get_int_carga_informacol
      Función que retorna los datos de informa colombia.
      Param IN  pnit  : nit
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_int_carga_informacol(
        pnit IN VARCHAR2)
      RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION F_GET_FIN_INDICA_SECTOR
      Función que retorna los datos de los indicadores del sector.
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_fin_indica_sector(
         psfinanci IN NUMBER,
         pcmonori IN VARCHAR2,
         pcmondes IN VARCHAR2)
      RETURN sys_refcursor;


     /**********************************************************************
      FUNCTION F_GET_CIIU
      Función que consulta el valor de CIIU
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_ciiu(
          psfinanci IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_NIT
      Función que consulta el valor de NIT
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_nit(
          psfinanci IN NUMBER)
       RETURN VARCHAR2;


     /**********************************************************************
      FUNCTION F_GET_UTLOPERACIONAL
      Función que consulta el valor del indicador UTLOPERACIONAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_utloperacional(
           pciiu IN NUMBER,
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_VENTAS
      Función que consulta el valor del indicador VENTAS
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_ventas(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_ACTCORRIENTE
      Función que consulta el valor del indicador ACTCORRIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_actcorriente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_PASCORRIENTE
      Función que consulta el valor del indicador PASCORRIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_pascorriente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_INVENTARIO
      Función que consulta el valor del indicador INVENTARIO
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_inventario(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;

     /**********************************************************************
      FUNCTION F_GET_PASTOTAL
      Función que consulta el valor del indicador PASTOTAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_pastotal(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_ACTIVOTOTAL
      Función que consulta el valor del indicador ACTIVOTOTAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_activototal(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_CARTCLIENTE
      Función que consulta el valor del indicador CARTCLIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_cartcliente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_PROVEEDORESCP
      Función que consulta el valor del indicador PROVEEDORESCP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_proveedorescp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_COSTOVENTAS
      Función que consulta el valor del indicador COSTOVENTAS
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_costoventas(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_UTLNETA
      Función que consulta el valor del indicador UTLNETA
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_utlneta(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_OBLIGFINANCP
      Función que consulta el valor del indicador OBLIGFINANCP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_obligfinancp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_OBLIGFINANLP
      Función que consulta el valor del indicador OBLIGFINANLP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_obligfinanlp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_GASTOSFINAN
      Función que consulta el valor del indicador GASTOSFINAN
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_gastosfinan(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
       RETURN NUMBER;


     /**********************************************************************
      FUNCTION F_GET_ITASA
      Función que consulta el valor de ITASA
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_itasa(
          psfinanci IN NUMBER,
		   pnmovimi IN NUMBER,
           pcmonori IN VARCHAR2,
           pcmondes IN VARCHAR2,
            pcparam IN VARCHAR2)
       RETURN NUMBER;

       FUNCTION f_modificar_cciiu(
       psfinanci IN NUMBER,
          pcciiu IN NUMBER,
        mensajes OUT T_IAX_MENSAJES )
        RETURN NUMBER;

    /**********************************************************************
      FUNCTION F_GET_PERSONA_FIN
      Función que retorna los datos deL tipo de persona.
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_persona_fin(
      psfinanci IN NUMBER)
      RETURN sys_refcursor;

      /**********************************************************************
     PROCEDURE P_UPDATE_FIN_GRAL_TO_INFORMA
      Procedimiento que actualiza los datos correspondientes a la información general de la ficha financiera encontrada a través del WS de Informa Colombia
      Param IN  pnit  : nit
      Fecha y Usuario Creacion: 21/11/2018 - csuarez
      Fecha  y Usuario Modificaciones:

     **********************************************************************/
 PROCEDURE P_UPDATE_FIN_GRAL_TO_INFORMA( pnit IN VARCHAR2);
    -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    /**********************************************************************
      FUNCTION F_VPATRIMONIAL (Validación patrimonial)
      Función que valida la ecuación patrimonial.
      Param  IN psfinanci: sfinanci
      Param  IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_vpatrimonial(psfinanci IN NUMBER, pnmovimi IN NUMBER, mensajes IN OUT t_iax_mensajes) 
				RETURN NUMBER;
        -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validación de la ecuación patrimonial
    -- INI -IAXIS-2099 -19/02/2020
    /******************************************************************************
      NOMBRE:    F_GRAB_AGENDA_NO_INF_FIN
      PROPSITO:  Funci󮠱ue almacena los datos de agenda de una persona cuando no tiene informaci󮠍
                 financiera actualizada.
                 El último cierre contable, se validara después del cuarto mes del año, es decir, en 
                 el de mayo la información financiera deberá star al cierre contable del inmediatamente anterior.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
    FUNCTION f_grab_agenda_no_inf_fin(psperson IN NUMBER,
                                      mensajes IN OUT t_iax_mensajes)
    
     RETURN NUMBER;
    -- FIN -IAXIS-2099 -19/02/2020

END PAC_FINANCIERA;
/