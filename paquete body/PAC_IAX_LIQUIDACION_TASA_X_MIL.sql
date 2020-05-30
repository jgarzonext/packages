--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LIQUIDACION_TASA_X_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LIQUIDACION_TASA_X_MIL" 
AS
   /******************************************************************************
    NOMBRE:      PAC_IAX_LIQUIDACION_TASA_X_MIL
    PROP¿SITO:   LIQUIDACION DE TASA POR MIL

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        21/12/2016   FFO                1. Creaci¿n del package.*/


     /*************************************************************************/

   FUNCTION LIQUIDACION_TASA_X_MIL(
      pcmodo                IN       NUMBER,
      pcempresa             IN       NUMBER,
      pcagente              IN       NUMBER,
      pcsucursal            IN       NUMBER,
      pfdesde               IN       DATE,
      pfhasta               IN       DATE,
      mensajes              OUT   t_iax_mensajes
   ) RETURN NUMBER IS
      vobjectname   VARCHAR2 (500)
                             := 'PAC_MD_LIQUIDACION_TASA_X_MIL.LIQUIDACION_TASA_X_MIL';
      vparam        VARCHAR2 (4000);
      vpasexec      NUMBER (5)       := 1;
      vnumerr       NUMBER (8)       := 0;
      vquery        VARCHAR2 (2000);
      verror        NUMBER (2);

  BEGIN

    verror := PAC_MD_LIQUIDACION_TASA_X_MIL.LIQUIDACION_TASA_X_MIL(pcmodo, pcempresa, pcagente, pcsucursal, pfdesde, pfhasta, mensajes);
      RETURN verror;
  EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END LIQUIDACION_TASA_X_MIL;

END PAC_IAX_LIQUIDACION_TASA_X_MIL;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACION_TASA_X_MIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACION_TASA_X_MIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDACION_TASA_X_MIL" TO "PROGRAMADORESCSI";
