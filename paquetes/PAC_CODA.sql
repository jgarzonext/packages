--------------------------------------------------------
--  DDL for Package PAC_CODA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE PAC_CODA AS
/******************************************************************************
   NOMBRE:       PAC_CODA
   PROPÓSITO:    Tratamiento de los ficheros CODA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/02/2009   JTS                1. Creación del package.
   4.0        16/09/2009   JTS                4. 11166: APR - Tratamiento de fichero CODA
   5.0        31/05/2010   PFA                5. 14750: ENSA101 - Reproceso de procesos ya existentes
   6.0        15/10/2010   DRA                6. 0016130: CRT - Error informando el codigo de proceso en carga
   7.0        24/05/2019   ECP                7. IAXIS-3592. Proceso de terminación por no pago
******************************************************************************/

   /*************************************************************************
      Extrae los datos del fichero CODA y los inserta en DEVBANREC_CODA
      param in  p_nombre    : nombre del fichero a leer
      param in  p_path      : path del fichero a leer
      param in out p_sproces   : Id. del proceso
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_lee_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      p_sproces IN OUT NUMBER)   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      RETURN NUMBER;

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
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_datos_proceso(
      p_sproces IN NUMBER,
      p_tnomfile OUT VARCHAR2,
      p_fproces OUT DATE,
      p_icobrado OUT NUMBER,
      p_iimpago OUT NUMBER,
      p_ipendcob OUT NUMBER,
      p_ipenimp OUT NUMBER,
      p_tbanco OUT VARCHAR2)
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
      return                : 0.-    OK
                              otro.- error
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
      p_refcursor OUT sys_refcursor)
      RETURN NUMBER;

   FUNCTION f_get_coda_detalle(
      p_sproces IN NUMBER,
      p_cbancar IN VARCHAR2,
      pnnumord IN NUMBER,
      pfultsald IN DATE,
      pnnumlin IN NUMBER,
      p_refcursor OUT sys_refcursor)
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
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_busca_tomadores(
      p_tnombre IN VARCHAR2,
      p_tdescrip IN VARCHAR2,
      p_numvia IN NUMBER,
      p_cpostal IN VARCHAR2,
      p_npoliza IN NUMBER,
      p_nrecibo IN NUMBER,
      p_refcursor OUT sys_refcursor)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los recibos en situación pendiente de un tomador
      recibido por parámetro
      param in  p_sperson   : Id de persona
      param out p_refcursor : Cursor resultante de la consulta
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_busca_recibos(
      p_sperson IN NUMBER,
      p_csigno IN NUMBER,
      pidioma IN NUMBER,
      p_refcursor OUT sys_refcursor)
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
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_gestion_recibos(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER,
      p_nrecibo IN VARCHAR2,
      p_ok IN NUMBER DEFAULT NULL,
      p_redo OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene los registros de un proceso de extraccion de fichero CODA según
      los parámetros de entrada y genera un fichero en excel
      param in  p_sproces   : Id. del proceso
      param in  p_fechaini  : Fecha inicio
      param in  p_fechafin  : Fecha fin
      param in  p_ctipreg   : Tipo registro
      param in  p_nrecibo   : Numero de recibo
      param in  p_tnombre   : Nombre tomador
      param in  p_tdescrip  : Descripcion
      param in  p_cbanco    : Descripción del banco
      param out p_ruta      : Ruta donde se ha guardado el excel
      return                : 0.-    OK
                              otro.- error
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
      p_ruta OUT VARCHAR2)
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
      return                : 0.-    OK
                              otro.- error
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
      p_reference OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Descarta un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      return                : 0.-    OK
                              otro.- error
      --BUG 11166 - JTS - 16/09/2009
   *************************************************************************/
   FUNCTION f_cancela_registro(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Obtiene el importe pendiente a pagar de un recibo
       param in  pnrecibo   : NUm recibo
       param in  psmovrec   : seq. mov. recibo
       param out p_importe   : Importe Pendiente
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION ff_importe_pendiente(pnrecibo IN NUMBER, psmovrec IN NUMBER, p_importe OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_dano
         Inserta a la taula SIN_TRAMITA_DANO dels paràmetres informats.
         param in pnsinies  : número sinistre
         param in pntramit  : número tramitació sinistre
         param in pndano    : número dany sinistre
         param in pctipdano : codi tipus dany
         param in ptdano    : descripció dany
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_detmovrecibo(
      psmovrec IN NUMBER,
      pnorden IN NUMBER,
      pnrecibo IN NUMBER,
      piimporte IN NUMBER,
      pfmovimi IN DATE,
      pfefeadm IN DATE,
      pcusuari IN VARCHAR2,
      psdevolu IN NUMBER,
      pnnumnlin IN NUMBER,
      pcbancar1 IN VARCHAR2,
      pnnumord IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_detmovrecibos(pnrecibo IN NUMBER, psmovrec IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;
	  
	  
	   -- INi IAXIS-5149 -- ECP -- 13/01/2020
   FUNCTION f_get_detmovrecibosc (
      pnrecibo   IN       NUMBER,
      psmovrec   IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER;  

   /*************************************************************************
      reactivar un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      return                : 0.-    OK
                              otro.- error
     --BUG 15816: CODA : doesn't allow undo a cancellation - XPL - 09/09/2010
   *************************************************************************/
   FUNCTION f_reactivar_registro(
      p_sproces IN NUMBER,
      p_nnumlin IN NUMBER,
      p_cbancar1 IN VARCHAR2,
      p_nnumord IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene el importe pendiente a pagar de un recibo
      param in  pnrecibo   : Num recibo
      param in  psmovrec   : seq. mov. recibo
      return               : importe pendiente
     --BUG 40771 227859: reporte balance de polizas positivas
   *************************************************************************/
   FUNCTION ff_get_imppend_rec(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER)
      RETURN NUMBER;
END pac_coda;

/
