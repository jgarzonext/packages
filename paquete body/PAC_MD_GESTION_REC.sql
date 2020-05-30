--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTION_REC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_GESTION_REC IS
   /******************************************************************************
      NOMBRE:      PAC_MD_GESTION_REC
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
      5          09/07/2010   ETM             5 0015353: MDP - Impagos de recibos
      6.0        25/05/2010   ICV             6. 14586: CRT - Añadir campo recibo compañia
      7.0        17/11/2010   ICV             7. 0016383: AGA003 - recargo por devolución de recibo (renegociación de recibos)
      8.0        16/12/2010   ICV             8. 0010837: APR - Docket no muestra información
      9.0        24/03/2011   JMF             9. 0017970 ENSA101- Campos pantallas de siniestros y mejoras
     10.0        03/01/2012   JMF            10. 0020761 LCOL_A001- Quotes targetes
     11.0        23/04/2012   JGR            11. 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135
     12.0        08/06/2012   APD            12. 0022342: MDP_A001-Devoluciones
     13.0        25/10/2012   DRA            13. 0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
     14.0        27/11/2012   ETM            14. 0024854: ENSA998-Boton de refresco de datos de recibo online SAP
     15.0        05/07/2013   MMM            15. 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto"
     16.0        12/11/2013   JDS            16. 0028613: LCOL_A001- Rehabilitación de Recibos
     17.0        25/11/2012   ETM            17.0029009: POSRA100-POS - Pantalla manual de recibos
     18.0        21/01/2014   JDS            18.0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
     19.0        02/06/2014   MMM            19.0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
     20.0        05/06/2019   ECP            20.IAXIS-3592 Proceso de Terminación por no pago
     21.0        09/07/2019   DFR            21. IAXIS-3651 Proceso calculo de comisiones de outsourcing
     22.0        17/09/2019   SPV            22. IAXIS-4516 Reversión de recaudos en recibos
     23.0        23/10/2019   DFR            23. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'psproduc=' || psproduc || ' pcagente=' || pcagente || ' psproces=' || psproces
            || ' pnpoliza=' || pnpoliza || ' pnrecibo=' || pnrecibo || ' pdataini='
            || pdataini || ' pdatafin=' || pdatafin || ' pcreimp=' || pcreimp || ' psproimp='
            || psproimp || ' pcreccia=' || pcreccia;   --Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_IMPR_PENDIENTE_MAN';
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

      num := pac_gestion_rec.f_impr_pendiente_man(psproduc, pcagente, psproces, pnpoliza,
                                                  pnrecibo, pdataini, pdatafin, pcreimp,
                                                  psproimp, pcreccia, psproimp2);

      IF num <> 0 THEN
         IF num = 1000254 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000254);
         ELSIF num = 9901779 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901779);   --etm nuevo mensaje
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_GET_IMPR_PENDIENTE_MAN';
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

      cur := pac_gestion_rec.f_get_impr_pendiente_man(psproimp, pcidioma, pitotalr);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      num            NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psproimp=' || psproimp || ' pnrecibo=' || pnrecibo || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_SET_IMPR_PENDIENTE_MAN';
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_gestion_rec.f_set_impr_pendiente_man(psproimp, pnrecibo, pcestado, pitotalr);

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
   END f_set_impr_pendiente_man;

   /*******************************************************************************
         FUNCION F_CANCEL_IMPRESION_MAN
   Se borrará la tabla tmp_recgestion para el sproimp informado
      param in psproimp : codigo proceso
      param out mensajes  : mensajes de error
      return : NUMBER , un número con el id del error, en caso de que todo vaya OK, retornará un cero
   ********************************************************************************/
   FUNCTION f_cancel_impresion_man(psproimp IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'Psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_CANCEL_IMPRESION_MAN';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_gestion_rec.f_cancel_impresion_man(psproimp);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_IMPRESION_RECIBOS_MAN';
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

      num := pac_gestion_rec.f_impresion_recibos_man(psproimp, pcidioma, pfichero);

      IF num <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107914);   --   Error en el proceso de generación del fichero
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000611);   -- Fichero generado ok
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
   END f_impresion_recibos_man;

   /*******************************************************************************
         FUNCION F_IMPRESION_REGISTRO_MAN
   Función que lanza los reports de agente.
     param in pcagente : Codigo agente
     param in pdataini : Fecha Inicio
     param in pdatafin : Fecha Fin
     param in pcidioma : Codigo idioma
     param out pfichero  : ruta del fichero generado --Bug 9005-MCC-Creación de fichero.
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(300)
         := 'pcagente=' || pcagente || ' pdataini=' || pdataini || ' pdatafin=' || pdatafin
            || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_IMPRESION_REGISTRO_MAN';
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

      num := pac_gestion_rec.f_impresion_registro_man(pcagente, pdataini, pdatafin, pcidioma,
                                                      pfichero1, pfichero2);   --Bug 9005-MCC-Nuevo parametro para creación de fichero.

      IF num <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107914);   --   Error en el proceso de generación del fichero
         RAISE e_object_error;
      ELSE
         IF pfichero1 IS NULL
            AND pfichero2 IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 102903);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 801280);   --No se ha encontrado nigun registro --BUg 9005-MCC-11/03/2009-Cambio de literal 1000611 por 102903*/
         END IF;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_SELEC_TODOS_RECIBOS';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_gestion_rec.f_selec_todos_recibos(psproimp, pitotalr);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300) := 'psproimp=' || psproimp;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTION_REC.F_DESSELEC_TODOS_RECIBOS';
      num            NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF psproimp IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RAISE e_param_error;
      END IF;

      num := pac_gestion_rec.f_desselec_todos_recibos(psproimp, pitotalr);

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
   END f_desselec_todos_recibos;

