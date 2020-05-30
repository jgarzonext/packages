--------------------------------------------------------
--  DDL for Package PAC_MIG_OLDAXIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MIG_OLDAXIS" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:    PAC_MIG_OLDAXIS
   PROPÓSITO: Funciones y procedimientos para migrar los datos proporcionados
              por OLDAXIS (cliente CRE) a las tablas de migración MIG_

   REVISIONES:
   Ver        Fecha       Autor          Descripción
   ---------  ----------  -------------  -------------------------------------
   1.0        01/09/2010  AFM            1.Creación del Package
******************************************************************************//***************************************************************************
      FUNCTION f_migra_siniestros
      Función que trata y traspasa la información de la tabla proporcionada por
      CEM CEM_SINIESTROS, a las tablas intermedias de migración:
         param in pproducte : Código producto CEM a migrar.
         param in pid       : Identificador migración
         return             : 0 si valido, sino codigo error
   ***************************************************************************/
   /***************************************************************************
       FUNCTION f_migra_sin_siniestros
          param in pproducte : producto CEM a migrar
          param in pid       : Identificador migración
          return             : 0 si valido, sino codigo error
    ***************************************************************************/
   FUNCTION f_migra_sin_siniestros(
      pid IN VARCHAR2 DEFAULT NULL,
      p_numrows IN NUMBER DEFAULT NULL,
      p_txt_error OUT VARCHAR2)
      RETURN NUMBER;

   /***************************************************************************
      PROCEDURE p_ejecutar_carga
      Traspasa los datos de las tablas de APRA a las intermedias MIG, segun el
      parametro pasado traspasa todas las tablas o solo las de un modulo
      determinado.
         param in ptipo     : modulo a migrar
         param in pproducte : Código producto CEM a migrar.
         param in pid       : Identificador migración
   ***************************************************************************/
   PROCEDURE p_ejecutar_carga(pid IN VARCHAR2, p_numrows IN NUMBER DEFAULT NULL);

   -- INI BUG:13370 - 11-05-2010 - JMC - Creación función f_crea_pk
   /***************************************************************************
      FUNCTION f_crea_pk
      Dados unos campos de entrada, concatena estos con un "|" entre ellos.
      Se utiliza para generar una pk ficticias que se graban en mig_pk_emp_axis.
      param in p_campo1 : primer valor a concatenar.
      param in p_campo2 : segundo valor a concatenar.
      param in p_campo3 : tercer valor a concatenar.
      param in p_campo4 : cuarto valor a concatenar.
      param in p_campo5 : quinto valor a concatenar.
      param in p_campo6 : sexto valor a concatenar.
      param in p_campo7 : séptimo valor a concatenar.
      return             : 0 si valido, sino codigo error
   ***************************************************************************/
   FUNCTION f_crea_pk(
      p_campo1 IN VARCHAR2,
      p_campo2 IN VARCHAR2 DEFAULT NULL,
      p_campo3 IN VARCHAR2 DEFAULT NULL,
      p_campo4 IN VARCHAR2 DEFAULT NULL,
      p_campo5 IN VARCHAR2 DEFAULT NULL,
      p_campo6 IN VARCHAR2 DEFAULT NULL,
      p_campo7 IN VARCHAR2 DEFAULT NULL)
      RETURN mig_pk_emp_mig.pkemp%TYPE DETERMINISTIC;

   PRAGMA RESTRICT_REFERENCES(f_crea_pk, WNDS, WNPS, RNPS, RNDS);
END pac_mig_oldaxis;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "PROGRAMADORESCSI";
