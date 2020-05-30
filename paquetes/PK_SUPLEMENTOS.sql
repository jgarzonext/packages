--------------------------------------------------------
--  DDL for Package PK_SUPLEMENTOS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PK_SUPLEMENTOS" IS
    --Modificaciones
    --JRH 09/2007 Tarea 2674: Intereses para LRC. Anadimos los nuevos campos ndesde y nhasta. Hemos de contar que en este caso
    --pueden haber m?s de un registro por poliza en las tablas de intereses a nivel de p?liza.
   /******************************************************************************
    NAME:       PK_SUPLEMENTOS
    PURPOSE:    Contiene las funciones necesarias para realizar un suplemento

    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????  ???              1. Created this package body.
    2.0        03/04/2009  DRA              2. 0009217: IAX - Suplement de cl?usules
    6.0        24/04/2009  RSC              6. 0009905: Suplemento de cambio de
                                                        forma de pago diferido
    7.0        29/05/2009  ICV              7. 0008947: CRE046 - Gesti?n de cobertura Enfermedad Grave en siniestros
    8.0        13/10/2009  XVM              8. 0011376: CEM - Suplementos y param. DIASATRAS
    9.0        30/10/2009  AMC              9. 11376 - Se anade el parametro pcmotmov a la funcion f_inicializa_suplemento
    10.0       21/01/2010  DRA              10.0011737: APR - suplemento de cambio de revalorizaci?n
    11.0       30/06/2010  DRA              11.0014709: CEM - Cambio de forma de pago diferida
    12.0       31/08/2010  DRA              12. 0015684: CRE800 - Modificaci? de garanties en prop. suplement
    13.0       02/11/2010  XPL              13. 16352: CRT702 - M?dulo de Propuestas de Suplementos, -- BUG16352:XPL:02112010 INICI
    14.0       04/11/2010  DRA              14. 0015823: CRE803 - Activar suplement autom?tic fi n?mina domiciliada per al producte CV Previsi? (293)
    15.0       10/03/2011  DRA              15. 0017787: CRE998 - Suplement m?ltiple en p?lisses d'estalvi
    16.0       04/07/2011  JTS              16. 0017255: CRT003 - Definir propuestas de suplementos en productos
    17.0       01/11/2012  DRA              17. 0024271: LCOL_T010-LCOL - SUPLEMENTO DE TRASLADO DE VIGENCIA
    18.0       30/05/2013  ECP              18. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI). Nota 145539
    19.0       30/01/2015  AFM              19. 0034462: Suplementos de convenios (retroactivos)
    20.0       23/01/2018  JLTS             20. CONF-1243 QT_724 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
    21.0       09/04/2019  CJMR             21. IAXIS-3396: Se agrega campo para ajustar cambios de fechas de vigencias
    22.0       18/06/2019  ROHIT            22. IAXIS 4320: Errores Ramo Cumplimiento : for adding Beneficiario anulado and Beneficiario añadido
    23.0       24/12/2019  ECP              23. IAXIS-3504. Pantallas Gestión Suplementos
   ******************************************************************************/
