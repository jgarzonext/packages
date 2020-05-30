--------------------------------------------------------
--  DDL for Package PAC_SUBTABLAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUBTABLAS" AS
    /******************************************************************************
    NOMBRE:     PAC_SINIESTROS
    PROPÓSITO:  Cuerpo del paquete de las funciones para los módulos de las subtablas SGT

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        07/07/2011   FPG / SRA         1. Creación del package.
    2.0        05/11/2011   JRH               2. 0018966: LCOL_T002 - Tramos con más de 2 dimensiones
   *************************************************************************/
   TYPE rec_cons_subt IS RECORD(
      cempres        sgt_subtabs_det.cempres%TYPE,
      csubtabla      sgt_subtabs_det.csubtabla%TYPE,
      fefecto        sgt_subtabs_ver.fefecto%TYPE,
      ccla1          sgt_subtabs_det.ccla1%TYPE,
      ccla2          sgt_subtabs_det.ccla2%TYPE,
      ccla3          sgt_subtabs_det.ccla3%TYPE,
      ccla4          sgt_subtabs_det.ccla4%TYPE,
      ccla5          sgt_subtabs_det.ccla5%TYPE,
      ccla6          sgt_subtabs_det.ccla6%TYPE,
      ccla7          sgt_subtabs_det.ccla7%TYPE,
      ccla8          sgt_subtabs_det.ccla8%TYPE,
      --18966 JRH
      ccla9          sgt_subtabs_det.ccla9%TYPE,
      ccla10         sgt_subtabs_det.ccla10%TYPE
   --Fi 18966 JRH
   );

   TYPE varray_cond_table IS VARRAY(5) OF VARCHAR2(2);

   v_conds        varray_cond_table := varray_cond_table('<', '<=', '=', '>=', '>');

   /*************************************************************************
      PROCEDURE f_montar_consulta
         Función que descodifica el string de entrada p_in_cquery y crea dinámicamente la consulta
         que se ejecuta sobre SGT_SUBTABS_DET
         param in p_in_cquery : string codificado
         return               : query generada dinámicamente
   *************************************************************************/
   FUNCTION f_montar_consulta(p_in_cquery IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      PROCEDURE f_rec_cons
         Función que retorna un type con el primer registro de SGT_SUBTABS_DET que cumple con las condiciones de filtrado
         param in pcempres    : código de empresa
         param in pcsubtabla  : código de subtabla
         param in pfefecto    : fecha de efecto
         param in pccla1      : valor para el filtrado del campo clave 1
         param in pccla2      : valor para el filtrado del campo clave 2
         param in pccla3      : valor para el filtrado del campo clave 3
         param in pccla4      : valor para el filtrado del campo clave 4
         param in pccla5      : valor para el filtrado del campo clave 5
         param in pccla6      : valor para el filtrado del campo clave 6
         param in pccla7      : valor para el filtrado del campo clave 7
         param in pccla8      : valor para el filtrado del campo clave 8
         return               : query generada dinámicamente
   *************************************************************************/
   FUNCTION f_rec_cons(
      pcempres IN sgt_subtabs_det.cempres%TYPE,
      pcsubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      pfefecto IN sgt_subtabs_ver.fefecto%TYPE,
      pccla1 IN sgt_subtabs_det.ccla1%TYPE,
      pccla2 IN sgt_subtabs_det.ccla2%TYPE,
      pccla3 IN sgt_subtabs_det.ccla3%TYPE,
      pccla4 IN sgt_subtabs_det.ccla4%TYPE,
      pccla5 IN sgt_subtabs_det.ccla5%TYPE,
      pccla6 IN sgt_subtabs_det.ccla6%TYPE,
      pccla7 IN sgt_subtabs_det.ccla7%TYPE,
      pccla8 IN sgt_subtabs_det.ccla8%TYPE,
      --JRH
      pccla9 IN sgt_subtabs_det.ccla9%TYPE,
      pccla10 IN sgt_subtabs_det.ccla10%TYPE
                                            --JRH
   )
      RETURN rec_cons_subt;

   /*************************************************************************
      PROCEDURE p_detalle_fila_din
         Procedimiento que llama a f_rec_cons y retorna un rowtype con el registro de SGT_SUBTABS_DET
         param in p_in_claves   : rowtype con las claves de filtrado
         param in p_in_cquery   : string con la codificación numérica de la query que se ha de ejecutar
         param in p_out_detalle : rowtype de SGT_SUBTABS_DET con el registro seleccionado
         param in p_out_error   : parámetro de control de errores
   *************************************************************************/
   PROCEDURE p_detalle_fila_din(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_out_detalle OUT sgt_subtabs_det%ROWTYPE,
      p_out_error OUT NUMBER);

   /*************************************************************************
      PROCEDURE p_detalle_valor_din
         Procedimiento que llama a f_rec_cons y retorna un rowtype con el registro de SGT_SUBTABS_DET
         param in p_in_claves   : rowtype con las claves de filtrado
         param in p_in_cquery   : string con la codificación numérica de la query que se ha de ejecutar
         param in p_out_detalle : rowtype de SGT_SUBTABS_DET con el registro seleccionado
         param in p_out_error   : parámetro de control de errores
   *************************************************************************/
   PROCEDURE p_detalle_valor_din(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_out_nval OUT NUMBER,
      p_out_error OUT NUMBER);

   /*************************************************************************
      FUNCTION f_detalle_valor_din
         Función que dado un código de empresa, un código de subtabla, una fecha de efecto y un filtrado por
         claves, retorna el valor de la campo n-ésimo apuntado por p_in_cval
         param in p_in_cempres   : código de empresa
         param in p_in_csubtabla : código de subtabla
         param in p_in_fefecto   : fecha de efecto
         param in p_in_cquery    : string codificado
         param in p_in_cval      : valor de la clave de la que queremos recuperar el valor
         param in p_in_ccla1     : valor para el filtrado del campo clave 1
         param in p_in_ccla2     : valor para el filtrado del campo clave 2
         param in p_in_ccla3     : valor para el filtrado del campo clave 3
         param in p_in_ccla4     : valor para el filtrado del campo clave 4
         param in p_in_ccla5     : valor para el filtrado del campo clave 5
         param in p_in_ccla6     : valor para el filtrado del campo clave 6
         param in p_in_ccla7     : valor para el filtrado del campo clave 7
         param in p_in_ccla8     : valor para el filtrado del campo clave 8
         return                  : contenido de la clave
   *************************************************************************/
   FUNCTION f_detalle_valor_din(
      p_in_cempres IN sgt_subtabs_det.cempres%TYPE,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_fefecto IN sgt_subtabs_ver.fefecto%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      -- BUG 16217 - 11/2011 - JRH  -  0018966: LCOL_T002 - Tramos con más de 2 dimensiones . Añadimos 2 claves
      -- JRH
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL
                                                             -- Fi BUG 16217 - 11/2011 - JRH                                                            --
   )
      RETURN NUMBER;

/*
-- USA DBMS_SQL
   PROCEDURE p_detalle_fila_sql(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_out_detalle OUT sgt_subtabs_det%ROWTYPE,
      p_out_error OUT NUMBER);
/*
   PROCEDURE p_detalle_valor_sql(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_out_nval OUT NUMBER,
      p_out_error OUT NUMBER);

   FUNCTION f_detalle_valor_sql(
      p_in_cempres IN sgt_subtabs_det.cempres%TYPE,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_fefecto IN sgt_subtabs_ver.fefecto%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL)
      RETURN NUMBER;
*/

   /*************************************************************************
      FUNCTION f_detalle_valor_din
         Función que dado un código de empresa, un código de subtabla, una fecha de efecto y un filtrado por
         claves, retorna el valor de la campo n-ésimo apuntado por p_in_cval
         param in p_in_nsesion  : código de sesión
         param in p_in_csubtabla : código de subtabla
         param in p_in_cquery    : string codificado
         param in p_in_cval      : valor de la clave de la que queremos recuperar el valor
         param in p_in_ccla1     : valor para el filtrado del campo clave 1
         param in p_in_ccla2     : valor para el filtrado del campo clave 2
         param in p_in_ccla3     : valor para el filtrado del campo clave 3
         param in p_in_ccla4     : valor para el filtrado del campo clave 4
         param in p_in_ccla5     : valor para el filtrado del campo clave 5
         param in p_in_ccla6     : valor para el filtrado del campo clave 6
         param in p_in_ccla7     : valor para el filtrado del campo clave 7
         param in p_in_ccla8     : valor para el filtrado del campo clave 8
         return                  : contenido de la clave
   *************************************************************************/
   FUNCTION f_vsubtabla(
      p_in_nsesion IN NUMBER,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      --JRH
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      --JRH)
      p_in_v_fecha IN DATE DEFAULT NULL   -- Bug 26638/161275 - 15/04/2014 - AMC
                                       )
      RETURN NUMBER;
END pac_subtablas;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "PROGRAMADORESCSI";
