--------------------------------------------------------
--  DDL for Package PAC_MD_DATOSCTASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DATOSCTASEGURO" AS
/******************************************************************************
   NOMBRE:       PAC_MD_DATOSCTASEGURO
   PROPÓSITO:  Funciones de obtención de datos de CTASEGURO e importes de las pólizas de productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/04/2008   JRH                1. Creación del package.
   2.0        21/12/2009   APD                2. Bug 12426 : se crea la funcion f_anula_linea_ctaseguro
   3.0        28/06/2010   RSC                3. 0014598: CEM800 - Información adicional en pantallas y documentos
   4.0        16/11/2011   JMC                4. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   5.0        31/07/2012   FAL                5. 0022839: LCOL - Funcionalidad Certificado 0
   6.0        28/03/2013   ETM                6. 0026085: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 178 - Creaci?n prod: Saldado, Prorrogado, Convertibilidad (Fase 2)
   7.0        03/09/2013   MLR                7. 0028044: RSA003-Limitar en consulta de poliza el numero de registros de resumen colectivo
******************************************************************************/

   --JRH 03/2008
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
      fecha IN DATE,
      datecon IN OUT ob_iax_datoseconomicos,
      mensajes IN OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL)   -- Bug 14598 - RSC - 28/06/2010 - CEM800 - Información adicional en pantallas y documentos
      RETURN NUMBER;

    --JRH 03/2008
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
      fechaini IN DATE,
      fechafin IN DATE,
      datctaseg IN OUT t_iax_datosctaseguro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Obtiene los registros de movimientos en CTASEGURO_shadow
       param in psseguro  : pÃ³liza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_DATOSCTASEGURO : Collection con datos CTASEGURO_shadow
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos_shw(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fechaini IN DATE,
      fechafin IN DATE,
      datctaseg IN OUT t_iax_datosctaseguro_shw,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      salpro IN OUT ob_iax_saldoprorroga,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      datecolect IN OUT ob_iax_datoscolectivo,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL,
      pmaxrows IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_suplem_obert(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
-- FI BUG 0022839
END pac_md_datosctaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "PROGRAMADORESCSI";
