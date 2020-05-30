--------------------------------------------------------
--  DDL for Package PAC_CFG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CFG_FILE" AS
/******************************************************************************
   NOMBRE:       PAC_CFG_FILE
   PROP¿SITO:    Control y gesti¿n de tratamiento de ficheros

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/02/2009   JTS                1. Creaci¿n del package.
   2.0        31/05/2010   PFA                2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        14/09/2010   PFA                3. 15730: CRT - Avisar que el fichero ya esta cargado
   4.0        04/11/2010   FAL                4. 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
******************************************************************************/

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Abre un cursor con los procesos definidos en CFG_FILES
      param out p_tprocesos : sys_refcursor
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_procesos(
      p_cempres IN NUMBER,
      p_cidioma IN NUMBER,
      p_tprocesos OUT sys_refcursor)
      RETURN NUMBER;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Retorna los par¿metros para la ejecuci¿n de un proceso
      param in  p_cproceso : Id. del proceso
      param out p_tdestino : Directorio de destino
      param out p_tproceso : Proceso de base de datos
      return               : 0.-    OK
                             otro.- error
   *************************************************************************/
   FUNCTION f_get_datos_proceso(
      p_cproceso IN NUMBER,
      p_cempres IN NUMBER,
      p_tdestino OUT VARCHAR2,
      p_tproceso OUT VARCHAR2,
      -- Bug 0016525. FAL. 04/11/2010. Se a¿ade parametro q indica si borrar fichero del servidor
      p_borrafich OUT NUMBER)
      -- Fi Bug 0016525
   RETURN NUMBER;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Realiza el tratamiento del fichero
      param in  p_cproceso : Id. del proceso
      param in  p_tfile    : Nombre del fichero
      param in out p_sproces : Num de proceso
      param out p_tpantalla: Pantalla de navegaci¿n siguiente
      return               : 0.-    OK
                             otro.- error
   *************************************************************************/
   FUNCTION f_ejecuta_proceso(
      p_cproceso IN NUMBER,
      p_tfile IN VARCHAR2,
      p_cempres IN NUMBER,
      p_sproces IN OUT NUMBER,   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      p_nnumcaso IN NUMBER,   -- Bug 28263/156016 - 15/10/2013 - AMC
      p_tpantalla OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      BUG15730 - 14/09/2010 - PFA
      Comprueba si el fichero ya est¿ cargado
      param in  pcproceso     : Id. del proceso
      param in  ptfichero     : Nombre del fichero
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_proceso_cargado(pcproceso IN NUMBER, ptfichero IN VARCHAR2)
      RETURN NUMBER;
END pac_cfg_file;

/

  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "PROGRAMADORESCSI";
