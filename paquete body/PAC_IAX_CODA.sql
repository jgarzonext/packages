--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CODA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CODA" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_CODA
   PROPÓSITO:    Tratamiento de los ficheros CODA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/02/2009   JTS                1. Creación del package.
   2.0        16/09/2009   JTS                2. 11166: APR - Tratamiento de fichero CODA
   3.0        09/09/2010   XPL                3. 15816: CODA : doesn't allow undo a cancellation
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      param out mensajes  : Mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_sproces = ' || p_sproces;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_get_datos_proceso';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_datos_proceso(p_sproces, p_tnomfile, p_fproces, p_icobrado,
                                                 p_iimpago, p_ipendcob, p_ipenimp, p_tbanco,
                                                 mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_datos_proceso;

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
      param out mensajes  : Mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_fechaini = ' || p_fechaini || ' p_fechafin = '
            || p_fechafin || ' p_ctipreg = ' || p_ctipreg || ' p_nrecibo = ' || p_nrecibo
            || ' p_tnombre = ' || p_tnombre || ' p_tdescrip = ' || p_tdescrip
            || ' p_cbanco = ' || p_cbanco;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_get_coda';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_coda(p_sproces, p_fechaini, p_fechafin, p_ctipreg,
                                        p_nrecibo, p_tnombre, p_tdescrip, p_cbanco,
                                        p_refcursor, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_coda;

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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_tnombre = ' || p_tnombre || ' p_tdescrip = ' || p_tdescrip || ' p_numvia = '
            || p_numvia || ' p_cpostal = ' || p_cpostal || ' p_npoliza = ' || p_npoliza
            || ' p_nrecibo = ' || p_nrecibo;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_busca_tomadores';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_busca_tomadores(p_tnombre, p_tdescrip, p_numvia, p_cpostal,
                                               p_npoliza, p_nrecibo, p_refcursor, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_busca_tomadores;

   /*************************************************************************
      Obtiene los recibos en situación pendiente de un tomador
      recibido por parámetro
      param in  p_sperson   : Id de persona
      param out p_refcursor : Cursor resultante de la consulta
      param out mensajes  : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_busca_recibos(
      p_sperson IN NUMBER,
      p_csigno IN NUMBER,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_sperson = ' || p_sperson;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_busca_recibos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_busca_recibos(p_sperson, p_csigno, p_refcursor, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_busca_recibos;

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
      param out mensajes  : Mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_nnumlin = ' || p_nnumlin || ' p_cbancar1 = '
            || p_cbancar1 || ' p_nrecibo = ' || p_nrecibo || ' p_ok = ' || p_ok;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_gestion_recibos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_gestion_recibos(p_sproces, p_nnumlin, p_cbancar1, p_nnumord,
                                               p_nrecibo, p_ok, p_redo, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_error;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_gestion_recibos;

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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_fechaini = ' || p_fechaini || ' p_fechafin = '
            || p_fechafin || ' p_ctipreg = ' || p_ctipreg || ' p_nrecibo = ' || p_nrecibo
            || ' p_tnombre = ' || p_tnombre || ' p_tdescrip = ' || p_tdescrip
            || ' p_cbanco = ' || p_cbanco;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_excel_coda';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_excel_coda(p_sproces, p_fechaini, p_fechafin, p_ctipreg,
                                          p_nrecibo, p_tnombre, p_tdescrip, p_cbanco, p_ruta,
                                          mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_excel_coda;

   /*************************************************************************
      Obtiene la información de una línea de la tabla de CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nombre    : Nombre del pagador
      param out p_descrip   : Descripción
      param out p_fecha     : Fecha de proceso
      param out p_importe   : Importe
      param out mensajes  : Mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_nnumlin = ' || p_nnumlin || ' p_cbancar1 = '
            || p_cbancar1 || ' p_nombre = ' || p_nombre || ' p_descrip = ' || p_descrip
            || ' p_fecha = ' || p_fecha || ' p_importe = ' || p_importe;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_get_line_coda';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_line_coda(p_sproces, p_nnumlin, p_cbancar1, p_nnumord,
                                             p_nombre, p_descrip, p_fecha, p_importe,
                                             p_reference, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_line_coda;

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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_nnumlin = ' || p_nnumlin || ' p_cbancar1 = '
            || p_cbancar1 || ' p_nnumord = ' || p_nnumord;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_cancela_registro';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_cancela_registro(p_sproces, p_nnumlin, p_cbancar1, p_nnumord,
                                                mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_cancela_registro;

/*************************************************************************
      Descarta un registro CODA
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_nnumlin = ' || p_nnumlin || ' p_cbancar1 = '
            || p_cbancar1 || ' p_nnumord = ' || p_nnumord;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_cancela_registro';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_reactivar_registro(p_sproces, p_nnumlin, p_cbancar1, p_nnumord,
                                                  mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_reactivar_registro;

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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.FF_IMPORTE_PENDIENTE';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.ff_importe_pendiente(pnrecibo, psmovrec, p_importe, mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END ff_importe_pendiente;

   /*************************************************************************
       Obtiene el importe pendiente a pagar de un recibo
       param in  pnrecibo   : NUm recibo
       param in  psmovrec   : seq. mov. recibo
       param out p_importe   : Importe Pendiente
       param out mensajes  : Mensajes de error
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_valida_importe(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pitotalr IN NUMBER,
      pipago IN NUMBER,
      p_importe OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.F_validA_IMPORTE';
      v_error        NUMBER(8);
      pipendiente    NUMBER;
   BEGIN
      v_error := pac_md_coda.ff_importe_pendiente(pnrecibo, psmovrec, pipendiente, mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

/*    IF pitotalr < NVL(pipago, 0)
         OR NVL(pipago, 0) > pipendiente THEN
         p_importe := pipendiente;   --SE RECORTA LO Q PAGAMOS
      ELSE
  */
      p_importe := NVL(pipago, pipendiente);   --SE ACEPTA EL PAGO ENTERO
      --   END IF;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_importe;

   /*************************************************************************
       Retornem el detall dels moviments pendents (pagaments parcials)
       param in  pnrecibo   : NUm recibo
       param in  psmovrec   : seq. mov. recibo
       param out mensajes  : Mensajes de error
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_detmovrecibos(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pcurdetmovrecibo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object       VARCHAR2(200) := 'f_det_detmovrecibos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_detmovrecibos(pnrecibo, psmovrec, pcurdetmovrecibo,
                                                 mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_detmovrecibos;
   
      -- INi IAXIS-5149 -- ECP -- 14/01/2020
    FUNCTION f_get_detmovrecibosc(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pcurdetmovrecibo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object       VARCHAR2(200) := 'f_det_detmovrecibos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_detmovrecibosc(pnrecibo, psmovrec, pcurdetmovrecibo,
                                                 mensajes);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_detmovrecibosc;
    -- Fin IAXIS-5149 -- ECP -- 14/01/2020
   

   FUNCTION f_get_coda_detalle(
      p_sproces IN NUMBER,
      p_cbancar IN VARCHAR2,
      pnnumord IN NUMBER,
      pfultsald IN DATE,
      pnnumlin IN NUMBER,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_sproces = ' || p_sproces || ' p_cbancar = ' || p_cbancar || ' pnnumord = '
            || pnnumord || ' pfultsald = ' || pfultsald || ' pnnumlin = ' || pnnumlin;
      v_object       VARCHAR2(200) := 'PAC_IAX_CODA.f_get_coda_Detalle';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_coda.f_get_coda_detalle(p_sproces, p_cbancar, pnnumord, pfultsald,
                                                pnnumlin, p_refcursor, mensajes);

      IF v_error != 0 THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_coda_detalle;
END pac_iax_coda;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODA" TO "PROGRAMADORESCSI";
