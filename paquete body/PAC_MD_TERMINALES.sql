--------------------------------------------------------
--  DDL for Package Body PAC_MD_TERMINALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TERMINALES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_TERMINALES
   PROPÓSITO:   Funciones para la gestión de los terminales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/11/2008   AMC                1. Creación del package.
******************************************************************************/

    e_object_error  exception;
    e_param_error   exception;

   /*************************************************************************
       Inserta o Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_SET_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES ) return number is

        vobject         VARCHAR2(500)  := 'PAC_MD_TERMINALES.F_SET_TERMINAL';
        vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
        vpasexec        NUMBER (5)              := 1;
        vnumerr         NUMBER (8)              := 0;

    BEGIN

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        vnumerr := pac_terminales.F_SET_TERMINAL(pcempres,pcmaqfisi,pcterminal);

        IF vnumerr <> 0 THEN
            PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
        END IF;

        return 0;

    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END F_SET_TERMINAL;


     /*************************************************************************
       Borra un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_DEL_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES ) return number is

        vobject         VARCHAR2(500)  := 'PAC_MD_TERMINALES.F_DEL_TERMINAL';
        vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
        vpasexec        NUMBER (5)              := 1;
        vnumerr         NUMBER (8)              := 0;

    BEGIN

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        vnumerr := pac_terminales.F_DEL_TERMINAL(pcempres,pcmaqfisi,pcterminal);

        IF vnumerr <> 0 THEN
            PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
        END IF;

        return 0;

    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END F_DEL_TERMINAL;


    /*************************************************************************
       Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param in pnewcmaqfisi  : Nueva Máquina física
       param in pnewcterminal : Nuevo Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_UPDATE_TERMINAL ( pcempres	    NUMBER,
                                 pcmaqfisi	    VARCHAR2,
                                 pcterminal     VARCHAR2,
                                 pnewcmaqfisi   VARCHAR2,
                                 pnewcterminal  VARCHAR2,
                                 mensajes IN OUT T_IAX_MENSAJES ) return number is

        vobject         VARCHAR2(500)  := 'PAC_MD_TERMINALES.F_UPDATE_TERMINAL';
        vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal||' pnewcmaqfisi:'||pnewcmaqfisi
                                           ||' pnewcterminal:'||pnewcterminal;
        vpasexec        NUMBER (5)              := 1;
        vnumerr         NUMBER (8)              := 0;

    BEGIN

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        vnumerr := pac_terminales.F_UPDATE_TERMINAL(pcempres,pcmaqfisi,pcterminal,pnewcmaqfisi,pnewcterminal);

        IF vnumerr <> 0 THEN
            PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
        END IF;

        return 0;

    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END F_UPDATE_TERMINAL;

    /*************************************************************************
       Devuelve los terminales que cumplan con el criterio de selección
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes    : mensajes de error
       return                : ref cursor
    *************************************************************************/
    FUNCTION F_CONSULTA_TERMINALES(pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES) RETURN SYS_REFCURSOR IS

        cur SYS_REFCURSOR;
        squery VARCHAR2(2500);
        buscar VARCHAR2(1000) :=' and rownum<=101 ';
        subus VARCHAR2(500);
        tabTp VARCHAR2(10);
        auxnom VARCHAR2(200);
        nerr NUMBER;

        vobject         VARCHAR2(500)  := 'PAC_MD_TERMINALES.F_ConsultaTerminal';
        vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
        vpasexec        NUMBER (5)              := 1;
    BEGIN

        squery:= pac_terminales.ff_consulta_terminales(pcempres, pcmaqfisi, pcterminal);

        cur := PAC_IAX_LISTVALORES.F_Opencursor(squery,mensajes);

        IF PAC_MD_LOG.F_LOG_CONSULTAS(squery,vobject, 1, 2, mensajes) <> 0
        THEN
            IF cur%isopen THEN close cur; END IF;
            RETURN cur;
        END IF;

        RETURN cur;

    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN close cur; END IF;
        RETURN cur;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN close cur; END IF;
        RETURN cur;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN close cur; END IF;
        RETURN cur;
    END F_CONSULTA_TERMINALES;


END PAC_MD_TERMINALES;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "PROGRAMADORESCSI";
