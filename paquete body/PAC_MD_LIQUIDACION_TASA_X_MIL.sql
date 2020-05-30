--------------------------------------------------------
--  DDL for Package Body PAC_MD_LIQUIDACION_TASA_X_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" 
AS
/******************************************************************************
    NOMBRE:      PAC_MD_LIQUIDACION_TASA_X_MIL
    PROP¿SITO:   LIQUIDACION DE TASA POR MIL

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        21/12/2016   FFO                1. Creaci¿n del package.*/


     /*************************************************************************

  /*
      pcmodo :=  1 - REAL, 0 PREVIO
  */

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION LIQUIDACION_TASA_X_MIL(
      pcmodo                IN       NUMBER,
      pcempresa             IN       NUMBER,
      pcagente              IN       NUMBER,
      pcsucursal            IN       NUMBER,
      pfdesde               IN       DATE,
      pfhasta               IN       DATE,
      mensajes              OUT   t_iax_mensajes
   ) RETURN NUMBER IS
      vobject   VARCHAR2 (500)
                             := 'PAC_MD_LIQUIDACION_TASA_X_MIL.LIQUIDACION_TASA_X_MIL';
      vparam        VARCHAR2 (4000);
      vpasexec      NUMBER (5)       := 1;
      vnumerr       NUMBER (8)       := 0;
      vquery        VARCHAR2 (2000);
      verror        NUMBER (2);

  BEGIN

      IF pcmodo IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := PAC_LIQUIDACION_TASA_X_MIL.LIQUIDACION_TASA_X_MIL(pcmodo, pcempresa, pcagente, pcsucursal, pfdesde, pfhasta);
      IF verror = 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111107);
        COMMIT;   --BUG 7174 - 17/06/2009 - DCT
        RETURN 0;
      ELSE
        ROLLBACK;
        RAISE e_object_error;
      END IF;
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
   END LIQUIDACION_TASA_X_MIL;

END PAC_MD_LIQUIDACION_TASA_X_MIL;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "PROGRAMADORESCSI";
