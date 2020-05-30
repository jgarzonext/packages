--------------------------------------------------------
--  DDL for Package PAC_FUN_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FUN_FORMATOS" AS
/******************************************************************************
   NOMBRE:      PAC_FUN_FORMATOS
   PROPÓSITO:   Funciones para obtener la data de cada formato

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/08/2013   JMG               1. Creación del package.
******************************************************************************/

   /*************************************************************************
     FUNCTION f_get_negocio
        Obtiene los registro de negocio para la generacion de formatos
        param in p_separador: separador de la tabla fic_gestores
        param in p_tgestor: codigo de gestor
        param in p_tformato: codigo de formato
        param in p_empres: empresa
        param in p_anio : objeto fichero
        param in p_mes: archivo de carga
        param in p_dia : objeto fichero
     *************************************************************************/
   FUNCTION f_get_negocio(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

    /*************************************************************************
   FUNCTION f_get_negocio483
      Obtiene los registro de negocio para la generacion de formatos
      param in p_separador: separador de la tabla fic_gestores
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_empres: empresa
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
   *************************************************************************/
   FUNCTION f_get_negocio483(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_nomina_reaseguradores
       Obtiene los registro de la nomina de reaseguradores - contratos de reaseguros
       proporcionales y no proporcionales para la generacion del formato 485.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_nomina_reaseguradores(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_contratos_noproporcional
       Obtiene los registro de los contratos de reaseguros de tipo no proporcionales
       para la generacion del formato 484.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_contratos_noproporcional(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_contratos_proporcionales
       Obtiene los registro de los contratos de reaseguros de tipo proporcionales
       para la generacion del formato 483.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_contratos_proporcionales(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;
END pac_fun_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "PROGRAMADORESCSI";
