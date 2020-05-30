/* Formatted on 2019/08/09 17:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_md_financiera
AS
/******************************************************************************
   NOMBRE:     pac_md_financiera
   PROP?SITO:  Funciones para realizar una conexi?n
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripci?n
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/06/2016   ERH               1. Creaci?n del package.
   2.0        29/11/2018   ACL               2. Modificacion de la funci? f_calcula_modelo cuando pnmovimi sea nulo.
   3.0        14/01/2019   JLTS              3. Ajuste de las condicionales de este factor c
   4.0        19/02/2018   JLTS              4. TCS_453B. Se ajustan las sentencias de SQL de la funcin f_calcuila_modelo
                                                que seleccionan datos de NVALPAR o TVALPARA incluyendo la funcin.
                                                nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
   5.0        25/02/2019   JLTS              5.0 IAXIS-2596 - Se ingresa la condicin de capacidad financiera. Funcion f_calcla_modelo
   6.0        27/02/2019   KRISHNAKANT       6.0 IAXIS-2120 - Declaracion de renta
   7.0        10/03/2019   JLTS              7.0 TCS_11;IAXIS-2119 - Creacin de las funciones F_GRABAR_GENERAL_DET, F_GET_GENERAL_PERSONA_DET
                                            y F_DEL_FIN_GENERAL_DET.
   8.0        15/04/2019   ECP              8.0 IAXIS-2122.  Reporte en Ingls
   9.0        15/04/2019   JLTS              9.0 IAXIS-3673. Validacin de la ecuacin patrimonial
  10.0        24/05/2019   JLTS             10.0 IAXIS-4143 Se ajustan algunos valores para que tomen variables de empresa y no sean valores quemados
  11.0        31/05/2019   Krishnakant      11.0 IAXIS-3674:AMPLIACIN DE LOS CAMPOS DE CONCEPTOS
  12.0        09/08/2019   ECP              12.0 IAXIS-4985. Tarifa Endosos
  13.0        06/11/2019   CJMR             13.0 IAXIS-4834. Marca Situación financiera deteriorada 
  14.0        19/02/2020   ECP              14.0 IAXIS-7548. Reporte Cupos   
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
   e_param_info     EXCEPTION;
   e_info           EXCEPTION;
   v_idioma         NUMBER    := pac_md_common.f_get_cxtidioma ();

    /**********************************************************************
    FUNCTION F_GRABAR_GENERAL
    Funci?n que almacena los datos generales de la ficha financiera.
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
   FUNCTION f_grabar_general (
      psperson    IN       NUMBER,
      psfinanci   IN       NUMBER,
      pcmodo      IN       VARCHAR2,
      ptdescrip   IN       VARCHAR2,
      pfccomer    IN       DATE,
      pcfotorut   IN       NUMBER,
      pfrut       IN       DATE,
      pttitulo    IN       VARCHAR2,
      pcfotoced   IN       NUMBER,
      pfexpiced   IN       DATE,
      pcpais      IN       NUMBER,
      pcprovin    IN       NUMBER,
      pcpoblac    IN       NUMBER,
      ptinfoad    IN       VARCHAR2,
      pcciiu      IN       NUMBER,
      pctipsoci   IN       NUMBER,
      pcestsoc    IN       NUMBER,
      ptobjsoc    IN       VARCHAR2,
      ptexperi    IN       VARCHAR2,
      pfconsti    IN       DATE,
      ptvigenc    IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_grabar_general';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
      verrores      t_ob_error;
   BEGIN
      IF psperson IS NULL
      THEN
         vparam := vparam || ' psperson =' || psperson;
         RAISE e_param_error;
      END IF;

      IF pcmodo IS NULL
      THEN
         vparam := vparam || ' pcmodo =' || pcmodo;
         RAISE e_param_error;
      END IF;

      --IF psfinanci IS NULL THEN
        -- vparam := vparam || ' psfinanci =' || psfinanci;
        -- RAISE e_param_error;
        -- psfinanci := sfinanci.nextval;
      --END IF;

      -- IF pfccomer IS NULL THEN
       --   vparam := vparam || ' pfccomer =' || pfccomer;
       --   RAISE e_param_error;
      -- END IF;
      IF pcciiu IS NULL
      THEN
         vparam := vparam || ' pcciiu =' || pcciiu;
         RAISE e_param_error;
      END IF;

      --  IF ptobjsoc IS NULL THEN
       --    vparam := vparam || ' ptobjsoc =' || ptobjsoc;
       --    RAISE e_param_error;
      --  END IF;

      --  IF pfconsti IS NULL THEN
       --    vparam := vparam || ' pfconsti =' || pfconsti;
       --    RAISE e_param_error;
      --  END IF;

      --  IF ptvigenc IS NULL THEN
       --    vparam := vparam || ' ptvigenc =' || ptvigenc;
       --    RAISE e_param_error;
      --  END IF;
      vnumerr :=
         pac_financiera.f_grabar_general (psperson,
                                          psfinanci,
                                          pcmodo,
                                          ptdescrip,
                                          pfccomer,
                                          pcfotorut,
                                          pfrut,
                                          pttitulo,
                                          pcfotoced,
                                          pfexpiced,
                                          pcpais,
                                          pcprovin,
                                          pcpoblac,
                                          ptinfoad,
                                          pcciiu,
                                          pctipsoci,
                                          pcestsoc,
                                          ptobjsoc,
                                          ptexperi,
                                          pfconsti,
                                          ptvigenc,
                                          mensajes
                                         );
      mensajes := f_traspasar_errores_mensajes (verrores);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_general;

   -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
   /**********************************************************************
        FUNCTION F_GRABAR_GENERAL_DET
        Funci?n que almacena los datos generales de la ficha financiera.
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
        return             : 0 todo ha sido correcto
                             1 ha habido un error
       **********************************************************************/
   FUNCTION f_grabar_general_det (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmodo      IN       VARCHAR2,
      ptdescrip   IN       VARCHAR2,
      pfccomer    IN       DATE,
      pcfotorut   IN       NUMBER,
      pfrut       IN       DATE,
      pttitulo    IN       VARCHAR2,
      pcfotoced   IN       NUMBER,
      pfexpiced   IN       DATE,
      pcpais      IN       NUMBER,
      pcprovin    IN       NUMBER,
      pcpoblac    IN       NUMBER,
      ptinfoad    IN       VARCHAR2,
      pcciiu      IN       NUMBER,
      pctipsoci   IN       NUMBER,
      pcestsoc    IN       NUMBER,
      ptobjsoc    IN       VARCHAR2,
      ptexperi    IN       VARCHAR2,
      pfconsti    IN       DATE,
      ptvigenc    IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)
                                  := 'PAC_MD_FINANCIERA.f_grabar_general_det';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
      verrores      t_ob_error;
   BEGIN
      IF pcmodo IS NULL
      THEN
         vparam := vparam || ' pcmodo =' || pcmodo;
         RAISE e_param_error;
      END IF;

      IF pcciiu IS NULL
      THEN
         vparam := vparam || ' pcciiu =' || pcciiu;
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_financiera.f_grabar_general_det (psfinanci,
                                              pnmovimi,
                                              pcmodo,
                                              ptdescrip,
                                              pfccomer,
                                              pcfotorut,
                                              pfrut,
                                              pttitulo,
                                              pcfotoced,
                                              pfexpiced,
                                              pcpais,
                                              pcprovin,
                                              pcpoblac,
                                              ptinfoad,
                                              pcciiu,
                                              pctipsoci,
                                              pcestsoc,
                                              ptobjsoc,
                                              ptexperi,
                                              pfconsti,
                                              ptvigenc,
                                              mensajes
                                             );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_general_det;

   -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

   /**********************************************************************
     FUNCTION F_GRABAR_RENTA
     Funci?n que almacena los datos de la declaraci?n de renta de la ficha financiera por persona.
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
   FUNCTION f_grabar_renta (
      psfinanci    IN       NUMBER,
      pcmodo       IN       VARCHAR2,
      pfcorte      IN       DATE,
      pcesvalor    IN       NUMBER,
      pipatriliq   IN       NUMBER,
      pirenta      IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_grabar_renta';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
      verrores      t_ob_error;
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pcmodo IS NULL
      THEN
         vparam := vparam || ' pcmodo =' || pcmodo;
         RAISE e_param_error;
      END IF;

      IF pfcorte IS NULL
      THEN
         vparam := vparam || ' pfcorte =' || pfcorte;
         RAISE e_param_error;
      END IF;

      IF pcesvalor IS NULL
      THEN
         vparam := vparam || ' pcesvalor =' || pcesvalor;
         RAISE e_param_error;
      END IF;

      IF pipatriliq IS NULL
      THEN
         vparam := vparam || ' pipatriliq =' || pipatriliq;
         RAISE e_param_error;
      END IF;

      IF pirenta IS NULL
      THEN
         vparam := vparam || ' pirenta =' || pirenta;
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_financiera.f_grabar_renta (psfinanci,
                                        pcmodo,
                                        pfcorte,
                                        pcesvalor,
                                        pipatriliq,
                                        pirenta,
                                        mensajes
                                       );

      --INI IAXIS-2120 - 27/02/2019 - Declaracion de renta
         -- mensajes := f_traspasar_errores_mensajes(verrores);
      --FIN IAXIS-2120 - 27/02/2019 - Declaracion de renta
      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_renta;

   /**********************************************************************
     FUNCTION F_GRABAR_ENDEUDA
     Funci?n que almacena los datos del endeudamiento financiero de la central de riesgos por persona.
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
   FUNCTION f_grabar_endeuda (
      psfinanci    IN       NUMBER,
      pfconsulta   IN       DATE,
      pcmodo       IN       VARCHAR2,
      pcfuente     IN       NUMBER,
      piminimo     IN       NUMBER,
      picappag     IN       NUMBER,
      picapend     IN       NUMBER,
      piendtot     IN       NUMBER,
      pncalifa     IN       NUMBER,
      pncalifb     IN       NUMBER,
      pncalifc     IN       NUMBER,
      pncalifd     IN       NUMBER,
      pncalife     IN       NUMBER,
      pnconsul     IN       NUMBER,
      pnscore      IN       NUMBER,
      pnmora       IN       NUMBER,
      picupog      IN       NUMBER,
      picupos      IN       NUMBER,
      pfcupo       IN       DATE,
      ptcupor      IN       VARCHAR2,
      pcrestric    IN       NUMBER,
      ptconcepc    IN       CLOB,          --IAXIS-3674 Krishnakant 31/05/2019
      ptconceps    IN       CLOB,          --IAXIS-3674 Krishnakant 31/05/2019
      ptcburea     IN       CLOB,          --IAXIS-3674 Krishnakant 31/05/2019
      ptcotros     IN       CLOB,          --IAXIS-3674 Krishnakant 31/05/2019
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_grabar_endeuda';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      --     IF pcmodo IS NULL THEN
      --        vparam := vparam || ' pcmodo =' || pcmodo;
      --        RAISE e_param_error;
      --     END IF;
      IF pfconsulta IS NULL
      THEN
         vparam := vparam || ' pfconsulta =' || pfconsulta;
         RAISE e_param_error;
      END IF;

      IF pcfuente IS NULL
      THEN
         vparam := vparam || ' pcfuente =' || pcfuente;
         RAISE e_param_error;
      END IF;

      --     IF piminimo IS NULL THEN
      --        vparam := vparam || ' piminimo =' || piminimo;
      --        RAISE e_param_error;
      --     END IF;

      --     IF picappag IS NULL THEN
      --        vparam := vparam || ' picappag =' || picappag;
      --       RAISE e_param_error;
      --     END IF;

      --     IF picapend IS NULL THEN
      --        vparam := vparam || ' picapend =' || picapend;
      --        RAISE e_param_error;
      --     END IF;

      --     IF piendtot IS NULL THEN
      --        vparam := vparam || ' piendtot =' || piendtot;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pncalifa IS NULL THEN
      --        vparam := vparam || ' pncalifa =' || pncalifa;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pncalifb IS NULL THEN
      --        vparam := vparam || ' pncalifb =' || pncalifb;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pncalifc IS NULL THEN
      --        vparam := vparam || ' pncalifc =' || pncalifc;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pncalifd IS NULL THEN
      --        vparam := vparam || ' pncalifd =' || pncalifd;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pnconsul IS NULL THEN
      --        vparam := vparam || ' pnconsul =' || pnconsul;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pncalife IS NULL THEN
      --        vparam := vparam || ' pncalife =' || pncalife;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pnscore IS NULL THEN
      --        vparam := vparam || ' pnscore =' || pnscore;
      --        RAISE e_param_error;
      --     END IF;

      --     IF pnmora IS NULL THEN
      --        vparam := vparam || ' pnmora =' || pnmora;
      --        RAISE e_param_error;
      --     END IF;
      vnumerr :=
         pac_financiera.f_grabar_endeuda (psfinanci,
                                          pfconsulta,
                                          pcmodo,
                                          pcfuente,
                                          piminimo,
                                          picappag,
                                          picapend,
                                          piendtot,
                                          pncalifa,
                                          pncalifb,
                                          pncalifc,
                                          pncalifd,
                                          pncalife,
                                          pnconsul,
                                          pnscore,
                                          pnmora,
                                          picupog,
                                          picupos,
                                          pfcupo,
                                          ptcupor,
                                          pcrestric,
                                          ptconcepc,
                                          ptconceps,
                                          ptcburea,
                                          ptcotros,
                                          mensajes
                                         );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_endeuda;

   /**********************************************************************
     FUNCTION F_GRABAR_INDICADOR
     Funci?n que almacena los datos de indicadores financieros por persona.
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
   FUNCTION f_grabar_indicador (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmodo      IN       VARCHAR2,
      pimargen    IN       NUMBER,
      picaptrab   IN       NUMBER,
      ptrazcor    IN       VARCHAR2,
      ptprbaci    IN       VARCHAR2,
      pienduada   IN       NUMBER,
      pndiacar    IN       NUMBER,
      pnrotpro    IN       NUMBER,
      pnrotinv    IN       NUMBER,
      pndiacicl   IN       NUMBER,
      pirentab    IN       NUMBER,
      pioblcp     IN       NUMBER,
      piobllp     IN       NUMBER,
      pigastfin   IN       NUMBER,
      pivalpt     IN       NUMBER,
      pcesvalor   IN       NUMBER,
      pcmoneda    IN       VARCHAR2,
      pfcupo      IN       DATE,
      picupog     IN       NUMBER,
      picupos     IN       NUMBER,
      pfcupos     IN       DATE,
      ptcupor     IN       VARCHAR2,
      ptconcepc   IN       CLOB,           --IAXIS-3674 Krishnakant 31/05/2019
      ptconceps   IN       CLOB,           --IAXIS-3674 Krishnakant 31/05/2019
      ptcburea    IN       CLOB,           --IAXIS-3674 Krishnakant 31/05/2019
      ptcotros    IN       CLOB,           --IAXIS-3674 Krishnakant 31/05/2019
      pcmoncam    IN       VARCHAR2,
      pncapfin    IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_grabar_indicador';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      --  IF pnmovimi IS NULL THEN
      --     vparam := vparam || ' pnmovimi =' || pnmovimi;
      --     RAISE e_param_error;
      --  END IF;
      IF pcmodo IS NULL
      THEN
         vparam := vparam || ' pcmodo =' || pcmodo;
         RAISE e_param_error;
      END IF;

      --  IF pimargen IS NULL THEN
      --     vparam := vparam || ' pimargen =' || pimargen;
      --     RAISE e_param_error;
      --  END IF;

      --  IF picaptrab IS NULL THEN
      --     vparam := vparam || ' picaptrab =' || picaptrab;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptrazcor IS NULL THEN
      --     vparam := vparam || ' ptrazcor =' || ptrazcor;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptprbaci IS NULL THEN
      --     vparam := vparam || ' ptprbaci =' || ptprbaci;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pienduada IS NULL THEN
      --     vparam := vparam || ' pienduada =' || pienduada;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pndiacar IS NULL THEN
      --     vparam := vparam || ' pndiacar =' || pndiacar;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pnrotpro IS NULL THEN
      --     vparam := vparam || ' pnrotpro =' || pnrotpro;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pnrotinv IS NULL THEN
      --     vparam := vparam || ' pnrotinv =' || pnrotinv;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pndiacicl IS NULL THEN
      --     vparam := vparam || ' pndiacicl =' || pndiacicl;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pirentab IS NULL THEN
      --     vparam := vparam || ' pirentab =' || pirentab;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pioblcp IS NULL THEN
      --     vparam := vparam || ' pioblcp =' || pioblcp;
      --     RAISE e_param_error;
      --  END IF;

      --  IF piobllp IS NULL THEN
      --     vparam := vparam || ' piobllp =' || piobllp;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pigastfin IS NULL THEN
      --     vparam := vparam || ' pigastfin =' || pigastfin;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pivalpt IS NULL THEN
      --     vparam := vparam || ' pivalpt =' || pivalpt;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pcesvalor IS NULL THEN
      --     vparam := vparam || ' pcesvalor =' || pcesvalor;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pcmoneda IS NULL THEN
      --     vparam := vparam || ' pcmoneda =' || pcmoneda;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pfcupo IS NULL THEN
      --     vparam := vparam || ' pfcupo =' || pfcupo;
      --     RAISE e_param_error;
      --  END IF;

      --  IF picupog IS NULL THEN
      --     vparam := vparam || ' picupog =' || picupog;
      --     RAISE e_param_error;
      --  END IF;

      --  IF picupos IS NULL THEN
      --     vparam := vparam || ' picupos =' || picupos;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptcupor IS NULL THEN
      --     vparam := vparam || ' ptcupor =' || ptcupor;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptconcepc IS NULL THEN
      --     vparam := vparam || ' ptconcepc =' || ptconcepc;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptconceps IS NULL THEN
      --     vparam := vparam || ' ptconceps =' || ptconceps;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptcburea IS NULL THEN
      --     vparam := vparam || ' ptcburea =' || ptcburea;
      --     RAISE e_param_error;
      --  END IF;

      --  IF ptcotros IS NULL THEN
      --     vparam := vparam || ' ptcotros =' || ptcotros;
      --     RAISE e_param_error;
      --  END IF;

      --  IF pcmoncam IS NULL THEN
      --     vparam := vparam || ' pcmoncam =' || pcmoncam;
      --     RAISE e_param_error;
      --  END IF;
      vnumerr :=
         pac_financiera.f_grabar_indicador (psfinanci,
                                            pnmovimi,
                                            pcmodo,
                                            pimargen,
                                            picaptrab,
                                            ptrazcor,
                                            ptprbaci,
                                            pienduada,
                                            pndiacar,
                                            pnrotpro,
                                            pnrotinv,
                                            pndiacicl,
                                            pirentab,
                                            pioblcp,
                                            piobllp,
                                            pigastfin,
                                            pivalpt,
                                            pcesvalor,
                                            pcmoneda,
                                            pfcupo,
                                            picupog,
                                            picupos,
                                            pfcupos,
                                            ptcupor,
                                            ptconcepc,
                                            ptconceps,
                                            ptcburea,
                                            ptcotros,
                                            pcmoncam,
                                            pncapfin,
                                            mensajes
                                           );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_indicador;

   /**********************************************************************
     FUNCTION F_GRABAR_DOC
     Funci?n que almacena los documentos asociados a la ficha financiera.
     Firma (Specification):
     Param IN psfinanci: sfinanci
     Param IN pcmodo: cmodo
     Param IN pnmovimi: nmovimi
     Param IN piddocgdx: iddocgdx
     Param IN ptobser: tobser
     Return             : 0 todo ha sido correcto
                          1 ha habido un error
    **********************************************************************/
   FUNCTION f_grabar_doc (
      psfinanci   IN       NUMBER,
      pcmodo      IN       VARCHAR2,
      pnmovimi    IN       NUMBER,
      piddocgdx   IN       NUMBER,
      ptobser     IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_grabar_doc';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pcmodo IS NULL
      THEN
         vparam := vparam || ' pcmodo =' || pcmodo;
         RAISE e_param_error;
      END IF;

      IF pnmovimi IS NULL
      THEN
         vparam := vparam || ' pnmovimi =' || pnmovimi;
         RAISE e_param_error;
      END IF;

      IF piddocgdx IS NULL
      THEN
         vparam := vparam || ' piddocgdx =' || piddocgdx;
         RAISE e_param_error;
      END IF;

      IF ptobser IS NULL
      THEN
         vparam := vparam || ' ptobser =' || ptobser;
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_financiera.f_grabar_doc (psfinanci,
                                      pcmodo,
                                      pnmovimi,
                                      piddocgdx,
                                      ptobser,
                                      mensajes
                                     );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_grabar_doc;

    -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
   /**********************************************************************
    FUNCTION F_GET_GENERAL_PERSONA_DET
    Funci?n que retorna los datos generales de la ficha financiera
    Param IN  psperson  : sperson
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_general_persona_det (
      psperson   IN       NUMBER,
      pnmovimi   IN       NUMBER DEFAULT NULL,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psperson = ' || psperson;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_FINANCIERA.f_get_general_persona_det';
      cur        sys_refcursor;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_general_persona_det (psperson, pnmovimi);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_general_persona_det;

   -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

   /**********************************************************************
    FUNCTION F_GET_GENERAL_PERSONA
    Funci?n que retorna los datos generales de la ficha financiera
    Param IN  psperson  : sperson
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_general_persona (
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psperson = ' || psperson;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_general_persona';
      cur        sys_refcursor;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_general_persona (psperson);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_general_persona;

   /**********************************************************************
    FUNCTION F_GET_GENERAL
    Funci?n que retorna los datos generales de la ficha financiera
    Param IN  psfinanci  : sfinanci
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_general (psfinanci IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_general';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_general (psfinanci);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_general;

   /**********************************************************************
    FUNCTION F_GET_RENTA
    Funci?n que retorna los datos de la declaraci?n de renta de la ficha financiera.
    Param IN  psfinanci: sfinanci
    Param IN DATE DEFAULT NULL pfrenta: frenta  fcorte
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_renta (
      psfinanci   IN       NUMBER,
      pfrenta     IN       DATE DEFAULT NULL,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_renta';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_renta (psfinanci, pfrenta);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_renta;

   /**********************************************************************
     FUNCTION F_GET_ENDEUDA
     Funci?n que retorna los datos de endeudamiento financiero de la ficha financiera
     Param IN  psfinanci: sfinanci
     Param IN VARCHAR2 DEFAULT NULL pfconsulta: fconsulta
     Param IN VARCHAR2 DEFAULT NULL pcfuente: cfuente
     Param OUT PRETCURSOR : SYS_REF_CURSOR
    **********************************************************************/
   FUNCTION f_get_endeuda (
      psfinanci    IN       NUMBER,
      pfconsulta   IN       DATE DEFAULT NULL,
      pcfuente     IN       NUMBER DEFAULT NULL,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_endeuda';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_endeuda (psfinanci, pfconsulta, pcfuente);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_endeuda;

   /**********************************************************************
     FUNCTION F_GET_INDICADOR
     Funci?n que retorna los datos de indicadores financieros de la ficha financiera
     Param IN  psfinanci: sfinanci
     Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
     Param OUT PRETCURSOR : SYS_REF_CURSOR
    **********************************************************************/
   FUNCTION f_get_indicador (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER DEFAULT NULL,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_indicador';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_indicador (psfinanci, pnmovimi);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_indicador;

   /**********************************************************************
    FUNCTION F_GET_DOC
    Funci?n que retorna los datos de los documentos asociados de la ficha financiera
    Param IN  psfinanci: sfinanci
    Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_doc (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER DEFAULT NULL,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_doc';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_doc (psfinanci, pnmovimi);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_doc;

     -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
   /**********************************************************************
     FUNCTION F_DEL_FIN_GENERL_DET
     Funcin que elimina los datos de la fin_general_det
     Param IN psfinanci: sfinanci
     Param IN pfcorte: nmovimi
     Param OUT PRETCURSOR : SYS_REF_CURSOR
    **********************************************************************/
   FUNCTION f_del_fin_general_det (
      psfinanci   IN       fin_general_det.sfinanci%TYPE,
      pnmovimi    IN       fin_general_det.nmovimi%TYPE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_del_fin_general_del';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pnmovimi IS NULL
      THEN
         vparam := vparam || ' pnmovimi =' || pnmovimi;
         RAISE e_param_error;
      END IF;

      vnumerr :=
          pac_financiera.f_del_fin_general_det (psfinanci, pnmovimi, mensajes);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_del_fin_general_det;

   -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

   /**********************************************************************
     FUNCTION F_DEL_RENTA
     Funci?n que elimina los datos de la declaraci?n de renta de la ficha financiera por persona
     Param IN psfinanci: sfinanci
     Param IN pfcorte: fcorte
     Param IN pcesvalor: cesvalor
     Param IN pipatriliq: ipatriliq
     Param IN pirenta: irenta
     Param OUT PRETCURSOR : SYS_REF_CURSOR
    **********************************************************************/
   FUNCTION f_del_renta (
      psfinanci    IN       fin_d_renta.sfinanci%TYPE,
      pfcorte      IN       fin_d_renta.fcorte%TYPE,
      pcesvalor    IN       fin_d_renta.cesvalor%TYPE,
      pipatriliq   IN       fin_d_renta.ipatriliq%TYPE,
      pirenta      IN       fin_d_renta.irenta%TYPE,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_del_renta';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pfcorte IS NULL
      THEN
         vparam := vparam || ' pfcorte =' || pfcorte;
         RAISE e_param_error;
      END IF;

      IF pipatriliq IS NULL
      THEN
         vparam := vparam || ' pipatriliq =' || pipatriliq;
         RAISE e_param_error;
      END IF;

      IF pirenta IS NULL
      THEN
         vparam := vparam || ' pirenta =' || pirenta;
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_financiera.f_del_renta (psfinanci,
                                     pfcorte,
                                     pcesvalor,
                                     pipatriliq,
                                     pirenta
                                    );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_del_renta;

   /**********************************************************************
    FUNCTION F_DEL_ENDEUDA
    Funci?n que elimina los datos de endeudamiento financiero de la ficha financiera
    Param IN psfinanci: sfinanci
    Param IN pfconsulta: fconsulta
    Param IN pcfuente: cfuente
   **********************************************************************/
   FUNCTION f_del_endeuda (
      psfinanci    IN       fin_endeudamiento.sfinanci%TYPE,
      pfconsulta   IN       fin_endeudamiento.fconsulta%TYPE,
      pcfuente     IN       fin_endeudamiento.cfuente%TYPE,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_del_endeuda';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pfconsulta IS NULL
      THEN
         vparam := vparam || ' pfconsulta =' || pfconsulta;
         RAISE e_param_error;
      END IF;

      IF pcfuente IS NULL
      THEN
         vparam := vparam || ' pcfuente =' || pcfuente;
         RAISE e_param_error;
      END IF;

      vnumerr :=
                pac_financiera.f_del_endeuda (psfinanci, pfconsulta, pcfuente);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_del_endeuda;

   /**********************************************************************
     FUNCTION F_DEL_INDICADOR
     Funci?n que elimina los datos de indicadores financieros de la ficha financiera
     Param IN psfinanci: sfinanci
     Param IN pnmovimi: nmovimi
    **********************************************************************/
   FUNCTION f_del_indicador (
      psfinanci   IN       fin_indicadores.sfinanci%TYPE,
      pnmovimi    IN       fin_indicadores.nmovimi%TYPE DEFAULT NULL,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_del_indicador';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pnmovimi IS NULL
      THEN
         vparam := vparam || ' pnmovimi =' || pnmovimi;
         RAISE e_param_error;
      END IF;

      vnumerr := pac_financiera.f_del_indicador (psfinanci, pnmovimi);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_del_indicador;

   -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
   /**********************************************************************
     FUNCTION F_DEL_PARAMETRO
     Funci?n que elimina los datos de indicadores financieros de la ficha financiera
     Param IN psfinanci: sfinanci
     Param IN pnmovimi: nmovimi
    **********************************************************************/
   FUNCTION f_del_parametro (
      psfinanci   IN       fin_indicadores.sfinanci%TYPE,
      pnmovimi    IN       fin_indicadores.nmovimi%TYPE DEFAULT NULL,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_del_indicador';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pnmovimi IS NULL
      THEN
         vparam := vparam || ' pnmovimi =' || pnmovimi;
         RAISE e_param_error;
      END IF;

      vnumerr := pac_financiera.f_del_parametro (psfinanci, pnmovimi);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_del_parametro;

     -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
   /**********************************************************************
    FUNCTION F_GET_PARCUENTA
    Funci?n que retorna los datos de parametros de la ficha financiera
    Param IN  psfinanci: sfinanci
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_parcuenta (
      psfinanci   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_parcuenta';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_parcuenta (psfinanci);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_parcuenta;

   /**********************************************************************
    FUNCTION F_INS_PARCUENTA
    Funci?n que almacena los datos de los parametros de la ficha financiera.
    Firma (Specification):
    Param IN  psfinanci: sfinanci
    Param IN  pcparam: cparam
    Param IN  pnvalpar: nvalpar
    Param IN  ptvalpar: tvalpar
    Param IN  pfvalpar: pfvalpar
   **********************************************************************/
   FUNCTION f_ins_parcuenta (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcparam     IN       VARCHAR2,
      pnvalpar    IN       NUMBER,
      ptvalpar    IN       VARCHAR2,
      pfvalpar    IN       DATE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_ins_parcuenta';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL
      THEN
         vparam := vparam || ' pcparam =' || pcparam;
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_financiera.f_ins_parcuenta (psfinanci,
                                         pnmovimi,
                                         pcparam,
                                         pnvalpar,
                                         ptvalpar,
                                         pfvalpar,
                                         mensajes
                                        );

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_ins_parcuenta;

   /**********************************************************************
     FUNCTION F_CALCULA_MODELO
     Funci?n que genera el calculo modelo de la ficha financiera
     Firma (Specification):
     Param IN  psfinanci: sfinanci
     Param IN  pcesvalor: cesvalor
     Param IN  pcuposug: cuposug
     Param IN  pcupogar: cupogar
    **********************************************************************/
   FUNCTION f_calcula_modelo (
      psfinanci     IN       NUMBER,
      pnmovimi      IN       NUMBER,
      pcesvalor     IN       NUMBER,
      pcuposug      OUT      NUMBER,
      pcupogar      OUT      NUMBER,
      pcapafin      OUT      NUMBER,
      pcuposugv1    OUT      NUMBER,
      pcupogarv1    OUT      NUMBER,
      pcapafinv1    OUT      NUMBER,
      pncontpol     OUT      NUMBER,
               -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
      pnaniosvinc   OUT      NUMBER,
               -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
      pcmonori      IN       VARCHAR2,
      pcmondes      IN       VARCHAR2,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr                   NUMBER;
      vobjectname               VARCHAR2 (500)
                                      := 'PAC_MD_FINANCIERA.f_calcula_modelo';
      vpasexec                  NUMBER (5)      := 1;
      vretmen                   NUMBER;
      vparam                    VARCHAR2 (1000) := 'parmetros - ';
      vmensaje                  VARCHAR2 (1000)
                                               := 'parmetros sin informar - ';
      v_nmovim                  NUMBER;
                                       -- CP0507M_SYS_PERS - ACL - 29/11/2018
      v_nmovimi                 NUMBER;
                                       -- CP0507M_SYS_PERS - ACL - 29/11/2018
      -- INI -TCS_456 -JLTS - 11/01/2019 - Ajuste de las condicionales del calculo
      v_pcmondes_cop   CONSTANT VARCHAR2 (3)    := 'COP';
      -- FIN -TCS_456 -JLTS - 11/01/2019 - Ajuste de las condicionales del calculo
        -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Mximo cupo sugerido de empresas)
      v_max_cup_sug             NUMBER;

      -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Mximo cupo sugerido de empresas)
      TYPE parametros IS VARRAY (28) OF VARCHAR2 (50);

      v_nombresparametros       parametros;
      v_cant_deci               NUMBER (1)      := 2;
      v_sperson                 NUMBER          := 0;
      v_tipo                    NUMBER          := 0;
      v_identif                 NUMBER          := 0;
      v_existe                  NUMBER          := 0;
      v_cupo                    NUMBER          := 0;
      v_iminio                  NUMBER          := 0;
      v_nscore                  NUMBER          := 0;
      v_act_total               NUMBER          := 0;
      v_act_corr                NUMBER          := 0;
      v_tot_act_no_corr         NUMBER          := 0;
      v_pas_corr                NUMBER          := 0;
      v_pas_no_corr             NUMBER          := 0;
      v_pas_total               NUMBER          := 0;
      v_patri_ano_actual        NUMBER          := 0;
      v_resv_legal              NUMBER          := 0;
      v_cap_social              NUMBER          := 0;
      v_res_ejer_ant            NUMBER          := 0;
      v_prima_accion            NUMBER          := 0;
      v_resv_ocasi              NUMBER          := 0;
      v_valoriza                NUMBER          := 0;
      v_asignado                NUMBER          := 0;
      v_fech_est_fin            DATE;
      c_act_total               NUMBER          := 0;
      c_act_corr                NUMBER          := 0;
      c_tot_act_no_corr         NUMBER          := 0;
      c_pas_corr                NUMBER          := 0;
      c_pas_no_corr             NUMBER          := 0;
      c_pas_total               NUMBER          := 0;
      c_patri_ano_actual        NUMBER          := 0;
      c_resv_legal              NUMBER          := 0;
      c_cap_social              NUMBER          := 0;
      c_res_ejer_ant            NUMBER          := 0;
      c_prima_accion            NUMBER          := 0;
      c_resv_ocasi              NUMBER          := 0;
      c_valoriza                NUMBER          := 0;
      c_asignado                NUMBER          := 0;
      v_rango                   NUMBER          := 100;
      v_existe_ind_fin          NUMBER          := 0;
      v_itasa                   NUMBER          := 1;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --       IF pnmovimi IS NULL THEN
      --          vparam := vparam || ' pnmovimi =' || pnmovimi;
      --          RAISE e_param_error;
      --       END IF;
      -- Ini CP0507M_SYS_PERS - ACL - 29/11/2018
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (fp.nmovimi)
           INTO v_nmovim
           FROM fin_parametros fp
          WHERE fp.sfinanci = psfinanci;
      END IF;

      vpasexec := 3;
      v_nmovimi := NVL (pnmovimi, v_nmovim);

      -- Fin CP0507M_SYS_PERS - ACL - 29/11/2018
      IF pcesvalor IS NULL
      THEN
         vparam := vparam || ' pcesvalor =' || pcesvalor;
         RAISE e_param_error;
      END IF;

      vpasexec := 4;

      SELECT sperson
        INTO v_sperson
        FROM fin_general
       WHERE sfinanci = psfinanci;

      vpasexec := 5;

      SELECT ctipper, ctipide
        INTO v_tipo, v_identif
        FROM per_personas
       WHERE sperson = v_sperson;

      vpasexec := 6;

      IF v_tipo = 1
      THEN
         SELECT COUNT (*)
           INTO v_existe_ind_fin
           FROM fin_indicadores fi
          WHERE fi.sfinanci = psfinanci AND fi.nmovimi = v_nmovimi;
                                        -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 7;

         IF v_existe_ind_fin > 0
         THEN
            v_tipo := 2;
         END IF;
      END IF;

      vpasexec := 8;
      -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Mximo cupo sugerido de empresas)
      v_max_cup_sug :=
         NVL
            (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                            'MAX_CUPOS_SUGER'
                                           ),
             0
            );

      -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Mximo cupo sugerido de empresas)
      IF v_tipo = 2
      THEN
         SELECT fp.fvalpar
           INTO v_fech_est_fin
           FROM fin_parametros fp
          WHERE fp.sfinanci = psfinanci
            AND fp.nmovimi = v_nmovimi  -- CP0507M_SYS_PERS - ACL - 29/11/2018
            AND cparam = 'FECHA_EST_FIN';

         vpasexec := 9;

         IF TO_CHAR (v_fech_est_fin, 'dd/mm/') <> '31/12/'
         THEN
            vretmen := 89906098;
            RAISE e_info;
         END IF;

         vpasexec := 10;
      END IF;

      IF v_tipo = 2 OR v_tipo = 96
      THEN
         -- Validacion Activo Total.
         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_act_total
           FROM fin_parametros
          WHERE cparam = 'ACT_TOTAL'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;    -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 11;

         IF c_act_total > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_act_total
              FROM fin_parametros
             WHERE cparam = 'ACT_TOTAL'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018

            vpasexec := 12;
         END IF;

         vpasexec := 13;

         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_act_corr
           FROM fin_parametros
          WHERE cparam = 'ACT_CORR'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;    -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 14;

         IF c_act_corr > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_act_corr
              FROM fin_parametros
             WHERE cparam = 'ACT_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 15;

         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_tot_act_no_corr
           FROM fin_parametros
          WHERE cparam = 'TOT_ACT_NO_CORR'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;    -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 16;

         IF c_tot_act_no_corr > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_tot_act_no_corr
              FROM fin_parametros
             WHERE cparam = 'TOT_ACT_NO_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 17;

         -- Validacion Pasivo Total.
         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_pas_corr
           FROM fin_parametros
          WHERE cparam = 'PAS_CORR'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;    -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 18;

         IF c_pas_corr > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_pas_corr
              FROM fin_parametros
             WHERE cparam = 'PAS_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 19;

         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_pas_no_corr
           FROM fin_parametros
          WHERE cparam = 'PAS_NO_CORR'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;    -- CP0507M_SYS_PERS - ACL - 29/11/2018

         vpasexec := 20;

         IF c_pas_no_corr > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_pas_no_corr
              FROM fin_parametros
             WHERE cparam = 'PAS_NO_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 21;

         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_pas_total
           FROM fin_parametros
          WHERE cparam = 'PAS_TOTAL'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;

         vpasexec := 22;

         IF c_pas_total > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_pas_total
              FROM fin_parametros
             WHERE cparam = 'PAS_TOTAL'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 23;

         -- Validacion Ecuacion Patrimonial
         SELECT COUNT (NVL (TO_NUMBER (nvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      ),
                            TO_NUMBER (tvalpar,
                                       '9999999999999D999',
                                       'NLS_NUMERIC_CHARACTERS = '',.'''
                                      )
                           )
                      )
           INTO c_patri_ano_actual
           FROM fin_parametros
          WHERE cparam = 'PATRI_ANO_ACTUAL'
            AND sfinanci = psfinanci
            AND nmovimi = v_nmovimi;

         vpasexec := 24;

         IF c_patri_ano_actual > 0
         THEN
            SELECT NVL (TO_NUMBER (nvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  ),
                        TO_NUMBER (tvalpar,
                                   '9999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = '',.'''
                                  )
                       )
              INTO v_patri_ano_actual
              FROM fin_parametros
             WHERE cparam = 'PATRI_ANO_ACTUAL'
               AND sfinanci = psfinanci
               AND nmovimi = v_nmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
         END IF;

         vpasexec := 25;

         -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
         -- Activo Total debe ser igual a Pasivo Total + Patrimonio.
         IF    (v_pas_total + v_patri_ano_actual) > (v_act_total + v_rango)
            OR (v_pas_total + v_patri_ano_actual) < (v_act_total - v_rango)
         THEN
            vretmen := 89906072;
            RAISE e_info;
         END IF;

         -- Pasivo Total debe ser igual a Activo Total - Patrimonio.
         IF    (v_act_total - v_patri_ano_actual) > (v_pas_total + v_rango)
            OR (v_act_total - v_patri_ano_actual) < (v_pas_total - v_rango)
         THEN
            vretmen := 89906073;
            RAISE e_info;
         END IF;

         -- Patrimonio debe ser igual a Activo Total - Pasivo Total.
         IF    (v_act_total - v_pas_total) > (v_patri_ano_actual + v_rango)
            OR (v_act_total - v_pas_total) < (v_patri_ano_actual - v_rango)
         THEN
            vretmen := 89906074;
            RAISE e_info;
         END IF;

         -- Otras validaciones
         -- Activo Corriente + Activo no corriente debe ser igual a Activo Total.
         IF    (v_act_corr + v_tot_act_no_corr) > (v_act_total + v_rango)
            OR (v_act_corr + v_tot_act_no_corr) < (v_act_total - v_rango)
         THEN
            vretmen := 89906070;
            RAISE e_info;
         END IF;

         -- Pasivo Corriente + Pasivo no Corriente debe ser igual a Pasivo Total.
         IF (v_pas_corr + v_pas_no_corr) < (v_pas_total - v_rango)
         THEN
            vretmen := 89906071;
            RAISE e_info;
         END IF;
         -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
      -- Validaciones superior patrimonio
      /*           SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_RESV_LEGAL
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RESV_LEGAL'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_RESV_LEGAL > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_RESV_LEGAL
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RESV_LEGAL'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
             END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_CAP_SOCIAL
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'CAP_SOCIAL'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_CAP_SOCIAL > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_CAP_SOCIAL
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'CAP_SOCIAL'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
             END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_RES_EJER_ANT
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RES_EJER_ANT'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_RES_EJER_ANT > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_RES_EJER_ANT
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RES_EJER_ANT'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
             END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_PRIMA_ACCION
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'PRIMA_ACCION'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_PRIMA_ACCION > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_PRIMA_ACCION
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'PRIMA_ACCION'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
             END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_RESV_OCASI
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RESV_OCASI'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_RESV_OCASI > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_RESV_OCASI
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'RESV_OCASI'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
             END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_VALORIZA
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'VALORIZA'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

             IF C_VALORIZA > 0 THEN
               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_VALORIZA
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'VALORIZA'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;
              END IF;


               SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO C_ASIGNADO
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'ASIGNADO'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

              IF  C_ASIGNADO > 0 THEN

               SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
                 INTO V_ASIGNADO
                 FROM FIN_PARAMETROS
                WHERE CPARAM = 'ASIGNADO'
                  AND SFINANCI = psfinanci
                  AND  NMOVIMI = pnmovimi;

                 IF V_ASIGNADO > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                    V_ASIGNADO < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                    vretmen := 89906084;
                    RAISE e_info;
                 END IF;

              END IF;

                 IF (V_ACT_CORR + V_TOT_ACT_NO_CORR) > (V_ACT_TOTAL + V_RANGO) OR
                    (V_ACT_CORR + V_TOT_ACT_NO_CORR) < (V_ACT_TOTAL - V_RANGO)  THEN
                    vretmen := 89906070;
                    RAISE e_info;
                 END IF;


                 IF (V_PAS_CORR + V_PAS_NO_CORR) > (V_PAS_TOTAL + V_RANGO) OR
                    (V_PAS_CORR + V_PAS_NO_CORR) < (V_PAS_TOTAL - V_RANGO) THEN
                    vretmen := 89906071;
                    RAISE e_info;
                 END IF;


                 IF (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) > (V_ACT_TOTAL + V_RANGO) OR
                    (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) < (V_ACT_TOTAL - V_RANGO) THEN
                    vretmen := 89906072;
                    RAISE e_info;
                 END IF;


                 IF (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) > (V_PAS_TOTAL + V_RANGO) OR
                    (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) < (V_PAS_TOTAL - V_RANGO) THEN
                    vretmen := 89906073;
                    RAISE e_info;
                 END IF;


                 IF (V_ACT_TOTAL - V_PAS_TOTAL) > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                    (V_ACT_TOTAL - V_PAS_TOTAL) < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                    vretmen := 89906074;
                    RAISE e_info;
                 END IF;
      */
      --
      /**            IF V_RESV_LEGAL  > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                 V_RESV_LEGAL  < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                 vretmen := 89906078;
                 RAISE e_info;
              END IF;


              IF  V_CAP_SOCIAL  > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                  V_CAP_SOCIAL  < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                 vretmen := 89906079;
                 RAISE e_info;
              END IF;


              IF  V_RES_EJER_ANT  > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                  V_RES_EJER_ANT  < (V_PATRI_ANO_ACTUAL - V_RANGO)THEN
                 vretmen := 89906080;
                 RAISE e_info;
              END IF;


              IF V_PRIMA_ACCION  > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                 V_PRIMA_ACCION  < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                 vretmen := 89906081;
                 RAISE e_info;
              END IF;


              IF V_RESV_OCASI  > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                 V_RESV_OCASI  < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                 vretmen := 89906082;
                 RAISE e_info;
              END IF;


              IF V_VALORIZA > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                 V_VALORIZA < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
                 vretmen := 89906083;
                 RAISE e_info;
              END IF;
      **/
      END IF;

      vpasexec := 26;

      IF v_tipo = 1
      THEN
         -- INI TCS_11 - JLTS - 13/03/2019 - Se ajusta la consulta para que tenga en cuenta la excepcion
         -- INi IAXIS-4985 -- ECP -- 09/08/2019
         BEGIN
            SELECT a.iminimo, a.nscore
              INTO v_iminio, v_nscore
              FROM fin_endeudamiento a
             WHERE a.sfinanci = psfinanci
               AND a.iminimo IS NOT NULL
               AND a.nscore IS NOT NULL
               AND a.fconsulta = (SELECT MAX (b.fconsulta)
                                    FROM fin_endeudamiento b
                                   WHERE b.sfinanci = a.sfinanci);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_iminio := 0;
               v_nscore := 0;
         END;
       -- Fin  IAXIS-4985 -- ECP -- 09/08/2019
      -- FIN TCS_11 - JLTS - 13/03/2019
      /*     ELSE

      v_nombresParametros := parametros ('FECHA_EST_FIN', 'VT_PER_ANT', 'VENTAS', 'COSTO_VT', 'GASTO_ADM',
                                         'UTIL_OPERAC', 'GASTO_FIN', 'RES_ANT_IMP', 'UTIL_NETA', 'INVENT',
                                         'CARTE_CLIE', 'ACT_CORR', 'PROP_PLNT_EQP', 'TOT_ACT_NO_CORR', 'ACT_TOTAL',
                                         'O_FIN_CORTO_PLAZO', 'PROVEE_CORTO_PLAZO', 'ATC_CORTO_PLAZO', 'PAS_CORR', 'O_FIN_LARGO_PLAZO',
                                         'ATC_LARGO_PLAZO', 'PAS_NO_CORR', 'PAS_TOTAL', 'PATRI_PERI_ANT', 'PATRI_ANO_ACTUAL',
                                         'RESV_LEGAL', 'CAP_SOCIAL', 'RES_EJER_ANT');


      FOR i IN 1 .. v_nombresParametros.COUNT LOOP

            SELECT COUNT(*)
            INTO V_EXISTE
            FROM FIN_PARAMETROS
           WHERE SFINANCI = PSFINANCI
              AND  CPARAM = v_nombresParametros(i);

           IF V_EXISTE = 0 THEN
              vmensaje  := vmensaje  || ' - ' || v_nombresParametros(i) || ' - ';
             -- EXIT;
           END IF;
      END LOOP;

      IF V_EXISTE = 0 THEN
        RAISE e_param_info;
      END IF; */
      END IF;

      vpasexec := 27;

      -- DDDD
      IF v_identif = 96
      THEN
         -- INI -TCS_456 -JLTS - 14/01/2019 - Se incluye la condici? (PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, v_nmovimi, 'PATRI_ANO_ACTUAL') <0 )
         -- Ini CP0507M_SYS_PERS - ACL - 29/11/2018
         IF    (    pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'UTIL_NETA'
                                                   ) < 0
                AND pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'UTIL_OPERAC'
                                                   ) < 0
               )
            OR (    pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'UTIL_NETA'
                                                   ) < 0
                AND pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'RES_EJER_ANT'
                                                   ) < 0
               )
            OR (    pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'UTIL_OPERAC'
                                                   ) < 0
                AND pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'RES_EJER_ANT'
                                                   ) < 0
               )
            OR (pac_financiera.f_get_fin_param (psfinanci,
                                                v_nmovimi,
                                                'PATRI_ANO_ACTUAL'
                                               ) < 0
               )
         THEN
            -- Tener en cuenta de colocar aqui la para MARCAS - Sitiuaci? financiera deteriorada JLTS
            vnumerr := pac_marcas.f_set_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067');  -- CJMR
            
            pcuposug := pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO');
            pcapafin := 0;
            vpasexec := 29;
         ELSE
            IF v_patri_ano_actual >= 0
            THEN
               pcuposug :=
                    pac_financiera.f_factor_r (psfinanci, v_nmovimi)
                  * pac_financiera.f_factor_c (psfinanci, v_nmovimi)
                  * pac_financiera.f_factor_z (psfinanci, v_nmovimi)
                  * pac_financiera.f_factor_f (psfinanci, v_nmovimi)
                  * pac_financiera.f_get_fin_param (psfinanci,
                                                    v_nmovimi,
                                                    'PATRI_ANO_ACTUAL'
                                                   );

               IF pcuposug >
                     (  pac_financiera.f_get_fin_param (psfinanci,
                                                        v_nmovimi,
                                                        'PATRI_ANO_ACTUAL'
                                                       )
                      * v_max_cup_sug
                     )
               THEN
                  pcuposug :=
                     (  pac_financiera.f_get_fin_param (psfinanci,
                                                        v_nmovimi,
                                                        'PATRI_ANO_ACTUAL'
                                                       )
                      * v_max_cup_sug
                     );
               -- Fin CP0507M_SYS_PERS - ACL - 29/11/2018
               END IF;

               vpasexec := 29;
               pcapafin := pcuposug / v_patri_ano_actual;

               IF pcesvalor = 1
               THEN
                  -- valores en miles
                  pcuposug := pcuposug * 1000;
               END IF;

               vpasexec := 30;
               vnumerr := pac_marcas.f_del_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067'); -- CJMR

            ELSE
               vnumerr := pac_marcas.f_set_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067');  -- CJMR
               pcuposug := pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO');
               pcapafin := 0;
               vpasexec := 31;
            END IF;
         END IF;
      -- FIN -TCS_456 -JLTS - 14/01/2019 - Se incluye la condici? (PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, v_nmovimi, 'PATRI_ANO_ACTUAL') <0 )
      ELSE
         -- Persona Natural
         vpasexec := 32;

         IF v_tipo = 1
         THEN
            -- INI -TCS_456 -JLTS - 14/01/2019 - Se incluye la condici? (PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, v_nmovimi, 'PATRI_ANO_ACTUAL') <0 )
            -- Ini CP0507M_SYS_PERS - ACL - 29/11/2018
            pcuposug := pac_financiera.f_factor_n (psfinanci, v_nmovimi);
            vpasexec := 33;
         ELSIF v_tipo = 2
         THEN
            IF    (    pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'UTIL_NETA'
                                                      ) < 0
                   AND pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'UTIL_OPERAC'
                                                      ) < 0
                  )
               OR (    pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'UTIL_NETA'
                                                      ) < 0
                   AND pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'RES_EJER_ANT'
                                                      ) < 0
                  )
               OR (    pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'UTIL_OPERAC'
                                                      ) < 0
                   AND pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'RES_EJER_ANT'
                                                      ) < 0
                  )
               OR (pac_financiera.f_get_fin_param (psfinanci,
                                                   v_nmovimi,
                                                   'PATRI_ANO_ACTUAL'
                                                  ) < 0
                  )
            THEN
               vnumerr := pac_marcas.f_set_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067');  -- CJMR
               pcuposug := pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO');
               pcapafin := 0;
               vpasexec := 34;
            ELSE
               IF v_patri_ano_actual >= 0
               THEN
                  pcuposug :=
                       pac_financiera.f_factor_s (psfinanci, v_nmovimi)
                     * pac_financiera.f_factor_c (psfinanci, v_nmovimi)
                     * pac_financiera.f_factor_z (psfinanci, v_nmovimi)
                     * (CASE
                           WHEN pac_financiera.f_factor_p (psfinanci,
                                                           v_nmovimi
                                                          ) = 0
                              THEN 1
                           ELSE pac_financiera.f_factor_p (psfinanci,
                                                           v_nmovimi
                                                          )
                        END
                       )
                     * (CASE
                           WHEN pac_financiera.f_factor_a (psfinanci,
                                                           v_nmovimi
                                                          ) = 0
                              THEN 1
                           ELSE pac_financiera.f_factor_a (psfinanci,
                                                           v_nmovimi
                                                          )
                        END
                       )
                     * pac_financiera.f_get_fin_param (psfinanci,
                                                       v_nmovimi,
                                                       'PATRI_ANO_ACTUAL'
                                                      );
                  vpasexec := 35;

                  IF pcuposug >
                        (  pac_financiera.f_get_fin_param (psfinanci,
                                                           v_nmovimi,
                                                           'PATRI_ANO_ACTUAL'
                                                          )
                         * v_max_cup_sug
                        )
                  THEN
                     pcuposug :=
                        (  pac_financiera.f_get_fin_param (psfinanci,
                                                           v_nmovimi,
                                                           'PATRI_ANO_ACTUAL'
                                                          )
                         * v_max_cup_sug
                        );
                  END IF;

                  vpasexec := 36;
                  -- Fin CP0507M_SYS_PERS - ACL - 29/11/2018
                  pcapafin := pcuposug / v_patri_ano_actual;

                  IF pcesvalor = 1
                  THEN
                     -- valores en miles
                     pcuposug := pcuposug * 1000;
                  END IF;

                  vpasexec := 37;
                  vnumerr := pac_marcas.f_del_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067'); -- CJMR

               ELSE
                  vnumerr := pac_marcas.f_set_marca_automatica(pac_md_common.f_get_cxtempresa, v_sperson, '0067');  -- CJMR
                  pcuposug := pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO');
                  pcapafin := 0;
                  vpasexec := 38;
               END IF;
            END IF;
         END IF;
      -- FIN -TCS_456 -JLTS - 14/01/2019 - Se incluye la condici? (PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, v_nmovimi, 'PATRI_ANO_ACTUAL') <0 )
      END IF;

      --    IF PCUPOSUG > (pac_parametros.f_parempresa_n(24, 'CUPO_MOD_MAXIMO')) * 10 THEN
      --       PCUPOGAR :=  (pac_parametros.f_parempresa_n(24, 'CUPO_MOD_MAXIMO')) * 10;
      --    ELSE
      --       PCUPOGAR := PCUPOSUG;
      --    END IF;

      -- INI -TCS_456 -JLTS - 14/01/2019 - Se moficica la moneda destino para que sea siempre COP
      vpasexec := 39;

      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL
      THEN
         v_itasa :=
            pac_financiera.f_get_itasa (psfinanci,
                                        v_nmovimi,
                                        pcmonori,
                                        v_pcmondes_cop,
                                        'FECHA_EST_FIN'
                                       );
                                       --  CP0507M_SYS_PERS - ACL - 29/11/2018
      END IF;

      vpasexec := 40;
      -- FIN -TCS_456 -JLTS - 14/01/2019 - Se moficica la moneda destino para que sea siempre COP
      pcuposug := pcuposug * v_itasa;

      IF pcuposug = pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO')
      THEN
         pcupogar := 0;
         pcapafin := 0;
         vpasexec := 41;
      ELSE
         pcupogar := pcuposug;
         pcupogar := ROUND (pcupogar, v_cant_deci);
         pcuposug := ROUND (pcuposug, v_cant_deci);
         pcapafin := ROUND (pcapafin, v_cant_deci);
         vpasexec := 42;
      END IF;

      -- INI - IAXIS-2596 - 25/02/2019 - JLTS - Se ingresa la condicin de capacidad financiera
      IF pcapafin <
            TO_NUMBER (pac_parametros.f_parempresa_t (24,
                                                      'CAPACIDAD_FINANCIERA'
                                                     ),
                       '9999999999999D999',
                       'NLS_NUMERIC_CHARACTERS = '',.'''
                      )
      THEN
         pcuposug := pac_parametros.f_parempresa_n (24, 'CUPO_DETERIORADO');
         pcupogar := 0;
         vnumerr :=
            pac_marcas.f_set_marca_automatica
                                             (pac_md_common.f_get_cxtempresa,
                                              v_sperson,
                                              '0113'
                                             );
      END IF;

      vpasexec := 43;

      -- FIN - IAXIS-2596 - 25/02/2019 - JLTS - Se ingresa la condicin de capacidad financiera
      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      -- INI TCS_3 - JLTS - 19/02/2019 - Se devuelve el valor de los campos ICUPOS, ICUPOG y NCAPFIN
      BEGIN
         SELECT f.icuposv1, f.icupogv1, f.ncapfinv1, f.ncontpol,
                -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
                f.naniosvinc
               -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
           INTO pcuposugv1, pcupogarv1, pcapafinv1, pncontpol,
                -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
                pnaniosvinc
               -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
           FROM fin_indicadores f
          WHERE f.sfinanci = psfinanci AND f.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pcuposugv1 := 0;
            pcupogarv1 := 0;
            pcapafinv1 := 0;
            pncontpol := 0;
            -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adiciona campo
            pnaniosvinc := 0;
      END;
     --Ini IAXIS-7748 -- ECP -- 19/02/2020
