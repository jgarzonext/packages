--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LISTVALORES_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LISTVALORES_COA" AS
/******************************************************************************
 NOMBRE: PAC_IAX_LISTVALORES_REA
 PROPÓSITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripción
 --------- ---------- --------------- ------------------------------------
1.0                                  1. Creacion del Package
2.0       23/05/2012 AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
3.0       18/04/2013 ECP             3 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran. Nota 142806
4.0       20/02/2014 AGG             4. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera la lista desplegable de conceptos de la cuenta técnica del Caoseguro
      param out mensajes : mensajes de error (CMOVIMI de CTACOASEGURO)
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_movcta(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_COA.f_get_tipo_movcta';
   BEGIN
      cur := pac_md_listvalores_coa.f_get_tipo_movcta(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_movcta;

   /*************************************************************************
      Recupera la lista de valores del desplegable Tipo de Coaseguro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   --Ini bug 23183 -- ECP -- 18/04/2013
   FUNCTION f_get_tipcoaseguro(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
      pcatribu IN NUMBER,
      pcvalordep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      --Fin bug 23183 -- ECP -- 18/04/2013
   RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_COA.f_get_tipcoaseguro';
   BEGIN
      cur := pac_md_listvalores_coa.f_get_tipcoaseguro(pcempres, pcvalor, pcatribu,
                                                       pcvalordep, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipcoaseguro;

       /*************************************************************************
      Recupera la lista desplegable de tipos importes de la cuenta técnica del
      Caoseguro
      param out mensajes : mensajes de error (CIMPORT de CTACOASEGURO)
      return             : ref cursor
      Nova funcio: 22076 AVT 02/01/2012
   *************************************************************************/
   FUNCTION f_get_tipo_importe(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_COA.f_get_tipo_importe';
   BEGIN
      --AGG 20/02/2014 se añade el parámetro pcempres
      cur := pac_md_listvalores_coa.f_get_tipo_importe(pcempres, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_importe;
END pac_iax_listvalores_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_COA" TO "PROGRAMADORESCSI";
