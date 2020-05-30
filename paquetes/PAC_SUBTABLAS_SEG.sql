--------------------------------------------------------
--  DDL for Package PAC_SUBTABLAS_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUBTABLAS_SEG" AS
    /******************************************************************************
    NOMBRE:     pac_subtablas_seg
    PROPÓSITO:

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1           25/10/2013  DCT              Creación funciones f_cero_seg y f_ftarifaseg BUG 27923/156553
   *************************************************************************/
   TYPE rec_cons_subt_det IS RECORD(
      sseguro        subtabs_seg_det.sseguro%TYPE,
      nriesgo        subtabs_seg_det.nriesgo%TYPE,
      cgarant        subtabs_seg_det.cgarant%TYPE,
      nmovimi        subtabs_seg_det.nmovimi%TYPE,
      cpregun        subtabs_seg_det.cpregun%TYPE,
      ccla1          subtabs_seg_det.ccla1%TYPE,
      ccla2          subtabs_seg_det.ccla2%TYPE,
      ccla3          subtabs_seg_det.ccla3%TYPE,
      ccla4          subtabs_seg_det.ccla4%TYPE,
      ccla5          subtabs_seg_det.ccla5%TYPE,
      ccla6          subtabs_seg_det.ccla6%TYPE,
      ccla7          subtabs_seg_det.ccla7%TYPE,
      ccla8          subtabs_seg_det.ccla8%TYPE,
      ccla9          subtabs_seg_det.ccla9%TYPE,
      ccla10         subtabs_seg_det.ccla10%TYPE
   );

   TYPE varray_cond_table IS VARRAY(5) OF VARCHAR2(2);

   v_conds        varray_cond_table := varray_cond_table('<', '<=', '=', '>=', '>');
   v_comodin      VARCHAR2(20) := '999999999';

   /*************************************************************************
      PROCEDURE f_montar_consulta
         Función que descodifica el string de entrada p_in_cquery y crea dinámicamente la consulta
         que se ejecuta sobre subtabs_seg_det
         param in p_in_cquery : string codificado
         return               : query generada dinámicamente
   *************************************************************************/
   FUNCTION f_montar_consulta(
      p_in_cquery IN VARCHAR2,
      psseguro IN subtabs_seg_det.sseguro%TYPE,
      pnriesgo IN subtabs_seg_det.nriesgo%TYPE,
      pcgarant IN subtabs_seg_det.cgarant%TYPE,
      pnmovimi IN subtabs_seg_det.nmovimi%TYPE,
      pcpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_ptablas IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      PROCEDURE f_rec_cons_seg
         Función que retorna un type con el primer registro de subtabs_seg_det que cumple con las condiciones de filtrado
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
   FUNCTION f_rec_cons_seg(
      psseguro IN subtabs_seg_det.sseguro%TYPE,
      pnriesgo IN subtabs_seg_det.nriesgo%TYPE,
      pcgarant IN subtabs_seg_det.cgarant%TYPE,
      pnmovimi IN subtabs_seg_det.nmovimi%TYPE,
      pcpregun IN subtabs_seg_det.cpregun%TYPE,
      pccla1 IN subtabs_seg_det.ccla1%TYPE,
      pccla2 IN subtabs_seg_det.ccla2%TYPE,
      pccla3 IN subtabs_seg_det.ccla3%TYPE,
      pccla4 IN subtabs_seg_det.ccla4%TYPE,
      pccla5 IN subtabs_seg_det.ccla5%TYPE,
      pccla6 IN subtabs_seg_det.ccla6%TYPE,
      pccla7 IN subtabs_seg_det.ccla7%TYPE,
      pccla8 IN subtabs_seg_det.ccla8%TYPE,
      pccla9 IN subtabs_seg_det.ccla9%TYPE,
      pccla10 IN subtabs_seg_det.ccla10%TYPE)
      RETURN rec_cons_subt_det;

   /*************************************************************************
      PROCEDURE p_detalle_fila_din_seg
         Procedimiento que llama a f_rec_cons_seg y retorna un rowtype con el registro de subtabs_seg_det
         param in p_in_claves   : rowtype con las claves de filtrado
         param in p_in_cquery   : string con la codificación numérica de la query que se ha de ejecutar
         param in p_out_detalle : rowtype de subtabs_seg_det con el registro seleccionado
         param in p_out_error   : parámetro de control de errores
   *************************************************************************/
   PROCEDURE p_detalle_fila_din_seg(
      p_in_claves IN rec_cons_subt_det,
      p_in_cquery IN VARCHAR2,
      p_in_ptablas IN VARCHAR2,
      p_out_detalle OUT subtabs_seg_det%ROWTYPE,
      p_out_error OUT NUMBER);

   /*************************************************************************
      PROCEDURE p_detalle_valor_din_seg
         Procedimiento que llama a f_rec_cons_seg y retorna un rowtype con el registro de subtabs_seg_det
         param in p_in_claves   : rowtype con las claves de filtrado
         param in p_in_cquery   : string con la codificación numérica de la query que se ha de ejecutar
         param in p_out_detalle : rowtype de subtabs_seg_det con el registro seleccionado
         param in p_out_error   : parámetro de control de errores
   *************************************************************************/
   PROCEDURE p_detalle_valor_din_seg(
      p_in_claves IN rec_cons_subt_det,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
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
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL
                                                             -- Fi BUG 16217 - 11/2011 - JRH                                                            --
   )
      RETURN NUMBER;

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
   FUNCTION f_vsubtabla_seg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cero_seg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ftarifaseg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER;
END pac_subtablas_seg;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "PROGRAMADORESCSI";
