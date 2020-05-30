--------------------------------------------------------
--  DDL for Package Body PAC_MD_FE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FE_VIDA" AS
/******************************************************************************
   NOMBRE:       PAC_MD_FE_VIDA
   PROPÓSITO:  Funciones necesarias para la generacion de las Cartas de Fe de Vida

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0        07/09/2010   ETM              1. Creación del package.--0015884: CEM - Fe de Vida. Nuevos paquetes PLSQL
    2.0        19/01/2011   APD              2. Bug 15289 : Cartas Fe de Vida
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;

-- Bug 15289 - APD - 21/01/2011 - se crea la funcion
   /*************************************************************************
   Función  F_PERCEPTORES_RENTA
   Devuelve las personas que reciben la renta.
   Solo se mostraran aquellas personas a las cuales se les ha enviado la carta de
   fe de vida previamente y que aun no han confirmado su fe de vida
      param in psseguro: identificador del seguro
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_perceptores_renta(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_FE_VIDA.f_perceptores_renta';
      cur            sys_refcursor;
      squery         VARCHAR2(4000);
      vsseguro       seguros.sseguro%TYPE;
      v_numerr       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery := pac_fe_vida.f_perceptores_renta(psseguro);
      vpasexec := 3;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_perceptores_renta;

/*******************************************************************************
   FUNCION  F_GET_DATOS_FE_VIDA
   -función qdevolverá un REF CURSOR con las pólizas que deben enviar la carta de fe de vida.
   Parámetros:
    Entrada :
    1.    psproces. Identificador del proceso.
    2.    pcempres. Identificador de la empresa. Obligatorio.
    3.    pcramo. Identificador del ramo.
    4.    psproduc. Identificador del producto.
    5.    pcagente. Identificador del agente.
    6.    pnpoliza. Número de póliza.
    7.    pncertif. Número de certificado.
    8.    pfhasta. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
    9.   pngenerar. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
    10.  pnpantalla. Identificador de visualización o no del resultado de la select por pantalla. 0.-No se visualiza el resultado de la select por pantalla (el resultado de la select se utiliza en el map);1.-Sí se visualiza el resultado de la select por pantalla. Obligatorio (valor por defecto 0)

 Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_datos_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      pnpantalla IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo=' || pcramo
            || ' psproduc=' || psproduc || ' pcagente=' || pcagente || ' pnpoliza='
            || pnpoliza || ' pncertif=' || pncertif || ' pfhasta=' || pfhasta || ' pngenerar='
            || pngenerar || ' pnpantalla= ' || pnpantalla;
      vobject        VARCHAR2(200) := 'PAC_MD_FE_VIDA.f_get_datos_fe_vida';
   BEGIN
      -- comprobar campos obligatorios
      IF pngenerar = 0 THEN
         IF pcempres IS NULL
            OR pfhasta IS NULL THEN
            RAISE e_param_error;
         END IF;
      ELSIF pngenerar = 1 THEN
         IF psproces IS NULL
            OR pcempres IS NULL THEN   -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 2;
      -- BUG 21546_108727- 01/03/2012 - JLTS - Se elimina la utilización de mensajes en pac_propio.f_get_datos_fe_vida
      v_cursor := pac_propio.f_get_datos_fe_vida(psproces, pcempres, pcramo, psproduc,
                                                 pcagente, pnpoliza, pncertif, pfhasta,
                                                 pngenerar, pnpantalla);
      vpasexec := 3;
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_datos_fe_vida;

   /*******************************************************************************
    FUNCION   F_GENERAR_FE_VIDA
    -función que genera el fichero con las pólizas a las cuales se les debe enviar la carta de fe de vida
        y crea un apunte en la Agenda de dichas pólizas indicando que se ha enviado la carta.
    -Llamará a la función PAC_MD_MAP.F_EJECUTA
    Parámetros:
     Entrada :
     1.    psproces IN. Identificador del proceso. Obligatorio si pngenerar = 1.
     2.    pcempres IN. Identificador de la empresa. Obligatorio.
     3.   pcramo IN. Identificador del ramo.
     4.   psproduc IN. Identificador del producto.
     5.   pcagente IN. Identificador del agente.
     6.   pnpoliza IN. Número de póliza.
     7.   pncertif IN. Número de certificado.
     8.   pfhasta. IN Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
     9.   pngenerar IN. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)


     Salida :
      10. sproces OUT. Identificador del proceso
       Mensajes T_IAX_MENSAJES

    Retorna : number 0 ok, 1 error
    ********************************************************************************/
   FUNCTION f_generar_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      sproces OUT NUMBER,
      pnomfich OUT VARCHAR2,
      vtimp OUT t_iax_impresion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_map_propio   VARCHAR2(100);
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo=' || pcramo
            || ' psproduc=' || psproduc || ' pcagente=' || pcagente || ' pnpoliza='
            || pnpoliza || ' pncertif=' || pncertif || ' pfhasta=' || pfhasta || ' pngenerar='
            || pngenerar || ' sproces=' || sproces;
      vobject        VARCHAR2(200) := 'PAC_MD_FE_DE_VIDA.F_GENERAR_FE_VIDA';
      v_nomfich      VARCHAR2(500);
      vpar           VARCHAR2(4000);
      vejecutarep    NUMBER;
      vterror        VARCHAR2(200);
      vreport        VARCHAR2(200);
      vobimp         ob_iax_impresion := ob_iax_impresion();
      v_existe_report NUMBER;
   BEGIN
      -- Se inicializa el objeto con el nombre del MAP y JASPER que se debe lanzar
      vtimp := t_iax_impresion();

      -- comprobar campos obligatorios
      IF pngenerar = 0 THEN
         IF pcempres IS NULL
            OR pfhasta IS NULL THEN
            RAISE e_param_error;
         END IF;
      ELSIF pngenerar = 1 THEN
         IF psproces IS NULL
            OR pcempres IS NULL THEN   -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
            RAISE e_param_error;
         END IF;
      END IF;

      vpar := TO_CHAR(psproces) || '|' || TO_CHAR(pcempres) || '|' || TO_CHAR(pcramo) || '|'
              || TO_CHAR(psproduc) || '|' || TO_CHAR(pcagente) || '|' || TO_CHAR(pnpoliza)
              || '|' || TO_CHAR(pncertif) || '|' || TO_CHAR(pfhasta, 'ddmmyyyy') || '|'
              || TO_CHAR(pngenerar) || '|' || 0;

      /*
      Llamar a la función PAC_MD_MAP.F_EJECUTA pasándole como parámetro el código del map dinámico de ---???
      PAREMPRESA = 'MAP_FE_DE_VIDA' para generar el fichero de cartas de fe de vida.
      productos de fe de vida???

      */
      SELECT pac_parametros.f_parempresa_t(pcempres, 'MAP_FE_VIDA')
        INTO v_map_propio
        FROM DUAL;

      v_nomfich := pac_md_map.f_ejecuta(v_map_propio, vpar, vejecutarep, mensajes);
      pnomfich := v_nomfich;

      IF v_nomfich IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      IF pngenerar = 0 THEN
         vpasexec := 3;
         vnumerr := pac_fe_vida.f_apunte_agenda(psproces, pcempres, pcramo, psproduc,
                                                pcagente, pnpoliza, pncertif, pfhasta,
                                                pngenerar, sproces);
         vpasexec := 4;

         IF vnumerr <> 0 THEN
            vpasexec := 5;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;
      -- Si todo ha ido bien, se informa el objeto vtimp con el nombre del MAP y JASPER que se debe lanzar
      vtimp.EXTEND;
      vobimp.fichero := v_nomfich;
      vobimp.descripcion := f_axis_literales(9901814);
      vtimp(vtimp.LAST) := vobimp;
      vpasexec := 7;

      -- Si el map tiene un report associado lo ejecutamos
      SELECT COUNT(1)
        INTO v_existe_report
        FROM detplantillas
       WHERE cmapead = v_map_propio;

      IF v_existe_report <> 0 THEN
         vpasexec := 8;
         vnumerr := pac_md_listado.f_genera_report(NULL, pcempres, v_nomfich,
                                                   pac_md_common.f_get_cxtidioma,
                                                   v_map_propio, vterror, vreport, mensajes);
         vtimp.EXTEND;
         vobimp.fichero := vreport;
         vtimp(vtimp.LAST) := vobimp;
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
   END f_generar_fe_vida;

