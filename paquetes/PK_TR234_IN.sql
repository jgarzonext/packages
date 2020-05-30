--------------------------------------------------------
--  DDL for Package PK_TR234_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_TR234_IN" AS
   /*****************************************************************************
      NOMBRE:     PK_TR234_IN
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha        Autor            Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        dd/mm/yyyy   XXX                1. Creación del package
      2.0        28/05/2010   PFA                2. 14750: ENSA101 - Reproceso de procesos ya existentes
      3.0        15/10/2010   DRA                3. 0016130: CRT - Error informando el codigo de proceso en carga
   ******************************************************************************/
   FUNCTION insertar_registro(pregistro IN tdc234_in_det%ROWTYPE, psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_carga_fichero(pfichero IN VARCHAR2, ppath IN VARCHAR2, psproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_recuperar_reg(
      psproces IN NUMBER,
      psref234 IN VARCHAR2,
      preg IN VARCHAR2,
      pnlinea IN NUMBER,
      preg234 OUT tdc234_in_det%ROWTYPE)
      RETURN NUMBER;

   --
   FUNCTION f_ejecutar_acciones(psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ejecutar_fichero(
      pfichero IN VARCHAR2,
      ppath IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      RETURN NUMBER;
--
--FUNCTION f_recuperar_plan () RETURN NUMBER;
--
--FUNCTION f_recuperar_poliza () RETURN NUMBER;
--
END pk_tr234_in;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "PROGRAMADORESCSI";
