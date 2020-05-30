--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MAP" AS
   /******************************************************************************
     NOMBRE:       PAC_IAX_MAP
     PROPÓSITO:  Package para gestionar los MAPS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
   ******************************************************************************/

   /*************************************************************************
       FUNCTION f_get_datmap
       Función para devolver los campos descriptivos de un map.
       param in PMAP: Tipo carácter. Id. del map.
       param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
       return             : Retorna un sys_refcursor con los campos descriptivos de un map.
   *************************************************************************/
   FUNCTION f_get_datmap(pmap IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pmap = ' || pmap;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.f_get_datmap';
      vcursor        sys_refcursor;
   BEGIN
      --Comprovem els parametres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_map.f_get_datmap(pmap, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_datmap;

   /*************************************************************************
        FUNCTION f_ejecuta
        Función que generará el fichero correspondiente del map.
        param in PMAP: Tipo carácter. Id. del map.
        param in PPARAM: Tipo carácter. Parámetros del map separados por '|'
        param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
        return             : Retorna una cadena de texto con el nombre y ruta del fichero ó con el código xml generado si todo ha ido bien.
                             Un nulo en caso contrario.

   Bug 14067 - 13/04/2010 - AMC
     *************************************************************************/
   FUNCTION f_ejecuta(
      pmap IN VARCHAR2,
      pparam IN VARCHAR2,
      pejecutarep OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                  := 'parámetros - pmap = ' || pmap || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.f_ejecuta';
      v_fich         VARCHAR2(400);
   BEGIN
      --Comprovem els parametres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_fich := pac_md_map.f_ejecuta(pmap, pparam, pejecutarep, mensajes);
      RETURN v_fich;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_ejecuta;

   /*************************************************************************
       FUNCTION F_get_tipomap
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
       return             : Devolverá una numérico con el tipo de fichero que genera el map.
   *************************************************************************/
   FUNCTION f_get_tipomap(pmap IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pmap = ' || pmap;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.f_get_tipomap';
   BEGIN
      --Comprovem els parametres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      RETURN pac_md_map.f_get_tipomap(pmap, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tipomap;

   /*************************************************************************
        FUNCTION f_ejecuta_multimap
        Función que generará el fichero correspondiente del map.
        param in PMAPS: Tipo carácter. Ids. de los maps. separados por '@'
        param in PPARAM: Tipo carácter. Parámetros del map separados por '|' mas '|' de la cuenta estan permitidos
        param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
        return             : Retorna una cadena de texto con los nombres y rutas de los ficheros generados separados por '@'
     *************************************************************************/
   FUNCTION f_ejecuta_multimap(
      pmaps IN VARCHAR2,
      pparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                := 'parámetros - pmaps = ' || pmaps || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.f_ejecuta_multimap';
      v_ficheros     VARCHAR2(2000);
   BEGIN
      --Comprovem els parametres d'entrada.
      IF pmaps IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_ficheros := pac_md_map.f_ejecuta_multimap(pmaps, pparam, mensajes);
      RETURN v_ficheros;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_ejecuta_multimap;

   FUNCTION f_get_arbol(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_arbol';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_map.f_get_arbol(pcmapead, mensajes);
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
   END f_get_arbol;

   FUNCTION f_get_listadomaps(
      ptiptrat IN VARCHAR2,
      ptipmap IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptiptrat = ' || ptiptrat || ' -ptipmap =' || ptipmap;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_listadomaps';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
   BEGIN
      vpasexec := 2;
      cur := pac_md_map.f_get_listadomaps(ptiptrat, ptipmap, mensajes);
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
   END f_get_listadomaps;

   FUNCTION f_get_cabeceramap(
      pcmapead IN VARCHAR2,
      ptcomentario OUT VARCHAR2,
      ptipotrat OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_cabeceramap';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
   BEGIN
      RETURN pac_md_map.f_get_cabeceramap(pcmapead, ptcomentario, ptipotrat, mensajes);
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
   END f_get_cabeceramap;

   FUNCTION f_get_lsttablahijos(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_lsttablahijos';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
   BEGIN
      IF pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_map.f_get_lsttablahijos(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_lsttablahijos;

   FUNCTION f_get_objeto(
      node_value IN VARCHAR2,
      node_label IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                          := 'node_value = ' || node_value || ' - node_label = ' || node_label;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_objeto';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_objeto(node_value, node_label, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_objeto;

   FUNCTION f_get_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - pnorden = ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapdetalle';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      IF pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_map.f_get_mapdetalle(pcmapead, pnorden, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapdetalle;

   FUNCTION f_get_mapdettratar(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - pnorden = ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_mapdettratar(pcmapead, pnorden, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapdettratar;

/*   FUNCTION f_set_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcampo IN VARCHAR2,
      ptmascara IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      pctipcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - ptcampo = ' || ptcampo;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_set_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      RETURN pac_md_map.f_set_mapdettratar(pcmapead, ptcampo, ptmascara, ptcondicion, pctabla,
                                           pnveces, pctipcampo, mensajes);
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
   END f_set_mapdettratar;*/

   /* FUNCTION f_set_mapdetalle(
         pcmapead IN VARCHAR2,
         pnorden IN NUMBER,
         pnposicion IN NUMBER,
         pnlongitud IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpasexec       NUMBER(8) := 1;
         vparam         VARCHAR2(200)
            := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden || ' - pnposicion ='
               || pnposicion || ' - pnlongitud =' || pnlongitud;
         vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_set_mapdetalle';
         cur            sys_refcursor;
         nivelmin       NUMBER;
         v_inici        NUMBER := 0;
         vtiptrat       VARCHAR2(1);
         pos1           NUMBER;
         pos2           NUMBER;
      BEGIN
         RETURN pac_md_map.f_set_mapdetalle(pcmapead, pnorden, pnposicion, pnlongitud, mensajes);
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
      END f_set_mapdetalle;
   */
   FUNCTION f_get_mapcabecera(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapcabecera';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_mapcabecera(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcabecera;

   FUNCTION f_get_mapcomodin(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapcomodin';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_mapcomodin(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcomodin;

   FUNCTION f_get_mapcabtratar(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapcabtratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_mapcabtratar(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcabtratar;

   FUNCTION f_get_maptabla(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_maptabla';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_maptabla(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_maptabla;

   FUNCTION f_get_mapcondicion(pcmapead IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      cur := pac_md_map.f_get_mapcondicion(pcmapead, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcondicion;

   FUNCTION f_generar_listados(
      pmap IN VARCHAR2,
      pparam IN VARCHAR2,
      pejecutarep OUT NUMBER,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                  := 'parámetros - pmap = ' || pmap || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.f_ejecuta';
      v_fich         VARCHAR2(400);
   BEGIN
      --Comprovem els parametres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_fich := pac_md_map.f_generar_listados(pmap, pparam, pejecutarep, vtimp, mensajes);
      RETURN v_fich;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_generar_listados;

   FUNCTION f_set_mapcabecera(
      pcmapead IN VARCHAR2,
      ptdesmap IN VARCHAR2,
      ptparpath IN VARCHAR2,
      pttipomap IN NUMBER,
      pcseparador IN VARCHAR2,
      pcmapcomodin IN VARCHAR2,
      pttipotrat IN VARCHAR2,
      ptcomentario IN VARCHAR2,
      ptparametros IN VARCHAR2,
      pcmanten IN NUMBER,
      pgenera_report IN NUMBER,
      pcmapead_salida OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmapead =' || pcmapead || ' - pttipomap =' || pttipomap || ' - pcseparador ='
            || pcseparador || ' - pcmapcomodin =' || pcmapcomodin || ' - pttipotrat ='
            || pttipotrat || ' - ptcomentario =' || ptcomentario || ' - ptparametros ='
            || ptparametros || ' - pcmanten =' || pcmanten || ' - ptparametros ='
            || ptparametros || ' - pgenera_report =' || pgenera_report;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_set_mapcabecera';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_map.f_set_mapcabecera(pcmapead, ptdesmap, ptparpath, pttipomap,
                                              pcseparador, pcmapcomodin, pttipotrat,
                                              ptcomentario, ptparametros, pcmanten,
                                              pgenera_report, pcmapead_salida, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapcabecera;

   FUNCTION f_set_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_set_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_set_mapcomodin(pcmapead, pcmapcom, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapcomodin;

   FUNCTION f_del_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_del_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapcomodin(pcmapead, pcmapcom, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapcomodin;

   FUNCTION f_set_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptsenten IN VARCHAR2,
      pcparam IN NUMBER,
      pcpragma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pctabla =' || pctabla || ' - pnveces =' || pnveces
            || ' - ptsenten =' || ptsenten || ' - pcparam =' || pcparam || ' - pcpragma ='
            || pcpragma;
      vobject        VARCHAR2(200) := 'PAC_iax_MAP.F_set_mapcabtratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_set_mapcabtratar(pcmapead, pctabla, pnveces, ptsenten, pcparam,
                                               pcpragma, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapcabtratar;

   FUNCTION f_del_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnveces =' || pnveces || ' - pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_iax_MAP.F_del_mapcabtratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapcabtratar(pcmapead, pctabla, pnveces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapcabtratar;

   FUNCTION f_set_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      pcatributs IN NUMBER,
      pctablafills IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pTPARE =' || ptpare || ' - pNORDFILL ='
            || pnordfill || ' - pTTAG =' || pttag || ' - pCATRIBUTS =' || pcatributs
            || ' - pCTABLAFILLS =' || pctablafills;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_set_mapxml';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_set_mapxml(pcmapead, ptpare, pnordfill, pttag, pcatributs,
                                         pctablafills, pnorden, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapxml;

   FUNCTION f_del_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pTPARE =' || ptpare || ' - pNORDFILL ='
            || pnordfill || 'pTTAG = ' || pttag;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_del_mapxml';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapxml(pcmapead, ptpare, pnordfill, pttag, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapxml;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      pttag IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden || ' - pnposicion ='
            || pnposicion || ' - pnlongitud =' || pnlongitud || ' - pttag =' || pttag;
      vobject        VARCHAR2(200) := 'PAC_iax_MAP.F_set_mapdetalle';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_set_mapdetalle(pcmapead, pnorden, pnposicion, pnlongitud, pttag,
                                             mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapdetalle;

   FUNCTION f_del_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_iax_MAP.F_del_mapdetalle';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapdetalle(pcmapead, pnorden, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapdetalle;

   FUNCTION f_set_maptabla(
      pctabla IN NUMBER,
      ptfrom IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pctabla_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctabla =' || pctabla || ' - ptfrom =' || ptfrom || ' - ptdescrip =' || ptdescrip;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_maptabla';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_map.f_set_maptabla(pctabla, ptfrom, ptdescrip, pctabla_out, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

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
   END f_set_maptabla;

   FUNCTION f_del_maptabla(pctabla IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_maptabla';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pctabla IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_maptabla(pctabla, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_maptabla;

   FUNCTION f_set_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pctipcampo IN VARCHAR2,
      ptmascara IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapdettratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptcondicion IS NULL
         OR pnveces IS NULL
         OR pctabla IS NULL
         OR ptcampo IS NULL
         OR pnorden IS NULL
         OR ptsetwhere IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_set_mapdettratar(pcmapead, ptcondicion, pctabla, pnveces,
                                               ptcampo, pctipcampo, ptmascara, pnorden,
                                               ptsetwhere, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapdettratar;

   FUNCTION f_del_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapdettratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptcondicion IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL
         OR ptcampo IS NULL
         OR pnorden IS NULL
         OR ptsetwhere IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapdettratar(pcmapead, ptcondicion, pctabla, pnveces,
                                               ptcampo, pnorden, ptsetwhere, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapdettratar;

   FUNCTION f_set_mapcondicion(
      pncondicion IN NUMBER,
      ptvalcond IN VARCHAR2,
      pnposcond IN NUMBER,
      pnlongcond IN NUMBER,
      pnordcond IN NUMBER,
      pctabla IN NUMBER,
      pncondicion_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pncondicion =' || pncondicion || ',ptvalcond=' || ptvalcond || ',pnposcond='
            || pnposcond || ',pnlongcond=' || pnlongcond || ',pnordcond=' || pnordcond
            || ',pctabla=' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapcondicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_map.f_set_mapcondicion(pncondicion, ptvalcond, pnposcond, pnlongcond,
                                               pnordcond, pctabla, pncondicion_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_set_mapcondicion;

   FUNCTION f_del_mapcondicion(pncondicion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pncondicion =' || pncondicion;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapcondicion';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pncondicion IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_md_map.f_del_mapcondicion(pncondicion, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_del_mapcondicion;

   FUNCTION f_get_unico_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_iax_MAP.f_get_unico_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      cur := pac_md_map.f_get_unico_mapdettratar(pcmapead, ptcondicion, pctabla, pnveces,
                                                 ptcampo, pnorden, ptsetwhere, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_mapdettratar;

   FUNCTION f_get_unico_mapcondicion(pncondicion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pncondicion =' || pncondicion;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_unico_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      cur := pac_md_map.f_get_unico_mapcondicion(pncondicion, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_mapcondicion;

   FUNCTION f_get_unico_maptabla(pctabla IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_IAX_MAP.F_get_unico_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      cur := pac_md_map.f_get_unico_maptabla(pctabla, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_maptabla;
END pac_iax_map;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MAP" TO "PROGRAMADORESCSI";