/*******************************************************************************
   FUNCION  F_GET_CONSULTA_FE_VIDA
   -función que devuelve las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de vida que cumplan con los filtros seleccionados

   Parámetros:
    Entrada :
    1.   pcidioma. Identificador del idioma.
    2.   pcempres. Identificador de la empresa. Obligatorio.
    3.   psproduc. Identificador del producto.
    4.   pfinicial. Fecha inicio.
    5.   pffinal. Fecha final
    6.   pcramo. Identificador del ramo.
    7.   pcagente. Identificador del agente.
    8.   pcagrpro. Identificador de la agrupación de la póliza.

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_consulta_fe_vida(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_FE_DE_VIDA.F_GET_CONSULTA_FE_VIDA';
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
      v_cursor       sys_refcursor;
   BEGIN
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery := pac_fe_vida.f_get_consulta_fe_vida(pcidioma, pcempres, psproduc, pfinicial,
                                                    pffinal, pcramo, pcagente, pcagrpro);
      vpasexec := 4;

      IF vsquery IS NULL THEN
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      v_cursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 6;
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_consulta_fe_vida;

/*******************************************************************************
   FUNCION  F_GET_RENTAS_BLOQUEADAS
   -función que devuelve que devuelve las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
   Parámetros:
    Entrada :
       1.   pcidioma. Identificador del idioma.
        2.  pcempres. Identificador de la empresa. Obligatorio.
        3.  psproduc. Identificador del producto.
        4.  pfinicial. Fecha inicio.
        5.  pffinal. Fecha final
        6.  pcramo. Identificador del ramo.
        7.  pcagente. Identificador del agente.
        8.  pcagrpro. Identificador de la agrupación de la póliza.

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_rentas_bloqueadas(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_FE_VIDA.F_GET_RENTAS_BLOQUEADAS ';
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
      v_cursor       sys_refcursor;
   BEGIN
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery := pac_fe_vida.f_get_rentas_bloqueadas(pcidioma, pcempres, psproduc, pfinicial,
                                                     pffinal, pcramo, pcagente, pcagrpro);

      IF vsquery IS NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      v_cursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_rentas_bloqueadas;

   /*******************************************************************************
    FUNCION   F_CONFIRMAR_FE_VIDA
    -función que se encargará de validar y confirmar la certificación de fe de vida de los titulares de una póliza.
    -Llamará a la función función PAC_FE_DE_VIDA.F_CONFIRMAR_FE_VIDA
    Parámetros:
     Entrada :

         1.  pnpoliza. number Número de póliza.
         2.  pncertif. number Número de certificado.
         3.  ptlista : sperson de los perceptores que han presentado su fe de vida
     Salida :
       Mensajes T_IAX_MENSAJES

    Retorna : number 0 ok, 1 error
    ********************************************************************************/
   FUNCTION f_confirmar_fe_vida(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptlista IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_numerr       NUMBER := 0;
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
             := ' pnpoliza=' || pnpoliza || ';pncertif=' || pncertif || ';ptlista=' || ptlista;
      vobject        VARCHAR2(200) := 'PAC_MD_FE_DE_VIDA.F_CONFIRMAR_FE_VIDA';
      psseguro       seguros.sseguro%TYPE;
   BEGIN
      v_numerr := pac_seguros.f_get_sseguro(pnpoliza, pncertif, NULL, psseguro);

      IF v_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      numerr := pac_fe_vida.f_confirmar_fe_vida(psseguro, ptlista);
      vpasexec := 3;

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
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
   END f_confirmar_fe_vida;
END pac_md_fe_vida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FE_VIDA" TO "PROGRAMADORESCSI";
