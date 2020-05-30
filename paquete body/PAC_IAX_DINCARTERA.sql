--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DINCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DINCARTERA" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_DINCARTERA
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        03/12/2008                 1. Creación del package.
      1.1        16/12/2008
      1.2        18/12/2008     xpl         2. Estandarització
      2.0        24/04/2009     RSC                2. Suplemento de cambio de forma de pago diferido
      3.0        04/07/2013     ECP         3. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII). Nota 148366
   ******************************************************************************/

   /*******************************************************************************
   FUNCION F_GET_PRODCARTERA
   Función que inserta los productos seleccionados para pasar la cartera en el proceso.
    Parámetros:
     Entrada :
       Pcempres   NUMBER : Identificador empresa
       Pcramo     NUMBER : Id. ramo
       Psproduc   NUMBER : Id. producto
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: Ref Cursor.
   ********************************************************************************/
   FUNCTION f_get_prodcartera(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprocar IN NUMBER,
      --Ini Bug 27539 --ECP--04/07/2013
      pmodo IN VARCHAR,
      --Fin Bug 27539 --ECP--04/07/2013
      pcurprcar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres || ' pcramo=' || pcramo;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_GET_PRODCARTERA';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF pcempres IS NULL THEN
         --OR pcramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*
       Deberá realizar una llamada a la función de la capa md pac_md_dincartera.f_get_prodcartera que nos retornará aquellos productos
       que pueden pasar  cartera (están en la tabla prodcartera) para la empresa y ramo informados por parámetro. En el caso de que
       ningún parámetro esté informado deberá retornarlos todos.
      */
      vnumerr := pac_md_dincartera.f_get_prodcartera(pcempres, pcramo, psproduc, psprocar,

                                                     --Ini Bug 27539 --ECP--04/07/2013
                                                     pmodo,
                                                     --Fin Bug 27539 --ECP--04/07/2013
                                                     pcurprcar, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      -- Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
   END f_get_prodcartera;

   /*******************************************************************************
   FUNCION F_SET_PRODCARTERA
   Función que inserta los productos seleccionados para pasar la cartera en el proceso.
    Parámetros:
     Entrada :
       Pcempres   NUMBER : Identificador empresa
       Psprocar   NUMBER : Id. proceso
       Psproduc   NUMBER : Id. producto
       Pseleccio  NUMBER : Valor seleccionado
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_prodcartera(
      pcempres IN NUMBER,
      psprocar IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psprocar=' || psprocar || ' psproduc=' || psproduc
            || ' pseleccio=' || pseleccio;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_SET_PRODCARTERA';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psprocar IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* Deberá realizar una llamada a la función de la capa md pac_md_dincartera.f_set_prodcartera que insertará en la tabla de productos a pasar
       cartera tmp_carteraux.
      */
      vnumerr := pac_md_dincartera.f_set_prodcartera(pcempres, psprocar, psproduc, pseleccio,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_set_prodcartera;

   /*******************************************************************************
   FUNCION F_GET_MES_CARTERA
   Función que inserta los productos seleccionados para pasar la cartera en el proceso.
    Parámetros:
     Entrada :
       Pnpoliza   NUMBER : Numero de poliza
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna:  Ref_Cursor.
   ********************************************************************************/
   FUNCTION f_get_mes_cartera(
      pnpoliza IN NUMBER,
      pcempres IN NUMBER,
      pcmodo IN VARCHAR2,
      pcurmescar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pnpoliza=' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_GET_MES_CARTERA';
      vsquery        VARCHAR2(2000);
      vnumerr        NUMBER := 0;
   BEGIN
      --Deberá llamar a la función de la capa MD, pac_md_dicartera.f_get_mes_cartera. Esta función nos devolverá los meses de las próximas carteras .
      vnumerr :=
         pac_md_dincartera.f_get_mes_cartera(pnpoliza, pcempres, pcmodo, pcurmescar, mensajes,
                                             psprocar   -- Bug 29952/169064 - 11/03/2014 - AMC
                                                     );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
   END f_get_mes_cartera;

   /*******************************************************************************
   FUNCION F_GET_ANYO_CARTERA
   Esta función nos devolverá el año de la próxima cartera
    Parámetros:
     Entrada :
       Pnpoliza   NUMBER   : Numero de poliza
       Pnmes      NUMBER   : Mes
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: NUMBER.
   ********************************************************************************/
   FUNCTION f_get_anyo_cartera(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnmes IN NUMBER,
      pnanyo OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Pnpoliza=' || pnpoliza || ' Pnmes=' || pnmes;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_GET_ANYO CARTERA';
      vnumerr        NUMBER;
   BEGIN
      -- Control parametros entrada
      IF pnmes IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Deberá llamar a la función de la capa MD, pac_md_dincartera.f_get_anyo_cartera. Esta función nos devolverá el año de la próxima cartera.
      vnumerr := pac_md_dincartera.f_get_anyo_cartera(pcempres, pnpoliza, pnmes, pnanyo,
                                                      mensajes, psprocar);   -- Bug 29952/169064 - 11/03/2014 - AMC

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Retorna : un NUMBER.
      RETURN vnumerr;
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
         RETURN 1;
   END f_get_anyo_cartera;

   /*******************************************************************************
   FUNCION F_GET_PROCESO
   Esta función nos devolverá el código de proceso temporal para el previo o cartera
    Parámetros:
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: NUMBER.
   ********************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_GET_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_common.f_get_proceso(psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Retorna :  un NUMBER.
      RETURN vnumerr;
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
         RETURN 1;
   END f_get_proceso;

   /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función nos devolverá el código de proceso real para el previo o cartera.
    Parámetros:
     Entrada :
       Pmodo    NUMBER  : Modo ejecucion
       Pfperini NUMBER  : Fecha Inicio
       Pcempres NUMBER  : Empresa
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el número de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pmodo IN VARCHAR2,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcempres IN NUMBER,
      pfcartera IN DATE,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pmodo=' || pmodo || ' pmes=' || pmes || ' panyo = ' || panyo || 'pcempres='
            || pcempres || ' pfcartera = ' || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF pmodo IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*Deberá llamar a la función de la capa MD, pac_md_dincartera.f_registra_proceso.
      Esta función nos devolverá el código de proceso real para el previo o cartera.
      Este proceso solo se obtendrá en el momento lanzar el previo de cartera o cartera.
      */
      vnumerr := pac_md_dincartera.f_registra_proceso(pmodo, pmes, panyo, pcempres, pfcartera,
                                                      pnproceso, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      --Retorna : un NUMBER.
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_registra_proceso;

   /*******************************************************************************
   FUNCION F_LANZA_PREVIO
   Deberá llamar a la función de la capa MD, pac_md_dincartera.f_lanza_previo.
   Parámetros
     Entrada :
      psproces   NUMBER : Id. proceso
      pcempres   NUMBER : Id. empresa
      pmes       NUMBER : Mes
      panyo      NUMBER : Año
      pnpoliza   NUMBER : Numero de poliza
      pncertif   NUMBER : Numero de certificado
      Psprocar   NUMBER
      prenuevan  NUMBER
     Salida :
     Mensajes   T_IAX_MENSAJES

   Retorna : NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_lanza_previo(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      prenuevan IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pmes=' || pmes
            || ' panyo=' || panyo || ' pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
            || ' Psprocar=' || psprocar || ' prenuevan=' || prenuevan || ' pfcartera='
            || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_LANZA_PREVIO';
      vnumerr        NUMBER;
   BEGIN
      -- Control parametros entrada
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_dincartera.f_lanza_previcartera(psproces, pcempres, pmes, panyo,
                                                        pnpoliza, pncertif, psprocar,
                                                        prenuevan, pfcartera, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_previo;

   /*******************************************************************************
   FUNCION F_LANZA_CARTERA
   Deberá llamar a la función de la capa MD, pac_md_dincartera.f_lanza_cartera.
   Parámetros
     Entrada :
      psproces   NUMBER : Id. proceso
      pcempres   NUMBER : Id. empresa
      pmes       NUMBER : Mes
      panyo      NUMBER : Año
      pnpoliza   NUMBER : Numero de poliza
      pncertif   NUMBER : Numero de certificado
      psprocar   NUMBER
     Salida:
      Mensajes   T_IAX_MENSAJES

   Retorna : NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_lanza_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pmes=' || pmes
            || ' panyo=' || panyo || ' pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
            || ' Psprocar=' || psprocar;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_LANZA_CARTERA';
      vnumerr        NUMBER;
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Deberá llamar a la función de la capa MD, pac_md_dincartera.f_lanza_cartera.
      vnumerr := pac_md_dincartera.f_lanza_cartera(psproces, pcempres, pmes, panyo, pnpoliza,
                                                   pncertif, psprocar, pfcartera, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      -- Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_cartera;

   /*******************************************************************************
   FUNCION F_LANZA_CARTERA
   Deberá llamar a la función de la capa MD, pac_md_dincartera.f_listado_cartera.
   Parametros.
     Entrada :
      report   VARCHAR2 : Id. del report
      pcempres NUMBER   : Id. empresa
      pselprod VARCHAR2 : Producto seleccionado
      psproces NUMBER   : Id. proceso
      pmes     NUMBER   : Mes
      panyo    NUMBER   : Año
      psprocar NUMBER   : Id.
     Salida :
      Mensajes  T_IAX_MENSAJES
   Retorna : un varchar2 con la cadena de ejecución del report.
   ********************************************************************************/
   FUNCTION f_listado_cartera(
      report IN VARCHAR2,
      pcempres IN NUMBER,
      pselprod IN VARCHAR2,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      psprocar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
         := 'Report=' || report || ' pcempres=' || pcempres || ' Pselprod=' || pselprod
            || ' panyo=' || panyo || ' pmes=' || pmes || ' Psproces=' || psproces
            || ' Psprocar=' || psprocar;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_LISTADO_CARTERA';
      nom            VARCHAR2(255);
      pcidioma       NUMBER;
   BEGIN
      mensajes := t_iax_mensajes();
      pcidioma := pac_md_common.f_get_cxtidioma;

      -- Control parametros entrada
      IF report IS NULL
         OR pselprod IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL
         OR pmes IS NULL
         OR panyo IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RETURN 140974;   --Faltan parametros por informar
      END IF;

      --Deberá llamar a la función de la capa MD, pac_md_dincartera.f_listado_cartera.
      nom := pac_md_dincartera.f_listado_cartera(report, pcempres, pselprod, psproces, pmes,
                                                 panyo, psprocar, mensajes);
      RETURN nom;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      -- Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y el código del proceso.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_listado_cartera;

   /*******************************************************************************
    FUNCION f_eval_genera_diferidos
    Nos indicará si debe o no generarse el MAP de información de pólizas que sufrirán
    un suplemento automático o un suplemento diferido en la cartera indicada por
    parámetro.

    Parámetros:
       pcempres NUMBER: Código de empresa seleccionada en pantalla de previo de cartera.
       psproces NUMBER: Identificador de proceso.
       pgeneramap NUMBER: 0 (no genera map) o 1 (si genera map)
     Salida :
       Mensajes   T_IAX_MENSAJES
    Retorna: NUMBER.
   ********************************************************************************/
   -- Bug 9905 - 21/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_genera_diferidos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pgeneramap OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_eval_genera_diferidos';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_dincartera.f_eval_genera_diferidos(pcempres, psproces, pgeneramap,
                                                           mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Retorna :  un NUMBER.
      RETURN vnumerr;
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
         RETURN 1;
   END f_eval_genera_diferidos;

-- Fin Bug 9905

   /*************************************************************************
      Devuelve las polizas que cumplan con el criterio de seleccion
      param in psproduc     : codigo de producto
      param in pnpoliza     : numero de poliza
      param in pncert       : numero de cerificado por defecto 0
      param in pnnumide     : numero identidad persona
      param in psnip        : numero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param in p_filtroprod : Tipo de productos requeridos:
                              'TF'         ---> Contratables des de Front-Office
                              'REEMB'      ---> Productos de salud
                              'APOR_EXTRA' ---> Con aportaciones extra
                              'SIMUL'      ---> Que puedan tener simulacion
                              'RESCA'      ---> Que puedan tener rescates
                              'SINIS'      ---> Que puedan tener siniestros
                              null         ---> Todos los productos
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_consulta_gestrenova(
      pramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncert IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      pnsolici IN NUMBER,
      ptipopersona IN NUMBER,
      pcagente IN NUMBER,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptdomici IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      pcsituac IN NUMBER,
      p_filtroprod IN VARCHAR2,
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pcestsupl IN NUMBER,
      pnpolini IN VARCHAR2,
      pfilage IN NUMBER,
      pfvencimini IN DATE,
      pfvencimfin IN DATE,
      psucurofi IN VARCHAR2,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pnpoliza: ' || pnpoliza || ' pncert=' || pncert
            || ' pnnumide=' || pnnumide || ' psnip=' || psnip || ' pbuscar=' || pbuscar
            || ' ptipopersona=' || ptipopersona || ' pnsolici=' || pnsolici
            || ' p_filtroprod=' || p_filtroprod || ' pcpolcia=' || pcpolcia || ' pccompani= '
            || pccompani || ' pcactivi=' || pcactivi || ' pcestsupl=' || pcestsupl
            || ',pnpolini = ' || pnpolini;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_Consulta_gestrenova';
   BEGIN
      cur := pac_md_dincartera.f_consulta_gestrenova(pramo, psproduc, pnpoliza, pncert,
                                                     pnnumide, psnip, pbuscar, pnsolici,
                                                     ptipopersona, pcagente, pcmatric,
                                                     pcpostal, ptdomici, ptnatrie, pcsituac,
                                                     p_filtroprod, pcpolcia, pccompani,
                                                     pcactivi, pcestsupl, pnpolini, pfilage,
                                                     pfvencimini, pfvencimfin, psucurofi,
                                                     pmodo, mensajes);
      RETURN cur;
   EXCEPTION
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

         RETURN cur;
   END f_consulta_gestrenova;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_act_cbloqueocol(
      psseguro IN NUMBER,
      pcbloqueocol IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'psseguro=' || psseguro || ' pcbloqueocol: ' || pcbloqueocol;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_act_cbloqueocol';
   BEGIN
      vnumerr := pac_md_dincartera.f_act_cbloqueocol(psseguro, pcbloqueocol, mensajes);
      COMMIT;
      RETURN vnumerr;
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
   END f_act_cbloqueocol;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_suplemento_renovacion(
      psseguro IN NUMBER,
      otexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_suplemento_renovacion';
   BEGIN
      num_err := pac_md_dincartera.f_suplemento_renovacion(psseguro, otexto, mensajes);

      IF num_err <> 0 THEN
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
   END f_suplemento_renovacion;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_botones_gestrenova(
      psseguro IN NUMBER,
      opermiteemitir OUT NUMBER,
      opermitepropret OUT NUMBER,
      opermitesuplemento OUT NUMBER,
      opermiterenovar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_botones_gestrenova';
   BEGIN
      num_err := pac_md_dincartera.f_botones_gestrenova(psseguro, opermiteemitir,
                                                        opermitepropret, opermitesuplemento,
                                                        opermiterenovar, mensajes);

      IF num_err <> 0 THEN
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
   END f_botones_gestrenova;

   FUNCTION f_get_carteradiaria_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_get_carteradiaria_poliza';
   BEGIN
      vresult := pac_md_dincartera.f_get_carteradiaria_poliza(pnpoliza, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteradiaria_poliza;

   FUNCTION f_get_carteraprog_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_get_carteraprog_poliza';
   BEGIN
      vresult := pac_md_dincartera.f_get_carteraprog_poliza(pnpoliza, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteraprog_poliza;

   FUNCTION f_get_carteradiaria_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_get_carteradiaria_producto';
   BEGIN
      vresult := pac_mdpar_productos.f_get_parproducto('CARTERA_DIARIA', psproduc);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteradiaria_producto;

   FUNCTION f_get_carteraprog_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_get_carteraprog_producto';
   BEGIN
      vresult := pac_mdpar_productos.f_get_parproducto('CARTERA_PROGRAMADA', psproduc);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteraprog_producto;

   FUNCTION f_programar_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pproductos IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfejecucion IN DATE,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pmes=' || pmes
            || ' panyo=' || panyo || ' pproductos=' || pproductos || ' psprocar=' || psprocar
            || ' pfejecucion=' || pfejecucion || ' pfcartera=' || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.F_PROGRAMAR_CARTERA';
      vnumerr        NUMBER;
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         --OR pproductos IS NULL
         OR pcempres IS NULL
         -- OR pmes IS NULL
          --OR panyo IS NULL
         OR pfejecucion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_dincartera.f_programar_cartera(psproces, pmodo, pcempres, pmes, panyo,
                                                       pproductos, pnpoliza, pncertif,
                                                       psprocar, pfejecucion, pfcartera,
                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_programar_cartera;

   FUNCTION f_lanza_cartera_cero(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pnpoliza=' || pnpoliza || ' pncertif=' || pncertif;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_lanza_cartera_cero';
      vnumerr        NUMBER;
      vpcempres      NUMBER;
   BEGIN
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpcempres := pac_md_common.f_get_cxtempresa;
      vnumerr := pac_md_dincartera.f_lanza_cartera_cero(vpcempres, pnpoliza, pncertif,
                                                        psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_cartera_cero;

   FUNCTION f_retroceder_cartera_cero(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_retroceder_cartera_cero';
      vnumerr        NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_dincartera.f_retroceder_cartera_cero(psseguro, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_retroceder_cartera_cero;

      /*********************************************************************************************************
       Funcio que realitza les validacions per a la renovació de la cartera.


         psproces  NUMBER,
         pcempres  NUMBER,
         pmes      NUMBER,
         panyo     NUMBER,
         pnpoliza  NUMBER,
         pncertif  NUMBER,
         psprocar  NUMBER,
         pfcartera DATE,
         mensajes  t_iax_mensajes
   *********************************************************************************************************/
   FUNCTION f_validacion_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER;
      vobject        VARCHAR2(500) := 'PAC_IAX_CARTERA.f_validacion_cartera';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(1000)
         := 'psproces:' || psproces || 'pcempres:' || pcempres || 'pmes:' || pmes || 'panyo:'
            || panyo || 'pnpoliza:' || pnpoliza || 'pncertif:' || pncertif || 'psprocar:'
            || psprocar;
   BEGIN
      RETURN 0;

      IF pnpoliza IS NOT NULL THEN
         IF psproces IS NULL
            OR psprocar IS NULL
            OR pmes IS NULL
            OR panyo IS NULL THEN
            RAISE e_param_error;
         END IF;

         numerr := pac_md_dincartera.f_validacion_cartera(psproces, pcempres, pmes, panyo,
                                                          pnpoliza, pncertif, psprocar,
                                                          pfcartera, mensajes);
         RETURN numerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validacion_cartera;
END pac_iax_dincartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "CONF_DWH";
