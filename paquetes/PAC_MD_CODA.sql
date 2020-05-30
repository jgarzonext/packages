--------------------------------------------------------
--  DDL for Package PAC_MD_CODA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CODA" AS
/******************************************************************************
   NOMBRE:       PAC_MD_CODA
   PROPÓSITO:    Tratamiento de los ficheros CODA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/02/2009   JTS                1. Creación del package.
   2.0        16/09/2009   JTS                2. 11166: APR - Tratamiento de fichero CODA
******************************************************************************/

   /*************************************************************************
      Obtiene la información de un proceso de extraccion de fichero CODA
      param in  p_sproces   : Id. del proceso
      param out p_tnomfile  : Nombre del fichero
      param out p_fproces   : Fecha del proceso
      param out p_icobrado  : Importe total de los recibos cobrados
      param out p_iimpago   : Importe total de los recibos impagados
      param out p_ipendcob  : Importe total de los recibos pendientes de pago
      param out p_ipenimp   : Importe total de los recibos pendientes de impagar
      param out p_tbanco    : Descripción del banco
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_get_datos_proceso(
      p_sproces IN NUMBER,
      p_tnomfile OUT VARCHAR2,
      p_fproces OUT DATE,
      p_icobrado OUT NUMBER,
      p_iimpago OUT NUMBER,
      p_ipendcob OUT NUMBER,
      p_ipenimp OUT NUMBER,
      p_tbanco OUT VARCHAR2,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los registros de un proceso de extraccion de fichero CODA según
      los parámetros de entrada
      param in  p_sproces   : Id. del proceso
      param in  p_fechaini  : Fecha inicio
      param in  p_fechafin  : Fecha fin
      param in  p_ctipreg   : Tipo registro
      param in  p_nrecibo   : Numero de recibo
      param in  p_tnombre   : Nombre pagador
      param in  p_tdescrip  : Descripcion
      param in  p_cbanco    : Codigo del banco
      param out p_refcursor : Cursor resultante de la consulta
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_get_coda(
      p_sproces IN NUMBER,
      p_fechaini IN DATE,
      p_fechafin IN DATE,
      p_ctipreg IN NUMBER,
      p_nrecibo IN NUMBER,
      p_tnombre IN VARCHAR2,
      p_tdescrip IN VARCHAR2,
      p_cbanco IN NUMBER,
      p_refcursor OUT sys_refcursor,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene todos los tomadores segun los parametros introducidos
      param in  p_tnombre   : Nombre del tomador
      param in  p_tdescrip  : Descripcion
      param in  p_numvia    : Numero de la via
      param in  p_cpostal   : Codigo postal
      param in  p_npoliza   : N poliza
      param in  p_nrecibo   : N recibo
      param out p_refcursor : Cursor resultante de la consulta
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_busca_tomadores(
      p_tnombre IN VARCHAR2,
      p_tdescrip IN VARCHAR2,
      p_numvia IN NUMBER,
      p_cpostal IN VARCHAR2,
      p_npoliza IN NUMBER,
      p_nrecibo IN NUMBER,
      p_refcursor OUT sys_refcursor,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los recibos en situación pendiente de un tomador
      recibido por parámetro
      param in  p_sperson   : Id de persona
      param out p_refcursor : Cursor resultante de la consulta
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_busca_recibos(
      p_sperson IN NUMBER,
      p_csigno IN NUMBER,
      p_refcursor OUT sys_refcursor,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Cobra/impaga un recibo y lo asocia a la tabla de devoluciones,
      actualizando la tabla del CODA,
      con el número de recibo y su estado del registro.
      param in  p_sproces   : Id del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param in  p_nrecibo   : Numeros de recibos
      param in  p_ok        : Confirmación de acción
      param out p_redo      : Indica si se puede relanzar o no 0 ok 1 ko
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_gestion_recibos(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER,
      p_nrecibo IN VARCHAR2,
      p_ok IN NUMBER DEFAULT NULL,
      p_redo OUT NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los registros de un proceso de extraccion de fichero CODA según
      los parámetros de entrada y genera un fichero en excel
      param in  p_sproces   : Id. del proceso
      param in  p_fechaini  : Fecha inicio
      param in  p_fechafin  : Fecha fin
      param in  p_ctipreg   : Tipo registro
      param in  p_nrecibo   : Numeros de recibos
      param in  p_tnombre   : Nombre tomador
      param in  p_tdescrip  : Descripcion
      param in  p_cbanco    : Descripción del banco
      param out p_ruta      : Ruta donde se ha guardado el excel
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_excel_coda(
      p_sproces IN NUMBER,
      p_fechaini IN DATE,
      p_fechafin IN DATE,
      p_ctipreg IN NUMBER,
      p_nrecibo IN NUMBER,
      p_tnombre IN VARCHAR2,
      p_tdescrip IN VARCHAR2,
      p_cbanco IN NUMBER,
      p_ruta OUT VARCHAR2,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene la información de una línea de la tabla de CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nombre    : Nombre del pagador
      param out p_descrip   : Descripción
      param out p_fecha     : Fecha de proceso
      param out p_importe   : Importe
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_get_line_coda(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER,
      p_nombre OUT VARCHAR2,
      p_descrip OUT VARCHAR2,
      p_fecha OUT DATE,
      p_importe OUT NUMBER,
      p_reference OUT VARCHAR2,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Descarta un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
      --BUG 11166 - JTS - 16/09/2009
   *************************************************************************/
   FUNCTION f_cancela_registro(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      reactivar un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      param out p_mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
      --BUG 15816: CODA : doesn't allow undo a cancellation - XPL - 09/09/2010
   *************************************************************************/
   FUNCTION f_reactivar_registro(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Obtiene el importe pendiente a pagar de un recibo
       param in  pnrecibo   : NUm recibo
       param in  psmovrec   : seq. mov. recibo
       param out p_importe   : Importe Pendiente
       param out mensajes  : Mensajes de error
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION ff_importe_pendiente(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      p_importe OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detmovrecibos(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pcurdetmovrecibo OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
	  
	-- INi IAXIS-5149 -- ECP -- 14/01/2020
    FUNCTION f_get_detmovrecibosc(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pcurdetmovrecibo OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
-- Fin IAXIS-5149 -- ECP -- 14/01/2020      
	  

   FUNCTION f_get_coda_detalle(
      p_sproces IN NUMBER,
      p_cbancar IN VARCHAR2,
      pnnumord IN NUMBER,
      pfultsald IN DATE,
      pnnumlin IN NUMBER,
      p_refcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_coda;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CODA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CODA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CODA" TO "PROGRAMADORESCSI";
