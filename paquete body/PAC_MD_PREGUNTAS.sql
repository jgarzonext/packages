--------------------------------------------------------
--  DDL for Package Body PAC_MD_PREGUNTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PREGUNTAS" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_PREGUNTAS
      PROPÓSITO:    Funciones para realizar acciones sobre las tablas de PREGUNTAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/07/2013  AMC                1. Creación del package.

   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

    /*************************************************************************
     Función que nos indica si una pregunta es de un plan

       param  in     pcpregun : Id. de pregunta
       param  in     psproduc  : ID del producto
       param  out    pesplan : 0- No pertenece 1 - pertenece
       return        : 0 todo OK
                       <> 0 algo KO

       Bug 27505/148732 - 19/07/2013 - AMC
   *************************************************************************/
   FUNCTION f_es_plan(
      pcpregun IN preguntas.cpregun%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pesplan OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'pcpregun: ' || pcpregun || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_PREGUNTAS.f_es_plan';
      num_err        NUMBER := 0;
   BEGIN
      num_err := pac_preguntas.f_es_plan(pcpregun, psproduc, pesplan);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001);
         RETURN 1;
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
   END f_es_plan;
END pac_md_preguntas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "PROGRAMADORESCSI";
