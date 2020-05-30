--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LIQUIDACOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LIQUIDACOR" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LIQUIDACOR
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones de Correduria

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/11/2010   XPL                1. Creación del package. Bug 16310
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_propuesta_fechainicio(
      p_ccompani IN NUMBER,
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_finiliq OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := ' p_mes = ' || p_mes || ',p_anyo = ' || p_anyo || ',  p_ccompani = ' || p_ccompani;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_inicializa_liquidacion';
      v_error        NUMBER(8);
      vfliquida      DATE;
      v_cont         NUMBER := 0;
   BEGIN
      IF p_mes IS NULL
         OR p_anyo IS NULL
         OR p_ccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vfliquida := TO_DATE('01/' || p_mes || '/' || p_anyo, 'DD/MM/YYYY');

      SELECT COUNT(1)
        INTO v_cont
        FROM adm_liquida
       WHERE ccompani = p_ccompani
         AND fliquida = vfliquida;

      IF v_cont > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901673);
      END IF;

      SELECT MAX(ffinliq)
        INTO p_finiliq
        FROM adm_liquida
       WHERE ccompani = p_ccompani;

      IF p_finiliq IS NULL THEN
         p_finiliq := f_sysdate;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_propuesta_fechainicio;

   /*************************************************************************
       Función que nos creará una nueva liquidación, pasándole el mes, año y descripción.
       Nos guardará en persistencia la liquidación inicializada
       param in  p_mes       : Mes de la liquidación
       param in  p_anyo      : Año de la liquidación
       param in  p_tliquida  : Observaciones
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
        25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_inicializa_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      p_sproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
           := ' p_mes = ' || p_mes || ',p_anyo = ' || p_anyo || ',p_tliquida = ' || p_tliquida;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_inicializa_liquidacion';
      v_error        NUMBER(8);
   BEGIN
      IF p_mes IS NULL
         OR p_anyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_liquidacor.f_inicializa_liquidacion(p_mes, p_anyo, p_ccompani,
                                                            p_finiliq, p_ffinliq, p_importe,
                                                            p_tliquida, vtliquida, p_sproces,
                                                            mensajes);
      v_pasexec := 2;

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      pac_iax_produccion.limpiartemporales();
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_inicializa_liquidacion;

   /*************************************************************************
       Función que modifica liquidación, pasándole el mes, año y descripción.
       Nos guardará en persistencia la liquidación inicializada
       param in  p_mes       : Mes de la liquidación
       param in  p_anyo      : Año de la liquidación
       param in  p_tliquida  : Observaciones
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
        15/12/2010#JBN#16310
   *************************************************************************/
   FUNCTION f_modifica_liquidacion(
      p_mes IN NUMBER,
      p_anyo IN NUMBER,
      p_ccompani IN NUMBER,
      p_finiliq IN DATE,
      p_ffinliq IN DATE,
      p_importe IN NUMBER,
      p_tliquida IN VARCHAR2,
      p_sproces IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      pob_liquida    ob_iax_liquidacion;
      v_param        VARCHAR2(200)
           := ' p_mes = ' || p_mes || ',p_anyo = ' || p_anyo || ',p_tliquida = ' || p_tliquida;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_modifica_liquidacion';
      v_error        NUMBER(8);
   BEGIN
      IF p_mes IS NULL
         OR p_anyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      v_error := pac_md_liquidacor.f_modifica_liquidacion(p_mes, p_anyo, p_ccompani, p_finiliq,
                                                          p_ffinliq, p_importe, p_tliquida,
                                                          p_sproces, mensajes);
      v_pasexec := 3;

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_modifica_liquidacion;

   /*************************************************************************
      Función que devolvera el objecto liquidación que tenemos en persistencia
      param in  p_sproliq   : Proceso liquidacion
       param out mensajes    : Mensajes de error
      param out pob_liquida  : Objeto liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida_ob(
      p_sproliq IN NUMBER,
      pob_liquida OUT ob_iax_liquidacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquida_ob';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               pob_liquida := vtliquida(i);
               /* IF pob_liquida.recibos IS NOT NULL
                   AND pob_liquida.recibos.COUNT > 0 THEN
                   FOR z IN pob_liquida.recibos.FIRST .. pob_liquida.recibos.LAST LOOP
                      IF pob_liquida.recibos(z).cselecc = 0 THEN
                         pob_liquida.recibos.DELETE(z);
                      END IF;
                   END LOOP;
                END IF;*/
               RETURN 0;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_liquida_ob;

   /*************************************************************************
      Función que devolvera el objecto liquidación que tenemos en persistencia
      param in  p_sproliq   : Proceso liquidacion
       param out mensajes    : Mensajes de error
      param out pob_liquida  : Objeto liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_lstliquida_ob(pob_liquida OUT t_iax_liquidacion, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquida_ob';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      pob_liquida := vtliquida;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_lstliquida_ob;

   /*************************************************************************
      Función que nos devuelve los movimientos de un proceso del objeto persistente
      param in  p_sproliq   : Proceso liquidacion
      param in  P_nmovliq   : Movimiento a recuperar
      param out pob_liquidamov : Objeto del movimiento
      param out mensajes    : mensajes de error
      return                : 0.-    OK
                              1.-    KO
       25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquidamov_ob(
      p_sproliq IN NUMBER,
      p_nmovliq IN NUMBER,
      pob_liquidamov OUT ob_iax_liquida_mov,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquidamov_ob';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               FOR j IN vtliquida(i).movimientos.FIRST .. vtliquida(i).movimientos.LAST LOOP
                  IF vtliquida(i).movimientos(j).nmovliq = p_nmovliq THEN
                     pob_liquidamov := vtliquida(i).movimientos(j);
                     RETURN 0;
                  END IF;
               END LOOP;

               RETURN 0;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_liquidamov_ob;

   /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos y recibos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquida';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      v_error := pac_md_liquidacor.f_get_liquida(p_cempres, p_sproduc, p_sproliq, p_nmes,
                                                 p_anyo, p_cestado, p_npoliza, p_cpolcia,
                                                 p_nrecibo, p_creccia, p_ccompani, p_cagente,
                                                 p_femiini, p_femifin, p_fefeini, p_fefefin,
                                                 p_fcobini, p_fcobfin, pt_liquida, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      vtliquida := pt_liquida;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_liquida;

   /*************************************************************************
      Función que cargará el  objecto liquidacion con sus movimientos buscados en la bd
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  p_sproliq   : Proceso liquidacion
      param in  p_mes       : Mes de la liquidación
      param in  p_anyo      : Año de la liquidación
      param in  p_cestado   : Estado de la liquidación(abierto, cerrado..)
      param in  P_npoliza   : Póliza
      param in  P_npolcia   : Póliza Compañia
      param in  p_nrecibo   : Recibo
      param in  p_creccia   : Recibo Compañia
      param in p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisión
      param in  P_femifin   : Fecha fin emisión
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param out mensajes    : Mensajes de error
      param out pt_liquida  : Colección liquidación
      return                : NUMBER 1/0
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_liquida_cab(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_sproliq IN NUMBER,
      p_nmes IN NUMBER,
      p_anyo IN NUMBER,
      p_cestado IN NUMBER,
      p_npoliza IN NUMBER,
      p_cpolcia IN VARCHAR2,
      p_nrecibo IN NUMBER,
      p_creccia IN VARCHAR2,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      pt_liquida OUT t_iax_liquidacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquida_cab';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      v_error := pac_md_liquidacor.f_get_liquida_cab(p_cempres, p_sproduc, p_sproliq, p_nmes,
                                                     p_anyo, p_cestado, p_npoliza, p_cpolcia,
                                                     p_nrecibo, p_creccia, p_ccompani,
                                                     p_cagente, p_femiini, p_femifin,
                                                     p_fefeini, p_fefefin, p_fcobini,
                                                     p_fcobfin, pt_liquida, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      vtliquida := pt_liquida;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_liquida_cab;

   /*  FUNCTION f_get_recliquida(
        p_sproliq IN NUMBER,
        p_nrecibo IN NUMBER,
        p_ccompani IN NUMBER,
        p_cagente IN NUMBER,
        p_cmonseg IN VARCHAR2,
        p_cmonliq IN VARCHAR2,
        p_cgescob IN NUMBER,
        p_cramo IN NUMBER,
        p_sproduc IN NUMBER,
        p_fefectoini IN DATE,
        p_fefectofin IN DATE,
        pt_recliquida OUT t_iax_liquida_rec,
        mensajes OUT t_iax_mensajes)
        RETURN NUMBER IS
        v_pasexec      NUMBER(8) := 1;
        v_param        VARCHAR2(200) := '';
        v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_liquida';
        v_recibos      t_iax_recibos;
        v_error        NUMBER(8) := 0;
     BEGIN
        IF p_sproliq IS NULL THEN
           RAISE e_param_error;
        END IF;

        v_error := pac_md_liquidacor.f_get_recliquida(p_sproliq, p_nrecibo, p_ccompani,
                                                      p_cagente, p_cmonseg, p_cmonliq, p_cgescob,
                                                      p_cramo, p_sproduc, p_fefectoini,
                                                      p_fefectofin, pt_recliquida, mensajes);

        IF v_error <> 0 THEN
           RAISE e_object_error;
        END IF;

        IF vtliquida IS NOT NULL
           AND vtliquida.COUNT > 0 THEN
           FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
              IF vtliquida(i).sproliq = p_sproliq THEN
                 vtliquida(i).recibos := pt_recliquida;
              END IF;
           END LOOP;
        END IF;

        RETURN 0;
     EXCEPTION
        WHEN e_param_error THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
           RETURN 1;
        WHEN e_object_error THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
           RETURN 1;
        WHEN OTHERS THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                             NULL, SQLCODE, SQLERRM);
           RETURN 1;
     END f_get_recliquida;*/
   FUNCTION f_actualiza_objeto(p_sproliq IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_actualiza_objeto';
      v_index        NUMBER := 0;
      v_import       NUMBER := 0;
      vnmovimi       NUMBER := 0;
      vindexj        NUMBER;
      vindexi        NUMBER;
   BEGIN
--actualitzem el itotliq de l'objecte
      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            --v_import := 0;
            IF vtliquida(i).sproliq = p_sproliq THEN
               IF vtliquida(i).recibos IS NOT NULL
                  AND vtliquida(i).recibos.COUNT > 0 THEN
                  FOR j IN vtliquida(i).recibos.FIRST .. vtliquida(i).recibos.LAST LOOP
                     IF vtliquida(i).recibos(j).cselecc = 1 THEN
                        v_import := v_import + vtliquida(i).recibos(j).iliquida;
                     END IF;
                  END LOOP;
               END IF;

               vtliquida(i).itotliq := v_import;
            END IF;
         END LOOP;
      END IF;

      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               FOR j IN vtliquida(i).movimientos.FIRST .. vtliquida(i).movimientos.LAST LOOP
                  IF vtliquida(i).movimientos(j).nmovliq > vnmovimi THEN
                     vnmovimi := vtliquida(i).movimientos(j).nmovliq;
                     vindexj := j;
                     vindexi := i;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      IF vindexj IS NOT NULL
         AND vindexi IS NOT NULL THEN
         vtliquida(vindexi).movimientos(vindexj).itotliq := v_import;
      END IF;

      pac_iax_produccion.limpiartemporales();
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_actualiza_objeto;

   /*************************************************************************
      Función que nos buscará los recibos que queremos liquidar
      param in  p_sproliq   : Proceso liquidacion
      param in  p_nrecibo   : Recibo
      param in  p_ccompani   : Compañia del seguro
      param in  P_cagente   : Agente
      param in  p_cmonseg : moneda
      param in  p_cmonliq : moneda liq
      param in  p_cgescob : gest cob
      param in  P_cramo  : ramo
      param in  P_sproduc   : Producto
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param out pt_recliquida : colección recibos
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
       25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_get_recibos_propuestos(
      p_sproliq IN NUMBER,
      p_nrecibo IN NUMBER,
      p_ccompani IN NUMBER,
      p_cagente IN NUMBER,
      p_cmonseg IN VARCHAR2,
      p_cmonliq IN VARCHAR2,
      p_cgescob IN NUMBER,
      p_cramo IN NUMBER,
      p_sproduc IN VARCHAR2,
      p_fefectoini IN DATE,
      p_fefectofin IN DATE,
      pt_recliquida OUT t_iax_liquida_rec,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_sproduc: ' || p_sproduc;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDAcor.f_get_recibos_propuestos';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
      p_sproduc_tmp  NUMBER;
      v_cadena1      VARCHAR2(5000);
      liquida        ob_iax_liquidacion := ob_iax_liquidacion();
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
         IF vtliquida(i).sproliq = p_sproliq THEN
            IF vtliquida(i).recibos IS NOT NULL
               AND vtliquida(i).recibos.COUNT > 0 THEN
               FOR z IN vtliquida(i).recibos.FIRST .. vtliquida(i).recibos.LAST LOOP
                  vtliquida(i).recibos(z).cselecc := 1;

                  IF p_sproduc IS NOT NULL THEN
                     v_cadena1 := p_sproduc || ',';
                     vtliquida(i).recibos(z).cselecc := 0;

                     WHILE NVL(LENGTH(v_cadena1), 0) > 0 LOOP
                        p_sproduc_tmp := TO_NUMBER(SUBSTR(v_cadena1, 1,
                                                          INSTR(v_cadena1, ',') - 1));
                        v_cadena1 := SUBSTR(v_cadena1, INSTR(v_cadena1, ',') + 1);

                        IF vtliquida(i).recibos(z).poliza.sproduc IN(p_sproduc_tmp) THEN
                           vtliquida(i).recibos(z).cselecc := 1;
                        END IF;
                     END LOOP;
                  END IF;

                  IF p_nrecibo IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).nrecibo <> p_nrecibo THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_ccompani IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).ccompani <> p_ccompani THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_cagente IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).cagente <> p_cagente THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_cmonseg IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).cmonseg <> p_cmonseg THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_cmonliq IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).cmonliq <> p_cmonliq THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_cgescob IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).cgescob <> p_cgescob THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_fefectoini IS NOT NULL THEN
                     IF TRUNC(vtliquida(i).recibos(z).recibo.fefecto) <= TRUNC(p_fefectoini) THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_fefectofin IS NOT NULL THEN
                     IF TRUNC(vtliquida(i).recibos(z).recibo.fefecto) >= TRUNC(p_fefectofin) THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;

                  IF p_cramo IS NOT NULL THEN
                     IF vtliquida(i).recibos(z).poliza.cramo <> p_cramo THEN
                        vtliquida(i).recibos(z).cselecc := 0;
                     END IF;
                  END IF;
               END LOOP;
            END IF;

            RETURN 0;
         END IF;
      END LOOP;

      v_error := f_actualiza_objeto(p_sproliq, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_recibos_propuestos;

/*************************************************************************
      Función que actualizará el objeto persistente, nos podrá marcar el recibo de un proceso,
      nos modificará el signo de la liquidación (iliquida), en el caso que no pasemos ningún recibo como parámetro
      nos marcará todos los registros con el param p_selec
      param in  P_nrecibo   : Nº de recibo devuelto
      param in  P_sproliq   : Identificador proceso liquidacion
      param in  P_selec     : Indica si el recibo/s es seleccionado
      param in  P_signo     : Indica el signo de iliquida
      param out mensajes    : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_setobjetorecliqui(
      p_nrecibo IN VARCHAR2,
      p_sproliq IN NUMBER,
      p_selec IN NUMBER,
      p_signo IN NUMBER,
      p_modif IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(4000)
         := 'p_nrecibo = ' || p_nrecibo || ' p_smovrec = ' || p_sproliq || ' p_selec = '
            || p_selec || ' p_signo = ' || p_signo;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_setobjetorecliqui';
      v_error        NUMBER(8);
      trobat         BOOLEAN := FALSE;
      v_index        NUMBER := 0;
      v_import       NUMBER := 0;
      vnmovimi       NUMBER := 0;
      vindexj        NUMBER;
      vindexi        NUMBER;
      v_cadena1      VARCHAR2(4000);
      p_nrecibo_tmp  NUMBER;
      estaliquidado  NUMBER;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF p_nrecibo IS NOT NULL THEN
         v_cadena1 := p_nrecibo || ',';
      ELSE
         v_cadena1 := NULL;
      END IF;

      WHILE NVL(LENGTH(v_cadena1), 0) > 0 LOOP
         p_nrecibo_tmp := TO_NUMBER(SUBSTR(v_cadena1, 1, INSTR(v_cadena1, ',') - 1));
         v_cadena1 := SUBSTR(v_cadena1, INSTR(v_cadena1, ',') + 1);
         trobat := FALSE;

         IF vtliquida IS NOT NULL
            AND vtliquida.COUNT > 0 THEN
            FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
               IF vtliquida(i).sproliq = p_sproliq THEN
                  IF vtliquida(i).recibos IS NOT NULL
                     AND vtliquida(i).recibos.COUNT > 0 THEN
                     FOR j IN vtliquida(i).recibos.FIRST .. vtliquida(i).recibos.LAST LOOP
                        IF vtliquida(i).recibos(j).nrecibo = p_nrecibo_tmp THEN
                           vtliquida(i).recibos(j).cselecc := NVL(p_selec, 0);

                           IF NVL(p_modif, 0) = 1 THEN
                              vtliquida(i).recibos(j).recibo :=
                                  pac_iax_adm.f_get_datosrecibo_mv(p_nrecibo_tmp, 0, mensajes);
                              vtliquida(i).recibos(j).itotalr :=
                                                        vtliquida(i).recibos(j).recibo.importe;
                              vtliquida(i).recibos(j).icomisi :=
                                                        vtliquida(i).recibos(j).recibo.icomisi;
                           END IF;

                           vtliquida(i).recibos(j).iliquida :=
                                                      vtliquida(i).recibos(j).icomisi * p_signo;
                           trobat := TRUE;
                        ELSIF p_nrecibo_tmp IS NULL THEN
                           vtliquida(i).recibos(j).cselecc := NVL(p_selec, 0);
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         v_pasexec := 2;

         IF trobat = FALSE
            AND p_nrecibo_tmp IS NOT NULL THEN
            IF vtliquida IS NOT NULL
               AND vtliquida.COUNT > 0 THEN
               FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
                  IF vtliquida(i).sproliq = p_sproliq THEN
                     vtliquida(i).recibos.EXTEND;
                     v_index := vtliquida(i).recibos.LAST;
                     vtliquida(i).recibos(v_index) := ob_iax_liquida_rec();
                     vtliquida(i).recibos(v_index).nrecibo := p_nrecibo_tmp;
                     vtliquida(i).recibos(v_index).cselecc := 1;
                     vtliquida(i).recibos(v_index).recibo :=
                                  pac_iax_adm.f_get_datosrecibo_mv(p_nrecibo_tmp, 0, mensajes);
                     /*vtliquida(i).recibos(v_index).poliza :=
                        pac_iax_produccion.f_get_datpoliza
                                                    (vtliquida(i).recibos(v_index).recibo.sseguro,
                                                     mensajes);*/
                     vtliquida(i).recibos(v_index).poliza := ob_iax_genpoliza();

                     SELECT cpolcia,
                            npoliza,
                            f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                                            pac_md_common.f_get_cxtidioma),
                            ccompani,
                            sproduc,
                            cramo
                       INTO vtliquida(i).recibos(v_index).poliza.cpolcia,
                            vtliquida(i).recibos(v_index).poliza.npoliza,
                            vtliquida(i).recibos(v_index).poliza.tproduc,
                            vtliquida(i).recibos(v_index).ccompani,
                            vtliquida(i).recibos(v_index).poliza.sproduc,
                            vtliquida(i).recibos(v_index).poliza.cramo
                       FROM seguros
                      WHERE sseguro = vtliquida(i).recibos(v_index).recibo.sseguro;

                     IF vtliquida(i).recibos(v_index).ccompani IS NOT NULL THEN
                        v_error := f_descompania(vtliquida(i).recibos(v_index).ccompani,
                                                 vtliquida(i).recibos(v_index).tcompani);
                     END IF;

                     IF v_error <> 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
                     END IF;

                     IF vtliquida(i).recibos(v_index).recibo.fefecto IS NULL THEN
                        SELECT fefecto
                          INTO vtliquida(i).recibos(v_index).recibo.fefecto
                          FROM recibos
                         WHERE nrecibo = p_nrecibo_tmp;
                     END IF;

                     vtliquida(i).recibos(v_index).cagente :=
                                                   vtliquida(i).recibos(v_index).recibo.cagente;
                     vtliquida(i).recibos(v_index).tagente :=
                                                   vtliquida(i).recibos(v_index).recibo.tagente;
                     vtliquida(i).recibos(v_index).cmonseg := NULL;
                     -- vtliquida(i).recibos(v_index).recibo.cmonseg;
                     vtliquida(i).recibos(v_index).tmonseg := '';
                     --vtliquida(i).recibos(v_index).recibo.tmonseg;
                     vtliquida(i).recibos(v_index).itotalr :=
                                                   vtliquida(i).recibos(v_index).recibo.importe;
                     vtliquida(i).recibos(v_index).icomisi :=
                                                   vtliquida(i).recibos(v_index).recibo.icomisi;
                     vtliquida(i).recibos(v_index).iretenc := NULL;
                     -- vtliquida(i).recibos(v_index).recibo.iretenc;
                     vtliquida(i).recibos(v_index).iprinet := NULL;
                     --vtliquida(i).recibos(v_index).recibo.iprinet;
                     vtliquida(i).recibos(v_index).iliquida :=
                                                   vtliquida(i).recibos(v_index).recibo.icomisi;
                     vtliquida(i).recibos(v_index).cgescob :=
                                                   vtliquida(i).recibos(v_index).recibo.cgescob;
                     vtliquida(i).recibos(v_index).tgescob :=
                                                   vtliquida(i).recibos(v_index).recibo.tgescob;
                     p_tab_error(f_sysdate, f_user, 'linea 933', 1, 'llega',
                                 vtliquida(i).recibos(v_index).iliquida || ' - '
                                 || vtliquida(i).recibos(v_index).recibo.ctiprec || ' - '
                                 || vtliquida(i).recibos(v_index).recibo.cestrec || ' - '
                                 || vtliquida(i).recibos(v_index).recibo.icomisi || ' - '
                                 || vtliquida(i).recibos(v_index).icomisi || ' - '
                                 || p_nrecibo_tmp);

                     --Miraremos si ya existe en alguna liquidación y lo marcaremos
                     SELECT COUNT(1)
                       INTO estaliquidado
                       FROM adm_liquida_recibos
                      WHERE nrecibo = p_nrecibo_tmp
                        AND sproliq <> p_sproliq;

                     IF estaliquidado > 0 THEN
                        vtliquida(i).recibos(v_index).estaliquidado := 1;
                     ELSE
                        vtliquida(i).recibos(v_index).estaliquidado := 0;
                     END IF;

                     --Le modificaremos el signo
                     IF vtliquida(i).recibos(v_index).iliquida <> 0
                        AND(vtliquida(i).recibos(v_index).recibo.ctiprec IN(8, 9)
                            OR vtliquida(i).recibos(v_index).recibo.cestrec = 2) THEN
                        IF vtliquida(i).recibos(v_index).iliquida > 0 THEN
                           vtliquida(i).recibos(v_index).iliquida :=
                                            vtliquida(i).recibos(v_index).recibo.icomisi
                                            *(-1);
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END LOOP;

      v_error := f_actualiza_objeto(p_sproliq, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      pac_iax_produccion.limpiartemporales();
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_setobjetorecliqui;

   /*************************************************************************
      Función que nos grabará un nuevo  movimiento con el estado que le pasamos
      param in  p_sproliq   : Proceso liquidacion
      param in  p_cestliq   : Nuevo estado
      param out mensajes    : mensajes de error
      return                : 0.-    OK
                              1.-    KO
       25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_movliqui(
      p_sproliq IN NUMBER,
      p_cestliq IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_set_movliqui';
      v_error        NUMBER(8);
      vnmovimi       NUMBER := 0;
      vindex         NUMBER;
      v_index        NUMBER;
      vindexj        NUMBER;
      vindexi        NUMBER;
   BEGIN
      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               FOR j IN vtliquida(i).movimientos.FIRST .. vtliquida(i).movimientos.LAST LOOP
                  IF vtliquida(i).movimientos(j).nmovliq > vnmovimi THEN
                     vnmovimi := vtliquida(i).movimientos(j).nmovliq;
                     vindexj := j;
                     vindexi := i;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      IF vindexj IS NOT NULL
         AND vindexi IS NOT NULL THEN
         vtliquida(vindexi).movimientos.EXTEND;
         v_index := vtliquida(vindexi).movimientos.LAST;
         vtliquida(vindexi).movimientos(v_index) := ob_iax_liquida_mov();
         vtliquida(vindexi).movimientos(v_index).nmovliq := vnmovimi + 1;
         vtliquida(vindexi).movimientos(v_index).cestliq := p_cestliq;
         vtliquida(vindexi).movimientos(v_index).testliq :=
                             ff_desvalorfijo(800030, pac_md_common.f_get_cxtidioma, p_cestliq);
         vtliquida(vindexi).movimientos(v_index).cmonliq :=
                                               vtliquida(vindexi).movimientos(vindexj).cmonliq;
         vtliquida(vindexi).movimientos(v_index).tmonliq :=
                                               vtliquida(vindexi).movimientos(vindexj).tmonliq;
         vtliquida(vindexi).movimientos(v_index).itotliq :=
                                               vtliquida(vindexi).movimientos(vindexj).itotliq;
         vtliquida(vindexi).movimientos(v_index).cusualt := pac_md_common.f_get_cxtusuario;
         vtliquida(vindexi).movimientos(v_index).falta := f_sysdate;
         vtliquida(vindexi).nmovliq := vnmovimi + 1;
         vtliquida(vindexi).cestliq := p_cestliq;
         vtliquida(vindexi).testliq := vtliquida(vindexi).movimientos(v_index).testliq;
      END IF;

      v_error := f_set_recliqui(p_sproliq, mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_movliqui;

   /*************************************************************************
       Función que insertará los recibos que forman la liquidación en BD, si pasamos un proceso liquidación
       liquidaremos ese proceso sinó liquidaremos todos los procesos que tenemos por pantalla.
       param in  P_sproliq   : Identificador proceso liquidacion
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
       25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_set_recliqui(p_sproliq IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_set_recliqui';
      v_error        NUMBER(8);
   BEGIN
      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               v_error := pac_md_liquidacor.f_set_recliqui(vtliquida(i), mensajes);

               IF v_error <> 0 THEN
                  RAISE e_object_error;
               END IF;
            ELSIF p_sproliq IS NULL THEN
               v_error := pac_md_liquidacor.f_set_recliqui(vtliquida(i), mensajes);
            END IF;
         END LOOP;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000405);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_recliqui;

   /*************************************************************************
      Función que actualizará el objeto persistente, nos podrá marcar el recibo de un proceso,
      nos modificará el signo de la liquidación (iliquida), en el caso que no pasemos ningún recibo como parámetro
      nos marcará todos los registros con el param p_selec
      param in  P_nrecibo   : Nº de recibo devuelto
      param in  P_sproliq   : Identificador proceso liquidacion
      param in  P_selec     : Indica si el recibo/s es seleccionado
      param in  P_signo     : Indica el signo de iliquida
      param out mensajes    : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
      25/11/2010#XPL#16310
   *************************************************************************/
   FUNCTION f_setobjetorecliquiall(
      p_sproliq IN NUMBER,
      p_selec IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(4000)
                                   := ' p_sproliq = ' || p_sproliq || ' p_selec = ' || p_selec;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_setobjetorecliquiall';
      v_error        NUMBER(8);
      trobat         BOOLEAN := FALSE;
      v_index        NUMBER := 0;
      v_import       NUMBER := 0;
      vnmovimi       NUMBER := 0;
      vindexj        NUMBER;
      vindexi        NUMBER;
   BEGIN
      IF p_sproliq IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF vtliquida IS NOT NULL
         AND vtliquida.COUNT > 0 THEN
         FOR i IN vtliquida.FIRST .. vtliquida.LAST LOOP
            IF vtliquida(i).sproliq = p_sproliq THEN
               IF vtliquida(i).recibos IS NOT NULL
                  AND vtliquida(i).recibos.COUNT > 0 THEN
                  FOR j IN vtliquida(i).recibos.FIRST .. vtliquida(i).recibos.LAST LOOP
                     vtliquida(i).recibos(j).cselecc := NVL(p_selec, 0);
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      v_error := f_actualiza_objeto(p_sproliq, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      pac_iax_produccion.limpiartemporales();
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_setobjetorecliquiall;

      /*************************************************************************
      Función nos devuelve las liquidaciones en las cuales se encuentra el recibo
      param in  P_nrecibo   : Nº de recibo
      param out mensajes    : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
      03/06/2011#XPL#0018732
   *************************************************************************/
   FUNCTION f_get_lstliquida_rec(
      p_nrecibo IN NUMBER,
      p_liquidarec OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(4000) := ' p_nrecibo = ' || p_nrecibo;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDACOR.f_get_liquida_rec';
      v_error        NUMBER(8);
   BEGIN
      IF p_nrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_liquidacor.f_get_liquida_rec(p_nrecibo, p_liquidarec, mensajes);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_lstliquida_rec;
END pac_iax_liquidacor;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACOR" TO "PROGRAMADORESCSI";
