--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DOMICILIACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DOMICILIACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_DOMICILIACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/02/2009   XCG                1. Creación del package.
   2.0        27/08/2010   FAL                2. 0015750: CRE998 - Modificacions mòdul domiciliacions
   3.0        19/07/2011   JMP                3. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
   4.0        03/04/2012   JGR                4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
 ******************************************************************************/
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente IN NUMBER,
      ptagente IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pttomador IN VARCHAR2,
      pnrecibo IN NUMBER,
      --FI BUG 23645
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nommap2 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nomdr OUT VARCHAR2,   --Path Completo Fichero de DR,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vnok           NUMBER;
      vnko           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc=' || psproduc
            || ' pccobban=' || pccobban;
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_DOMICILIAR';
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA  FUNCIÓN
      vnumerr :=
         pac_md_domiciliaciones.f_domiciliar
                                      (psproces, pcempres, pfefecto, pffeccob, pcramo,
                                       psproduc, psprodom, pccobban, pcbanco, pctipcta,
                                       pfvtotar, pcreferen, pdfefecto, pcagente, ptagente,
                                       pnnumide, pttomador, pnrecibo, vnok, vnko, sproces,   -- Bug 15750 - FAL - 27/08/2010. Añade psprodom
                                       nommap1, nommap2, nomdr, mensajes);

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
   END f_domiciliar;

   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010
      mensajes OUT t_iax_mensajes,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL
                                    -- FIN BUG 18825 - 19/07/2011 - JMP
   ,
      pcagente IN NUMBER DEFAULT NULL,
      -- Código Mediador -- 4. 0021718 / 0111176 - Inicio
      ptagente IN VARCHAR2 DEFAULT NULL,   -- Nombre Mediador
      pnnumide IN VARCHAR2 DEFAULT NULL,   -- Nif Tomador
      pttomador IN VARCHAR2 DEFAULT NULL,   -- Nombre Tomador
      pnrecibo IN NUMBER DEFAULT NULL   -- Recibo -- 4. 0021718 / 0111176 - Fin
                                     )
      RETURN sys_refcursor IS
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vrefcursor :=
         pac_md_domiciliaciones.f_get_domiciliacion
                                                (psproces, pcempres, pcramo, psproduc,
                                                 pfefecto, psprodom,
                                                 -- BUG 18825 - 19/07/2011 - JMP
                                                 pccobban, pcbanco, pctipcta, pfvtotar,
                                                 pcreferen, pdfefecto,   -- FIN BUG 18825 - 19/07/2011 - JMP
                                                 pcagente, ptagente, pnnumide, pttomador,
                                                 pnrecibo,   -- 4. 0021718 / 0111176
                                                 mensajes);
      RETURN vrefcursor;

      IF vrefcursor%ISOPEN THEN
         CLOSE vrefcursor;
      END IF;
   END f_get_domiciliacion;

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Entrada :
       Pcempres   NUMBER : Identificador empresa
       Psproces   NUMBER : Id. proceso
       Psproduc   NUMBER : Id. producto
       Pseleccio  NUMBER : Valor seleccionado
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc=' || psproduc
            || ' pseleccio=' || pseleccio;
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_SET_PRODDOMIS';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* Deberá realizar una llamada a la función de la capa md pac_md_domiciliaciones.f_set_prodDomis que insertará en la tabla de productos a pasar
       domiciliación tmp_domisaux.
      */
      vnumerr := pac_md_domiciliaciones.f_set_proddomis(pcempres, psproces, psproduc,
                                                        pseleccio, mensajes);

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
   END f_set_proddomis;

/*******************************************************************************
   FUNCION F_GET_PROCESO
   Función que recupera id. proceso que agrupa de los productos a domiciliar
    Parámetros:
     Entrada :
     Salida :
       psproces   NUMBER
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el código de error.
   ********************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_GET_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_common.f_get_procesodom(psproces, mensajes);

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

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación

   /*************************************************************************
    --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

          Funcion en capa MD para obtener los datos de la cabecera de domiciliaciones
          param in pcempres   : Código de empresa
          param in psproces   : Código de proceso (número de remesa)
          param in pccobban   : Código de cobrador bancario
          param in pfinirem   : Fecha inicio remesa
          param in pffinrem   : Fecha fin remesa
          param out mensaje   : Tratamiento del mensaje
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfinirem IN DATE,
      pffinrem IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_GET_DOMICILIACION_CAB';
      vnumerr        NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vrefcursor := pac_md_domiciliaciones.f_get_domiciliacion_cab(pcempres, psproces,
                                                                   pccobban, pfinirem,
                                                                   pffinrem, mensajes);
      RETURN vrefcursor;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vrefcursor;
   END f_get_domiciliacion_cab;

/*************************************************************************
 --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para modificar el cabecera de domiciliaciones
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pccobban   : Código de cobrador bancario
       param in pfefecto   : Fecha de efecto de la remesa
       param in ptfileenv  : Nombre del fichero de envío
       param in ptfiledev  : Nombre del fichero de devolución
       param in pcestdom   : Estado de la remesa
       param in pcremban   : Número de remesa interna de la entidad bancaria
       param in pidioma    : Código de idioma
       param out psquery   : Query
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_set_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfefecto IN DATE,
      ptfileenv IN VARCHAR2,
      ptfiledev IN VARCHAR2,
      pcestdom IN NUMBER,
      pcremban IN VARCHAR2,
      psdevolu IN NUMBER,
      psprocie IN NUMBER,
      -- 9. 0022753: MDP_A001-Cierre de remesa (+)
      pcidioma IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_SET_DOMICILIACION_CAB';
   BEGIN
      vpasexec := 2;
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vpasexec := 3;
      vnumerr :=
         pac_md_domiciliaciones.f_set_domiciliacion_cab
                                        (pcempres, psproces, pccobban, pfefecto, ptfileenv,
                                         ptfiledev, pcestdom, pcremban, psdevolu, psprocie,   -- 9. 0022753: MDP_A001-Cierre de remesa (+)
                                         pcidioma, mensajes);
      vpasexec := 4;
      COMMIT;
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
   END f_set_domiciliacion_cab;

/*************************************************************************
 --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para retroceder una domiciliación
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pfecha     : Fecha de la retrocesión
       param in pidioma    : Código de idioma
       return              : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_retro_domiciliacion(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_DOMICILIACIONES.F_RETRO_DOMICILIACION';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 2;
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vpasexec := 3;
      vnumerr := pac_md_domiciliaciones.f_retro_domiciliacion(pcempres, psproces, pfecha,
                                                              pcidioma, mensajes);
      vpasexec := 4;
      COMMIT;
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
   END f_retro_domiciliacion;
END pac_iax_domiciliaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOMICILIACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOMICILIACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOMICILIACIONES" TO "PROGRAMADORESCSI";