-----------------------------------------------------------------------------

  --IAXIS 4320   Errores Ramo Cumplimiento 18/06/2019
  ---for adding Beneficiario anulado
  G_VANTES     VARCHAR2 (1000):=null; ----added 


   FUNCTION f_permite_este_suplemento(psseguro IN NUMBER, pfefecto IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;
-- Ini IAXIS-3504 --ECP -- 24/12/2019
   FUNCTION f_inicializar_fechas(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pdate IN DATE DEFAULT NULL,
      pcmodo IN VARCHAR2 DEFAULT 'SUPLEMENTO',
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
-- Fin IAXIS-3504 --ECP -- 24/12/2019
   -- Ini Bug.: 8947 - ICV - 28/05/2009
   -- Se anade un nuevo parametro de entrada para diferenciar
   -- si este movimiento se valida a el mismo exclusivamente
   -- o si valida con el resto de movimientos del producto.
   -- Pcmotmov in number default null : Codigo de movimiento del suplemento.
   FUNCTION f_validar_cambios(
      pcuser IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      ptform VARCHAR2,
      pcmodo IN VARCHAR2,
      pcidioma IN NUMBER DEFAULT 2,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_fecha_efecto(psseguro IN NUMBER, pnmovimi IN NUMBER, pfecha IN OUT DATE)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_obtener_cmotmov(psseguro IN NUMBER, pnmovimi IN NUMBER, pcmotmov IN OUT NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_visitar_forms(psseguro IN NUMBER, pform_act IN VARCHAR2, psproduc IN NUMBER)
      RETURN VARCHAR2;

-----------------------------------------------------------------------------
   FUNCTION f_capital(psproduc IN NUMBER, psseguro IN NUMBER, pdata IN OUT DATE)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_cforpag(psproduc IN NUMBER, psseguro IN NUMBER, pdata IN OUT DATE)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_fcarpro(psseguro IN NUMBER, pdata IN OUT DATE)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   PROCEDURE p_insdetmovseguro(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pantes IN VARCHAR2,
      pdespues IN VARCHAR2,
      pcpregun IN NUMBER DEFAULT 0);

-----------------------------------------------------------------------------
   FUNCTION f_validar_garantias(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pssegpol IN NUMBER,
      vmensa IN OUT VARCHAR2)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_traspasar_direcciones(psseguro IN NUMBER, psperson IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_recuperar_direcciones(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_borrar_supdirecciones(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_pds_deshabilitar(pccampval IN VARCHAR2, pttabval IN VARCHAR2, psseguro IN NUMBER)
      RETURN VARCHAR2;

-----------------------------------------------------------------------------
   FUNCTION f_obtener_k_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      picapital IN OUT NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_obtener_porcentaje(psseguro IN NUMBER, pporcen IN OUT NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_actualiza_porcentaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      picapital IN NUMBER,
      ppporcen IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_traspasar_datos_personas(psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   PROCEDURE p_borrar_datos_asegurado(psseguro IN NUMBER);

-----------------------------------------------------------------------------
   FUNCTION f_recuperar_datos_asegurado(psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_validar_fechasup(
      psseguro IN NUMBER,
      pfefesup IN DATE,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_permite_suplementos(
      psseguro IN NUMBER,
      pfefesup IN DATE DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      pcmodo IN VARCHAR2 DEFAULT 'SUPLEMENTO')
      RETURN NUMBER;

-- Bug 11376 - 30/10/2009 - AMC  - Se anade el pcmotmov
-----------------------------------------------------------------------------
   FUNCTION f_permite_anadir_suplementos(
      psseguro IN NUMBER,
      puser IN VARCHAR2,
      pcmodo IN VARCHAR2,
      ptform IN VARCHAR2,
      ptcampo IN VARCHAR2 DEFAULT '*',
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-----------------------------------------------------------------------------
-- Bug 11376 - 30/10/2009 - AMC - Se anade el parametro pcmotmov
   FUNCTION f_inicializar_suplemento(
      psseguro IN NUMBER,
      pcmodo IN VARCHAR2,
      pfefesup IN DATE DEFAULT NULL,
      ptform IN VARCHAR2,
      ptcampo IN VARCHAR2 DEFAULT '*',
      pcmotmov IN NUMBER,
      p_est_sseguro OUT NUMBER,
      pnmovimi OUT NUMBER,
      pllamada IN VARCHAR2 DEFAULT 'PRAGMA',   -- BUG15823:DRA:04/11/2010
      pvalida_supl IN NUMBER DEFAULT 1)   -- Bug 26070 - APD - 11/03/2013
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_grabar_suplemento_poliza(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_final_suplemento(p_est_sseguro IN NUMBER, pnmovimi IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_update_rec_pend(psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_abrir_sin_baja_ries(psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_abrir_sin_baja_gar(psseguro IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_post_suplemento(psseguro IN NUMBER, pcmodo IN VARCHAR2 DEFAULT 'SUPLEMENTO')
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_anular_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      pnmovimi IN NUMBER,
      pssegpol IN NUMBER,
      pcnotibaja IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_borrar_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   /*************************************************************************
      BUG9217 - 03/04/2009 - DRA
      Retorna por par?metro si permite hacer el suplemento de un motivo determinado
      param in  pcuser      : C?digo del usuario
      param in  pcmotmov    : C?digo del motivo
      param in  psproduc    : id. producto
      return                : 0.- SI    <> 0 --> NO (literal error)
   *************************************************************************/
   FUNCTION f_permite_supl_prod(
      p_cuser IN pds_config_user.cuser%TYPE,
      p_cmotmov IN pds_supl_config.cmotmov%TYPE,
      p_sproduc IN productos.sproduc%TYPE)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   /*************************************************************************
      Retorna en una variable de salida de tipo T_LISTA_ID la lista de motivos
      de movimiento de suplemento generados en un suplemento.

      param in  pcuser    : C?digo del usuario.
      param in  psseguro  : C?digo de seguro.
      param in  pnmovimi  : C?digo de movimiento de suplemento.
      param in  psproduc  : C?digo de producto.
      param in  ptform    : C?digo de form (BBDD)
      param in  pcmodo    : Modalidad
      param out pcmotmovs : Lista de motivos de movimiento
      param in  pcidioma  : Idioma
      return              : 0.- OK    <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_cmotmov_cambios(
      pcuser IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      ptform VARCHAR2,
      pcmodo IN VARCHAR2,
      pcmotmovs OUT t_lista_id,
      pcidioma IN NUMBER DEFAULT 2)
      RETURN NUMBER;

    /*************************************************************************
      Funci?n destinada a su utilizaci?n como POST SUPLEMENTO en aquellos
      contextos en que se utilice la tabla SEG_CBANCAR y se quiera dejar
      el campo CBANCOB a NULL cuando se haya realizado un suplemento
      de modificaci?n de cuenta.

      param in  psseguro  : C?digo de seguro.
      return              : 0.- OK    <> 0 --> Error
   *************************************************************************/
   -- Bug 7926 - 01/06/2009 - RSC - Fecha de vencimiento a nivel de garant?a
   FUNCTION f_update_cbancob_cbancar(psseguro IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 7926

   /***********************************************************************
     FUNCTION F_VALIDA_FEFECTO:
      Funci? que valida la data efecte
      param in psproduc : Codi producte
      param in pfefecto  : Data efecte
      param in pfvencim : Data venciment
      param in pcmotmov : Codi motiu
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
      13/10/2009   XVM    --BUG11376
   ***********************************************************************/
   FUNCTION f_valida_fefecto(
      psproduc IN seguros.sproduc%TYPE,
      pfefecto IN seguros.fefecto%TYPE,
      pfvencim IN seguros.fvencim%TYPE,
      pcduraci IN seguros.cduraci%TYPE,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que sirve para realizar un cambio de agente y para crear nuevos detalles de personas
   de aguellas personas que no tenga detalle seg?n el agente de visi?n de la poliza.
   Donde este proceso es: vcagente_ant  === Agente inicio
                          reg.cpervisio ==  Agente Final

        param in psseguro : codigo del seguro
        retorno : 0 ok
                  1 error

     Bug 11468 - 22/10/2009 - AMC
   *************************************************************************/
   FUNCTION f_cambio_agente(psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Funcion para saber si un suplemento es incompatible
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pcestado : estado del suplemento
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_supl_incompatible(psseguro IN NUMBER, pcmotmov IN NUMBER, pcestado OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Funcion para buscar la fecha del suplemento de la configuraci?n indicada en las PDS
    param in psproduc : codigo del producto
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pfefecto : fecha de efecto
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_fsupl_pds(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfefecto OUT DATE,
      pfsuplem IN DATE DEFAULT NULL)   -- BUG14709:DRA:30/06/2010
      RETURN NUMBER;

   -- BUG11737:DRA:21/01/2010:Inici
   /*************************************************************************
      Funci?n destinada a su utilizaci?n como POST SUPLEMENTO en aquellos
      suplementos que se haya modificado el tipo de revalorizacion

      param in  psseguro  : C?digo de seguro.
      return              : 0.- OK    <> 0 --> Error
   *************************************************************************/
   FUNCTION f_actualiza_crevali_detgaran(psseguro IN NUMBER)
      RETURN NUMBER;

-- BUG11737:DRA:21/01/2010:Fi
   FUNCTION f_anular_recibos_pend(psseguro IN NUMBER)
      RETURN NUMBER;

-- BUG16352:XPL:02112010 inici
   /***********************************************************************
        Recupera la query con las solicitudes seg?n los filtros introducidos
        psseguro IN NUMBER,
        pnmovimi IN NUMBER,
        pnriesgo IN NUMBER,
        pquery out varchar2
        return             : error
     ***********************************************************************/
   FUNCTION f_get_solicitudsuplementos(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : Código seguro
      param in pnsolici  : Código seguro tablas EST
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_actualizar_sol_suplemento(psseguro IN NUMBER, pnsolici IN NUMBER)
      RETURN NUMBER;

   -- BUG16352:XPL:02112010 fi

   -- BUG17787:DRA:10/03/2011:Inici
   /*************************************************************************
      Realiza los cambios en las tablas EST antes de empezar a modificar
      param in psseguro  : C?digo seguro tablas EST
      param in pnmovimi  : Numero movimiento
      param in pcmotmov  : C?digo motivo movimiento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_pre_suplemento(psseguro IN NUMBER, pnmovimi IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER;

-- BUG17787:DRA:10/03/2011:Fi

   /*************************************************************************
      Actualiza el estado de la solicitud del suplemento
      param in psseguro  : C?digo seguro
      param in pnmovimi  : Num. Movimiento
      param in pnriesgo  : N. riesgo
      param in pcestsupl  : Estado suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_set_actualizarestado_supl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcestado IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_prod_permite_supl
      param in psproduc  : psproduc
      param in pcmotmov  : pcmotmov
      param out tmensaje : Mens Error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
      --BUG17255 - 04/07/2011 - JTS
   *************************************************************************/
   FUNCTION f_prod_permite_supl(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcactivi IN NUMBER,
      tmensaje OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_fcaranu(psseguro IN NUMBER, pdata IN OUT DATE)
      RETURN NUMBER;

   -- BUG24271:DRA:01/11/2012
   FUNCTION f_traslado_vigencia(psseguro IN NUMBER)
      RETURN NUMBER;
  -- INI BUG CONF-1243 QT_724 y QT_728- JLTS - 06/02/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   FUNCTION f_cambio_fechas_traslado_vig(psseguro IN NUMBER, psproduc IN NUMBER, pnriesgo IN NUMBER, pcgarant IN NUMBER, pnmovimi IN NUMBER,
                                         pFINIEFE IN DATE, pFEFECTO IN DATE, pFVENCIM IN DATE, pFEFEPLAZO IN DATE, pFVENCPLAZO IN DATE, pextcontractual OUT NUMBER,
                                         pcmotmov IN NUMBER, -- IAXIS-3396 CJMR 09/04/2019
                                         pndias IN NUMBER DEFAULT NULL, pnmeses IN NUMBER DEFAULT NULL, pnanios IN NUMBER DEFAULT NULL)  -- IAXIS-3394 CJMR 22/04/2019
      RETURN NUMBER;
  -- FIN BUG CONF-1243 QT_724 y QT_728- JLTS - 06/02/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)

-- BUG 226488 ECP:30/05/2013
   FUNCTION f_inicia_prorroga(psseguro IN NUMBER)
      RETURN NUMBER;

   --BUG 29229 - INICIO - DCT - 09/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi?n / Reinicio (VIII)
   FUNCTION f_pre_inicializacion_supl(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

   -- INI BUG 34462 - AFM
   FUNCTION f_fversconv(
      psseguro IN NUMBER,
      pmodo IN VARCHAR2,
      pfecha OUT DATE,
      pidversion OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_corregir_gar_movant(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-- FIN BUG 34462 - AFM

   -- BUG 0034462 - FAL - 08/04/2015
   FUNCTION f_get_cmovseg(pcmotmov IN NUMBER, pcmovseg OUT NUMBER)
      RETURN NUMBER;
-- FI BUG 0034462 - FAL - 08/04/2015

-- INICIO IAXIS-3606 - 12/04/2019
   FUNCTION f_ins_contragaran_pol (psseguro  IN NUMBER)
      RETURN NUMBER; 
-- FIN IAXIS-3606 - 12/04/2019

END pk_suplementos;
/