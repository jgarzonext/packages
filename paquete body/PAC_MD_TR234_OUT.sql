--------------------------------------------------------
--  DDL for Package Body PAC_MD_TR234_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TR234_OUT" AS
/******************************************************************************
   NOMBRE:       pac_md_TR234_OUT
   PROPÓSITO:    Package para llamadas desde JAVA a funciones del paquete PK_TR234_OUT (envio ficheros norma 234)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/01/2010   JGM                1. Creación del package. Bug 13503
   2.0        01/10/2010   RSC                2. 0016185: Traspasos de salida externos PPA (Añadimos el TRUNC)
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         Función que sirve para generar el fichero MAP de norm 234
           1.    PCINOUT: Tipo numérico. Parámetro de entrada. Nos dice si es traspaso de Entrada (1) o Salida (2)
           2.    PFHASTA: Tipo Fecha. Parámetro de entrada. Hasta que fecha hacemos el fichero de traspasos
           3.    PTNOMFICH: Tipo String. Parámetro de salida. Nombre del fichero resultado
           4.    MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
           5.    PNFICHERO: Tipo NUMBER (opcional) indica que numero de orden de fichero (0-9) queremos generar
   *************************************************************************/
   FUNCTION f_generar_fichero(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      ptnomfich IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnfichero IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pcinout=' || pcinout || ' ptnomfich:' || ptnomfich;
      vobject        VARCHAR2(200) := 'pac_md_TR234_OUT.f_generar_fichero';
      pptnomfich     VARCHAR2(100);
   BEGIN
      IF pcinout IS NULL
         OR NVL(pnfichero, 1) <= 0
         OR NVL(pnfichero, 1) > 9 THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pk_tr234_out.f_generar_fichero(pcinout, pfhasta, pptnomfich, pnfichero);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      ELSE
         ptnomfich := pptnomfich;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_generar_fichero;

   FUNCTION f_buscar_traspasos(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_traspasos IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pcinout=' || pcinout;
      vobject        VARCHAR2(200) := 'pac_iax_TR234_OUT.f_buscar_traspasos';
      v_strfecha     VARCHAR2(200) := '';   -- BUG 17245 - 14/01/2011 - JMP - se amplía a 200
      v_strinout     VARCHAR2(100) := '';
      squery         VARCHAR2(2000);
      traspaso       ob_iax_traspasos := ob_iax_traspasos();
      v_result       t_iax_traspasos := t_iax_traspasos();
      cur            sys_refcursor;
   BEGIN
      IF pcinout IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfhasta IS NOT NULL THEN
         -- Bug 16185 - RSC - 01/10/2010 - CEM - Traspasos de salida externos PPA (Añadimos el TRUNC)
         v_strfecha := '  AND ( TRUNC(traspaso.festado) <= to_date('''
                       || TO_CHAR(pfhasta, 'dd/mm/yyyy')
                       || ''',''DD/MM/YYYY'')  or (traspaso.festado is null) ) ';
      END IF;

      IF pcinout = 1 THEN
         v_strinout := ' traspaso.cinout = 1 AND traspaso.cestado IN(1, 2) ';
      ELSIF pcinout = 2 THEN
         v_strinout := ' traspaso.cinout = 2 AND traspaso.cestado IN(3, 4, 6, 8) ';
      END IF;

      squery :=
         'select traspaso.stras, ' || 's.sseguro, ' || 's.npoliza, s.ncertif,'
         || 'PAC_IAX_LISTVALORES.F_Get_NameTomador(s.sseguro,1),' || 'traspaso.fsolici, '
         || 'traspaso.cinout,FF_DESVALORFIJO(679,f_usu_idioma,traspaso.cinout) ,'
         || 'traspaso.ctiptras, FF_DESVALORFIJO(676,f_usu_idioma,traspaso.ctiptras) ,'
         || 'traspaso.ctiptrassol,FF_DESVALORFIJO(330,f_usu_idioma,traspaso.ctiptrassol),'
         || 'traspaso.cestado, FF_DESVALORFIJO(675,f_usu_idioma,traspaso.cestado)'
         || 'from seguros s, trasplainout traspaso where s.sseguro = traspaso.sseguro '
         || 'AND ' || v_strinout || ' AND traspaso.cexterno = 1 ' || v_strfecha
         || 'AND traspaso.cenvio = 0' || ' UNION ALL ' || 'select traspaso.stras, '
         || 'null sseguro, ' || 'null npoliza, null ncertif,' || 'null,'
         || 'traspaso.fsolici, '
         || 'traspaso.cinout,FF_DESVALORFIJO(679,f_usu_idioma,traspaso.cinout) ,'
         || 'traspaso.ctiptras, FF_DESVALORFIJO(676,f_usu_idioma,traspaso.ctiptras) ,'
         || 'traspaso.ctiptrassol,FF_DESVALORFIJO(330,f_usu_idioma,traspaso.ctiptrassol),'
         || 'traspaso.cestado, FF_DESVALORFIJO(675,f_usu_idioma,traspaso.cestado)'
         || 'from trasplainout traspaso where traspaso.sseguro is null ' || 'AND '
         || v_strinout || ' AND traspaso.cexterno = 1 ' || v_strfecha
         || 'AND traspaso.cenvio = 0';

      OPEN cur FOR squery;

      LOOP
         FETCH cur
          INTO traspaso.stras, traspaso.sseguro, traspaso.npoliza, traspaso.ncertif,
               traspaso.tnomtom, traspaso.fsolici, traspaso.cinout, traspaso.tcinout,
               traspaso.ctiptras, traspaso.tctiptras, traspaso.ctiptrassol,
               traspaso.tctiptrassol, traspaso.cestado, traspaso.tcestado;

         EXIT WHEN cur%NOTFOUND;
         v_result.EXTEND;
         v_result(v_result.LAST) := traspaso;
         traspaso := ob_iax_traspasos();
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_buscar_traspasos;
END pac_md_tr234_out;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "PROGRAMADORESCSI";
