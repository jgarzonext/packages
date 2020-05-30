--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTION_REC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_IAX_GESTION_REC" IS
/******************************************************************************
   NOMBRE:      PAC_IAX_GESTION_REC
   PROPÓSITO:   Impresion de recibos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/01/2009                   1. Creación del package.
   1.1        11/02/2009   FAL             1. Añadir funcionalidades de gestión de recibos. Bug: 0007657
   1.2        27/02/2009   MCC             1. Excel para la impresion del docket. Bug 009005: APR - docket para los brokers
   1.3        15/06/2009   JTS             1. BUG 10069
   1.4        04/09/2009   JTS             1. Bug 10529: Pantallas de recibos
   2          24/03/2010   XPL             1. 0013450: APREXT02 - Transferencia de saldos entre rebuts
   3          30/03/2009   XPL             3 13850: APRM00 - Lista de recibos por personas
   4          29/04/2010   LCF             4 14302 Campo descripción traspaso saldo
   5.0        25/05/2010   ICV             5. 14586: CRT - Añadir campo recibo compañia
   6.0        17/11/2010   ICV             6. 0016383: AGA003 - recargo por devolución de recibo (renegociación de recibos)
   7.0        14/04/2011   APD             7. 0018263: ENSA101-Mejoras Prestaciones II
   8.0        03/01/2012   JMF             8. 0020761 LCOL_A001- Quotes targetes
   9.0        08/06/2012   APD             9. 0022342: MDP_A001-Devoluciones
   10.0       25/10/2012   DRA             10. 0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
   11.0       27/11/2012   ETM             11.0024854: ENSA998-Boton de refresco de datos de recibo online SAP
   12.0       25/11/2012   ETM             12.0029009: POSRA100-POS - Pantalla manual de recibos
   13.0       21/01/2014   JDS             13.0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
   14.0       02/06/2014   MMM             14.0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
   15.0       09/07/2019   DFR             15. IAXIS-3651 Proceso calculo de comisiones de outsourcing      
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*******************************************************************************
FUNCION F_IMPR_PENDIENTE_MAN
la funcion se encargará de grabar en la tabla temporal de la impresión de recibos aquellos que cumplan con los criterios de búsqueda

   param in psproduc : Id. producto
   param in pcagente : Agente
   param in psproces : Proceso
   param in pnpoliza : Poliza
   param in pnrecibo : Recibo
   param in pdataini : Fecha inicio
   param in pdatafin : Fecha fin
   param in pcreimp  : Reimpresion
   param in psproimp : Codigo proceso
   param in pcreccia : Recibo compañia
   param out psproimp2 : Codigo proceso
   param out mensajes  : mensajes de error
   return : number con el código de proceso para la impresión.
********************************************************************************/
   FUNCTION f_impr_pendiente_man(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      psproces IN NUMBER,
      pnpoliza IN NUMBER,
      pnrecibo IN NUMBER,
      pdataini IN DATE,
      pdatafin IN DATE,
      pcreimp IN NUMBER,
      psproimp IN NUMBER,
      pcreccia IN VARCHAR2,   --Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia
      psproimp2 OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'psproduc=' || psproduc || ' pcagente=' || pcagente || ' psproces=' || psproces
            || ' pnpoliza=' || pnpoliza || ' pnrecibo=' || pnrecibo || ' pdataini='
            || pdataini || ' pdatafin=' || pdatafin || ' pcreimp=' || pcreimp || ' psproimp='
            || psproimp || ' pcreccia=' || pcreccia;   --Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_IMPR_PENDIENTE_MAN';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      --En el cas de reimpressions si no hi ha cap camp informat (ni el número de procés) ,    ha de donar un error.
      IF pcreimp IS NOT NULL
         AND psproimp IS NULL
         AND pdataini IS NULL
         AND pdatafin IS NULL
         AND psproduc IS NULL
         AND pcagente IS NULL
         AND psproces IS NULL
         AND pnpoliza IS NULL
         AND pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_impr_pendiente_man(psproduc, pcagente, psproces, pnpoliza,
                                                     pnrecibo, pdataini, pdatafin, pcreimp,
                                                     psproimp, pcreccia, psproimp2, mensajes);   --Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_impr_pendiente_man;

/*******************************************************************************
FUNCION F_GET_IMPR_PENDIENTE_MAN
Esta función retornará el conteniendo de la tabla tmp_recgestion para el proceso solicitado.
   param in psproimp : Codigo proceso
   param in pcidioma : Idioma
   param in pitotalr : Total recibo
   param out mensajes  : mensajes de error
   return: ref_cursor con los registros que cumplan con el criterio
********************************************************************************/
   FUNCTION f_get_impr_pendiente_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_GET_IMPR_PENDIENTE_MAN';
   BEGIN
      mensajes := t_iax_mensajes();
      pitotalr := 0;

      -- Control parametros entrada
      IF psproimp IS NULL
         OR pcidioma IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     f_axis_literales(140974, pcidioma) || '  ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      cur := pac_md_gestion_rec.f_get_impr_pendiente_man(psproimp, pcidioma, pitotalr,
                                                         mensajes);
      RETURN cur;
   EXCEPTION
-- Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN cur;
   END f_get_impr_pendiente_man;

/*******************************************************************************
FUNCION F_SET_IMPR_PENDIENTE_MAN
Se actualizará el cestado de la tabla tmp_recgestion para el recibo y proceso informado por parámetro.
   param in psproimp : Codigo proceso
   param in pnrecibo : Recibo
   param in pcestado : Estado
   param out pitotalr : Total recibo
   param out mensajes  : mensajes de error
   return : NUMBER
********************************************************************************/
   FUNCTION f_set_impr_pendiente_man(
      psproimp IN NUMBER,
      pnrecibo IN NUMBER,
      pcestado IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      num            NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psproimp=' || psproimp || ' pnrecibo=' || pnrecibo || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_SET_IMPR_PENDIENTE_MAN';
   BEGIN
      mensajes := t_iax_mensajes();

-- Control parametros entrada
      IF psproimp IS NULL
         OR pnrecibo IS NULL
         OR pcestado IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_set_impr_pendiente_man(psproimp, pnrecibo, pcestado,
                                                         pitotalr, mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_set_impr_pendiente_man;

/*******************************************************************************
FUNCION F_CANCEL_IMPRESION_MAN
Se borrará la tabla tmp_recgestion para el sproimp informado

   param in psproimp : codigo proceso
   param out mensajes  : mensajes de error
   return : NUMBER , un número con el id del error, en caso de que todo vaya OK, retornará un cero
********************************************************************************/
   FUNCTION f_cancel_impresion_man(psproimp IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_CANCEL_IMPRESION_MAN';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_cancel_impresion_man(psproimp, mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_cancel_impresion_man;

/*******************************************************************************
FUNCION F_IMPRESION_RECIBOS_MAN
Función que imprimirá los recibos seleccionados.

  param in psproimp : codigo proceso
  param in pcidioma : codigo idioma
  param out pfichero : ruta del fichero generado
  param out mensajes  : mensajes de error
  return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
********************************************************************************/
   FUNCTION f_impresion_recibos_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_IMPRESION_MAN';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL
         OR pcidioma IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     f_axis_literales(140974, pcidioma) || '  ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_impresion_recibos_man(psproimp, pcidioma, pfichero, mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_impresion_recibos_man;

/*******************************************************************************
FUNCION F_IMPRESION_REGISTRO_MAN
Función que lanza los reports de agente.

  param in pcagente : Codigo agente
  param in pdataini : Fecha Inicio
  param in pdatafin : Fecha Fin
  param in pcidioma : Codigo idioma
  param out pfichero : ruta del fichero generado --Bug 9005-MCC-Creación de fichero.
  param out mensajes  : mensajes de error
  return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
********************************************************************************/
   FUNCTION f_impresion_registro_man(
      pcagente IN NUMBER,
      pdataini IN DATE,
      pdatafin IN DATE,
      pcidioma IN NUMBER,
      pfichero1 OUT VARCHAR2,
      pfichero2 OUT VARCHAR2,   --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'pcagente=' || pcagente || ' pdataini=' || pdataini || ' pdatafin=' || pdatafin
            || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_IMPRESION_REGISTRO_MAN';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF pdataini IS NULL
         OR pcidioma IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     f_axis_literales(140974, pcidioma) || '  ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num :=
         pac_md_gestion_rec.f_impresion_registro_man
                                             (pcagente, pdataini, pdatafin, pcidioma,
                                              pfichero1, pfichero2,   --Bug 9005-MCC-Nuevo parametro pfichero
                                              mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_impresion_registro_man;

/*******************************************************************************
FUNCION F_SELEC_TODOS_RECIBOS
Se actualizará el cestado a 1 de todos los recibos la tabla tmp_recgestion para un proceso psproimp por parámetro.
  param in psproimp : Codigo proceso
  param in pitotalr : Total recibos
  param out mensajes  : mensajes de error
  return : NUMBER
********************************************************************************/
   FUNCTION f_selec_todos_recibos(
      psproimp IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_SELEC_TODOS_RECIBOS';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_selec_todos_recibos(psproimp, pitotalr, mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_selec_todos_recibos;

/*******************************************************************************
FUNCION F_DESSELEC_TODOS_RECIBOS
Se actualizará el cestado a 0 de todos los recibos de la tabla tmp_recgestion para un proceso psproimp por parámetro.

  param in psproimp : Codigo proceso
  param in pitotalr : Total recibos
  param out mensajes  : mensajes de error
  return : NUMBER
********************************************************************************/
   FUNCTION f_desselec_todos_recibos(
      psproimp IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTION_REC.F_DESSELEC_TODOS_RECIBOS';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_md_gestion_rec.f_desselec_todos_recibos(psproimp, pitotalr, mensajes);

      IF num <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num;
   EXCEPTION
--Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_desselec_todos_recibos;

/*-----------------------------------------------------------------------*/
/* Gestión manual de recibos                                             */
/* Bug: 0007657: IAX - Gestión de recibos                                */
/* FAL                                              */
/*-----------------------------------------------------------------------*/

   --BUG 10069 - 15/06/2009 - JTS
   /*******************************************************************************
   FUNCION F_COBRO_RECIBO
   Función que realiza el cobro para usuarios de central (cobro manual)
      param in pcempres : empres
      param in pnrecibo : recibo
      param in pfmovini : fecha de cobro
      param in pccobban : cobrador bancario
      param in pdelega : delegación
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_cobro_recibo(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER,
      pfmovini IN DATE,
      pccobban IN NUMBER,
      pdelega IN NUMBER,
      phost IN NUMBER,
      pctipcob IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_cobro_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - pnrecibo: ' || pnrecibo
            || ' - pfmovini: ' || pfmovini || ' - pccobban: ' || pccobban || ' - pdelega: '
            || pdelega || ' - phost: ' || phost || ' - pctipcob: ' || pctipcob;
      vpasexec       NUMBER := 1;
   BEGIN
      IF (pcempres IS NULL
          OR pnrecibo IS NULL
          OR pfmovini IS NULL
          OR(pccobban IS NULL   --BUG 10529 - JTS - 29/10/2009
             AND pdelega IS NULL)) THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_cobro_recibo(pcempres, pnrecibo, pfmovini, NULL, NULL,
                                               pccobban, pdelega, phost, pctipcob, mensajes);

      IF err <> 0 THEN
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000838);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_cobro_recibo;

   --Fi BUG 10069 - 15/06/2009 - JTS

   /*******************************************************************************
   FUNCION F_ANULA_RECIBO
   Función que realiza la anulación de un recibo.
      param in pnrecibo : recibo
      param in pfanulac : fecha anulación
      param in pcmotanu : motivo anulación
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anula_recibo(
      pnrecibo IN NUMBER,
      pfanulac IN DATE,
      pcmotanu IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_anula_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfanulac: ' || pfanulac
            || ' - pcmotanu: ' || pcmotanu;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pfanulac IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_anula_recibo(pnrecibo, pfanulac, pcmotanu, mensajes);

--      IF err IS NULL THEN
--         RAISE NO_DATA_FOUND;
--      END IF;
      IF err = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000839);
      END IF;

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         -- Bug 18263 - APD - 14/04/2011 - faltaba controlar que si hay un error, vaya a la
         -- exception y se realice el ROLLBACK.
         RAISE e_object_error;
      -- Fin Bug 18263 - APD - 14/04/2011
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;   -- Bug 18263 - APD - 14/04/2011 - se añade el ROLLBACK
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;   -- Bug 18263 - APD - 14/04/2011 - se añade el ROLLBACK
         RETURN NULL;
--      WHEN NO_DATA_FOUND THEN
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
--         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
--         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;   -- Bug 18263 - APD - 14/04/2011 - se añade el ROLLBACK
         RETURN NULL;
   END f_anula_recibo;

/*******************************************************************************
FUNCION F_MODIFICA_RECIBO
Función que realiza modificación en el recibo.
   param in pnrecibo : recibo
   param in pctipban : tipo cuenta
   param in pcbancar : cuenta bancaria
   param in pcgescob : gestor de cobro
   param in pcestimp : estado de impresión
   param in pcaccpre : código de acción preconcedida
   param in pcaccret : código de acción retenida
   param in ptobserv : texto de observaciones
   param out mensajes  : mensajes de error
   return: number indicando código de error (0: sin errores)
   -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
   -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros pcaccpre, pcaccret y ptobserv
********************************************************************************/
   FUNCTION f_modifica_recibo(
      pnrecibo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgescob IN NUMBER,
      pcestimp IN NUMBER,
      pccobban IN NUMBER,
      pncuotar IN NUMBER DEFAULT NULL,
      pcaccpre IN NUMBER DEFAULT NULL,
      pcaccret IN NUMBER DEFAULT NULL,
      ptobserv IN VARCHAR2 DEFAULT NULL,
      pctipcob IN NUMBER DEFAULT NULL,
      --AAC_INI-CONF_OUTSOURCING-20160906
      pcgescar IN NUMBER DEFAULT NULL,
      --AAC_FI-CONF_OUTSOURCING-20160906
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_modifica_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pctipban: ' || pctipban
            || ' - pcbancar: ' || pcbancar || ' - pcgescob: ' || pcgescob || ' - pcestimp: '
            || pcestimp || ' pccobban : ' || pccobban || ' - pncuotar: ' || pncuotar
            || ' pcaccpre: ' || pcaccpre || ' pcaccret: ' || pcaccret || ' ptobserv: '
            || ptobserv || ' pcgescar: ' || pcgescar ;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pcgescob IS NULL
          OR pcestimp IS NULL) THEN
         RAISE e_param_error;
      END IF;

      --AAC_INI-CONF_OUTSOURCING-20160906
      err := pac_md_gestion_rec.f_modifica_recibo(pnrecibo, pctipban, pcbancar, pcgescob,
                                                  pcestimp, pccobban, pncuotar, pcaccpre,
                                                  pcaccret, ptobserv, pctipcob,pcgescar, mensajes);
      --AAC_FI-CONF_OUTSOURCING-20160906

--      IF err IS NULL THEN
--         RAISE NO_DATA_FOUND;
--      END IF;
      IF err = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000840);
      END IF;

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
--      WHEN NO_DATA_FOUND THEN
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
--         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
--         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_modifica_recibo;

/*******************************************************************************
FUNCION F_ANULACION_PENDIENTE
Función que marca un recibo como pendiente de anulación
   param in pnrecibo : recibo
   param out mensajes  : mensajes de error
   return: number indicando código de error (0: sin errores)
********************************************************************************/
   FUNCTION f_anulacion_pendiente(pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_anulacion_pendiente';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_anulacion_pendiente(pnrecibo, mensajes);

--      IF err IS NULL THEN
--         RAISE NO_DATA_FOUND;
--      END IF;
      IF err = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000839);
      END IF;

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
--      WHEN NO_DATA_FOUND THEN
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
--         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
--         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_anulacion_pendiente;

/*******************************************************************************
FUNCION F_VALIDA_COBRO
Función que valida si el recibo pertenece a la empresa: pempresa
   param in pempresa : empresa
   param in pnrecibo : recibo
   param out mensajes  : mensajes de error
   return: number indicando código de error (0: sin errores)
********************************************************************************/
   FUNCTION f_valida_cobro(pempresa IN NUMBER, pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_valida_cobro';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pempresa: ' || pempresa;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pempresa IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_valida_cobro(pempresa, pnrecibo, mensajes);
--      IF err IS NULL THEN
--         RAISE NO_DATA_FOUND;
--      END IF;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
--      WHEN NO_DATA_FOUND THEN
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
--         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
--         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_valida_cobro;

/*******************************************************************************
FUNCION F_IMPAGO_RECIBO
Función que realiza el impago o descobro de un recibo
   param in pnrecibo : recibo
   param in pfecha : fecha de descobro
   param in pccobban : cobrador bancario
   param in pcmotivo : motivo de descobro
   param out mensajes  : mensajes de error
   return: number indicando código de error (0: sin errores)
********************************************************************************/
   FUNCTION f_impago_recibo(
      pnrecibo IN NUMBER,
      pfecha IN DATE,
      pccobban IN NUMBER,
      pcmotivo IN NUMBER,
      pcrecimp IN NUMBER DEFAULT 0,   --Bug.: 16383 - ICV - 17/11/2010
      mensajes OUT t_iax_mensajes,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_iax_gestion_rec.f_impago_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfecha: ' || pfecha
            || ' - pccobban: ' || pccobban || ' - pcmotivo: ' || pcmotivo
            || ' - pcrecimp: ' || pcrecimp|| ' - pnpoliza: ' || pnpoliza;
      error          NUMBER;
      terror         VARCHAR2(2000);
   BEGIN
      IF (pnrecibo IS NULL
          OR pfecha IS NULL) THEN
         RAISE e_param_error;
      END IF;

      error := pac_md_gestion_rec.f_impago_recibo(pnrecibo, pfecha, pccobban, pcmotivo,
                                                  pcrecimp, mensajes, pnpoliza);

      IF error = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000841);
      END IF;

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END f_impago_recibo;

   /* FUNCION f_get_anula_pend
   Función que recupera si un recibo está marcado como pendiente de anulación ó está desmarcado
      param in pnrecibo : recibo
      param out mensajes : mensajes de error
      return: number indicando si el recibo esta marcado como pendiente de anulación
   ********************************************************************************/
   FUNCTION f_get_anula_pend(pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_iax_gestion_rec.f_impago_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnrecibo: ' || pnrecibo;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      RETURN(pac_md_gestion_rec.f_get_anula_pend(pnrecibo, mensajes));
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_anula_pend;

/*******************************************************************************
FUNCION F_GET_ACCIONES
Función que recupera las acciones posibles a realizar sobre un recibo en función del estado del recibo y configuración del usuario
   param in pnrecibo : recibo
   param out mensajes  : mensajes de error
   param in pavisos : Indica si se han de mostrar los avisos 1.- Sí 0.- No
   return: sysrefcursor con las posibles acciones a realizar
********************************************************************************/
   FUNCTION f_get_acciones(
      pnrecibo IN NUMBER,
      psaltar OUT NUMBER,
      pavisos IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_get_acciones';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      cur            sys_refcursor;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_gestion_rec.f_get_acciones(pnrecibo, psaltar, pavisos, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_acciones;

/*******************************************************************************
FUNCION F_get_saldo_inicial
Función que recupera el saldo de un recibo
   param in pnrecibo : recibo
   param out pisaldo : importe total
   param out mensajes  : mensajes de error
   return: number, 0 OK 1 KO
 24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
********************************************************************************/
   FUNCTION f_get_saldo_inicial(
      pnrecibo IN NUMBER,
      pisaldo OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_get_saldo_inicial';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_get_saldo_inicial(pnrecibo, pisaldo, mensajes);

      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_saldo_inicial;

/*******************************************************************************
FUNCION f_transferir
Función que se encarga de transferir el importe al recibo
destino y de cobrar el recibo destino si fuese necesario
   param in pnrecibo : recibo
   param in pisaldo : importe total
   param in tdescrip : descripcion
   param out mensajes  : mensajes de error
   return: number, 0 OK 1 KO
  24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
********************************************************************************/
   FUNCTION f_transferir(
      pnrecibo_origen IN NUMBER,
      pnrecibo_destino IN NUMBER,
      pisaldo IN NUMBER,
      ptdescrip IN VARCHAR2,   --BUG 14302 - 28/04/2010 - LCF
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_TRANSFERIR';
      vparam         VARCHAR2(500)
         := 'parámetros - PNRECIBO_ORIGEN: ' || pnrecibo_origen || '- PNRECIBO_DESTINO: '
            || pnrecibo_destino || '- PISALDO : ' || pisaldo || '- TDESCRIP : ' || ptdescrip;
      vpasexec       NUMBER(5) := 1;
      vtmsg          VARCHAR2(1000);
   BEGIN
      IF pnrecibo_origen IS NULL
         OR pnrecibo_destino IS NULL
         OR pisaldo IS NULL
         OR pisaldo = 0
         OR pnrecibo_origen = pnrecibo_destino THEN
         RAISE e_param_error;
      END IF;

      --BUG 14302 - 28/04/2010 - LCF
      err := pac_md_gestion_rec.f_transferir(pnrecibo_origen, pnrecibo_destino, pisaldo,
                                             ptdescrip, mensajes);

      --Fi BUG 14302 - 28/04/2010 - LCF
      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      vtmsg := pac_iobj_mensajes.f_get_descmensaje(9901058, pac_md_common.f_get_cxtidioma);
      vtmsg := vtmsg || ' '
               || pac_iobj_mensajes.f_get_descmensaje(9901105, pac_md_common.f_get_cxtidioma)
               || ' : ' || pnrecibo_origen;
      vtmsg := vtmsg || ' '
               || pac_iobj_mensajes.f_get_descmensaje(9901106, pac_md_common.f_get_cxtidioma)
               || ' : ' || pnrecibo_destino;
      vtmsg := vtmsg || ' '
               || pac_iobj_mensajes.f_get_descmensaje(9901107, pac_md_common.f_get_cxtidioma)
               || ' ' || TO_CHAR(pisaldo, 'FM999G999G999G990D00');
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_transferir;

    /*******************************************************************************
   FUNCION f_get_rebtom
   Función que se encarga de devolver los recibos del tomador en los ultimos 5 años
      param in sperson : seq. persona a buscar
      param out pipagado : importe de todos los recibos cobrados
      param out pipendiente : importe de todos los recibos pendientes
      param out pimpagados : importe de todos los recibos impagados
      param out precibos  : Cursos con los recibos a mostrar
      param out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
      30/03/2009#XPL#13850: APRM00 - Lista de recibos por personas
   ********************************************************************************/
   FUNCTION f_get_rebtom(
      psperson IN NUMBER,
      pipagado OUT NUMBER,
      pipendiente OUT NUMBER,
      pimpagado OUT NUMBER,
      pisaldo OUT NUMBER,
      precibos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_get_rebtomR';
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vpasexec       NUMBER(5) := 1;
      vtmsg          VARCHAR2(1000);
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_get_rebtom(psperson, pipagado, pipendiente, pimpagado,
                                             pisaldo, precibos, mensajes);

      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_rebtom;

   /**************************************************************************************
     F_REHABILITA_REC. Funci¿n que rehabilita un recibo.
        pnrecibo: Recibo que queremos anular
        pfrehabi: Fecha de efecto de rehabilitacion del recibo
        psmovagr: agrupaci¿n de recibos por remesa. Si es null se incrementa la secuencia
        param out mensajes  : mensajes de error
        return: number indicando código de error (0: sin errores)

        Bug 18908/93215 - 05/10/2011 - AMC
   ********************************************************************************/
   FUNCTION f_rehabilita_rec(pnrecibo IN NUMBER, pfrehabi IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_REHABILITA_REC';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfrehabi: ' || pfrehabi;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pfrehabi IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_rehabilita_rec(pnrecibo, pfrehabi, mensajes);

      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_rehabilita_rec;

/*******************************************************************************
FUNCION F_MODIFICA_ACCPRECONOCIDA
Función que realiza modificación en el recibo complementario.
   param in pnrecibo : recibo
   param in pcaccpre : código de acción preconocida
   return: number indicando código de error (0: sin errores)
   Bug 22342 - 11/06/2012 - APD
********************************************************************************/
   FUNCTION f_modifica_accpreconocida(
      pnrecibo IN NUMBER,
      pcaccpre IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_REHABILITA_REC';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pcaccpre: ' || pcaccpre;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_gestion_rec.f_modifica_accpreconocida(pnrecibo, pcaccpre, mensajes);

      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_modifica_accpreconocida;

   -- BUG23853:DRA:09/11/2012:Inici
   FUNCTION f_desctiprec(pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_DESCTIPREC';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := NULL;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_texto := pac_gestion_rec.f_desctiprec(pnrecibo, pac_md_common.f_get_cxtidioma);
      RETURN v_texto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN '**';
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN '**';
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN '**';
   END f_desctiprec;

-- BUG23853:DRA:09/11/2012:Fi

   -- BUG24854 :ETM: 27/12/2012 : Inici
   FUNCTION f_sincroniza_sap(pnrecibo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_sincroniza_sap';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := NULL;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_gestion_rec.f_sincroniza_sap(pnrecibo, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_sincroniza_sap;

--fIN  BUG24854 :ETM:27/12/2012:
-- BUG 29009 -- ETM -- 25/11/2013 -- INI
   FUNCTION f_recman_pens(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pimporte IN NUMBER,
      pctipcob IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.F_APUNTEMANUAL_CP';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ',pnmovimi:=' || pnmovimi
            || ',pctiprec:=' || pctiprec || ',pimporte:=' || pimporte || ',pctipcob:='
            || pctipcob;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := NULL;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pctiprec IS NULL
         OR pimporte IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001768);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_gestion_rec.f_recman_pens(psseguro, pnmovimi, pctiprec, pimporte,
                                                  pctipcob, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_recman_pens;

-- FIN  BUG 29009 -- ETM -- 25/11/2013

   -- BUG 29603 -- JDS -- 21/01/2014 -- INI
/*******************************************************************************
FUNCION f_desctippag
Función que devolverá el literal del pagador del recibo.
param in pnrecibo
param in pcidioma
********************************************************************************/
   FUNCTION f_desctippag(pnrecibo IN NUMBER, pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_desctippag';
      vparam         VARCHAR2(500)
                         := 'parámetros - pnrecibo: ' || pnrecibo || ',pcidioma:=' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := '';
   BEGIN
      v_texto := pac_md_gestion_rec.f_desctippag(pnrecibo, pcidioma, mensajes);
      RETURN v_texto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_desctippag;

-- FIN  BUG 29603 -- JDS -- 10/01/2014

   -- 14.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio

   /*******************************************************************************
   FUNCION f_get_lista_dias_gracia
   Función que devuelve un cursor con la lista de dias de gracia dado un
   agente / producto
   param in pcagente
   param in psproduc
   param out mensajes
   ********************************************************************************/
   FUNCTION f_get_lista_dias_gracia(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION_REC.f_get_lista_dias_gracia';
      vparam         VARCHAR2(500)
                        := 'parámetros - pcagente: ' || pcagente || ' - psproduc ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gestion_rec.f_get_lista_dias_gracia(pcagente, psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lista_dias_gracia;

   /*******************************************************************************
   FUNCION f_set_dias_gracia_agente_prod
   Función que inserta / modifica los dias de gracia, dado un agente y prodcuto
   agente / producto
   param in pcagente
   param in psproduc
   param in pfini
   param in pdias
   param out mensajes
   ********************************************************************************/
   FUNCTION f_set_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE,
      pdias IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_gestion_rec.f_set_dias_gracia_agente_prod';
      vparam         VARCHAR2(550)
         := 'pccagente:' || pcagente || ' psproduc:' || psproduc || ' pfini:' || pfini
            || ' pdias:' || pdias;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL
         OR pfini IS NULL
         OR pdias IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gestion_rec.f_set_dias_gracia_agente_prod(pcagente, psproduc, pfini,
                                                                  pdias, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      --ELSE
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 180121);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_dias_gracia_agente_prod;

   /*******************************************************************************
   FUNCION f_del_dias_gracia_agente_prod
   Función que borra un registro de parametrizacion de dias de gracia, dado un
   agente / producto
   param in pcagente
   param in psproduc
   param in pfini
   param out mensajes
   ********************************************************************************/
   FUNCTION f_del_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_gestion_rec.f_del_dias_gracia_agente_prod';
      vparam         VARCHAR2(550)
                 := 'pccagente:' || pcagente || ' psproduc:' || psproduc || ' pfini:' || pfini;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL
         OR pfini IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gestion_rec.f_del_dias_gracia_agente_prod(pcagente, psproduc, pfini,
                                                                  mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_dias_gracia_agente_prod;
-- 14.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Fin

FUNCTION f_get_anula_x_no_pago(
          pcempres IN NUMBER,
          pcramo   IN NUMBER,
          psproduc IN NUMBER,
          pcagente IN NUMBER,
          pnpoliza IN NUMBER,
          pncertif IN NUMBER,
          psucur    IN     NUMBER,
          pnrecibo IN NUMBER,
          pidtomador IN VARCHAR2,
          pntomador IN VARCHAR2,
		  abrecibo IN NUMBER,
          soferta     IN     NUMBER,
          pcmodif     IN     NUMBER,
          ppdlegal    IN     NUMBER,
          ppjudi      IN     NUMBER,
          ppgunica    IN     NUMBER,
          ppestatal   IN     NUMBER,
          cur OUT sys_refcursor,
          mensajes OUT t_iax_mensajes)
     RETURN NUMBER
IS
     err         NUMBER := 0;
     vpasexec NUMBER(8) := 1;
     vobject  VARCHAR2 (500) := 'PAC_IAX_GESTION_REC.f_get_anula_x_no_pago';
     vparam   VARCHAR2 (500) := 'parámetros - pcempres: ' || pcempres || ', pcramo: ' || pcramo ||
     ', psproduc: ' || psproduc || ', pcagente: ' || pcagente || ', pncertif: ' || pncertif ||
     ', pnrecibo: ' || pnrecibo || ', psucur: ' || psucur || ', pditomador: ' || pidtomador || ', pntomador: ' || pntomador ||
	 ', abrecibo: ' || abrecibo || ', soferta: ' || soferta || ', pcmodif: ' || pcmodif || ', ppdlegal: ' || ppdlegal ||
	 ', ppjudi: ' || ppjudi || ', ppgunica: ' || ppgunica || ', ppestatal: ' || ppestatal;

BEGIN
     err := pac_md_gestion_rec.f_get_anula_x_no_pago(pcempres,pcramo,psproduc,pcagente,pnpoliza,pncertif,psucur,pnrecibo,pidtomador,pntomador,abrecibo,soferta,pcmodif,ppdlegal,ppjudi,ppgunica,ppestatal,cur,mensajes);
     vpasexec := 2;
     RETURN err;
EXCEPTION
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN err;
END f_get_anula_x_no_pago;
FUNCTION f_set_anula_x_no_pago(
          pnrecibo IN NUMBER,
          pccheck  IN NUMBER,
          mensajes OUT t_iax_mensajes)
     RETURN NUMBER
IS
     vobject  VARCHAR2 (500) := 'PAC_IAX_GESTION_REC.f_get_anula_x_no_pago';
     vparam   VARCHAR2 (500) := 'parámetros - pnrecibo: ' || pnrecibo || ', pccheck: ' || pccheck;
     vpasexec NUMBER(8) := 1;
     vnumerr        NUMBER(10);
BEGIN
     IF pnrecibo IS NULL OR pccheck IS NULL THEN
         vpasexec := 2;
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := PAC_MD_GESTION_REC.f_set_anula_x_no_pago(pnrecibo, pccheck, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      COMMIT;
      vpasexec := 6;
      RETURN(0);
EXCEPTION
WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 9001768, vpasexec, vparam);
     --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
     ROLLBACK;
     RETURN 1;
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
     ROLLBACK;
     RETURN 1;
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     ROLLBACK;
     RETURN 1;
END f_set_anula_x_no_pago;
--
--Inicio IAXIS-3651 09/07/2019
--
/*******************************************************************************
FUNCION f_get_liquidacion
Función que obtiene los recibos a liquidar para un outsourcing especificado.
param in pnumidetom -> Número de identificación
param in pcestgest  -> Estado gestiòn
param in pfefeini -> Fecha de efecto inicio
param in pfefefin -> Fecha de efecto fin
param in pcagente -> Agente
param in pnrecibo -> Recibo
param in pctipoper -> Tipo de persona Outsourcing/Tomador
********************************************************************************/
FUNCTION f_get_liquidacion(
   pnumidetom IN VARCHAR2,
   pcestgest IN NUMBER,
   pfefeini IN DATE,
   pfefefin IN DATE,
   pcagente IN NUMBER,
     pnrecibo IN NUMBER,
   pctipoper  IN NUMBER,
   mensajes OUT t_iax_mensajes)
   RETURN sys_refcursor
IS
   cur sys_refcursor;
   numerr         NUMBER := 0;
   vpasexec NUMBER(8) := 1;
   vobject  VARCHAR2 (500) := 'PAC_IAX_GESTION_REC.f_get_liquidacion';
   vparam   VARCHAR2 (500) := 'parámetros - pnumidetom: ' || pnumidetom || ', pcestgest: ' || pcestgest ||
   ', pfefeini: ' || pfefeini || ', pcagente: ' || pcagente || ', pfefefin: ' || pfefefin || ', pnrecibo: ' || pnrecibo; 
BEGIN
  vpasexec := 1;
  cur := pac_md_gestion_rec.f_get_liquidacion(pnumidetom,pcestgest,pfefeini,pfefefin,pcagente,pnrecibo,pctipoper,mensajes);
  vpasexec := 2;
  RETURN cur;   
EXCEPTION
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>SQLCODE, psqerrm => SQLERRM);
  IF cur%ISOPEN THEN
    CLOSE cur;
  END IF; 
  RETURN cur;
END f_get_liquidacion;
--
--Fin IAXIS-3651 09/07/2019
--
END pac_iax_gestion_rec;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_REC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_REC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_REC" TO "PROGRAMADORESCSI";
