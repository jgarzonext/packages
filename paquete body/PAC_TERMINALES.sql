--------------------------------------------------------
--  DDL for Package Body PAC_TERMINALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TERMINALES" AS
/******************************************************************************
   NOMBRE:      PAC_TERMINALES
   PROPÓSITO:   Funciones para la gestión de los terminales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/11/2008   AMC                1. Creación del package.
******************************************************************************/

    e_object_error  exception;
    e_param_error   exception;

   /*************************************************************************
       Inserta o Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_SET_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return number is

          vobjectname     VARCHAR2(500)  := 'PAC_TERMINALES.F_SET_TERMINAL';
          vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
          vpasexec        NUMBER (5)              := 1;


    begin

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        insert into terminales(cempres,cmaqfisi,cterminal,cusualt,falta)
        values(pcempres,pcmaqfisi,pcterminal,f_user,f_sysdate);

        return 0;

    EXCEPTION
        WHEN e_param_error THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');
            RETURN 9000505;  --Error falten parametres
        WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '||SQLCODE||' - '||SQLERRM);
            RETURN 9000579;  --Error al insertar en la tabla terminales.
    END F_SET_TERMINAL;


    /*************************************************************************
       Borra un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_DEL_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return number is

          vobjectname     VARCHAR2(500)  := 'PAC_TERMINALES.F_DEL_TERMINAL';
          vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
          vpasexec        NUMBER (5)              := 1;


    begin

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        delete terminales
        where cempres = pcempres
        and cmaqfisi = pcmaqfisi
        and cterminal = pcterminal;

        return 0;

    EXCEPTION
        WHEN e_param_error THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');
            RETURN 9000505;  --Error falten parametres
        WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '||SQLCODE||' - '||SQLERRM);
            RETURN 9000581;  --Error al borrar en la tabla terminales.
    END F_DEL_TERMINAL;


       /*************************************************************************
       Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param in pnewcmaqfisi  : Nueva Máquina física
       param in pnewcterminal : Nuevo Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_UPDATE_TERMINAL ( pcempres	    NUMBER,
                                 pcmaqfisi	    VARCHAR2,
                                 pcterminal     VARCHAR2,
                                 pnewcmaqfisi   VARCHAR2,
                                 pnewcterminal  VARCHAR2 ) return number is

          vobjectname     VARCHAR2(500)  := 'PAC_TERMINALES.F_DEL_TERMINAL';
          vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal||' pnewcmaqfisi:'||pnewcmaqfisi
                                           ||' pnewcterminal:'||pnewcterminal;
          vpasexec        NUMBER (5)              := 1;


    begin

        --Comprovació dels parámetres d'entrada
        IF pcempres IS NULL OR pcmaqfisi IS NULL OR pcterminal IS NULL THEN
            RAISE e_param_error;
        END IF;

        if pnewcmaqfisi is not null then

            update terminales
            set cmaqfisi = pnewcmaqfisi,
                fmodif = f_sysdate,
                cusumod = f_user
            where cempres = pcempres
            and cmaqfisi = pcmaqfisi
            and cterminal = pcterminal;

        end if;

        if pnewcterminal is not null then

            update terminales
            set cterminal = pnewcterminal,
                fmodif = f_sysdate,
                cusumod = f_user
            where cempres = pcempres
            and cmaqfisi = pcmaqfisi
            and cterminal = pcterminal;

        end if;

        return 0;

    EXCEPTION
        WHEN e_param_error THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');
            RETURN 9000505;  --Error falten parametres
        WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '||SQLCODE||' - '||SQLERRM);
            RETURN 9000579;  --Error al insertar en la tabla terminales.
    END F_UPDATE_TERMINAL;


   /*************************************************************************
       Consulta terminales.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : retorna la cadena con la búsqueda
    *************************************************************************/
    FUNCTION FF_CONSULTA_TERMINALES ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return VARCHAR2 is

          vobjectname     VARCHAR2(500)  := 'PAC_TERMINALES.FF_CONSULTA_TERMINAL';
          vparam          VARCHAR2(500) := 'parámetros - pcempres:'||pcempres||' pcmaqfisi:'||pcmaqfisi
                                           ||' pcterminal:'||pcterminal;
          vpasexec        NUMBER (5)              := 1;
          vselec          VARCHAR2(500);


    begin

        vselec := 'SELECT cmaqfisi, cterminal FROM TERMINALES WHERE cempres = '||pcempres;

        IF pcmaqfisi IS NOT NULL THEN
            vselec := vselec||' AND UPPER (cmaqfisi) like ''%' || UPPER (pcmaqfisi) || '%''';
        END IF;

        IF pcterminal IS NOT NULL THEN
            vselec := vselec||' AND UPPER (cterminal) like ''%' || UPPER (pcterminal) || '%''';
        END IF;

        return vselec;

    EXCEPTION
        WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '||SQLCODE||' - '||SQLERRM);
            RETURN 111715;  --Error a la definició de la consulta.
    END FF_CONSULTA_TERMINALES;

end PAC_TERMINALES;

/

  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "PROGRAMADORESCSI";
