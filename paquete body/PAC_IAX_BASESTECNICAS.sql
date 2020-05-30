--------------------------------------------------------
--  DDL for Package Body PAC_IAX_BASESTECNICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_BASESTECNICAS" AS
/*****************************************************************************
   NAME:       PAC_IAX_BASESTECNICAS
   PURPOSE:    Funciones de obtención de las bases técnicas de una póliza

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/12/2009   APD             1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 14/12/2009
    /*************************************************************************
       Obtiene un objeto del tipo OB_IAX_BASESTECNICAS con las bases técnicas
       param in psseguro  : póliza
       param in pnriesgo  : riesgo (si pnriesgo IS NULL, se mostraron todos)
       param in pnmovimi     : pnmovimi
       param out mensajes : mensajes de error
       return             : El objeto del tipo OB_IAX_BASESTECNICAS con los valores de esos importes
    *************************************************************************/
   FUNCTION f_obtbasestecnicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ptabla IN VARCHAR2 DEFAULT 'SEG')
      RETURN ob_iax_basestecnicas IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pnmovimi= ' || pnmovimi
            || 'ptabla= ' || ptabla;
      vobject        VARCHAR2(200) := 'PAC_IAX_BASESTECNICAS.f_ObtBasesTecnicas';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      vbastec        ob_iax_basestecnicas;
   BEGIN
      IF psseguro IS NULL
         --OR pnriesgo IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_basestecnicas.f_obtbasestecnicas(psseguro, pnriesgo, pnmovimi, vbastec,
                                                         mensajes, ptabla);

      IF vnumerr <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN vbastec;
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
   END f_obtbasestecnicas;
--JRH 14/12/2009
END pac_iax_basestecnicas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "PROGRAMADORESCSI";
