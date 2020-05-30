--------------------------------------------------------
--  DDL for Package PAC_FICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FICO" AS
   /******************************************************************************
      NOMBRE:      PAC_FICO
      PROPÓSITO:   Package propio para carga y generación de ficheros FICO de ICEA

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/10/2012   XVM              1. 0023945: MDP002-MDP- Implementación de Interfaces
   ******************************************************************************/

   /*************************************************************************
       PROCEDURE p_genera_logs: Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve número o null si existe error.
   *************************************************************************/
   PROCEDURE p_genera_logs(
      p_tabobj IN VARCHAR2,
      p_tabtra IN NUMBER,
      p_tabdes IN VARCHAR2,
      p_taberr IN VARCHAR2,
      p_propro IN NUMBER,
      p_protxt IN VARCHAR2);

   /*************************************************************************
          FUNCTION f_marcalinea: Función que marca linea que tratamos con un estado.
          param pnsproces   in : proceso
          param pnlinea     in : linea
          param pctipo      in : tipo
          param pnestado    in : estado
          param pnvalidado  in : validado
          param pid_ext     in : Id. interno
          RETURN               : 0.-    OK
                                 otro.- error
      *************************************************************************/
   FUNCTION f_marcalinea(
      pnsproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pnestado IN NUMBER,
      pnvalidado IN NUMBER,
      pid_ext IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
          FUNCTION f_marcalineaerror: Función que marca el error de la linea que tratamos.
          param pssproces in : proceso
          param pnlinea   in : linea
          param pnnumerr  in : numero error
          param pctipo    in : tipo
          param pncodigo  in : codigo
          param ptmensaje in : mensaje
          RETURN             : 0.-    OK
                               otro.- error
      *************************************************************************/
   FUNCTION f_marcalineaerror(
      pssproces IN NUMBER,
      pnlinea IN NUMBER,
      pnnumerr IN NUMBER,
      pctipo IN NUMBER,
      pncodigo IN NUMBER,
      ptmensaje IN VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_cargar_fico: Función de carga de ficheros FICO de ICEA
      param in  pnombre        : nombre del fichero a leer
      param in  ppath          : path del fichero a leer
      param in  pcproceso      : código del proceso FICO
      param in out psproces    : Id. del proceso
      return                   : 0.-    OK
                                 otro.- error
   ***********************************************************************/
   FUNCTION f_cargar_fico(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproceso IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     F_DET_FICO1: Función que genera el texto detalle para el listado de FICO
     Paràmetres entrada: - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
     return:             texto detalle
   ******************************************************************************************/
   FUNCTION f_det_fico1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
END pac_fico;

/

  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "PROGRAMADORESCSI";
