--------------------------------------------------------
--  DDL for Package PAC_FISCIERRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FISCIERRE" AS
/******************************************************************************
   NOMBRE:    PAC_FISCIERRE

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        08/10/2008  SBG              1. Creación F_GENERAR
                                           2. Creación F_GET_MODELOS
                                           3. Creación F_GETDETVALORES
                                           4. Creación F_GET_MODELOCFG
                                           5. Creación F_GETLINEAPARAM
   3.0        17/02/2010  FAL              6. Creación FF_PENALIZACION
   4.0        20/10/2012  DCG              7. 0023887: AGM800-Modelo 347. Contemplar (operaciones con terceros)
******************************************************************************/

   /*************************************************************************
      28/01/2005 CPM
      Package que contiene la función para realizar el cierre fiscal
   *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   /*************************************************************************
      Genera el fichero
      param in  P_EMPRESA : código empresa
      param in  P_CMODELO : modelo fiscal
      param in  P_LINEA   : línea de parámetros
      param in  P_FICH_IN : nombre fichero deseado (opcional)
      param in  P_FICH_OUT: path + nombre fichero salida
   *************************************************************************/
   FUNCTION f_generar(
      p_empresa IN NUMBER,
      p_cmodelo IN VARCHAR2,
      p_linea IN VARCHAR2,
      p_fich_in IN VARCHAR2 DEFAULT NULL,
      p_fich_out OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Retorna un cursor a los modelos fiscales ACTIVOS para la empresa
      param in  P_EMPRESA : código empresa
      param in  P_IDIOMA  : idioma
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_get_modelos(p_empresa IN NUMBER, p_idioma IN NUMBER, p_error OUT NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
      Retorna un cursor con los diferentes valores y descripciones
      param in  P_EMPRESA : código empresa
      param in  P_CVALOR  : valor
      parma in  P_IDIOMA  : idioma
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_getdetvalores(
      p_empresa IN NUMBER,
      p_cvalor IN VARCHAR2,
      p_idioma IN NUMBER,
      p_error OUT NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
      Retorna el LPARAME de la tabla FIS_MODELOSDET
      param in  P_EMPRESA : código empresa
      param in  P_CMODELO : modelo fiscal
      param out P_ERROR   : código de error
   *************************************************************************/
   FUNCTION f_getlineaparam(p_empresa IN NUMBER, p_cmodelo IN VARCHAR2, p_error OUT NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Retorna la penalizacion de la poliza/producto. Tipo mov. penal: rescate total. Se usa en el map 310. Modelo fiscal 189
      param in  P_SPRODUC : código producto
      param in  P_SSEGURO : código del seguro
      param out P_FECHA   : fecha del rescate
   *************************************************************************/
   FUNCTION ff_penalizacion(
      psproduc IN parproductos.sproduc%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pfecha IN DATE,
      picaprisc IN NUMBER)
      RETURN NUMBER;

-- Bug 0023887 - DCG - 20/10/2012 -  AGM800-Modelo 347. Contemplar (operaciones con terceros)
   /*************************************************************************
      Obtiene los datos del modelo fiscal 347 para comisiones.
      param in  pany : año fiscal
      param in  pempres: empresa
      param in  psfiscab: secuencia fiscal
      param in  psproces: proceso
      param in  pfperfin: fecha del cierre
   *************************************************************************/
   FUNCTION cierre_fis_pag_com(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los datos del modelo fiscal 347 para reaseguro.
      param in  pany : año fiscal
      param in  pempres: empresa
      param in  psfiscab: secuencia fiscal
      param in  psproces: proceso
      param in  pfperfin: fecha del cierre
   *************************************************************************/
   FUNCTION cierre_fis_reaseg(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los datos del modelo fiscal 347 para coaseguro.
      param in  pany : año fiscal
      param in  pempres: empresa
      param in  psfiscab: secuencia fiscal
      param in  psproces: proceso
      param in  pfperfin: fecha del cierre
   *************************************************************************/
   FUNCTION cierre_fis_coaseg(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;
-- Fin Bug 0023887
END pac_fiscierre;

/

  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FISCIERRE" TO "PROGRAMADORESCSI";