/*-----------------------------------------------------------------------*/
/* Gestión manual de recibos                                             */
/* Bug: 0007657: IAX - Gestión de recibos                                */
/* FAL                                              */
/*-----------------------------------------------------------------------*/
--BUG 10069 - 15/06/2009 - JTS
--BUG 11777 - 11/11/2009 - JRB - Se pasa el ctipban y cbancar para actualizarlo en el recibo.
/*******************************************************************************
    FUNCION F_COBRO_RECIBO
 Función que realiza el cobro para usuarios de central (cobro manual)
    param in pcempres : empres
    param in pnrecibo : recibo
    param in pfmovini : fecha de cobro
    param in pctipban : Tipo de cuenta.
    param in pcbancar : Cuenta bancaria.
    param in pccobban : cobrador bancario
    param in pdelega : delegación
    param in phost : 1.- Cobro por host y manual 0.- Solo cobro manual
    param out mensajes  : mensajes de error
    return: 0.- OK, 1.- KO
 ********************************************************************************/
   FUNCTION f_cobro_recibo(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER,
      pfmovini IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pccobban IN NUMBER,
      pdelega IN NUMBER,
      phost IN NUMBER,
      pctipcob IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vpcobrado      NUMBER;
      vpsinterf      NUMBER;
      vperror        VARCHAR2(2000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_cobro_recibo';
      vparam         VARCHAR2(1000)
         := 'parámetros - pcempres: ' || pcempres || ' - pnrecibo: ' || pnrecibo
            || ' - pfmovini: ' || pfmovini || ' - pctipban= ' || pctipban || ' - pcbancar= '
            || pcbancar || ' - pccobban: ' || pccobban || ' - pdelega: ' || pdelega
            || ' - phost: ' || phost || ' - pctipcob: ' || pctipcob;
      vpasexec       NUMBER := 1;
      vterminal      VARCHAR2(50);
      vsmovrec       NUMBER;
   BEGIN
      IF (pcempres IS NULL
          OR pnrecibo IS NULL
          OR pfmovini IS NULL
          OR(pccobban IS NULL
             AND pdelega IS NULL)   --BUG 10529 - JTS - 29/10/2009
          OR phost IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_cobro_recibo(pcempres, pnrecibo, pfmovini, pctipban, pcbancar,
                                            pccobban, pdelega, pctipcob);

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RAISE e_object_error;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DETALLE_RECIBOS'), 0) = 1 THEN
         BEGIN
            SELECT MAX(smovrec)
              INTO vsmovrec
              FROM detmovrecibo
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               vsmovrec := NULL;
         END;

         err := pac_coda.f_ins_detmovrecibo(vsmovrec, NULL, pnrecibo, NULL, pfmovini, NULL,
                                            f_user, 0, 0, pcbancar, 1);
      END IF;

      IF phost = 1 THEN
         err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
         err := pac_gestion_rec.f_cobro_recibo_online(pcempres, pnrecibo, vterminal,
                                                      vpcobrado, vpsinterf, vperror,
                                                      pac_md_common.f_get_cxtusuario);

         IF err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vperror);
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_anula_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfanulac: ' || pfanulac
            || ' - pcmotanu: ' || pcmotanu;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pfanulac IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_anula_recibo(pnrecibo, pfanulac, pcmotanu);

      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         --         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_modifica_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pctipban: ' || pctipban
            || ' - pcbancar: ' || pcbancar || ' - pcgescob: ' || pcgescob || ' - pcestimp: '
            || pcestimp || ' pccobban : ' || pccobban || ' pncuotar: ' || pncuotar
            || ' pcaccpre: ' || pcaccpre || ' pcaccret: ' || pcaccret || ' ptobserv: '
            || ptobserv
			--AAC_INI-CONF_OUTSOURCING-20160906
			|| ' pcgescar: ' || pcgescar;
			--AAC_FI-CONF_OUTSOURCING-20160906
      vpasexec       NUMBER(5) := 1;
      vspertom       NUMBER;
      vctipban       NUMBER;
   BEGIN
      IF (pnrecibo IS NULL
          OR pcgescob IS NULL
          OR pcestimp IS NULL) THEN
         RAISE e_param_error;
      END IF;

      -- Bug 20012/96897 - 11/11/2011 - AMC
      IF pctipban IS NULL
         AND pcbancar IS NOT NULL THEN
         err := pac_gestion_rec.f_get_tomrecibo(pnrecibo, vspertom);

         IF err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vctipban := pac_md_listvalores.f_gettipban(vspertom, pcbancar, mensajes);
      END IF;

      -- Fi Bug 20012/96897 - 11/11/2011 - AMC

      err := pac_gestion_rec.f_modifica_recibo(pnrecibo, NVL(pctipban, vctipban), pcbancar,
                                               pcgescob, pcestimp, pccobban, pncuotar,
                                               pcaccpre, pcaccret, ptobserv, pctipcob,
											--AAC_INI-CONF_OUTSOURCING-20160906
											   pcgescar);
											--AAC_FI-CONF_OUTSOURCING-20160906
      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --Si el estado de impresion es impreso y el tipo de pago es domiciliacion, se añade un aviso
      --Lo haremos por avisos
      /*IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'AVISO_DOMREC'), 0) =
                                                                                                    1 THEN
         IF pcestimp = 2
            AND pctipcob = 2 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904234);
         END IF;
      END IF;*/
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         --         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RETURN NULL;
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
   FUNCTION f_anulacion_pendiente(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_anulacion_pendiente';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_anulacion_pendiente(pnrecibo);

      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         --         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RETURN NULL;
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
   FUNCTION f_valida_cobro(
      pempresa IN NUMBER,
      pnrecibo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_valida_cobro';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pempresa: ' || pempresa;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF (pnrecibo IS NULL
          OR pempresa IS NULL) THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_valida_cobro(pempresa, pnrecibo);

      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         --         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RETURN NULL;
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
      mensajes IN OUT t_iax_mensajes,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_impago_recibo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfecha: ' || pfecha
            || ' - pccobban: ' || pccobban || ' - pcmotivo: ' || pcmotivo
            || ' - pcrecimp: ' || pcrecimp|| ' - pnpoliza: ' || pnpoliza;
      vpasexec       NUMBER(5) := 1;
      viimporte      NUMBER;
      vsmovrec       NUMBER;
      v_fecha        DATE;   --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto"
      e_error        EXCEPTION;
   BEGIN
      IF (pnrecibo IS NULL
                          /*OR pfecha IS NULL*/
         ) THEN   --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto"
         RAISE e_param_error;
      END IF;

      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
      IF pfecha IS NULL THEN
         SELECT fmovini
           INTO v_fecha
           FROM movrecibo m
          WHERE m.nrecibo = pnrecibo
            AND m.fmovfin IS NULL;

         IF f_sysdate >= v_fecha THEN
            v_fecha := f_sysdate;
         END IF;
      ELSE
         v_fecha := pfecha;
      END IF;

      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN

      -- 11. 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135 - Inicio
      -- Cambio de planes, ahora también se he de permitir el impago de recibos, cuando el parametro 'GESTIONA_COBPAG' = 1
      /*
              -- ini Bug 0017970 - 24/03/2011 - JMF
        SELECT NVL(MAX(110300), 0)
          INTO err
          FROM recibos
         WHERE nrecibo = pnrecibo
           AND NVL(pac_parametros.f_parempresa_n(cempres, 'GESTIONA_COBPAG'), 0) = 1;
      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;
      */
      -- 11. 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135 - Fin

      -- fin Bug 0017970 - 24/03/2011 - JMF
      err := pac_devolu.f_impaga_rebut(pnrecibo,
                                       --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
                                       --pfecha,
                                       v_fecha,
                                       --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
                                       pccobban, pcmotivo, pcrecimp, NULL, pnpoliza);

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
         RAISE e_error;
      END IF;
      -- INI SPV IAXIS-4516 Reversión de recaudos en recibos
     -- Se llama el proceso de reversion de recibo despues de descobrarlo
     --
    -- Inicio IAXIS-4926 23/10/2019 
    -- 
    -- Se comenta hasta que se defina la razón de dicho llamado pues, no tiene relación con el proceso que se debe hacer cuando hay un impago.
    --
    --p_reversa_recibo(pnrecibo);
    --
    -- Fin IAXIS-4926 23/10/2019 
    --
      -- FIN SPV IAXIS-4516 Reversión de recaudos en recibos
      IF NVL(pac_parametros.f_parempresa_n(pac_iax_common.f_get_cxtempresa, 'DETALLE_RECIBOS'),
             0) = 1 THEN
         SELECT itotalr
           INTO viimporte
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;

         SELECT MAX(smovrec)
           INTO vsmovrec
           FROM detmovrecibo
          WHERE nrecibo = pnrecibo;

         err := pac_coda.f_ins_detmovrecibo(vsmovrec, NULL, pnrecibo, viimporte * -1,
                                            --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
                                            --pfecha,
                                            v_fecha,
                                            --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
                                            NULL, f_user, 0, 0, 0, 1);
      END IF;

      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         --RETURN NULL;
         --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
         RETURN 1000006;
      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         --RETURN NULL;
         --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
         RETURN 1000006;
      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam);
         --RETURN NULL;
         --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
         RETURN 1000006;
      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam);
         --RETURN NULL;
         --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
         RETURN 9901299;
      --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         --RETURN NULL;
         --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
         RETURN 1000006;
   --15. MMM 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
   END f_impago_recibo;

      /*******************************************************************************
                           FUNCION f_get_anula_pend
   Función que recupera si un recibo está marcado como pendiente de anulación ó está desmarcado
      param in pnrecibo : recibo
      param out mensajes : mensajes de error
      return: number indicando si el recibo esta marcado como pendiente de anulación
   ********************************************************************************/
   FUNCTION f_get_anula_pend(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_md_gestion_rec.f_impago_recibo';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnrecibo: ' || pnrecibo;
   BEGIN
      IF (pnrecibo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      RETURN(pac_gestion_rec.f_get_anula_pend(pnrecibo));
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
      param out mensajes : t_iax_mensajes
      param in pavisos : Indica si se han de mostrar los avisos 1.- Sí 0.- No
      return: sysrefcursor con las posibles acciones a realizar
   ********************************************************************************/
   FUNCTION f_get_acciones(
      pnrecibo IN NUMBER,
      psaltar OUT NUMBER,
      pavisos IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros: pnrecibo=' || pnrecibo;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_get_acciones';
      recibo         ob_iax_recibos;
      err            NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      vcidioma       NUMBER;
      vcontador      NUMBER;
      usu_no_gestiona EXCEPTION;
      v_nrecunif     NUMBER := 0;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      recibo := ob_iax_recibos();
      recibo := pac_md_adm.f_get_datosrecibo(pnrecibo, 0, mensajes);
      err := pac_seguros.f_get_sproduc(recibo.sseguro, 'SEG', vsproduc);
      vcidioma := pac_md_common.f_get_cxtidioma;

      IF err <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      cur := pac_gestion_rec.f_get_acciones(pnrecibo, vsproduc, vcidioma,
                                            pac_md_common.f_get_cxtempresa,
                                            pac_md_common.f_get_cxtusuario, psaltar);

      --19028: AGA800 - Cobrament despeses de retorn
      -- Es controla si es un rebut unificat i s'avisa amb missatges.
      IF NVL(f_parproductos_v(vsproduc, 'RECUNIF'), 0) IN(1, 2, 3) THEN   --BUG 0019627: GIP102 - Reunificación de recibos - FAL - 10/11/2011
         BEGIN
            SELECT nrecunif
              INTO v_nrecunif
              FROM adm_recunif
             WHERE nrecibo = pnrecibo
                OR nrecunif = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               v_nrecunif := NULL;
         END;

         IF v_nrecunif IS NOT NULL THEN
            IF pnrecibo <> v_nrecunif THEN   --Si no estamos gestionando el recibo unificado no dejamos hacer nada
               cur := NULL;
            END IF;

            IF NVL(pavisos, 0) = 1 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9902277);   --Rebut amb altres rebuts associats. Es gestionaren conjuntament
            END IF;
         END IF;
      END IF;

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
      WHEN NO_DATA_FOUND THEN
         --         pac_iobj_mensajes.p_tratarmensaje(mensajes, NULL, err, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
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
      param in out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
      24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
   ********************************************************************************/
   FUNCTION f_get_saldo_inicial(
      pnrecibo IN NUMBER,
      pisaldo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_get_saldo_inicial';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_get_saldo_inicial(pnrecibo, pisaldo);
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
      param in pnrecibo_origen : recibo origen
      param in pnrecibo_destino : recibo destino
      param out pisaldo : importe total
      param in ptdescrip : descripción
      param in out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
      24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
   ********************************************************************************/
   FUNCTION f_transferir(
      pnrecibo_origen IN NUMBER,
      pnrecibo_destino IN NUMBER,
      pisaldo IN NUMBER,
      ptdescrip IN VARCHAR2,   --BUG 14302 - 28/04/2010 - LCF
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_TRANSFERIR';
      vparam         VARCHAR2(500)
         := 'parámetros - PNRECIBO_ORIGEN: ' || pnrecibo_origen || '- PNRECIBO_DESTINO: '
            || pnrecibo_destino || '- PISALDO : ' || pisaldo || '-PTDESCRIP' || ptdescrip;
      vpasexec       NUMBER(5) := 1;
      visaldo_inicial_origen NUMBER;
      visaldo_inicial_destino NUMBER;
      v_obrecibo_origen ob_iax_recibos;
      v_obrecibo_destino ob_iax_recibos;
      recestado      NUMBER;
      vtmsg          VARCHAR2(1000);
   BEGIN
      IF pnrecibo_origen IS NULL
         OR pnrecibo_destino IS NULL
         OR pisaldo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --se comprueba el estado de los recibos, si son nulos enviaremos un mensaje de error diciendo que el recibo no se
      --puede gestionar
      num_err := f_situarec(pnrecibo_origen, f_sysdate, recestado);
      vtmsg := pac_iobj_mensajes.f_get_descmensaje(9901116, pac_md_common.f_get_cxtidioma);

      IF recestado IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              vtmsg || ' : ' || pnrecibo_origen);
      END IF;

      num_err := f_situarec(pnrecibo_destino, f_sysdate, recestado);

      IF recestado IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                              vtmsg || ' : ' || pnrecibo_destino);
      END IF;

      -- isaldo del recibo origen
      num_err := pac_gestion_rec.f_get_saldo_inicial(pnrecibo_origen, visaldo_inicial_origen);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      -- isaldo del recibo destino
      num_err := pac_gestion_rec.f_get_saldo_inicial(pnrecibo_destino, visaldo_inicial_destino);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      -- datos del recibo origen
      v_obrecibo_origen := pac_md_adm.f_get_datosrecibo(pnrecibo_origen, 0, mensajes);
      -- datos del recibo destino
      v_obrecibo_destino := pac_md_adm.f_get_datosrecibo(pnrecibo_destino, 0, mensajes);
      --      p_control_error('xpl', 'itotalr', v_obrecibo_origen.importe);
      --      p_control_error('xpl', 'resta', visaldo_inicial_origen - pisaldo);
      num_err := f_situarec(pnrecibo_origen, f_sysdate, recestado);

      --Validaremos que itotalr del recibo  de origen sea >= al (visaldo_inicial_origen - pisaldo)
      IF (NVL(visaldo_inicial_origen - pisaldo, 0) < v_obrecibo_origen.importe)
         AND recestado <> 0 THEN
         --crearemos mensaje de error. No podemos impagar un recibo
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901059);
         RAISE e_object_error;
      END IF;

      --BUG 14302 - 28/04/2010 - LCF
      num_err := pac_gestion_rec.f_transferir(pnrecibo_origen, pnrecibo_destino, pisaldo,
                                              ptdescrip);

      --FI BUG 14302 - 28/04/2010 - LCF
      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Si hem sobrepassat l'import del rebut destí o igualat el cobrem
      IF (pisaldo + NVL(visaldo_inicial_destino, 0)) >= v_obrecibo_destino.importe THEN
         num_err := f_situarec(pnrecibo_destino, f_sysdate, recestado);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF recestado = 0 THEN   --rebut pendent
            num_err := pac_gestion_rec.f_cobro_recibo(pac_md_common.f_get_cxtempresa,
                                                      pnrecibo_destino, f_sysdate,
                                                      v_obrecibo_destino.ctipban,
                                                      v_obrecibo_destino.cbancar,
                                                      v_obrecibo_destino.ccobban,
                                                      v_obrecibo_destino.cdelega);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      RETURN num_err;
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
   END f_transferir;

   /*******************************************************************************
                                 FUNCION f_get_rebtom
   Función que se encarga de devolver los recibos del tomador en los ultimos 5 años
      param in sperson : seq. persona a buscar
      param out pipagado : importe de todos los recibos cobrados
      param out pipendiente : importe de todos los recibos pendientes
      param out pimpagados : importe de todos los recibos impagados
      param out precibos  : Cursos con los recibos a mostrar
      param in out mensajes  : mensajes de error
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_get_rebtom';
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vpasexec       NUMBER(5) := 1;
      vtmsg          VARCHAR2(1000);
      vquery         VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_get_rebtom(psperson, pac_md_common.f_get_cxtempresa,
                                          pac_md_common.f_get_cxtidioma, pipagado, pipendiente,
                                          pimpagado, pisaldo, vquery);

      IF err <> 0 THEN
         RAISE e_object_error;
      END IF;

      precibos := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   FUNCTION f_rehabilita_rec(
      pnrecibo IN NUMBER,
      pfrehabi IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_REHABILITA_REC';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pfrehabi: ' || pfrehabi;
      vpasexec       NUMBER(5) := 1;
      v_fmovimi      DATE;
   BEGIN
      IF (pnrecibo IS NULL
          OR pfrehabi IS NULL) THEN
         RAISE e_param_error;
      END IF;

      SELECT fmovini
        INTO v_fmovimi
        FROM movrecibo
       WHERE cestrec = 2
         AND fmovfin IS NULL
         AND nrecibo = pnrecibo;

      IF (pfrehabi < v_fmovimi) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906265);
         err := 1;
      ELSE
         err := pac_gestion_rec.f_rehabilita_rec(pnrecibo, pfrehabi);

         IF err <> 0 THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_MODIFICA_ACCPRECONOCIDA';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pcaccpre: ' || pcaccpre;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      err := pac_gestion_rec.f_modifica_accpreconocida(pnrecibo, pcaccpre);

      IF err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_modifica_accpreconocida;

   -- BUG23853:DRA:25/10/2012:Inici
   FUNCTION f_genrec_primin_col(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,
      pfvencim IN DATE,
      piimprec IN NUMBER,
      pnrecibo IN OUT NUMBER,
      pmodo IN VARCHAR2,
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_GENREC_PRIMIN_COL';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi
            || ' - pctiprec: ' || pctiprec || ', pfemisio: ' || pfemisio || ', pfefecto: '
            || pfefecto || ', pfvencim: ' || pfvencim || ' - pnrecibo: ' || pnrecibo
            || ' - pmodo: ' || pmodo || ' - psproces: ' || psproces || ' - ptablas: '
            || ptablas;
      vpasexec       NUMBER(5) := 1;
      v_sproces      NUMBER;
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF psproces IS NULL THEN
         vnumerr := f_procesini(pac_md_common.f_get_cxtusuario,
                                pac_md_common.f_get_cxtempresa,
                                'GENERAR RECIBO PRIMA MINIMA COLECTIVO',
                                f_axis_literales(9902189, pac_md_common.f_get_cxtidioma),
                                v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_gestion_rec.f_genrec_primin_col(psseguro, pnmovimi, pctiprec, pfemisio,
                                                     pfefecto, pfvencim, piimprec, pnrecibo,
                                                     pmodo, v_sproces, ptablas);

      IF vnumerr <> 0 THEN
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_genrec_primin_col;

   FUNCTION f_desctiprec(pnrecibo IN NUMBER, pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_DESCTIPREC';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnrecibo: ' || pnrecibo || ' - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := NULL;
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_texto := pac_gestion_rec.f_desctiprec(pnrecibo, pcidioma);
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

   -- BUG23853:DRA:25/10/2012:Fi
   -- BUG24854 :ETM: 27/12/2012 : Inici
   FUNCTION f_sincroniza_sap(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_sincroniza_sap';
      vparam         VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := NULL;
      v_propio       VARCHAR2(500);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      ss             VARCHAR2(3000);
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT pac_parametros.f_parempresa_t(pac_iax_common.f_get_cxtempresa, 'PAC_PROPIO')
        INTO v_propio
        FROM DUAL;

      vpasexec := 3;
      ss := 'BEGIN ' || v_propio || '.' || 'p_actualizar_pagos_recibos(' || 4 || ','
            || pnrecibo || ')' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vpasexec := 4;
      v_cursor := DBMS_SQL.open_cursor;
      vpasexec := 5;
      DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_sincroniza_sap;

--fIN  BUG24854 :ETM:27/12/2012:

   -- JLB - I 23074
   FUNCTION f_genrec_gastos_expedicion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,
      pfvencim IN DATE,
      piimprec IN NUMBER,
      pnrecibo IN OUT NUMBER,
      pmodo IN VARCHAR2,
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_GENREC_GASTOS_EXPEDICION';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi
            || ' - pctiprec: ' || pctiprec || ', pfemisio: ' || pfemisio || ', pfefecto: '
            || pfefecto || ', pfvencim: ' || pfvencim || ' - pnrecibo: ' || pnrecibo
            || ' - pmodo: ' || pmodo || ' - psproces: ' || psproces || ' - ptablas: '
            || ptablas;
      vpasexec       NUMBER(5) := 1;
      v_sproces      NUMBER;
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF psproces IS NULL THEN
         -- Bug 29665/163095 - 14/01/2014 - AMC
         vnumerr := f_procesini(pac_md_common.f_get_cxtusuario,
                                pac_md_common.f_get_cxtempresa, 'GEN REC GATOS EXPED',   --'GENERAR RECIBO GATOS EXPEDICION'
                                f_axis_literales(9902189, pac_md_common.f_get_cxtidioma),
                                v_sproces);
      -- Fi Bug 29665/163095 - 14/01/2014 - AMC
      ELSE
         v_sproces := psproces;
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_gestion_rec.f_genrec_gastos_expedicion(psseguro, pnmovimi, pctiprec,
                                                            pfemisio, pfefecto, pfvencim,
                                                            piimprec, pnrecibo, pmodo,
                                                            v_sproces, ptablas);

      IF vnumerr <> 0 THEN
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_genrec_gastos_expedicion;

-- BUG 29009 -- ETM -- 25/11/2013 -- INI
   FUNCTION f_recman_pens(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pimporte IN NUMBER,
      pctipcob IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      err            NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.F_RECMAN_PENS';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ',pnmovimi:=' || pnmovimi
            || ',pctiprec:=' || pctiprec || ',pimporte:=' || pimporte || ',pctipcob:='
            || pctipcob;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      err := pac_gestion_rec.f_recman_pens(psseguro, pnmovimi, pctiprec, pimporte, pctipcob);

      IF err <> 0 THEN
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, err);   --etm nuevo mensaje no se puede insertar el apunte
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906313);
      END IF;

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
   END f_recman_pens;

-- FIN  BUG 29009 -- ETM -- 25/11/2013

   -- INI  BUG 29603 -- JDS -- 21/01/2014
/*******************************************************************************
FUNCION f_desctippag
Función que devolverá el literal del pagador del recibo.
param in pnrecibo
param in pcidioma
********************************************************************************/
   FUNCTION f_desctippag(pnrecibo IN NUMBER, pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_desctippag';
      vparam         VARCHAR2(500)
                         := 'parámetros - pnrecibo: ' || pnrecibo || ',pcidioma:=' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      v_texto        VARCHAR2(500) := '';
   BEGIN
      v_texto := pac_gestion_rec.f_desctippag(pnrecibo, pcidioma);
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

-- FIN  BUG 29603 -- JDS -- 21/01/2014

   -- 19.0 - 02/06/2014 - MMM -0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio

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
      vobject        VARCHAR2(500) := 'pac_md_gestion_rec.f_get_dias_gracia_agente_prod';
      vparam         VARCHAR2(550) := 'pccagente:' || pcagente || ' psproduc:' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      cur            sys_refcursor;
   BEGIN
      mensajes := t_iax_mensajes();
      cur := pac_gestion_rec.f_get_lista_dias_gracia(pcagente, psproduc);
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
      vobject        VARCHAR2(500) := 'pac_md_gestion_rec.f_set_dias_gracia_agente_prod';
      vparam         VARCHAR2(550)
         := 'pcagente:' || pcagente || ' psproduc:' || psproduc || ' pfini:' || pfini
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

      vnumerr := pac_gestion_rec.f_set_dias_gracia_agente_prod(pcagente, psproduc, pfini,
                                                               pdias);

      IF vnumerr = 1 THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr > 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_del_dtosespeciales';
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

      vnumerr := pac_gestion_rec.f_del_dias_gracia_agente_prod(pcagente, psproduc, pfini);

      IF vnumerr = 1 THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr > 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_dias_gracia_agente_prod;
-- 19.0 - 02/06/2014 - MMM -0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Fin

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
          pntomador VARCHAR2,
		  abrecibo IN NUMBER,
          soferta     IN     NUMBER,
          pcmodif     IN     NUMBER,
          ppdlegal    IN     NUMBER,
          ppjudi      IN     NUMBER,
          ppgunica    IN     NUMBER,
          ppestatal   IN     NUMBER,
          cur OUT sys_refcursor,
          mensajes IN OUT t_iax_mensajes)
     RETURN NUMBER
IS
  --IAXIS-3592 -- ECP--05/06/2019
     vsquery VARCHAR2(20000);
     --IAXIS-3592 -- ECP--05/06/2019
     vnumerr NUMBER:=0;
     vparam  VARCHAR2 (500) := 'parámetros - pcempres: ' || pcempres || ', pcramo: ' || pcramo ||
     ', psproduc: ' || psproduc || ', pcagente: ' || pcagente || ', pncertif: ' || pncertif ||
     ', pnrecibo: ' || pnrecibo || ', psucur: ' || psucur || ', pidtomador: ' || pidtomador || ', pntomador: ' || pntomador ||
	 ', abrecibo: ' || abrecibo || ', soferta: ' || soferta || ', pcmodif: ' || pcmodif || ', ppdlegal: ' || ppdlegal ||
	 ', ppjudi: ' || ppjudi || ', ppgunica: ' || ppgunica || ', ppestatal: ' || ppestatal;


     vobject  VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_get_anula_x_no_pago';
     vpasexec NUMBER := 10;
BEGIN
     vpasexec:=20;
     vnumerr := pac_gestion_rec.f_get_anula_x_no_pago(pcempres,pcramo,psproduc,pcagente,pnpoliza,
     pncertif,psucur,pnrecibo,pidtomador,pntomador,abrecibo,soferta,pcmodif,ppdlegal,ppjudi,ppgunica,ppestatal,vsquery);
     IF vnumerr <> 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          RAISE e_object_error;
     END IF;
     vpasexec := 30;
     cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
     vpasexec := 40;
     RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
END f_get_anula_x_no_pago;
FUNCTION f_set_anula_x_no_pago(
          pnrecibo IN NUMBER,
          pccheck  IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
     RETURN NUMBER
IS
     vnumerr  NUMBER := 0;
     vpasexec NUMBER := 1;
     vobject  VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_set_anula_x_no_pago';
     vparam   VARCHAR2 (500) := 'parámetros - pnrecibo: ' || pnrecibo || ', pccheck: ' || pccheck;
BEGIN
     IF pnrecibo IS NULL OR pccheck IS NULL THEN
          vpasexec := 2;
          RAISE e_param_error;
     END IF;
     vpasexec := 3;
     vnumerr := pac_gestion_rec.f_set_anula_x_no_pago(pnrecibo, pccheck);
     vpasexec := 4;
     IF vnumerr <> 0 THEN
          vpasexec := 5;
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          vpasexec := 6;
          RAISE e_object_error;
          ELSE
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9908875);
     END IF;
     vpasexec := 7;
     COMMIT;
     vpasexec := 8;
     RETURN(vnumerr);
EXCEPTION
WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, f_axis_literales(9000642,
     pac_md_common.f_get_cxtidioma), 9001768, vpasexec, vparam);
     RETURN 1;
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
     ROLLBACK;
     RETURN 1;
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     ROLLBACK;
     RETURN 1;
END f_set_anula_x_no_pago;
--
--Inicio IAXIS-3651 04/06/2019
--
/*******************************************************************************
FUNCION f_get_liquidacion
Función que obtiene los recibos a liquidar para un outsourcing especificado.
param in pnumide -> Número de identificación
param in pnombre -> Nombre
param in pfefecto -> Fecha de efecto
param in pcagente -> Agente
********************************************************************************/
FUNCTION f_get_liquidacion(
  pnumidetom IN VARCHAR2,
  pcestgest IN NUMBER,
  pfefeini IN DATE,
  pfefefin IN DATE,
  pcagente IN NUMBER,
    pnrecibo IN NUMBER,
  pctipoper IN NUMBER,
  mensajes OUT t_iax_mensajes)
  RETURN sys_refcursor
IS
  vcursor sys_refcursor;
  vnumerr NUMBER:=0;
  vsquery VARCHAR2(9000);
  vparam   VARCHAR2 (500) := 'parámetros - pnumidetom: ' || pnumidetom || ', pcestgest: ' || pcestgest ||
  ', pfefeini: ' || pfefeini || ', pcagente: ' || pcagente || ', pfefefin: ' || pfefefin || ', pnrecibo: ' || pnrecibo
  || ', pctipoper: ' || pctipoper;
  vobject  VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_get_liquidacion';
  vpasexec NUMBER := 10;
  
BEGIN
  --
  vsquery := pac_gestion_rec.f_get_liquidacion(pnumidetom,pcestgest,pfefeini,pfefefin,pcagente,pnrecibo,pctipoper, mensajes);
  --
  vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

   IF pac_md_log.f_log_consultas(vsquery,
                                 'pac_md_gestion_rec.f_get_liquidacion',
                                 1, 4, mensajes) <> 0
   THEN
      IF vcursor%ISOPEN
      THEN
         CLOSE vcursor;
      END IF;
   END IF;

   RETURN vcursor;
   vpasexec := 30;
  --     
EXCEPTION
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
     IF vcursor%ISOPEN THEN
       CLOSE vcursor;
     END IF;
  RETURN vcursor;
WHEN OTHERS THEN
  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
  SQLCODE, psqerrm => SQLERRM);
  IF vcursor%ISOPEN THEN
    CLOSE vcursor;
  END IF;
  RETURN vcursor;
END f_get_liquidacion;
--
--Fin IAXIS-3651 04/06/2019
--
END pac_md_gestion_rec;

/