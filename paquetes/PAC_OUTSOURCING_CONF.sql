--------------------------------------------------------
--  DDL for Package PAC_OUTSOURCING_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_OUTSOURCING_CONF" IS
   /******************************************************************************
      NOMBRE:    pac_outsourcing_conf
      PROP¿SITO: Funciones para carga de facturas de outsourcing

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creaci¿n del objeto.

   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_ejecutar_carga

      param in p_nombre     : Nombre del archivo
      param in p_path       : Patch
      param in p_cproces    : C¿digo del proceso
      param in out psproces : Secuencia de proceso
      return                : NUMBER
   *************************************************************************/
   FUNCTION f_ejecutar_carga(p_nombre  IN VARCHAR2,
                             p_path    IN VARCHAR2,
                             p_cproces IN NUMBER,
                             psproces  IN OUT NUMBER) RETURN NUMBER;
   /*************************************************************************
      FUNCTION f_carga_gescar
      param in p_nombre     : Nombre del archivo
      param in p_path       : Patch
      param in p_cproces    : C¿digo del proceso
      param in out psproces : Secuencia de proceso
      return                : NUMBER
   *************************************************************************/
   FUNCTION f_carga_gescar(p_nombre  IN VARCHAR2,
                           p_path    IN VARCHAR2,
                           p_cproces IN NUMBER,
                           psproces  IN OUT NUMBER) RETURN NUMBER;

END pac_outsourcing_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "PROGRAMADORESCSI";
