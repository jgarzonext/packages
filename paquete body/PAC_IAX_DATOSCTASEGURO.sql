--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DATOSCTASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DATOSCTASEGURO" AS
/*****************************************************************************
   NAME:       PAC_IAX_DATOSCTASEGURO
   PURPOSE:    Funciones de obtención de datos de CTASEGURO e importes de las pólizas de productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/04/2008   JRH             1. Creación del package.
   2.0        21/12/2009   APD             2. Bug 12426 : se crea la funcion f_anula_linea_ctaseguro
   3.0        28/06/2010   RSC             3. 14598: CEM800 - Información adicional en pantallas y documentos
   4.0        16/11/2011   JMC             4. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   5.0        31/07/2012   FAL             5. 0022839: LCOL - Funcionalidad Certificado 0
   6.0        28/03/2013   ETM             6. 0026085: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 178 - Creaci?n prod: Saldado, Prorrogado, Convertibilidad (Fase 2)
   7.0        03/09/2013   MLR             7. 0028044: RSA003-Limitar en consulta de poliza el numero de registros de resumen colectivo
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 04/2008
    /*************************************************************************
       Obtiene una serie de importes calculados propios de la póliza que se deben mostrar en varias parte de la aplicación
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       param out          : El objeto del tipo OB_IAX_DATOSECONOMICOS con los valores de esos importes
       param out mensajes : mensajes de error
       return             : 0 si todo va bien o  1.
    *************************************************************************/
   FUNCTION f_obtdatecon(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL)   -- Bug 14598 - RSC - 28/06/2010 - CEM800 - Información adicional en pantallas y documentos
      RETURN ob_iax_datoseconomicos IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
              := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_ObtDatEcon';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
      datecon        ob_iax_datoseconomicos;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_md_datosctaseguro.f_obtdatecon(psseguro, pnriesgo, pfecha, datecon,
                                                   mensajes,
                                                   -- Bug 14598 - RSC - 28/06/2010 - CEM800 - Información adicional en pantallas y documentos
                                                   ptablas);

      -- Fin Bug 14598
      IF numerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN datecon;
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
   END f_obtdatecon;

   --JRH 03/2008

   --JRH 04/2008
   /*************************************************************************
       Obtiene los registros de movimientos en CTASEGURO
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_DATOSCTASEGURO : Collection con datos CTASEGURO
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_datosctaseguro IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfechaini= '
            || pfechaini || ' pfechaFin= ' || pfechafin;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_obtenerMovimientos';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg      t_iax_datosctaseguro;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_datosctaseguro.f_obtenermovimientos(psseguro, pnriesgo, pfechaini,
                                                           pfechafin, datctaseg, mensajes);

      IF numerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN datctaseg;
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
   END f_obtenermovimientos;

   /*************************************************************************
       Obtiene los registros de movimientos en CTASEGURO
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_DATOSCTASEGURO : Collection con datos CTASEGURO
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos_shw(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_datosctaseguro_shw IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfechaini= '
            || pfechaini || ' pfechaFin= ' || pfechafin;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_obtenerMovimientos';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg      t_iax_datosctaseguro_shw;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_datosctaseguro.f_obtenermovimientos_shw(psseguro, pnriesgo, pfechaini,
                                                               pfechafin, datctaseg, mensajes);

      IF numerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN datctaseg;
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
   END f_obtenermovimientos_shw;

--JRH 03/2008

   -- Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
   /*************************************************************************
       Funcion que anulará una linea en ctasseguro
       param in psseguro  : póliza
       param in pfcontab  : fecha contable
       param in pnnumlin  : Número de línea de ctaseguro
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1 si ha habido algún error
    *************************************************************************/
   FUNCTION f_anula_linea_ctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pfcontab= ' || pfcontab || ' pnnumlin= ' || pnnumlin;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_anula_linea_ctaseguro';
   BEGIN
      IF psseguro IS NULL
         OR pfcontab IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_datosctaseguro.f_anula_linea_ctaseguro(psseguro, pfcontab, pnnumlin,
                                                              mensajes);

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

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
   END f_anula_linea_ctaseguro;

-- fin Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
-- Bug 19303 - JMC - 16/11/2011 - se crea la funcion f_obtsaldoprorroga
   /*************************************************************************
       Funcion que obtiene los datos necesarios para saldar o prorrogar una
       póliza.
       param in psseguro  : póliza
       param in pnriesgo  : Número del riesgo.
       param in pfecha  : Fecha.
       param in ptablas  : Tablas sobre las que actua.
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1 si ha habido algún error
    *************************************************************************/
   FUNCTION f_obtsaldoprorroga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      ptablas IN VARCHAR2,
      pmode IN VARCHAR2,
      piprifinanpen IN NUMBER,   --  bug 26085 - ETM -0026085
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_saldoprorroga IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' piprifinanpen= ' || piprifinanpen || ' ptablas= ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_obtsaldoprorroga';
      vsalpro        ob_iax_saldoprorroga;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsalpro := ob_iax_saldoprorroga();
      numerr := pac_md_datosctaseguro.f_obtsaldoprorroga(psseguro, pnriesgo, pfecha, ptablas,
                                                         pmode, piprifinanpen, vsalpro,
                                                         mensajes);

      IF numerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN vsalpro;
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
   END f_obtsaldoprorroga;

-- fin Bug 19303 - JMC - 16/11/2011

   -- BUG 0022839 - FAL - 31/07/2012
   /*************************************************************************
      Obtiene una serie de campos informativos a nivel general del colectivo
      param in psseguro  : póliza
      param out          : El objeto del tipo OB_IAX_DATOSCOLECTIVO con la info de los colectivos
      param out mensajes : mensajes de error
      return             : 0 si todo va bien o 1.
   *************************************************************************/
   FUNCTION f_obtdatcolect(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL,
      pmaxrows NUMBER DEFAULT NULL)   --03/09/2013   MLR             7. 0028044
      RETURN ob_iax_datoscolectivo IS
      datecolect     ob_iax_datoscolectivo;
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_obtdatcolect';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_md_datosctaseguro.f_obtdatcolect(psseguro, datecolect, mensajes, ptablas,
                                                     pmaxrows);   --03/09/2013   MLR             7. 0028044

      -- Fin Bug 14598
      IF numerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN datecolect;
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
   END f_obtdatcolect;

   FUNCTION f_suplem_obert(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro= ' || psseguro || ' ptablas= ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_IAX_DATOSCTASEGURO.f_suplem_obert';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_datosctaseguro.f_suplem_obert(psseguro, ptablas, mensajes);

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_suplem_obert;
-- FI BUG 0022839
END pac_iax_datosctaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DATOSCTASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DATOSCTASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DATOSCTASEGURO" TO "PROGRAMADORESCSI";