BEGIN
   UPDATE fin_indicadores a
      SET a.icupos = pcuposug,
          a.icupog = pcupogar,
          a.fcupos = f_sysdate,
          a.fcupo  = f_sysdate,
          a.icupogv1 = pcuposugv1,
          a.icuposv1 = pcupogarv1,
          a.ncapfin = pcapafin,
          a.ncapfinv1 = pcapafinv1,
          a.naniosvinc = pnaniosvinc,
          a.ncontpol = pncontpol
    WHERE a.sfinanci = psfinanci AND a.nmovimi = v_nmovimi and icupog = 0 and icupos = 3 ;
END;
BEGIN
   UPDATE fin_indicadores a
      SET a.icupos = pcuposug,
          a.icupog = pcupogar,
          a.fcupos = f_sysdate,
          a.fcupo  = f_sysdate,
          a.icupogv1 = pcuposugv1,
          a.icuposv1 = pcupogarv1,
          a.ncapfin = pcapafin,
          a.ncapfinv1 = pcapafinv1,
          a.naniosvinc = pnaniosvinc,
          a.ncontpol = pncontpol
    WHERE a.sfinanci = psfinanci AND a.nmovimi = v_nmovimi and icupog is null and icupos is null ;
END;
--Fin IAXIS-7748 -- ECP -- 19/02/2020
      vpasexec := 44;
      -- FIN TCS_3 - JLTS - 19/02/2019 - Se devuelve el valor de los campos ICUPOS, ICUPOG y NCAPFIN
      COMMIT;
      RETURN v_cupo;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vmensaje
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_param_info
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vmensaje
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_info
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vmensaje
                                           );
         ROLLBACK;
         RETURN vretmen;
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
         ROLLBACK;
         RETURN 1;
   END f_calcula_modelo;

   /**********************************************************************
    FUNCTION f_get_cifin_intermedio
    Funci?n que retorna los datos de cifin intermenio.
    Param IN  pctipide  : ctipide
    Param IN  pnnumide  : snnumide
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_cifin_intermedio (
      pctipide   IN       NUMBER,
      pnnumide   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)                  := 1;
      vparam     VARCHAR2 (2000)
                    := 'pctipide = ' || pctipide || 'pnnumide = ' || pnnumide;
      vobject    VARCHAR2 (200) := 'PAC_MD_FINANCIERA.f_get_cifin_intermedio';
      cur        sys_refcursor;
      vsinterf   NUMBER;
      v_msg      VARCHAR2 (32000);
      v_msgout   VARCHAR2 (32000);
      vparser    xmlparser.parser;
      v_domdoc   xmldom.domdocument;
      verror     int_resultado.terror%TYPE;
      vnerror    int_resultado.nerror%TYPE;
      vctipide   NUMBER;
   BEGIN
      IF pctipide IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      IF pnnumide IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      IF pctipide = 36
      THEN
         vctipide := 1;
      ELSIF pctipide = 37
      THEN
         vctipide := 2;
      ELSIF pctipide = 33
      THEN
         vctipide := 3;
      ELSIF pctipide = 34
      THEN
         vctipide := 4;
      ELSIF pctipide = 24
      THEN
         vctipide := 5;
      ELSIF pctipide = 35
      THEN
         vctipide := 9;
      ELSIF pctipide = 44
      THEN
         vctipide := 10;
      END IF;

      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      v_msg :=
            '<?xml version="1.0"?>
                  <cifin_out>
                    <sinterf>'
         || vsinterf
         || '</sinterf>
                    <cempres>'
         || pac_md_common.f_get_cxtempresa
         || '</cempres>
                    <codigoInformacion>'
         || pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                           'CIFIN_CODINFO'
                                          )
         || '</codigoInformacion>
                    <motivoConsulta>'
         || pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                           'CIFIN_MOTIVO'
                                          )
         || '</motivoConsulta>
                    <numeroIdentificacion>'
         || pnnumide
         || '</numeroIdentificacion>
                    <tipoIdentificacion>'
         || vctipide
         || '</tipoIdentificacion>
                  </cifin_out> ';
      vpasexec := 4;

      INSERT INTO int_mensajes
                  (sinterf, cinterf, finterf, tmenout, tmenin
                  )
           VALUES (vsinterf, 'I070', f_sysdate, v_msg, NULL
                  );

      COMMIT;
      pac_int_online.peticion_host (pac_md_common.f_get_cxtempresa,
                                    'I070',
                                    v_msg,
                                    v_msgout
                                   );
      parsear (v_msgout, vparser);
      v_domdoc := xmlparser.getdocument (vparser);
      verror := NVL (pac_xml.buscarnodotexto (v_domdoc, 'error'), 0);

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      cur := pac_financiera.f_get_cifin_intermedio (pctipide, pnnumide);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cifin_intermedio;

   /**********************************************************************
    FUNCTION f_get_int_carga_informacol
    Funci?n que retorna los datos de informa colombia.
    Param IN  pnit  : nit
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_int_carga_informacol (
      pnit       IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)                  := 1;
      vparam     VARCHAR2 (2000)             := 'pnit = ' || pnit;
      vobject    VARCHAR2 (200)
                            := 'PAC_MD_FINANCIERA.f_get_int_carga_informacol';
      cur        sys_refcursor;
      vsinterf   NUMBER;
      v_msg      VARCHAR2 (32000);
      v_msgout   VARCHAR2 (32000);
      vparser    xmlparser.parser;
      v_domdoc   xmldom.domdocument;
      verror     int_resultado.terror%TYPE;
      vnerror    int_resultado.nerror%TYPE;
   BEGIN
      IF pnit IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      v_msg :=
            '<?xml version="1.0"?>
                  <informa_out>
                    <sinterf>'
         || vsinterf
         || '</sinterf>
                    <cempres>'
         || pac_md_common.f_get_cxtempresa
         || '</cempres>
                    <nombre>222</nombre>
                    <numeroIdentificacion>'
         || pnit
         || '</numeroIdentificacion>
                  </informa_out> ';
      vpasexec := 4;

      INSERT INTO int_mensajes
                  (sinterf, cinterf, finterf, tmenout, tmenin
                  )
           VALUES (vsinterf, 'I071', f_sysdate, v_msg, NULL
                  );

      COMMIT;
      pac_int_online.peticion_host (pac_md_common.f_get_cxtempresa,
                                    'I071',
                                    v_msg,
                                    v_msgout
                                   );
      parsear (v_msgout, vparser);
      v_domdoc := xmlparser.getdocument (vparser);
      verror := NVL (pac_xml.buscarnodotexto (v_domdoc, 'error'), 0);

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      cur := pac_financiera.f_get_int_carga_informacol (pnit);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_int_carga_informacol;

   /*************************************************************************
      Traspasa a las EST si es necesario desde las tablas reales
      param out mensajes  : mensajes de error
      return              : Nulo si hay un error
   *************************************************************************/
   FUNCTION f_traspasar_errores_mensajes (errores IN t_ob_error)
      RETURN t_iax_mensajes
   IS
      vnumerr       NUMBER (8)      := 0;
      mensajesdst   t_iax_mensajes;
      errind        ob_error;
      msg           ob_iax_mensajes;
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (500)  := ' ';
      vobject       VARCHAR2 (200)
                          := 'PAC_MD_FINANCIERA.f_traspasar_errores_mensajes';
   BEGIN
      mensajesdst := t_iax_mensajes ();

      IF errores IS NOT NULL
      THEN
         IF errores.COUNT > 0
         THEN
            FOR vmj IN errores.FIRST .. errores.LAST
            LOOP
               IF errores.EXISTS (vmj)
               THEN
                  errind := errores (vmj);
                  mensajesdst.EXTEND;
                  mensajesdst (mensajesdst.LAST) := ob_iax_mensajes ();
                  mensajesdst (mensajesdst.LAST).tiperror := 1;
                  mensajesdst (mensajesdst.LAST).cerror := errind.cerror;
                  mensajesdst (mensajesdst.LAST).terror := errind.terror;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN mensajesdst;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajesdst,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN mensajesdst;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajesdst,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN mensajesdst;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajesdst,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN mensajesdst;
   END f_traspasar_errores_mensajes;

        /**********************************************************************
    FUNCTION F_INDICADORES_CLIENTE
    Funci?n que consulta los indicadores del cliente.
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
   FUNCTION f_indicadores_cliente (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmonori    IN       VARCHAR2,
      pcmondes    IN       VARCHAR2,
      pmaropecl   OUT      NUMBER,
      pcaptracl   OUT      NUMBER,
      prazcorcl   OUT      NUMBER,
      ppruacicl   OUT      NUMBER,
      pendtotcl   OUT      NUMBER,
      protcarcl   OUT      NUMBER,
      protprocl   OUT      NUMBER,
      protinvcl   OUT      NUMBER,
      pcicefecl   OUT      NUMBER,
      prentabcl   OUT      NUMBER,
      pobficpcl   OUT      NUMBER,
      pobfilpcl   OUT      NUMBER,
      pgasfincl   OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr               NUMBER (8)      := 0;
      vpasexec              NUMBER (8)      := 1;
      vparam                VARCHAR2 (500)  := 'parametros  - ';
      vobject               VARCHAR2 (200)
                                 := 'PAC_MD_FINANCIERA.f_indicadores_cliente';
      v_cant_deci           NUMBER (1)      := 2;
      v_itasa               NUMBER          := 0;
      v_existe              NUMBER          := 0;
      vmensaje              VARCHAR2 (1000) := 'parmetros sin informar - ';

      TYPE parametros IS VARRAY (28) OF VARCHAR2 (50);

      v_nombresparametros   parametros;
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pnmovimi IS NULL
      THEN
         vparam := vparam || ' pnmovimi =' || pnmovimi;
         RAISE e_param_error;
      END IF;

      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL
      THEN
         v_itasa :=
            pac_financiera.f_get_itasa (psfinanci,
                                        pnmovimi,
                                        pcmonori,
                                        pcmondes,
                                        'FECHA_EST_FIN'
                                       );
      END IF;

      /*
            v_nombresParametros := parametros ('FECHA_EST_FIN', 'VT_PER_ANT', 'VENTAS', 'COSTO_VT', 'GASTO_ADM',
                                               'UTIL_OPERAC', 'GASTO_FIN', 'RES_ANT_IMP', 'UTIL_NETA', 'INVENT',
                                               'CARTE_CLIE', 'ACT_CORR', 'PROP_PLNT_EQP', 'TOT_ACT_NO_CORR', 'ACT_TOTAL',
                                               'O_FIN_CORTO_PLAZO', 'PROVEE_CORTO_PLAZO', 'ATC_CORTO_PLAZO', 'PAS_CORR', 'O_FIN_LARGO_PLAZO',
                                               'ATC_LARGO_PLAZO', 'PAS_NO_CORR', 'PAS_TOTAL', 'PATRI_PERI_ANT', 'PATRI_ANO_ACTUAL',
                                               'RESV_LEGAL', 'CAP_SOCIAL', 'RES_EJER_ANT');


            FOR i IN 1 .. v_nombresParametros.COUNT LOOP

                  SELECT COUNT(*)
                  INTO V_EXISTE
                  FROM FIN_PARAMETROS
                 WHERE SFINANCI = PSFINANCI
                    AND  CPARAM = v_nombresParametros(i);

                 IF V_EXISTE = 0 THEN
                    vmensaje  := vmensaje  || ' - v_nombresParametros(i) - ';
                    RAISE e_param_info;
                    EXIT;
                 END IF;
            END LOOP;
        */
      pmaropecl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'UTIL_OPERAC'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'VENTAS'
                                                    )
                  )
                * 100,
                v_cant_deci
               );
      pcaptracl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'ACT_CORR'
                                                    )
                   - pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'PAS_CORR'
                                                    )
                  )
                / 1000,
                0
               );

      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL AND v_itasa IS NOT NULL
      THEN
         pcaptracl := pcaptracl * v_itasa;
      END IF;

      prazcorcl :=
         ROUND (  pac_financiera.f_get_fin_param (psfinanci,
                                                  pnmovimi,
                                                  'ACT_CORR'
                                                 )
                / pac_financiera.f_get_fin_param (psfinanci,
                                                  pnmovimi,
                                                  'PAS_CORR'
                                                 ),
                v_cant_deci
               );
      ppruacicl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'ACT_CORR'
                                                    )
                   - pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'INVENT'
                                                    )
                  )
                / pac_financiera.f_get_fin_param (psfinanci,
                                                  pnmovimi,
                                                  'PAS_CORR'
                                                 ),
                v_cant_deci
               );
      pendtotcl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'PAS_TOTAL'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'ACT_TOTAL'
                                                    )
                  )
                * (100),
                v_cant_deci
               );
      protcarcl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'CARTE_CLIE'
                                                    )
                   * 360
                  )
                / pac_financiera.f_get_fin_param (psfinanci,
                                                  pnmovimi,
                                                  'VENTAS'
                                                 ),
                v_cant_deci
               );
      protprocl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'PROVEE_CORTO_PLAZO'
                                                    )
                   * 360
                  )
                / pac_financiera.f_get_fin_param (psfinanci,
                                                  pnmovimi,
                                                  'COSTO_VT'
                                                 ),
                v_cant_deci
               );
      protinvcl :=
         ROUND (  360
                * (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'INVENT'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'VENTAS'
                                                    )
                  ),
                v_cant_deci
               );
      pcicefecl := ROUND ((protcarcl + protinvcl - protprocl), v_cant_deci);
      prentabcl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'UTIL_NETA'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'VENTAS'
                                                    )
                  )
                * 100,
                v_cant_deci
               );
      pobficpcl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'O_FIN_CORTO_PLAZO'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'VENTAS'
                                                    )
                  )
                * 100,
                v_cant_deci
               );
      pobfilpcl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'O_FIN_LARGO_PLAZO'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'VENTAS'
                                                    )
                  )
                * 100,
                v_cant_deci
               );
      pgasfincl :=
         ROUND (  (  pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'GASTO_FIN'
                                                    )
                   / pac_financiera.f_get_fin_param (psfinanci,
                                                     pnmovimi,
                                                     'UTIL_OPERAC'
                                                    )
                  )
                * 100,
                v_cant_deci
               );
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_indicadores_cliente;

   /**********************************************************************
    FUNCTION F_INDICADORES_SECTOR
    Funci?n que consulta los indicadores del cliente.
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
   FUNCTION f_indicadores_sector (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmonori    IN       VARCHAR2,
      pcmondes    IN       VARCHAR2,
      pmaropese   OUT      NUMBER,
      pcaptrase   OUT      NUMBER,
      prazcorse   OUT      NUMBER,
      ppruacise   OUT      NUMBER,
      pendtotse   OUT      NUMBER,
      protcarse   OUT      NUMBER,
      protprose   OUT      NUMBER,
      protinvse   OUT      NUMBER,
      pcicefese   OUT      NUMBER,
      prentabse   OUT      NUMBER,
      pobficpse   OUT      NUMBER,
      pobfilpse   OUT      NUMBER,
      pgasfinse   OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr               NUMBER (8)      := 0;
      vpasexec              NUMBER (8)      := 1;
      vparam                VARCHAR2 (500)  := 'parametros  - ';
      vobject               VARCHAR2 (200)
                               := 'PAC_MD_FINANCIERA.f_get_margenoperacional';
      v_cant_deci           NUMBER (1)      := 2;
      v_cursor              sys_refcursor;
      v_ciiu                NUMBER          := 0;
      v_nit                 VARCHAR2 (50)   := 0;
      v_itasa               NUMBER          := 0;
      v_existe              NUMBER          := 0;
      vmensaje              VARCHAR2 (1000) := 'parmetros sin informar - ';

      TYPE parametros IS VARRAY (28) OF VARCHAR2 (50);

      v_nombresparametros   parametros;
   BEGIN
      IF psfinanci IS NULL
      THEN
         vparam := vparam || ' psfinanci =' || psfinanci;
         RAISE e_param_error;
      END IF;

      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL
      THEN
         v_itasa :=
            pac_financiera.f_get_itasa (psfinanci,
                                        pnmovimi,
                                        pcmonori,
                                        pcmondes,
                                        'FECHA_EST_FIN'
                                       );
      END IF;

      /*
              v_nombresParametros := parametros ('FECHA_EST_FIN', 'VT_PER_ANT', 'VENTAS', 'COSTO_VT', 'GASTO_ADM',
                                                 'UTIL_OPERAC', 'GASTO_FIN', 'RES_ANT_IMP', 'UTIL_NETA', 'INVENT',
                                                 'CARTE_CLIE', 'ACT_CORR', 'PROP_PLNT_EQP', 'TOT_ACT_NO_CORR', 'ACT_TOTAL',
                                                 'O_FIN_CORTO_PLAZO', 'PROVEE_CORTO_PLAZO', 'ATC_CORTO_PLAZO', 'PAS_CORR', 'O_FIN_LARGO_PLAZO',
                                                 'ATC_LARGO_PLAZO', 'PAS_NO_CORR', 'PAS_TOTAL', 'PATRI_PERI_ANT', 'PATRI_ANO_ACTUAL',
                                                 'RESV_LEGAL', 'CAP_SOCIAL', 'RES_EJER_ANT');


              FOR i IN 1 .. v_nombresParametros.COUNT LOOP

                    SELECT COUNT(*)
                    INTO V_EXISTE
                    FROM FIN_PARAMETROS
                   WHERE SFINANCI = PSFINANCI
                      AND  CPARAM = v_nombresParametros(i);

                   IF V_EXISTE = 0 THEN
                      vmensaje  := vmensaje  || ' - v_nombresParametros(i) - ';
                      RAISE e_param_info;
                      EXIT;
                   END IF;
              END LOOP;
       */
      v_ciiu := pac_financiera.f_get_ciiu (psfinanci);
      --  v_nit := PAC_FINANCIERA.F_GET_NIT(psfinanci);
      pmaropese :=
         ROUND (  (  pac_financiera.f_get_utloperacional (v_ciiu,
                                                          psfinanci,
                                                          pnmovimi
                                                         )
                   / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi)
                  )
                * 100,
                v_cant_deci
               );
      pcaptrase :=
         ROUND (  (  pac_financiera.f_get_actcorriente (v_ciiu,
                                                        psfinanci,
                                                        pnmovimi
                                                       )
                   - pac_financiera.f_get_pascorriente (v_ciiu,
                                                        psfinanci,
                                                        pnmovimi
                                                       )
                  )
                / 1000,
                0
               );

      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL AND v_itasa IS NOT NULL
      THEN
         pcaptrase := pcaptrase * v_itasa;
      END IF;

      prazcorse :=
         ROUND (  pac_financiera.f_get_actcorriente (v_ciiu,
                                                     psfinanci,
                                                     pnmovimi
                                                    )
                / pac_financiera.f_get_pascorriente (v_ciiu,
                                                     psfinanci,
                                                     pnmovimi
                                                    ),
                v_cant_deci
               );
      ppruacise :=
         ROUND (  (  pac_financiera.f_get_actcorriente (v_ciiu,
                                                        psfinanci,
                                                        pnmovimi
                                                       )
                   - pac_financiera.f_get_inventario (v_ciiu,
                                                      psfinanci,
                                                      pnmovimi
                                                     )
                  )
                / pac_financiera.f_get_pascorriente (v_ciiu,
                                                     psfinanci,
                                                     pnmovimi
                                                    ),
                v_cant_deci
               );
      pendtotse :=
         ROUND (  (  pac_financiera.f_get_pastotal (v_ciiu,
                                                    psfinanci,
                                                    pnmovimi
                                                   )
                   / pac_financiera.f_get_activototal (v_ciiu,
                                                       psfinanci,
                                                       pnmovimi
                                                      )
                  )
                * 100,
                v_cant_deci
               );
      protcarse :=
         ROUND (  (  pac_financiera.f_get_cartcliente (v_ciiu,
                                                       psfinanci,
                                                       pnmovimi
                                                      )
                   * 360
                  )
                / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi),
                v_cant_deci
               );
      protprose :=
         ROUND (  (  pac_financiera.f_get_proveedorescp (v_ciiu,
                                                         psfinanci,
                                                         pnmovimi
                                                        )
                   * 360
                  )
                / pac_financiera.f_get_costoventas (v_ciiu,
                                                    psfinanci,
                                                    pnmovimi
                                                   ),
                v_cant_deci
               );
      protinvse :=
         ROUND (  360
                * pac_financiera.f_get_inventario (v_ciiu, psfinanci,
                                                   pnmovimi)
                / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi),
                v_cant_deci
               );
      pcicefese := ROUND ((protcarse + protinvse - protprose), v_cant_deci);
      prentabse :=
         ROUND (  (  pac_financiera.f_get_utlneta (v_ciiu, psfinanci,
                                                   pnmovimi)
                   / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi)
                  )
                * 100,
                v_cant_deci
               );
      pobficpse :=
         ROUND (  (  pac_financiera.f_get_obligfinancp (v_ciiu,
                                                        psfinanci,
                                                        pnmovimi
                                                       )
                   / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi)
                  )
                * 100,
                v_cant_deci
               );
      pobfilpse :=
         ROUND (  (  pac_financiera.f_get_obligfinanlp (v_ciiu,
                                                        psfinanci,
                                                        pnmovimi
                                                       )
                   / pac_financiera.f_get_ventas (v_ciiu, psfinanci, pnmovimi)
                  )
                * 100,
                v_cant_deci
               );
      pgasfinse :=
         ROUND (  (  pac_financiera.f_get_gastosfinan (v_ciiu,
                                                       psfinanci,
                                                       pnmovimi
                                                      )
                   / pac_financiera.f_get_utloperacional (v_ciiu,
                                                          psfinanci,
                                                          pnmovimi
                                                         )
                  )
                * 100,
                v_cant_deci
               );

      -- Inicio IAXIS-2122 -- ECP -- 15/04/2019
      BEGIN
         INSERT INTO fin_indica_sector
                     (cciiu, nmovimi, imargen, icaptrab, trazcor,
                      tprbaci, ienduada, ndiacar, nrotpro, nrotinv,
                      ndiacicl, irentab, ioblcp, iobllp, igastfin,
                      ivalpt
                     )
              VALUES (v_ciiu, pnmovimi, pmaropese, pcaptrase, prazcorse,
                      ppruacise, pendtotse, protcarse, protprose, protinvse,
                      pcicefese, prentabse, pobficpse, pobfilpse, pgasfinse,
                      v_itasa
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            NULL;
      END;

      -- Fin  IAXIS-2122 -- ECP -- 15/04/2019
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_indicadores_sector;

   -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
   /**********************************************************************
     FUNCTION F_VPATRIMONIAL
     Funcin que valida la ecuacin patrimonial.
     Param  IN psfinanci: sfinanci
     Param  IN pnmovimi: nmovimi
    **********************************************************************/
   FUNCTION f_vpatrimonial (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros  - ';
      vobject    VARCHAR2 (200) := 'PAC_IAX_FINANCIERA.f_vpatrimonial';
      verrores   t_ob_error;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      vnumerr := pac_financiera.f_vpatrimonial (psfinanci, pnmovimi, mensajes);

      IF vnumerr <> 0
      THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_vpatrimonial;

   -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial

   /**********************************************************************
    FUNCTION F_GET_FIN_INDICA_SECTOR
    Funci?n que retorna los datos de los indicadores del sector.
    Param IN  psfinanci  : sfinanci
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_fin_indica_sector (
      psfinanci   IN       NUMBER,
      pcmonori    IN       VARCHAR2,
      pcmondes    IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_FINANCIERA.f_get_fin_indica_sector';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur :=
         pac_financiera.f_get_fin_indica_sector (psfinanci, pcmonori,
                                                 pcmondes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_fin_indica_sector;

-- ===========================================================================
--  P A R A M E T R O S  C O N E X I O N
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de par?metros de CONEXION
       param out mensajes : mensajes de error
       return             : descripci?n del par?metro -> Si ha ido bi?n
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_conparam (
      psfinanci   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcmonori    IN       VARCHAR2,
      pcmondes    IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vcursor    sys_refcursor;
      squery     VARCHAR2 (2000);
      squery1    VARCHAR2 (2000);
      vnumerr    NUMBER (8);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_conparam';
      vitasa     NUMBER;
   BEGIN
      IF pcmonori IS NOT NULL AND pcmondes IS NOT NULL
      THEN
         --Inicialitzacions
         squery1 :=
               '(SELECT NVL(MAX(e.itasa),1) contador FROM ECO_TIPOCAMBIO e WHERE  e.CMONORI = '''
            || pcmonori
            || ''' AND e.CMONDES = '''
            || pcmondes
            || ''' AND e.FCAMBIO = (SELECT FVALPAR FROM FIN_PARAMETROS WHERE CPARAM = ''FECHA_EST_FIN'' AND SFINANCI = '
            || psfinanci
            || ' AND NMOVIMI = '
            || pnmovimi
            || ' ))';
      ELSE
         squery1 := '1';
      END IF;

      squery :=
            ''
         || ' select norden_agr,  cgrppar,tgrppar,cutili,cobliga,cparam,ctipo,tparam,cvisible,to_number(tvalpar, ''9999999999999D999'', ''NLS_NUMERIC_CHARACTERS = '''',.'''''') * '
         || squery1
         || ' AS tvalpar,nvalpar * '
         || squery1
         || '  AS nvalpar,fvalpar,resp,e ,norden '
         || ' from(SELECT cd.norden norden_agr, c.cgrppar,null tgrppar,c.cutili,c.cobliga,c.cparam, c.ctipo, d.tparam, cp.cvisible, fp.tvalpar, fp.nvalpar, fp.fvalpar, '
         || ' (select det.tvalpar from detparam det  where det.cparam = c.cparam and det.cidioma = d.cidioma and det.cvalpar = fp.nvalpar) resp,3 e, c.norden '
         || ' FROM CODGRPPARAM cd, codparam c, desparam d, codparam_per cp, fin_parametros fp, fin_general fg '
         || ' WHERE c.cutili = 11 '
         || ' AND d.cparam = c.cparam  AND cd.cgrppar = c.cgrppar '
         || ' AND cp.cparam = c.cparam '
         || ' AND d.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ' AND fp.cparam (+)= cp.cparam '
         || ' AND fp.sfinanci (+)= '
         || psfinanci
         || ' AND fp.nmovimi (+)=  '
         || pnmovimi
         || ' and fg.sfinanci (+)= fp.sfinanci'
         || ' ) order by norden_agr, decode(e,1,1,2), norden ';
      vcursor := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_conparam;

   PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser)
   IS
   BEGIN
      p_parser := xmlparser.newparser;
      xmlparser.setvalidationmode (p_parser, FALSE);

      IF DBMS_LOB.getlength (p_clob) > 32767
      THEN
         xmlparser.parseclob (p_parser, p_clob);
      ELSE
         xmlparser.parsebuffer (p_parser,
                                DBMS_LOB.SUBSTR (p_clob,
                                                 DBMS_LOB.getlength (p_clob),
                                                 1
                                                )
                               );
      END IF;
   END;

   FUNCTION f_modificar_cciiu (
      psfinanci   IN       NUMBER,
      pcciiu      IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER;
      vobjectname   VARCHAR2 (500)  := 'PAC_MD_FINANCIERA.f_modificar_cciiu';
      vpasexec      NUMBER (5)      := 1;
      vparam        VARCHAR2 (1000) := 'parmetros - ';
      verrores      t_ob_error;
   BEGIN
      IF pcciiu IS NULL
      THEN
         vparam := vparam || ' pcciiu =' || pcciiu;
         RAISE e_param_error;
      END IF;

      vnumerr :=
                pac_financiera.f_modificar_cciiu (psfinanci, pcciiu, mensajes);
      mensajes := f_traspasar_errores_mensajes (verrores);

      IF vnumerr = 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
                                            vparam
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
   END f_modificar_cciiu;

   /**********************************************************************
    FUNCTION F_GET_PERSONA_FIN
    Funci?n que retorna los datos deL tipo de persona.
    Param IN  psfinanci: sfinanci
    Param OUT PRETCURSOR : SYS_REF_CURSOR
   **********************************************************************/
   FUNCTION f_get_persona_fin (
      psfinanci   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000) := 'psfinanci = ' || psfinanci;
      vobject    VARCHAR2 (200)  := 'PAC_MD_FINANCIERA.f_get_persona_fin';
      cur        sys_refcursor;
   BEGIN
      IF psfinanci IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      cur := pac_financiera.f_get_persona_fin (psfinanci);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_persona_fin;
END pac_md_financiera;

/
